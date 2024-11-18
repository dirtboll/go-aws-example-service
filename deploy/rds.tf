resource "random_password" "rds_main" {
  length           = 32
  special          = false
}

resource "aws_db_subnet_group" "main" {
  name       = provider::slugify::slug("${local.application_name}-${var.environment}")
  subnet_ids = aws_subnet.main_private[*].id
}

resource "aws_db_instance" "main" {
  identifier              = provider::slugify::slug("${local.application_name}-${var.environment}")
  allocated_storage       = 5
  engine                  = "postgres"
  engine_version          = "14.14"
  instance_class          = "db.t3.micro"
  db_name                 = local.application_name
  username                = local.application_name
  password                = random_password.rds_main.result
  skip_final_snapshot     = true
  publicly_accessible     = false
  backup_retention_period = 7
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  tags = {
    Name        = provider::slugify::slug("${local.application_name}-${var.environment}")
    Environment = var.environment
  }
}

resource "aws_db_instance" "main_replica" {
  identifier              = provider::slugify::slug("${local.application_name}-${var.environment}-replica")
  instance_class          = "db.t3.micro"
  skip_final_snapshot     = true
  publicly_accessible     = false
  backup_retention_period = 7
  replicate_source_db     = aws_db_instance.main.identifier
  tags = {
    Name        = provider::slugify::slug("${local.application_name}-${var.environment}-replica")
    Environment = var.environment
  }
}
