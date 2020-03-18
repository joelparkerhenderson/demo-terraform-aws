##
#
# Terraform file with helpful annotations.
#
# This file has many annotations to explain how to use it.
# When you're creating you own systems, then you customize
# this file for your own purposes, with your own settings.
#
# We welcome questions and constructive feedback.
#
##

# The file starts with the `terraform` block configuration.
terraform {
  required_version = ">= 0.12.18"
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  version = "~> 2.43.0"
  # Terraform needs to know the AWS credentials:
  #
  #   * access_key
  #   * secret_key
  #
  # If you omit AWS credentials, then Terraform will automatically 
  # search for saved API credentials (for example, in ~/.aws/credentials
  # or IAM instance profile credentials. This option is much cleaner for 
  # situations where tf files are checked into source control or where 
  # there is more than one admin user. See details here. 
  #
  # Omiting IAM credentials in Terraform config files enables you to 
  # leave those credentials out of source control, and also use different 
  # IAM credentials for each user without modifying the configuration files.
  #
  # If you prefer to put credentials in this config file,
  # then uncomment the lines below, and fill in your credentials.
  #
  #access_key = "6IAIN7RHCYWDYJAHV8LS"
  #secret_key = "OJif8/L9UgHqfJzkO3RDqEcypvWkilfkfe8N5YOO"
  #region = "us-east-1"
}

##
#
# IAM users
#
##

# Create our primary user, which we call "Commanding Officer".
# For your setup, customize this for your own primary user,
# such as a person in your organization who heads your team.
resource "aws_iam_user" "co" {
  name = "co"
  tags = {
    name = "Commanding Officer"
    email = "co@nonprofitnetworks.org"
  }
}

# Create our secondary user, which we call "Executive Officer".
# For your setup, customize this for your own secondary user.
# such as a person in your organization who helps your team.
resource "aws_iam_user" "xo" {
  name = "xo"
  tags = {
    name = "Executive Officer"
    email = "xo@nonprofitnetworks.org"
  }
}

##
#
# Identity etc.
#
##

# Create a default group for our organization.
# This is helpful because our AWS account also has
# default groups for many of our partner organizations.
resource "aws_iam_group" "nonprofitnetworks_default_group" {
  name = "nonprofitnetworks_default_group"
}

# Create a default group policy for our organization.
# We recommend including at least the policy to change password.
# You will likely want to customize this for your purposes.
resource "aws_iam_group_policy_attachment" "nonprofitnetworks_default_group_policy_attachment" {
  group = aws_iam_group.nonprofitnetworks_default_group.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

##
#
# Mail
#
##

resource "aws_ses_domain_identity" "nonprofitnetworks_org" {
  domain = "nonprofitnetworks.org"
}

data "aws_iam_policy_document" "nonprofitnetworks_org" {
  statement {
    actions   = ["SES:SendEmail", "SES:SendRawEmail"]
    resources = [aws_ses_domain_identity.nonprofitnetworks_org.arn]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

##
#
# Network etc.
#
##

# Connect to our existing AWS default virtual public cloud (VPC).
# If your AWS doesn't have a default VPC, then you can either omit
# this block, or use the AWS console (or API) to create a default VPC.
resource "aws_default_vpc" "default" {
  tags = {
    Name = "default"
  }
}

# Create a VPC named "main" that we use for general needs.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

# Create a subnet named "main_public" that we use for extranet needs,
# where we want public access, such as a public-facing webserver.
resource "aws_subnet" "main_public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "main_public"
  }
}

# Create a subnet named "main_private" that we use for intranet needs,
# where we want internal access, such as an inside-facing webserver.
resource "aws_subnet" "main_private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "main_private"
  }
}

##
#
# Security etc.
#
##

# Create a demo security group, suitable for typical demo traffic,
# such as SSH for connecting to an EC2 instance, and web traffic.
# You will probably want to customize this for your own needs.
resource "aws_security_group" "demo_security_group" {
  name        = "demo_security_group"
  description = "Demo traffic such as SSH, HTTP, HTTPS"
  vpc_id      = aws_default_vpc.default.id

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

##
#
# AMI: Amazon Machine Image
#
# For our teaching purposes, we favor Ubuntu over alternatives such
# as Alpine because many of our developers already use Ubuntu locally.
#
# We favor the current version and the long term support (LTS) version,
# depending on whether the goal is freshest OS or production OS.
##

# Define local variables, such as for Canonical, the maker of Ubuntu.
# This variable enables us to search AMIs for ones made by Canonical.
# We use our preferred naming convention of a single-underscore to 
# separate words, and a double-underscore to separate concepts.
# You can use any variable you want, and any naming convention.
locals {
  aws_ami__owner__canonical = "099720109477"
}

# Look up the AMI id of the current Ubuntu OS.
data "aws_ami" "ubuntu_with_current_version" {
  most_recent = true
  owners = [local.aws_ami__owner__canonical]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-eoan-19.10-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Look up the AMI id of the current Ubuntu Long Term Support (LTS) OS.
data "aws_ami" "ubuntu_with_long_term_support_version" {
  most_recent = true
  owners = [local.aws_ami__owner__canonical]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

