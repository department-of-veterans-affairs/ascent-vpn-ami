###############################################################################
# REQUIRED VARIABLES
###############################################################################

variable "security_group_id" {
  description = "The ID of the security group to which we should add the VPN security group rules"
}

variable "allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to VPN"
  type        = "list"
}

###############################################################################
# OPTIONAL VARIABLES
###############################################################################

variable "allowed_ssh_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections"
  type        = "list"
  default     = []
}

variable "allowed_inbound_security_group_ids" {
  description = "A list of security group IDs that will be allowed to connect to VPN"
  type        = "list"
  default     = []
}

variable "vpn_udp_port" {
  description = "The port used to connect to VPN."
  default     = 1194
}

variable "ssh_port" {
  description = "The port used to ssh to VPN."
  default     = 22
}
