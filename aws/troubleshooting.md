# Terraform AWS troubleshooting


## VPC resource not specified

Issue: `terraform apply` failed due to VPC resource not specified.

   * Error message: aws_instance.example: Error launching source instance: VPCResourceNotSpecified: The specified instance type can only be used in a VPC. A subnet ID or network interface ID is required to carry out the request.

  * See this issue: https://github.com/hashicorp/terraform/issues/4367

  * Workaround is to change to an AMI and instance that do not need a VPC, such as:

      resource "aws_instance" "example" {
         ami = "ami-408c7f28"
         instance_type = "t1.micro"
      }


## Unauthorized operation

Issue: `terraform apply` failed due to unauthorized operation.

  * Error message: aws_instance.example: Error launching source instance: UnauthorizedOperation: You are not authorized to perform this operation. Encoded authorization failure message...

  * See this issue: https://github.com/hashicorp/terraform/issues/2834

  * The solution is to use policy; we recommend the policy that is described in the issue above, thanks to [https://github.com/artburkart](https://github.com/artburkart)

