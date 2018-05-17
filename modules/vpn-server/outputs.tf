output "vpn_eip" {
  value = "${aws_instance.vpn.public_ip}"
}

output "security_group_id" {
  value = "${aws_security_group.vpn_security_group.id}"
}

output "vpn_udp_port" {
  value = "${module.security_group_rules.vpn_udp_port}"
}

output "vpn_client_subnet" {
  value = "${var.vpn_client_subnet}"
}
