output "vpn_eip" {
  value = "${aws_instance.vpn.public_ip}"
}

output "security_group_id" {
  value = "${aws_security_group.vpn_security_group.id}"
}
