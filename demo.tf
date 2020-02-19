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
# We recommend including at least the polict to change password.
# You will likely want to customize this for your purposes.
resource "aws_iam_group_policy_attachment" "nonprofitnetworks_default_group_policy_attachment" {
  group = aws_iam_group.nonprofitnetworks_default_group.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

# Use an existing key pair that we created via the the AWS console.
# We named the key pair `administrator`, and we import it like this:
#
#     terraform import aws_key_pair.administrator administrator
#
# We use this key pair for our default needs, such as SSH to an instance.
# Our public key below won't work for you, so you'll want to change it.
resource "aws_key_pair" "administrator" {
  key_name   = "administrator"
  public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmXB4ltuJqH7xOUYOwkY9O4H4Wkd5+fDzhWbCeD3vnIYJB7j+V0M9/4b1wLXOZyZkyxvYkaxKdRy0Q41esWp7KaOHgmAHeIXZyXyXdKoofylDilxG1wRx0/b03scdnO5jNIof+Otp/8z57Y2xzr+pqbWGal6D/8VGLyykOKrGFGNft+2mOsAquOnKoZ1siIK44tkPt7D2LfQp+PrckKEQ5TSAvXTisRbQxF3VRJePf6cCADLYwShza8GKJrK+vUVo2GNJ9Pn4yvT9L2zUa0eYflHeq4799045meqY+Jn/Y+IOYN0dEDsWEv7sqMgjzmC1fm/Pp/hWjUDXXo++r0ir9wIDAQAB"
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
# AMIs
#
##

# Define local variables, such as for Canonical, the maker of Ubuntu.
# This variable enables us to search AMIs for ones made by Canonical.
# We use our preferred naming convention of a single-underscore to 
# separate words, and a double-underscore to separate concepts.
# You can use any variable you want, and any naming convention.
locals {
  aws_ami__owner__canonical = "099720109477"
}

# Look up the Amazon Machine Image (AMI) number of a recent Ubuntu OS.
# For our teaching purposes, we favor Ubuntu over alternatives such as
# Apine because many of our developers already use Ubuntu locally, and
# we favor the most-recent version over long term support (LTS) because
# many of our developers already use the most-recent version locally.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-eoan-19.10-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [local.aws_ami__owner__canonical]
}

##
#
# Instances
#
##

# Define local varibles that notate what the AWS free tier can do.
locals {
  free__aws_instance__instance_type = "t2.micro"
  free__aws_instance__root_block_device__volume_size = "30"
}

# Create an EC2 instance, using our existing key pair from above.
resource "aws_instance" "demo" {
  ami = data.aws_ami.ubuntu.id
  instance_type = local.free__aws_instance__instance_type
  associate_public_ip_address = true
  key_name = "administrator"
  vpc_security_group_ids = [aws_security_group.demo_security_group.id]

  tags = {
    Name = "demo"
  }

  root_block_device {
    volume_size           = local.free__aws_instance__root_block_device__volume_size
  }

  # Install some typical software, by using the typical package manager.
  # You will likely want to customize this section for your own purposes.
  user_data = <<EOF
		#!/bin/sh
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install -y build-essential
    sudo apt-get install -y curl
    sudo apt-get install -y default-jdk
    sudo apt-get install -y emacs
    sudo apt-get install -y fd-find
		sudo apt-get install -y git
    sudo apt-get install -y git-core 
		sudo apt-get install -y htop
		sudo apt-get install -y jq
    sudo apt-get install -y libssl-dev
    sudo apt-get install -y libv8-dev
		sudo apt-get install -y nginx
    sudo apt-get install -y openssl
    sudo apt-get install -y ripgrep
 		sudo apt-get install -y ruby
    sudo apt-get install -y software-properties-common
 		sudo apt-get install -y tmux
 		sudo apt-get install -y vim
    sudo apt-get install -y wget
	EOF

}
