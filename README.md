# LocalStack And Terraform For Testing AWS IaC
This is an introduction to using localStack to test Terraform IaC to build AWS Cloud resources.

The commands used in this document have been included and can be ran in sequence by running [allThings.sh](./allTheThings.sh)

This document and included sample files is publicly available on [GitLab](https://gitlab.com/SiliconTao-Systems/Introduction2tflocal) can be downloaded using the **git clone** command.
```bash
git clone https://gitlab.com/SiliconTao-Systems/Introduction2tflocal.git
```

## Tech Stuff
This document covers a working introduction to using the following technologies.

[AWS](https://aws.amazon.com/) provides computer assets as the world leader or cloud computing.

[Terraform](https://www.terraform.io/) is a tool to create code that builds AWS resources. This is the definition or IaC (Infrastructure as Code). Terraform supports many different cloud and containerization platforms. This document only focuses on AWS.

[localStack](https://docs.localstack.cloud/overview/) uses Docker containers to mimic AWS resources. Scripts like Terraform can build AWS resources in the localStack Docker and not use real AWS assets. This allows developers to save money while creating and testing Terraform code before deploying to real AWS. localStack has two levels of functionality, a free version known as CRUD does not create resources that do anything, they simply respond to queries and report that they are setup to function. A paid version of localStack will create functional assets in Docker that more closely work like real AWS, these licensed assets can be used for testing and security scans on products before sending them off for deployment. For a full list of supported services and what are CRUD under the free license please visit [feature coverage](https://docs.localstack.cloud/user-guide/aws/feature-coverage/)

[tfenv](https://github.com/tfutils/tfenv) can install and manage Terraform environments. This will allow quickly switching between versions to maintain older code.

[jQ](https://jqlang.github.io/jq/) will be used to format AWS JSON data for easy reading and adjusting values.

## Overview
This document was tested using Linux Mint 22 Wilma, a fork of Ubuntu 24.04

Overview
 1. Install Docker to simulate an AWS environment
 2. Install JQ for scripting with JSON data
 3. Install TFENV to manage the Terraform installs
 4. Install Terraform to markup AWS
 5. Install AWS-CLI required
 6. Install localStack to create and manage CRUD
 7. Setup test environment
 8. Create AWS resources inside localStack CRUD


## Installing Packages
[Installing Docker](https://docs.docker.com/engine/install/ubuntu/)

[Installing AWS CLI for RPM](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

[Installing AWS CLI for DEB](https://www.geeksforgeeks.org/how-to-install-aws-cli-on-ubuntu/)

Setup the working environment
```bash
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
```

## Docker CLI Color
Optionally adding colorized Docker commands can enhance the user experience.

[Docker Color Output](https://github.com/devemio/docker-color-output)

```bash
sudo su
add-apt-repository ppa:dldash/core
apt update
apt -y install docker-color-output
# Add alias commands to root account
echo "alias di='docker images ${@} | docker-color-output'" >> ${HOME}/.bashrc
echo "alias dps='docker ps ${@} | docker-color-output'" >> ${HOME}/.bashrc
# Add alias commands to user account
grep "alias.*docker" ~/.bashrc >> $(eval echo ~${SUDO_USER})/.bashrc

exit
source ~/.bashrc # Load the alias values
```

![docker-color-output](./docker_list_output.png)


The permission change for the general user account does not take affect until the terminal session ends and restarts. Disconnect from the terminal and login again.

Confirm the permissions
```bash
id | grep docker
```

Check the localStack version
```bash
localstack --version
LocalStack CLI 4.0.3
```

Start the localStack service
```bash
localstack start -d
```

The ``-d`` starts the service detached to allow the terminal to be used.


## Config

### Resolver
The localStack service will connect to a resolver service hosted by the localStack project. Besides reporting your use of localStack to the project developers, this service will simply resolve to localhost. This will not work if you are not connected to the Internet or are behind a firewall that restricts out going requests.

Add the local resolver to ``/etc/hosts``, this will allow the ``localstack status services`` command to work without an Internet connection. Doing this will prevent some services from working such as [localStack REST API](http://localhost.localstack.cloud:4566/_localstack/swagger)

```
127.0.0.1 localhost.localstack.cloud
```

### Without Internet

These could be helpful if there is no Internet connection.
```
export SKIP_SSL_CERT_DOWNLOAD=1
export SKIP_INFRA_DOWNLOADS=1
export DISABLE_EVENTS=1
```

### localStack Profile & Credentials
AWS-CLI uses token identification to associate the permissions of an [IAM (Identity and Access Management)](https://aws.amazon.com/iam)

The AWS credential files are simple text that could be edited manually but that is not recommended as AWS-CLI is intolerant of any white space malformations. It is recommended to use the AWS-CLI tool to make all modifications to the credential files.

```bash
PROFILE=localStack
REGION=us-east-1
KEY_ID=local
ACCESS_KEY=local
aws configure set profile.${PROFILE}.region ${REGION} --profile ${PROFILE}      # Create the profile
aws configure set aws_access_key_id ${KEY_ID} --profile ${PROFILE}              # ID for this IAM
aws configure set aws_secret_access_key "${ACCESS_KEY}" --profile ${PROFILE}    # Secret for this IAM
aws configure set endpoint-url http://localhost:4566 --profile ${PROFILE}       # Set endpoint to be the localStack Docker service
```

## Status

```bash
localstack status services
┏━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┓
┃ Service                  ┃ Status      ┃
┡━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━┩
│ acm                      │ ✔ available │
│ apigateway               │ ✔ available │
│ cloudformation           │ ✔ available │
│ cloudwatch               │ ✔ available │
│ config                   │ ✔ available │
│ dynamodb                 │ ✔ available │
...
```

Now test the AWS local CLI
```bash
awslocal secretsmanager list-secrets | jq
```

Run ``localstack status services`` again and notice that after having touched **secretsmanager** it has changed status from **available** to **running**. localStack services will automatically start by simply querying them.

## localStack Wrapper Tools
The *awslocal* tool is a wrapper for AWS CLI that sets the profile internally to use the localStack endpoints and region. Using this command will prevent accidentally touching paid resources.

The *tflocal* is also a wrapper to safely develop Terraform code without touching paid AWS resources.


## AWS Local CLI
[awslocal](https://docs.localstack.cloud/user-guide/integrations/aws-cli/#localstack-aws-cli-awslocal)

The localStack service assumes the region to be ``us-east-1``. Terraform code must use the region setting of ``us-east-1``.

## AWS Profile
### Useful AWS CLI commands.
```bash
awslocal sts get-caller-identity | jq # Get AWS account
awslocal iam get-user | jq # Display information about the IAM account

# Get a list of all AMIs (Amazon Machine Images) that are provided by Amazon and are described as Linux
awslocal ec2 describe-images --owners amazon | jq '.Images[]|select(.Description | contains("Linux")).Name'

# Adding a filter to shorten the list helps
awslocal ec2 describe-images --owners amazon --filters 'Name=name,Values=*node*' | jq '.Images[]|select(.Description | contains("Linux"))'
```

Selecting by ``.Platform`` may also work but can cause errors as some AMIs will have blank values. **jQ** can filter out null values using a more advanced query.
```json
{
  "BlockDeviceMappings": [
    {
      "Ebs": {
        "DeleteOnTermination": false,
        "SnapshotId": "snap-d08b2095f3339f17a",
        "VolumeSize": 15,
        "VolumeType": "standard"
      },
      "DeviceName": "/dev/sda1"
    }
  ],
  "Description": "EKS Kubernetes Worker AMI with AmazonLinux2 image",
  "Hypervisor": "xen",
  "ImageOwnerAlias": "amazon",
  "Name": "amazon-eks-node-linux",
  "RootDeviceName": "/dev/sda1",
  "RootDeviceType": "ebs",
  "Tags": [],
  "VirtualizationType": "hvm",
  "ImageId": "ami-ekslinux",
  "ImageLocation": "amazon/amazon-eks",
  "State": "available",
  "OwnerId": "801119661308",
  "CreationDate": "2024-12-14T17:16:58.000Z",
  "Public": true,
  "Architecture": "x86_64",
  "ImageType": "machine",
  "KernelId": "None",
  "RamdiskId": "ari-1a2b3c4d",
  "Platform": "Linux/UNIX"
}
```

## Services
### S3
S3 is AWS virtual disk. In the free version of localStack it is a functioning storage device within Docker.
https://docs.localstack.cloud/user-guide/aws/s3/


This command will start the S3 service and create a bucket.
```bash
awslocal s3api create-bucket --bucket mybucket
awslocal s3api list-buckets
```

```json
{
  "Buckets": [
    {
      "Name": "mybucket",
      "CreationDate": "2024-12-14T16:14:49.000Z"
    }
  ],
  "Owner": {
    "DisplayName": "webfile",
    "ID": "75aa57f09aa0c8caeab4f8c24e99d10f8e7faeebf76c078efc7c6caea54ba06a"
  },
  "Prefix": null
}
```

```bash
awslocal s3 cp README.md s3://mybucket/
awslocal s3 ls s3://mybucket
2024-12-14 13:58:32       11196 README.md
```


#### S3 Offline
To use S3 offline add this resolver to /etc/hosts

```bash
# localStack
127.0.0.1 <THE S3 BUCKET NAME>.s3.localhost.localstack.cloud
```

# Terraform
For simplicity a small example Terraform project is included.

1. VPC (Virtual Private Cloud)
2. Security Group (SG)
3. Elastic Cloud Compute (EC2)
3. Simple Storage Service (S3)
4. AWS Identity and Access Management Interface (IAM)
5. Relational Database Service (RDS)

## VPC (Virtual Private Cloud)
A VPC is used to create group of resources comparable to a LAN
