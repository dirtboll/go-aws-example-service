resource "aws_security_group" "main" {
  name   = provider::slugify::slug("${local.application_name}-${var.environment}")
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "main_ingress_self" {
  security_group_id = aws_security_group.main.id
  description       = "Allow from the same security group"
  type              = "ingress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  self              = true
}

resource "aws_security_group_rule" "main_egress" {
  security_group_id = aws_security_group.main.id
  description       = "Allow egress to everything"
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "main_ingress_ssh" {
  security_group_id = aws_security_group.main.id
  description       = "Allow SSH"
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "main_ingress_sg_alb" {
  security_group_id        = aws_security_group.main.id
  description              = "Allow from ALB"
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "main_ingress_sg_rds" {
  security_group_id        = aws_security_group.main.id
  description              = "Allow from RDS"
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  source_security_group_id = aws_security_group.rds.id
}
