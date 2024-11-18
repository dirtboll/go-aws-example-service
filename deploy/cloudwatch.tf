resource "aws_cloudwatch_log_group" "app" {
  name = "/ecs/${provider::slugify::slug("${local.application_name}-${var.environment}")}"
  retention_in_days = 7
  tags = {
    Environment = var.environment
  }
}