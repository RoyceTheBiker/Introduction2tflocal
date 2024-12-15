#!/bin/bash

# Exit if anything goes wrong
set -e

# This needs to be ran when ever a new module is added.
# This will download the TF module libraries to use the new module.
tflocal init

# This will check the code to validate that there are no syntax errors.
tflocal validate

# This will show what is about to be done.
tflocal plan

# This will show the plan first then apply the changes.
# -auto-approve avoids prompting the user to type yes before proceeding.
tflocal apply -auto-approve

# Show Terraform details about the running asset
tflocal state show module.instance.aws_instance.linux