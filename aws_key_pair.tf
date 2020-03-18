##
#
# Key Pair
#
# To create a key pair via the the AWS console:
#
#   * Use the AWS console to create a key pair such as `administrator`.
#
#   * Download the key pair file such as `administrator.pem`.
#
# To convert a AWS *.pem file to the resource's public key format:
#
#     openssl rsa -in administrator.pem -pubout
#
# Output such as:
#
#     -----BEGIN PUBLIC KEY-----
#     MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp6hb0N8fI+EzfWDPibdr
#     ZWxkr+hV9tIiXOGqVxjRfyT9Ot/oSQ2UXWT/S1+YP4f8VVfsK8koH04/aW1jFV7X
#     0bUAOkt4C+EWWdBaWMnUDb7Y/urDfQKNg801m2GZji/iVqWvLRuEHeYHY3HGcHyC
#     A2wa6euHX++DIFEn079IkCPUKjLTy0uvZV0Xr6gQ0f8uPMycXgmsaUKUTrh0YUdq
#     2v7mKou1E0KDZhu9HQksHwPinWKMjxBHUCO34jNlVTMn5FpUaNtt/+Vqh0dQ4z6t
#     Vd4cVAHdqP7uM+zhsVadb9ulkbcPeqn6xYK38zwG5OpECvpeFQAgq45ZakCvFKAF
#     OwIDAQAB
#     -----END PUBLIC KEY-----
#
# If you get this error message:
#
#     Error import KeyPair: InvalidKey.Format: 
#     Key is not in valid OpenSSH public key format
#
# Edit the public key content (not the BEGIN line nor END line),
# and remove the newlines, then use that to set `public_key` below.
#
# Then import the key pair such as `administrator`:
#
#     terraform import aws_key_pair.administrator administrator
#
# Output:
#
#     aws_key_pair.administrator: Importing from ID "administrator"...
#     aws_key_pair.administrator: Import prepared!
#     Prepared aws_key_pair for import
#     aws_key_pair.administrator: Refreshing state... [id=administrator]
#     Import successful!
#
# We use this key pair for our default needs, such as SSH to an instance.
# Our public key below won't work for you, so you'll want to change it.
#
# To try using SSH, such as with a file `administrator.pem`, to a machine
# username `ubuntu`, on a machine with IP address `12.34.56.78`:
#
#     ssh -i administrator.pem ubuntu@12.34.56.78
#
# If you choose to generate your key pair locally, not using the AWS console,
# then we suggest you can use  the `openssh` command to create the public key. 
# Then you need to generate the correct format of the public key.
###

resource "aws_key_pair" "administrator" {
  key_name   = "administrator"
  public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp6hb0N8fI+EzfWDPibdrZWxkr+hV9tIiXOGqVxjRfyT9Ot/oSQ2UXWT/S1+YP4f8VVfsK8koH04/aW1jFV7X0bUAOkt4C+EWWdBaWMnUDb7Y/urDfQKNg801m2GZji/iVqWvLRuEHeYHY3HGcHyCA2wa6euHX++DIFEn079IkCPUKjLTy0uvZV0Xr6gQ0f8uPMycXgmsaUKUTrh0YUdq2v7mKou1E0KDZhu9HQksHwPinWKMjxBHUCO34jNlVTMn5FpUaNtt/+Vqh0dQ4z6tVd4cVAHdqP7uM+zhsVadb9ulkbcPeqn6xYK38zwG5OpECvpeFQAgq45ZakCvFKAFOwIDAQAB"
}
