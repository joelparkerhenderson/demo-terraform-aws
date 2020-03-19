##
# AWS IAM policies
#
# We import the existing AWS IAM policy name AdmnistratorAccess:
#
#     terraform import aws_iam_policy.AdministratorAccess arn:aws:iam::aws:policy/AdministratorAccess 
##

resource "aws_iam_policy" "AdministratorAccess" {
    description = "Provides full access to AWS services and resources."
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}
