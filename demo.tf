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

resource "aws_instance" "example" {
  # For our EC2 instance, we specify an AMI for Ubuntu, 
  # a "t2.micro" instance, so we can use the free tier.
  ami = "ami-2757f631"
  instance_type = "t2.micro"
}
