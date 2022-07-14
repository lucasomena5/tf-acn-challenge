############################################# TERRAFORM #############################################
resource "aws_security_group" "sg_app" {
  name        = join("-", [var.prefix, "security", "group", format("%02d", var.number_of_sequence)])
  description = join(" ", [var.prefix, "security", "group", lower(var.environment)])
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  ingress {
    description     = "Allow Application SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_lb.id]
  }

  tags = {
    "Name" = join("-", [var.prefix, "security", "group", var.environment, format("%02d", var.number_of_sequence)]),
  }
}

// SECURITY GROUP RULES
resource "aws_security_group_rule" "app_egress_rule" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_app.id
}

// INGRESS ICMP RULES
resource "aws_security_group_rule" "icmp" {
  type              = "ingress"
  description       = "Allow ICMP protocol"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.sg_app.id
}
