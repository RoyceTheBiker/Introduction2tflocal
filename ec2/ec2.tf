resource "aws_instance" "linux" {
	ami                         = "ami-0b301ce3ce347599c"
	associate_public_ip_address = true
	depends_on 									= [ var.roles	]
	disable_api_termination     = false
	iam_instance_profile				= "S3_Access"
	instance_type               = "t2.micro"
	monitoring                  = false
	private_ip                  = "10.1.2.3"
	source_dest_check           = true

	root_block_device {
		volume_type           = "gp2"
		volume_size           = "10"
		delete_on_termination = false
		tags 									= { }
	}

	tags = {
		"Name"	= "hostname"
	}
}
