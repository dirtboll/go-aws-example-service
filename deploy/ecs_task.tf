resource "aws_ecs_task_definition" "app" {
  family             = provider::slugify::slug("${local.application_name}-${var.environment}")
  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.ecs_task.arn
  network_mode       = "awsvpc"
  cpu                = 512
  memory             = 512


  container_definitions = jsonencode([
    {
      name      = local.application_name,
      image     = "${aws_ecr_repository.app.repository_url}:${var.app_image_tag}"
      essential = true,
      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080
        }
      ],

      secrets = [
        {
          "valueFrom" = "${aws_secretsmanager_secret.app.arn}:DATABASE_URL::",
          "name" = "DATABASE_URL"
        },
      ]

      dependsOn = [
        {
          containerName = "pgpool",
          condition     = "HEALTHY"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-region"        = data.aws_region.current.name,
          "awslogs-group"         = aws_cloudwatch_log_group.app.name,
          "awslogs-stream-prefix" = provider::slugify::slug("${local.application_name}-${var.environment}")
        }
      },
      }, {
      name      = "pgpool",
      image     = "${aws_ecr_repository.pgpool.repository_url}:${var.pgpool_image_tag}"
      essential = true,
      portMappings = [
        {
          containerPort = 5432
        }
      ],

      healthCheck = {
        command  = ["CMD", "/opt/bitnami/scripts/pgpool/healthcheck.sh"]
        interval = 5
        timeout  = 2
        retries  = 3
      }

      environment = [
        { name = "PGPOOL_ENABLE_LDAP", value = "no" }
      ]

      secrets = [
        {
          "valueFrom" = "${aws_secretsmanager_secret.app.arn}:PGPOOL_BACKEND_NODES::",
          "name" = "PGPOOL_BACKEND_NODES"
        },
        {
          "valueFrom" = "${aws_secretsmanager_secret.app.arn}:PGPOOL_SR_CHECK_USER::",
          "name" = "PGPOOL_SR_CHECK_USER"
        },
        {
          "valueFrom" = "${aws_secretsmanager_secret.app.arn}:PGPOOL_SR_CHECK_PASSWORD::",
          "name" = "PGPOOL_SR_CHECK_PASSWORD"
        },
        {
          "valueFrom" = "${aws_secretsmanager_secret.app.arn}:PGPOOL_POSTGRES_USERNAME::",
          "name" = "PGPOOL_POSTGRES_USERNAME"
        },
        {
          "valueFrom" = "${aws_secretsmanager_secret.app.arn}:PGPOOL_POSTGRES_PASSWORD::",
          "name" = "PGPOOL_POSTGRES_PASSWORD"
        },
        {
          "valueFrom" = "${aws_secretsmanager_secret.app.arn}:PGPOOL_ADMIN_USERNAME::",
          "name" = "PGPOOL_ADMIN_USERNAME"
        },
        {
          "valueFrom" = "${aws_secretsmanager_secret.app.arn}:PGPOOL_ADMIN_PASSWORD::",
          "name" = "PGPOOL_ADMIN_PASSWORD"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-region"        = data.aws_region.current.name,
          "awslogs-group"         = aws_cloudwatch_log_group.app.name,
          "awslogs-stream-prefix" = provider::slugify::slug("${local.application_name}-${var.environment}-pgpool")
        }
      },
    }
  ])
}


resource "aws_ecs_service" "app" {
  name            = provider::slugify::slug("${local.application_name}-${var.environment}")
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 0

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = local.application_name
    container_port   = 8080
  }

  network_configuration {
    security_groups = [aws_security_group.main.id]
    subnets         = aws_subnet.main_private[*].id
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = 1
    weight            = 100
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
