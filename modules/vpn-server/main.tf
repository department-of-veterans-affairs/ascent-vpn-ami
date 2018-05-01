# ---------------------------------------------------------------------------------------------------------------------
# THESE TEMPLATES REQUIRE TERRAFORM VERSION 0.8 AND ABOVE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.9.3"
}

resource "aws_eip_association" "eip_address" {
  instance_id   = "${aws_instance.vpn.id}"
  allocation_id = "${var.eip_address}"
}
# ---------------------------------------------------------------------------------------------------------------------
# Create the VPN instance
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "vpn" {
  instance_type               = "${var.instance_type}"
  ami                         = "${var.ami_id}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${var.subnet_ids[length(var.subnet_ids) - 1]}"
  vpc_security_group_ids      = ["${aws_security_group.vpn_security_group.id}"]
  user_data                   = "${var.user_data == "" ? data.template_file.vpn_user_data.rendered : var.user_data}"
  tags {
      Name = "${var.instance_name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Control Traffic to Fortify instances
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "vpn_security_group" {
  name_prefix = "${var.instance_name}"
  description = "Security group for the ${var.instance_name} instances"
  vpc_id      = "${var.vpc_id}"
  tags {
    Name = "${var.instance_name}"
  }
}

module "security_group_rules" {
  source = "../vpn-security-group-rules"

  security_group_id                  = "${aws_security_group.vpn_security_group.id}"
  allowed_inbound_cidr_blocks        = ["${var.allowed_inbound_cidr_blocks}"]
  allowed_inbound_security_group_ids = ["${var.allowed_inbound_security_group_ids}"]
  allowed_ssh_cidr_blocks            = ["${var.allowed_ssh_cidr_blocks}"]
  vpn_udp_port                       = "${var.vpn_udp_port}"
}


# ---------------------------------------------------------------------------------------------------------------------
# Default User Data script
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "vpn_user_data" {
 template = "${file("${path.module}/vpn-user-data.sh")}"

  vars {
    master_dns_ip             = "${var.master_dns_ip}"
    slave_dns_ip              = "${var.slave_dns_ip}"
    vpc_cidr                  = "${var.vpc_cidr}"
  }
}

