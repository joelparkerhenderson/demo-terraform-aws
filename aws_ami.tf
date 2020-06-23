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

# Define local variables.
#
# We use our preferred naming convention of a single-underscore to
# separate words, and a double-underscore to separate concepts.
# You can use any variable you want, and any naming convention.
#
# We define the AWS AMI owner id numbers of our preferred vendors:
#
#   * Canonical (the maker of Ubuntu)
#
#   * Fedora (the maker community that creates Fedora AMIs)
#
# These variables enable us to search AMIs for ones made by owners.
locals {
  aws_ami__owner__canonical = "099720109477"
  aws_ami__owner__fedora = "125523088429"
}

# Look up the AMI id of the current Ubuntu OS.
data "aws_ami" "ubuntu_with_current_version" {
  most_recent = true
  owners = [local.aws_ami__owner__canonical]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
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
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
