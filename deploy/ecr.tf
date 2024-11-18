locals {
  default_ecr_lifecycle_policy = <<-EOT
    {
        "rules": [
            {
                "rulePriority": 1,
                "description": "Expire untagged images older than 7 days",
                "selection": {
                    "tagStatus": "untagged",
                    "countType": "sinceImagePushed",
                    "countUnit": "days",
                    "countNumber": 7
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    }
  EOT
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy = local.default_ecr_lifecycle_policy
}

resource "aws_ecr_repository" "app" {
  name                 = provider::slugify::slug("${local.application_name}-${var.environment}")
  image_tag_mutability = "MUTABLE"
  tags = {
    Name        = provider::slugify::slug("${local.application_name}-${var.environment}")
    Environment = var.environment
  }
}

resource "aws_ecr_lifecycle_policy" "pgpool" {
  repository = aws_ecr_repository.pgpool.name
  policy = local.default_ecr_lifecycle_policy
}

resource "aws_ecr_repository" "pgpool" {
  name                 = "bitnami/pgpool"
  image_tag_mutability = "MUTABLE"
  tags = {
    Name        = "pgpool"
    Environment = var.environment
  }
}
