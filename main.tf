provider "aws" {
	region		= var.site.region
	access_key	= var.access_key
	secret_key	= var.secret_key
}

module "default_vpc" {
	source						= "./vpc"
	#AvailabilityZones	= var.AvailabilityZones
	site							= var.site
}

module "instance" {
	source        		= "./ec2"
	AvailabilityZones	= var.AvailabilityZones
	default_vpc				= module.default_vpc.default_vpc
	home_dir					= var.home_dir
	instances					= var.instances
	nova_file					= var.nova_file
	rds_endpoints 		= module.rds.rds_endpoints
	roles							= module.s3.roles
	s3  							= var.s3
	sgs								= module.security.sgs
	site							= var.site
	ssh_keys					= var.ssh_keys
	vpc								= var.vpc
	vpc_resources			= module.vpc.vpc_resources
}

module "rds" {
	source						= "./rds"
	AvailabilityZones	= var.AvailabilityZones
	default_vpc				= length(var.vpc) > 0 ? null : module.default_vpc[0].default_vpc
	rds								= var.rds
	site							= var.site
	sgs								= module.security.sgs
	vpc								= var.vpc
	vpc_resources			= length(var.vpc) > 0 ? module.vpc[0].vpc_resources : null
}

module "s3" {
	source 				= "./s3"
	#bucket_name 	= length(var.s3) > 0 ? module.s3[0].bucket_name : []
}

module "security" {
	source 				= "./sg"
	default_vpc		= length(var.vpc) > 0 ? null : module.default_vpc[0].default_vpc
	site					= var.site
	vpc						= length(var.s3) > 0 ? var.vpc : []
	vpc_resources	= length(var.vpc) > 0 ? module.vpc[0].vpc_resources : null
}

# output "public_ip" {
# 	value = [ aws_instance.linux["${count.index}"].public_ip ]
# }
