#!/bin/bash

# Exit if anything goes wrong
set -e

eval $(grep ^PATH ~/.bashrc) # Load the PATH value

# Start the service
localstack start -d

# Check the service status
localstack status services

# Check secretsmanager
awslocal secretsmanager list-secrets | jq

# Touching secretsmanager started the service
localstack status services

# Get AWS account
awslocal sts get-caller-identity | jq

# Display information about the IAM account
awslocal iam get-user | jq

# Get a list of all AMIs (Amazon Machine Images) that are provided by Amazon and are described as Linux
awslocal ec2 describe-images --owners amazon | jq '.Images[]|select(.Description | contains("Linux")).Name'

# Create a bucket and copy the README.md file into it
awslocal s3api create-bucket --bucket mybucket
awslocal s3api list-buckets
awslocal s3 cp README.md s3://mybucket/
awslocal s3 ls s3://mybucket
