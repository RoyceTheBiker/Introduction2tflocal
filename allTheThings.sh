#!/bin/bash

# Exit if anything goes wrong
set -e

./setup.sh

./dockerColor.sh

./awsCredentials.sh

./testLocalStack.sh

./testDynamoDb.sh
