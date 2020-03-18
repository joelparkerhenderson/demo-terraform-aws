##
#
# AWS EC2 instances
#
##

# Define local varibles that notate what the AWS free tier can do.
locals {
  free__aws_instance__instance_type = "t2.micro"
  free__aws_instance__root_block_device__volume_size = "30"
}

# Create an EC2 instance, using our existing key pair from above.
resource "aws_instance" "demo" {
  ami = data.aws_ami.ubuntu_with_current_version.id
  instance_type = local.free__aws_instance__instance_type
  associate_public_ip_address = true
  key_name = "administrator"
  vpc_security_group_ids = [aws_security_group.demo_security_group.id]

  tags = {
    Name = "demo"
  }

  root_block_device {
    volume_size           = local.free__aws_instance__root_block_device__volume_size
  }

  # Install some typical software, by using the typical package manager.
  # You will likely want to customize this section for your own purposes.
  # Install some typical software, by using the typical package manager.
  # You will likely want to customize this section for your own purposes.
  user_data = <<EOF
    #!/bin/sh

    # Update
    sudo apt-get -q -y update
    sudo apt-get -q -y upgrade

    # Infrastructure
    sudo apt-get install -q -y apt-transport-https
    sudo apt-get install -q -y build-essential
    sudo apt-get install -q -y ca-certificates
    sudo apt-get install -q -y curl
    sudo apt-get install -q -y gnupg-agent
    sudo apt-get install -q -y software-properties-common

    # Libraries
    sudo apt-get install -q -y libssl-dev
    sudo apt-get install -q -y libv8-dev

    # Typicals
    sudo apt-get install -q -y default-jdk
    sudo apt-get install -q -y emacs
    sudo apt-get install -q -y fd-find
    sudo apt-get install -q -y git
    sudo apt-get install -q -y git-core 
    sudo apt-get install -q -y htop
    sudo apt-get install -q -y jq
    sudo apt-get install -q -y nginx
    sudo apt-get install -q -y openssl
    sudo apt-get install -q -y python3.6
    sudo apt-get install -q -y ripgrep
    sudo apt-get install -q -y ruby
    sudo apt-get install -q -y tmux
    sudo apt-get install -q -y vim
    sudo apt-get install -q -y wget

    # Node-related
    sudo apt-get install -q -y nodejs
    sudo apt-get install -q -y npm
    sudo npm install -g express

    # Docker-related
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get -q -y update
    sudo apt-get install -q -y docker-ce 
    sudo apt-get install -q -y docker-ce-cli
    sudo apt-get install -q -y containerd.io

    # Finish
    sudo apt-get -q -y autoclean
    sudo apt-get -q -y --purge autoremove
    
  EOF

}
