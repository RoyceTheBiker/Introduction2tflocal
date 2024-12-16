#!/bin/bash

# Exit if anything goes wrong
set -e

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