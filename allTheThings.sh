#!/bin/bash

[ $(id -u) -ne 0 ] && {
  echo "Please run as root"
  echo "sudo $0"
  exit
}
# Exit if anything goes wrong
set -e

echo "Setup as root"
./setup.sh

echo "Setup as user"
su ${SUDO_USER} -c ./setupAsUser.sh

echo "Add color to Docker"
./dockerColor.sh
eval $(grep ^PATH ~/.bashrc) # Load the PATH value

echo "Create AWS credentials"
su ${SUDO_USER} -c ./awsCredentials.sh

echo "Test LocalStack"
su ${SUDO_USER} -c ./testLocalStack.sh

echo "Run Terraform"
su ${SUDO_USER} -c ./terraform.sh

echo "Test DynamoDB"
su ${SUDO_USER} -c ./testDynamoDb.sh
