# Setup


## Get your credentials

Get an AWS account, if you don't already have one:

* Go to https://aws.amazon.com/free/

Get your security credentials:

* When you sign in, the AWS console shows your username in the upper right. 

* Click your username. You see a dropdown menu. Click "Security Credentials". 

* If this is your first time using AWS, or if you are still using old-style credentials, then you may see a dialog box asking you to switch to best practices using AWS IAM; click the IAM button.


## Create a user

* Create an IAM user: enter the user name "demo_terraform" then check the box "Generate an access key for each user".

* Click "Show User Security Credentials" and copy the info, which looks like this:

      Access Key ID: 6IAIN7RHCYWDYJAHV8LS
      Secret Access Key: OJif8/L9UgHqfJzkO3RDqEcypvWkilfkfe8N5YOO


## Create a policy

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

  * Policy Document: create the policy you want, such as [these examples](policies)

  * Click the button "Validate Policy". If it's not valid, then keep working on it; do not apply it.

  * Click the button "Apply Policy".
