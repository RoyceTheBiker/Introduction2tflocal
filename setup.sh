#!/bin/bash

# Exit if anything goes wrong
set -e

sudo su  # Become the root administrator
apt update # Update the information about available packages
apt -y install ca-certificates curl # Install c[ommand line]url tool and latest TLS certificates
install -m 0755 -d /etc/apt/keyrings # Make the keyring dir if it does not exist

# Installing Docker 🐳
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# For Linux Mint 22, change wilma to noble to match Ubuntu 24.04
sed -i /etc/apt/sources.list.d/docker.list -e 's/wilma/noble/'

apt update
apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker run hello-world # Test if Docker is working

apt -y install jq # The CLI JSON tool

# 🌩 Install the AWS Command Line Tool
apt -y install python3-pip pipx

# The general user account needs permission to use the new services
usermod -a -G docker $SUDO_USER

exit # Exit root administrator account and become a general user again

# As a general user, add AWS CLI to your profile.
pipx install awscli

# Add the AWS commands to the PATH
PATH=$PATH:${HOME}/.local/bin/
echo "PATH=${PATH}:${HOME}/.local/bin/" >> ~/.bashrc

# Install TFENV
git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
echo "PATH=${PATH}:${HOME}/.tfenv/bin" >> ~/.bashrc
PATH=${PATH}:${HOME}/.tfenv/bin

# Use tfenv to install Terraform
tfenv install

# Install localStack
pipx install --include-deps localstack
pipx install terraform-local
pipx install awscli-local