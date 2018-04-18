output "vpn_eip" {
  value = "${var.eip_address}"
}

output "security_group_id" {
  value = "${aws_security_group.vpn_security_group.id}"
}
