##
#
# AWS AMI: Amazon Machine Image
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
