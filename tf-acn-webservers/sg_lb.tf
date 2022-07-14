############################################# TERRAFORM #############################################
resource "aws_security_group" "sg_lb" {
  name        = join("-", ["lb", "security", "group", format("%02d", var.number_of_sequence)])
  description = join(" ", ["lb", "security", "group", lower(var.environment)])
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.lb_allowed_ports
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  tags = {
    "Name" = join("-", ["lb", "security", "group", var.environment, format("%02d", var.number_of_sequence)]),
  }
}

// SECURITY GROUP RULES
resource "aws_security_group_rule" "lb_egress_rule" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_lb.id
}
