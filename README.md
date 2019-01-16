# Demo of Terraform by HashiCorp for AWS

<img src="README.png" alt="Terraform" style="width: 100%;"/>

Contents:

* [AWS setup](#aws-setup)
  * [Get your AWS account](#get-your-aws-account)
  * [Get your AWS security credentials](#get-your-aws-security-credentials)
  * [Get an AWS user](#get-an-aws-user)
  * [Create an AWS IAM user (optional)](#create-an-aws-iam-user-optional)
  * [Create an AWS IAM policy (optional)](#create-an-aws-iam-policy-optional)
* [Terraform setup](#terraform-setup)
  * [Install](#install)
  * [Configure](#configure)
  * [Build](#build)
* [Troubleshooting](#troubleshooting)
  * [VPC resource not specified](#vpc-resource-not-specified)
  * [Unauthorized operation](#unauthorized-operation)


## AWS setup


### Get your AWS account

Get an AWS account, if you don't already have one:

  * Go to https://aws.amazon.com/free/

  * Sign up.
  

### Get AWS command line software (optional)

To install AWS CIO on macOS via brew:

```sh
$ brew update && brew install awscli
```

To install AWS CLI via python pip:

```sh
$ pip install awscli --upgrade --user
```

Verify:

```sh
$ aws --version
aws-cli/1.15.30 Python/3.6.5 Darwin/17.7.0 botocore/1.10.30
```


### Get your AWS security credentials

Get your AWS security credentials, if you don't already have them.

  * When you sign in the AWS website, the AWS console shows your username in the upper right. 

  * Click your username. You see a dropdown menu. Click "Security Credentials". 
  * If this is your first time using AWS, or if you are still using old-style credentials, then you may see a dialog box asking you to switch to best practices using AWS IAM; click the IAM button.


### Get your AWS user

You can run this demo by using any AWS user you want.

  * For example, you can run this as your own user.

  * We prefer to create a new AWS IAM user that is specific for this demo. We name the user "demo_terraform".


### Create an AWS IAM user (optional)

  * Enter the user name "demo_terraform" then check the box "Generate an access key for each user".

  * Click "Show User Security Credentials" and copy the info, which looks like the info below.

Example credentials:
```txt
Access Key ID: 6IAIN7RHCYWDYJAHV8LS
Secret Access Key: OJif8/L9UgHqfJzkO3RDqEcypvWkilfkfe8N5YOO
```


### Create an AWS IAM policy (optional)

Authorize the Terraform user, if you need to.

To set up the policy:

  * Go to https://console.aws.amazon.com/iam/home

  * Choose the "demo_terraform" user (or whatever you call your user)

  * You see the "Set Permissions" page.

  * Choose the "Permissions" tab

Option 1 - choose the Administration policy:

  * This is a good option if you want to get up and running easily, and the AWS system is low value.

  * Click the row "Managed Policies"

  * Click the button "Attach Policies".

Option 2 - choose a custom policy:

  * This is a good option if you need to be cautious with your AWS systems, such as protecting them from accidential deletions of servers.

  * Click the row "Inline Policies"

  * Click the button "Create User Policy".

  * Click the "Select" button.

  * Policy Name: demo_terraform_policy (or anything you want)

  * Policy Document: create the policy you want, such as [these examples](doc/policies)

  * Click the button "Validate Policy". If it's not valid, then keep working on it; do not apply it.

  * Click the button "Apply Policy".


## Terraform setup


### Install

Use the Terraform install page.

  * Go to https://www.terraform.io/intro/getting-started/install.html

  * Caveat: When I try to install Terraform on a MacBook with macOS by using `brew install terraform`, then the brew tool warns me that this is not yet supported. 

  * Workaround on Mac: download the Mac binary, unzip it, and move the `terraform` binary to somewhere convenient; I move it to my `/usr/local/bin` directory, which already on my path.


### Configure

Create a Terraform configuration file.

Our demo configuration file is [demo.tf](demo.tf)


### Build

Use the Terraform build page.

  * Go to https://www.terraform.io/intro/getting-started/build.html

Typical commands:

  * `terraform plan` shows what will run.

  * `terraform apply` runs it.

  * `terraform show` prints the results file.

  * Caveat: when I ran `terraform apply` then I saw error messages; I needed to choose a different region, AMI, instance type, and IAM security policy.

Congratulations, you're up and running!


## Troubleshooting


### VPC resource not specified

Issue: `terraform apply` failed due to VPC resource not specified.

   * Error message: aws_instance.example: Error launching source instance: VPCResourceNotSpecified: The specified instance type can only be used in a VPC. A subnet ID or network interface ID is required to carry out the request.

  * See this issue: https://github.com/hashicorp/terraform/issues/4367

  * Workaround is to change to an AMI and instance that do not need a VPC.

Example:

```tf
resource "aws_instance" "example" {
  ami = "ami-408c7f28"
  instance_type = "t1.micro"
}
```


### Unauthorized operation

Issue: `terraform apply` failed due to unauthorized operation.

  * Error message: aws_instance.example: Error launching source instance: UnauthorizedOperation: You are not authorized to perform this operation. Encoded authorization failure message...

  * See this issue: https://github.com/hashicorp/terraform/issues/2834

  * The solution is to use policy; we recommend the policy that is described in the issue above, thanks to [https://github.com/artburkart](https://github.com/artburkart)
