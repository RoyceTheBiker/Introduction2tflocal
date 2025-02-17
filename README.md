# LocalStack And Terraform For Testing AWS IaC
This is an introduction to using localStack to test Terraform IaC and build AWS Cloud resources.

The commands used in this document have been included and can be run in sequence by running **[sudo ./allTheThings.sh](./allTheThings.sh)**

This document and included sample files are publicly available on [GitLab](https://gitlab.com/SiliconTao-Systems/Introduction2tflocal) and can be downloaded using the **git clone** command.
```bash
git clone https://gitlab.com/SiliconTao-Systems/Introduction2tflocal.git
```

Project homepage on [SiliconTao.com](https://silicontao.com/main/marquis/article/RoyceTheBiker/LocalStack%20And%20Terraform%20For%20Testing%20AWS%20IaC)

---

<table width="100%">
   <tr>
      <td width="30%"></td>
      <td width="40%">
         <a href="https://www.youtube.com/watch?v=YLrloXeXhuVzuHa-" target="_blank">
            <img src="https://img.youtube.com/vi/meYZOXQo5mY/0.jpg"
              alt="Introduction to building AWS with Terraform and LocalStack">
         </a>
      </td>
      <td width="30%"></td>
   </tr>
</table>

---


Linux systems that use DEB packages can install the **git** command like so ``sudo apt -y install git``

## Tech Stuff
This document covers an introduction to using the following technologies.

[AWS](https://aws.amazon.com/) provides computer resources and is the world leader in cloud computing.

[Terraform](https://www.terraform.io/) is a tool that uses code to build AWS resources. This is the definition of IaC (Infrastructure as Code). Terraform supports many different cloud and containerization platforms. This document only focuses on AWS.

[localStack](https://docs.localstack.cloud/overview/) uses Docker containers to mimic AWS resources. Scripts like Terraform can build AWS resources in the localStack Docker and not use real AWS resources.
This allows developers to save money while creating and testing Terraform code before deploying to real AWS.
localStack has two levels of functionality, a free version known as CRUD (Create, Read, Update, Delete) does not create resources that do active processing, they only respond to instructions and report that they are ready to function.
A paid version of localStack can create functional resources in Docker that more closely work like real AWS,
these licensed resources can be used for testing and security scans on products before sending them off for deployment.
For a full list of supported services and what are CRUD under the free license please visit [feature coverage](https://docs.localstack.cloud/user-guide/aws/feature-coverage/)

[tfenv](https://github.com/tfutils/tfenv) can install and manage Terraform environments. This will allow quick updating and switching between versions to maintain older code, and get the latest updates.

[jQ](https://jqlang.github.io/jq/) will be used to format AWS JSON data for easy reading and filtering values.

## Overview
This document was tested using [Linux Mint 22 Wilma](https://www.linuxmint.com/rel_uma_cinnamon.php), a fork of [Ubuntu 24.04 LTS](https://ubuntu.com/blog/tag/ubuntu-24-04-lts). Mint was installed as a VM inside [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

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

[Installing AWS CLI for RPM](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) for RPM systems.

[Installing AWS CLI for DEB](https://www.geeksforgeeks.org/how-to-install-aws-cli-on-ubuntu/) for DEB systems. This document and scripts use the DEB commands, not the RPM commands.

Setup the working environment
```bash
sudo su  # Become the root administrator
apt update # Update the information about available packages
apt -y install ca-certificates curl # Install c[ommand line]url tool and latest TLS certificates
install -m 0755 -d /etc/apt/keyrings # Make the keyring dir if it does not exist
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Installing Docker 🐳
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# For Linux Mint 22, change wilma to noble to match Ubuntu 24.04
sed -i /etc/apt/sources.list.d/docker.list -e 's/wilma/noble/'

apt update
apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker run hello-world # Test if Docker is working

# The general user account needs permission to use Docker
usermod -a -G docker $SUDO_USER

# Confirm group membership. Any terminals with that user account will need to exit and reconnect for the membership.
id $SUDO_USER

apt -y install jq # The CLI JSON tool

# 🌩 pipx is needed to install the AWS Command Line Tool & localStack
apt -y install python3-pip pipx

# Git is needed to install TFENV
apt -y install git

exit # Exit root administrator account and become a general user again

# Fork the shell to use the new Docker group
exec su - $USER

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

# Set the default Terraform to use
tfenv use

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

exit # Exit root administrator account and become a general user again
# Restart the shell to use the new alias commands
$SHELL
```

This is a screenshot of how Docker color looks after localStack is running.
![docker_list_output.png](https://cdn.SiliconTao.com/docker_list_output.png)


## Install localStack
The permission change for the general user account does not take effect until the terminal session ends and restarts. Disconnect from the terminal and log in again.

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


## Config Changes For Offline
It is recommended to use localStack with an Internet connection. Sometimes that is not possible. These are tips that may be helpful for offline use.

### Resolver
The localStack service will connect to a resolver service hosted by the localStack project. Besides providing helpful API into the localStack service, this service will also redirect endpoint requests to localhost.

Add the local resolver to ``/etc/hosts``, this will allow the ``localstack status services`` command to work without an Internet connection. Doing this will prevent some services from working such as [localStack REST API](http://localhost.localstack.cloud:4566/_localstack/swagger)

```
127.0.0.1 localhost.localstack.cloud
```

### Without Internet

These could be helpful if there is no Internet connection.
```
export LOCALSTACK_SKIP_SSL_CERT_DOWNLOAD=1
export LOCALSTACK_SKIP_INFRA_DOWNLOADS=1
export LOCALSTACK_DISABLE_EVENTS=1
```

### localStack Profile & Credentials
AWS-CLI uses token identification to associate the permissions of an [IAM (Identity and Access Management)](https://aws.amazon.com/iam)

The AWS credential files are simple text that could be edited manually but that is not recommended as AWS-CLI is intolerant of white space malformations. It is recommended that the AWS-CLI tool be used to modify the credential files.

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

# Check Status & Wrapper Tools

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
S3 is AWS virtual disk. The free version of localStack is a functioning S3 storage device within Docker.
https://docs.localstack.cloud/user-guide/aws/s3/


This command will start the S3 service and create a bucket.
```bash
awslocal s3api create-bucket --bucket mybucket | jq
awslocal s3api list-buckets | jq
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
awslocal s3 cp ~/.bashrc s3://mybucket/
awslocal s3 ls s3://mybucket
2024-12-18 10:44:46       4163 .bashrc
```


#### S3 Offline
To use S3 offline add this resolver to /etc/hosts

```bash
# localStack
127.0.0.1 <THE S3 BUCKET NAME>.s3.localhost.localstack.cloud
```

# Terraform
For simplicity a small example Terraform project is included.

To follow along using the sample project, use git to clone the project and change into that directory.
```bash
git clone https://gitlab.com/SiliconTao-Systems/Introduction2tflocal.git
cd Introduction2tflocal
```

1. Virtual Private Cloud (VPC)
2. Security Group (SG)
3. Elastic Cloud Compute (EC2)
3. Simple Storage Service (S3)
4. Identity and Access Management (IAM)
5. Relational Database Service (RDS)

### Virtual Private Cloud (VPC)
A VPC is a group of resources comparable to a LAN. Resources cannot communicate directly with resources in another VPC, to do that [peering connections](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html) would be used.
This sample project does not create a VPC, a default will be created but not managed by Terraform.

### Security Groups (SG)
SGs restrict inbound and outbound data connections much like a typical firewall.

### Elastic Cloud Compute (EC2)
[EC2s](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html) are a form of virtual machine (VM).

With an EC2 the developer can choose how much RAM, CPU, and HDD resources. When increasing these resources, Terraform automatically manages the changes and only rebuilds the EC2 if a major change requires it to be done.

### Simple Storage Service (S3)
[S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) is a virtual storage with extremely large capacity. S3s are global resources that are not associated with any one region but are available in all regions.

A common problem with S3 is failing to secure them from public access. Read [Blocking public access to your Amazon S3 storage](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html) before using.

### Identity and Access Management (IAM)
[IAMs](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-access-management.html) are user accounts with access to view and change AWS resources. Using IAM access can be compartmentalized for different access.

Through the use of groups, roles, and policies, great detail of control to access can be managed.

### Relational Database Service (RDS)
An [RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html) is a typical SQL Database.

RDS is only supported in [localStack](https://docs.localstack.cloud/references/coverage/coverage_rds/) when using the Pro version.

This example uses [DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html) which is not an RDS because it is a NoSQL, but it is supported by localStack in the free version.

## Initialize Terraform

[awslocal](https://docs.localstack.cloud/user-guide/integrations/aws-cli/#localstack-aws-cli-awslocal)

The localStack service assumes the region to be ``us-east-1``. Terraform code must use the region setting of ``us-east-1``.

```bash
tflocal init
```

## Set Variables
By passing the credentials on the command line as environment variables, they are not saved to a file in the project but they could be shown on screen and anyone with access to the current shell can read the values.

```bash
export TF_VAR_access_key=$(awslocal configure get aws_access_key_id)
export TF_VAR_secret_key=$(awslocal configure get aws_secret_access_key)
```


## Validate
Validate checks for any missing variables or syntax errors.
```bash
tflocal validate
```

## Plan
Plan show what is about to be changed.
To explain what it is going to do.
```bash
tflocal plan
```

## Apply
Apply first runs ``plan``, and prompts the user to type **yes** before proceeding.

The auto approve will cause the **apply** to run without prompting the user to type **yes**.
```bash
tflocal apply -auto-approve
```

## State List
Use **state list** to show a list of all resources that the state knows to be running. This information comes from the state file.
```bash
tflocal state list
```

If resources are changed in [Console](https://docs.aws.amazon.com/awsconsolehelpdocs/latest/gsg/what-is.html) those changes are not reflected in the state file.
See [state pull](https://developer.hashicorp.com/terraform/cli/commands/state/pull)

## State Show
Show Terraform details about the running resource. Teams of developers should not use the local state but rather share the state on a common S3.
```bash
tflocal state show module.instance.aws_instance.linux
```

Show AWS details about the running resource
```bash
awslocal ec2 describe-instances | jq
```

## Testing
Check the running services.
```bash
localstack status services -f json | jq '[. | to_entries[] | select(.value == "running") | {(.key) : (.value)}] | add'

# Or
curl -XGET http://localhost:4566/_localstack/health | jq
```

```json
{
  "ec2": "running",
  "iam": "running",
  "kms": "running",
  "s3": "running",
  "secretsmanager": "running",
  "sts": "running"
}
```

Set some values in DynamoDB
```bash
awslocal dynamodb put-item --table-name Music --item \
        '{"TrackId": {"S": "1"}, "Artist": {"S": "No One You Know"}, "SongTitle": {"S": "Call Me Today"}, "AlbumTitle": {"S": "Somewhat Famous"}, "Awards": {"N": "1"}}'

awslocal dynamodb put-item --table-name Music --item \
        '{"TrackId": {"S": "2"}, "Artist": {"S": "No One You Know"}, "SongTitle": {"S": "Howdy"}, "AlbumTitle": {"S": "Somewhat Famous"}, "Awards": {"N": "2"}}'

awslocal dynamodb put-item --table-name Music --item \
        '{"TrackId": {"S": "3"}, "Artist": {"S": "Acme Band"}, "SongTitle": {"S": "Happy Day"}, "AlbumTitle": {"S": "Songs About Life"}, "Awards": {"N": "10"}}'

awslocal dynamodb put-item --table-name Music --item \
        '{"TrackId": {"S": "4"}, "Artist": {"S": "Acme Band"}, "SongTitle": {"S": "PartiQL Rocks"}, "AlbumTitle": {"S": "Another Album Title"}, "Awards": {"N": "8"}}'

awslocal dynamodb scan --table-name Music | jq
```