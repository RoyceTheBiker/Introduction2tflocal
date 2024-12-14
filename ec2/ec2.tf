data "http" "myip" {
	url = "http://ipv4.icanhazip.com"
}

data "aws_caller_identity" "current" {}

resource "aws_key_pair" "ssh-key" {
	key_name	= pathexpand("${var.ssh_keys["private_key"]}")
	public_key	= file(pathexpand("${var.ssh_keys["public_key"]}"))
}

resource "aws_instance" "linux" {
	ami                         = var.machine_image[var.instances[count.index].distro].ami
	associate_public_ip_address = length(var.vpc) > 0 ? false : true
	# Can't set AZ and subnets if using ELB
	# availability_zone           = var.AvailabilityZones[0].ZoneName
	count 											= length(var.instances)
	depends_on 									= [ var.rds_endpoints	]
	disable_api_termination     = false
	# ebs_optimized               =
	iam_instance_profile				= length(var.s3) > 0 ? "S3_Access" : null
	# ipv6_address_count					= 1 # Subnet does not contain any IPv6 CIDR block ranges yes
	instance_type               = var.instances[count.index].instance_type
	key_name                    = aws_key_pair.ssh-key.key_name
	monitoring                  = false
	# private_ip                  =
	subnet_id                   = length(var.vpc) > 0 ? contains(var.instances[count.index].security_groups, "web-server") ? var.vpc_resources.elb_subnet.id : var.vpc_resources.prod_subnet.id : null
	#subnet_id                   = contains(var.instances[count.index].security_groups, "web-server") ? var.vpc_resources.elb_subnet.id : var.vpc_resources.prod_subnet.id
	vpc_security_group_ids			= [ for sg in var.instances[count.index].security_groups: var.sgs[sg] ]
	source_dest_check           = true

	root_block_device {
		volume_type           = "gp2"
		volume_size           = var.instances[count.index].volume_size
		delete_on_termination = false
		tags 									= { }
	}

	tags = {
		"Name"	= var.instances[count.index].hostname
	}

	# This will enable SSH connections only from your current IP address so it's not exposed to the world.
	#provisioner "local-exec" {
	#	command = "aws ec2 authorize-security-group-ingress --group-id ${var.sgs["ssh-admin"]} --cidr \"${chomp(data.http.myip.body)}/32\" --protocol tcp --port 22 ||:"
	#}

	# provisioner "file" {
	# 	source      = var.payload_dir
	# 	destination = "/home/alpine/payload"

	# 	connection {
	# 		type        = "ssh"
	# 		host        = self.public_ip
	# 		user        = var.instance-username
	# 		private_key	= file(var.ssh_keys.private_key)
	# 	}
	# }

	connection {
		type        = "ssh"
		host        = length(var.vpc) > 0 ? self.private_ip : self.public_ip
		user        = var.machine_image[var.instances[count.index].distro].username
		private_key	= file(var.ssh_keys.private_key)
		script_path = "/home/${var.machine_image[var.instances[count.index].distro].username}/tmpSetup.sh"
	}

	provisioner "file" {
		source      = "./setup"
		destination = "/home/${var.machine_image[var.instances[count.index].distro].username}/"
	}

	provisioner "file" {
		source      = var.nova_file
		destination = "/home/${var.machine_image[var.instances[count.index].distro].username}/setup/nova.json"
	}

	provisioner "file" {
		content 		= jsonencode(
			{
				"rds": 		[ var.rds_endpoints],
				"owner": 	[ data.aws_caller_identity.current ],
				"vpc":		length(var.vpc) > 0 ? [ var.vpc ] : []
			})
		destination	= "/home/${var.machine_image[var.instances[count.index].distro].username}/setup/environment.json"
	}

	# Pass Terraform variables to Setup.sh where it uses sed to configure services.
	provisioner "remote-exec" {
		inline = [
			"cd /home/${var.machine_image[var.instances[count.index].distro].username}/setup/",
			"sudo /bin/sh ./Setup.sh ${var.instances[count.index].hostname}"
		]
	}

	# This will disable SSH connections after the instance is built if SSH to the instance is not needed.
	# provisioner "local-exec" {
	# 	command = "aws ec2 revoke-security-group-ingress --group-id ${var.sgs["ssh-server"]} --cidr \"${chomp(data.http.myip.body)}/32\" --protocol tcp --port 22"
	#}
}

output "host_ips" {
	value = [ for hip in aws_instance.linux[*]:
			{
				hostname		= hip.tags["Name"]
				private_ip	= hip.private_ip
				public_ip		= hip.public_ip
			}
	]
}

output "aws_instances" {
	value = aws_instance.linux[*]
}