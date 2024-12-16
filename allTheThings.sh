#!/bin/bash

# Exit if anything goes wrong
set -e

echo "Setup as root"
sudo ./setup.sh

echo "Setup as user"
./setupAsUser.sh

echo "Add color to Docker"
./dockerColor.sh

echo "Create AWS credentials"
./awsCredentials.sh

echo "Test LocalStack"
./testLocalStack.sh

echo "Run Terraform"
./terraform.sh

echo "Test DynamoDB"
./testDynamoDb.sh
