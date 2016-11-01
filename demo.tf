provider "aws" {
  access_key = "6IAIN7RHCYWDYJAHV8LS"
  secret_key = "OJif8/L9UgHqfJzkO3RDqEcypvWkilfkfe8N5YOO"
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami = "ami-408c7f28"
  instance_type = "m3.medium"
}
