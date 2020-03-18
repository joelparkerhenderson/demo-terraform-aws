##
#
# AWS default VPC
#
# Connect to our existing AWS default virtual public cloud (VPC).
# If your AWS doesn't have a default VPC, then you can either omit
# this block, or use the AWS console (or API) to create a default VPC.
#
# Import a default VPC such as:
#
#     terraform import aws_default_vpc.default vpc-9d069e6135c7e813dbc61872f38dc632
#
##

resource "aws_default_vpc" "default" {
  tags = {
    Name = "default"
  }
}
