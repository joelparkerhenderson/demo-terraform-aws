##
#
# AWS IAM account password policy
#
# We like to configure a strong password policy.
#
# We expect our users to have a password manager.
#
##

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length = 32
  require_lowercase_characters = true
  require_numbers = true
  require_uppercase_characters = true
  require_symbols = true
  allow_users_to_change_password = true
  password_reuse_prevention = 20
  max_password_age = 180
}
