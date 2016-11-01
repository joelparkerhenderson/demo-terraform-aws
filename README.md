# Demo of Terraform by Hashicorp

You need an AWS account for this demo.

* You can use any AWS user you want; we prefer to create a new user named "demo_terraform".

* See our help page for [Terraform AWS setup](aws/setup.md).

Install Terraform:

* Go to https://www.terraform.io/intro/getting-started/install.html

* Caveat: When I try to install Terraform on a MacBook with macOS by using `brew install terraform`, then the brew tool warns me that this is not yet supported. 

* Workaround on Mac: download the Mac binary, unzip it, and move the `terraform` binary to somewhere convenient; I move it to my `/usr/local/bin` directory, which already on my path.

Create a Terraform configuration file by customizing this code with your own information:

    provider "aws" {
      access_key = "ACCESS_KEY_HERE"
      secret_key = "SECRET_KEY_HERE"
      region = "us-east-1"
    }

    resource "aws_instance" "example" {
       ami = "ami-0d729a60"
       instance_type = "t2.micro"
    }

Follow the Terraform build page: https://www.terraform.io/intro/getting-started/build.html

  * `terraform plan` shows what will run.

  * `terraform apply` runs it.

    * Caveat: when I ran `terraform apply` then I saw error messages; I needed to choose a different region, AMI, instance type, and IAM security policy. See [Terraform AWS troubleshooting](aws/troubleshooting.md)

  * `terraform show` prints the results file.

Congratulations, you're up and running!