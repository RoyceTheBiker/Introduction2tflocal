provider "aws" {
	region		= "us-east-1"
	access_key	= var.access_key
	secret_key	= var.secret_key
}

# module "default_vpc" {
# 	source						= "./vpc"
# 	site							= var.site
# }

module "instance" {
	source        		= "./ec2"
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

