###############################################################################
#
# Create Security group for Vpn services
#
###############################################################################

resource "aws_security_group_rule" "allow_vpn_web_inbound" {
  count        = "${length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0}"
  type         = "ingress"
  from_port    = "${var.vpn_udp_port}"
  to_port      = "${var.vpn_udp_port}"
  protocol     = "udp"
  cidr_blocks  = ["${var.allowed_inbound_cidr_blocks}"]
  security_group_id = "${var.security_group_id}"
}

resource "aws_security_group_rule" "allow_vpn_udp_inbound_from_security_group_ids" {
  count                      = "${length(var.allowed_inbound_security_group_ids)}"
  type                       = "ingress"
  from_port                  = "${var.vpn_udp_port}"
  to_port                    = "${var.vpn_udp_port}"
  protocol                   = "udp"
  source_security_group_id   = "${element(var.allowed_inbound_security_group_ids, count.index)}"
  security_group_id          = "${var.security_group_id}"
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  count       = "${length(var.allowed_ssh_cidr_blocks) >= 1 ? 1 : 0}"
  type        = "ingress"
  from_port   = "${var.ssh_port}"
  to_port     = "${var.ssh_port}"
  protocol    = "tcp"
  cidr_blocks = ["${var.allowed_ssh_cidr_blocks}"]

  security_group_id = "${var.security_group_id}"

}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${var.security_group_id}"

}
