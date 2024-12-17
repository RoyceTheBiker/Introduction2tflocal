#!/bin/bash

# Exit if anything goes wrong
set -e

eval $(grep ^PATH ~/.bashrc) # Load the PATH value
PROFILE=localStack
REGION=us-east-1
KEY_ID=local
ACCESS_KEY=local
aws configure set profile.${PROFILE}.region ${REGION} --profile ${PROFILE}      # Create the profile
aws configure set aws_access_key_id ${KEY_ID} --profile ${PROFILE}              # ID for this IAM
aws configure set aws_secret_access_key "${ACCESS_KEY}" --profile ${PROFILE}    # Secret for this IAM
aws configure set endpoint-url http://localhost:4566 --profile ${PROFILE}       # Set endpoint to be the localStack Docker service
