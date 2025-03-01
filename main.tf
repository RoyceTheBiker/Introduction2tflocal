provider "aws" {
	region		= "us-east-1"
	access_key	= var.access_key
	secret_key	= var.secret_key
}

# It is not required to make a VPC. AWS will provide a default VPC.
# module "default_vpc" {
# 	source						= "./vpc"
# 	site							= var.site
# }

module "instance" {
	source        		= "./ec2"
	roles             = module.s3.roles
}

module "rds" {
	source						= "./rds"
}

module "s3" {
	source 				= "./s3"
}

# module "security" {
# 	source 				= "./sg"
# }

