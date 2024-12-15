variable "AvailabilityZones" {
	description	= "Availability Zones for the selected region."
	default			= []
}

variable "roles" {
	type = map
}
