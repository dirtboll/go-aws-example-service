resource "aws_security_group" "rds" {
  name   = provider::slugify::slug("${local.application_name}-${var.environment}-rds")
  vpc_id = aws_vpc.main.id
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    from_port        = "0"
    to_port          = "0"
    protocol         = "-1"
    self             = "false"
  }
  ingress {
    description = "Allow from the same security group"
    self        = true
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  ingress {
    description = "Allow from main security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [
      aws_security_group.main.id
    ]
  }
}
