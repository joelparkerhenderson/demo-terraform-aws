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
# Password policy
#
##

# We currently set this via the console.
# We want to find out how to set this via Terraform.
#
#   * Minimum password length is 12 characters
#   * Require at least one uppercase letter from Latin alphabet (A-Z)
#   * Require at least one lowercase letter from Latin alphabet (a-Z)
#   * Require at least one number
#   * Require at least one non-alphanumeric character (!@#$%^&*()_+-=[]{}|')
#   * Allow users to change their own password
#   * Remember last 5 password(s) and prevent reuse 
#   * Do not expire passwords

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
  ami = data.aws_ami.ubuntu_with_current_version.id
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
  # Install some typical software, by using the typical package manager.
  # You will likely want to customize this section for your own purposes.
  user_data = <<EOF
    #!/bin/sh

    # Update
    sudo apt-get -q -y update
    sudo apt-get -q -y upgrade

    # Infrastructure
    sudo apt-get install -q -y apt-transport-https
    sudo apt-get install -q -y build-essential
    sudo apt-get install -q -y ca-certificates
    sudo apt-get install -q -y curl
    sudo apt-get install -q -y gnupg-agent
    sudo apt-get install -q -y software-properties-common

    # Libraries
    sudo apt-get install -q -y libssl-dev
    sudo apt-get install -q -y libv8-dev

    # Typicals
    sudo apt-get install -q -y default-jdk
    sudo apt-get install -q -y emacs
    sudo apt-get install -q -y fd-find
    sudo apt-get install -q -y git
    sudo apt-get install -q -y git-core 
    sudo apt-get install -q -y htop
    sudo apt-get install -q -y jq
    sudo apt-get install -q -y nginx
    sudo apt-get install -q -y openssl
    sudo apt-get install -q -y python3.6
    sudo apt-get install -q -y ripgrep
    sudo apt-get install -q -y ruby
    sudo apt-get install -q -y tmux
    sudo apt-get install -q -y vim
    sudo apt-get install -q -y wget

    # Node-related
    sudo apt-get install -q -y nodejs
    sudo apt-get install -q -y npm
    sudo npm install -g express

    # Docker-related
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get -q -y update
    sudo apt-get install -q -y docker-ce 
    sudo apt-get install -q -y docker-ce-cli
    sudo apt-get install -q -y containerd.io

    # Finish
    sudo apt-get -q -y autoclean
    sudo apt-get -q -y --purge autoremove
    
  EOF

}

##
#
# Database
#
##

resource "aws_db_instance" "demo" {

  # The name of the RDS instance.
  # Letters and hyphens are allowed; underscores are not.
  # Terraform default is  a random, unique identifier. 
  identifier = "demo-rds"

  # The name of the database to create when the DB instance is created. 
  name = "demo_db"

  # The RDS instance class.
  instance_class       = "db.t2.micro"

  # The allocated storage in gibibytes. 
  allocated_storage    = 20

  # The database engine.
  engine               = "aurora-postgresql"

  # The master account username and password.
  # Note that these settings may show up in logs, 
  # and will be stored in the state file in raw text.
  # We strongly recommend doing this differently if you
  # are building a production system or secure system.
  username             = "postgres"
  password             = "cc38f91c340473c43b160aec6c559e0e"

  # We like to use the database with public tools such as DB admin apps.
  publicly_accessible = "true"

  # We like performance insights, which help us optimize the data use.
  performance_insights_enabled = "true"

  # We like to have the demo database update to the current version.
  allow_major_version_upgrade = "true"

  # We like backup retention for as long as possible.
  backup_retention_period = "35"

  # Backup window time in UTC is in the middle of the night in the United States.
  backup_window = "08:00-09:00"

  # We prefer to preserve the backups if the database is accidentally deleted.
  delete_automated_backups = "false"

  # Maintenance window is after backup window, and on Sunday, and in the middle of the night.
  maintenance_window = "sun:09:00-sun:10:00"

}
