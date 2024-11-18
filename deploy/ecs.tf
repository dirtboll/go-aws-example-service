resource "aws_ecs_cluster" "main" {
  name = provider::slugify::slug("${local.application_name}-${var.environment}")
}

resource "aws_ecs_capacity_provider" "main" {
  name = provider::slugify::slug("${local.application_name}-${var.environment}-ec2")

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.main.arn
    managed_termination_protection = "DISABLED"
    managed_scaling {
      maximum_scaling_step_size = 3
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [ 
    aws_ecs_capacity_provider.main.name 
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = 1
    weight            = 100
  }
}
