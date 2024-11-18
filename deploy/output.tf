output "app_fqdn" {
  value = var.app_domain
}

output "alb_fqdn" {
  value = aws_lb.main.dns_name
}

output "rds_primary_url" {
  value = aws_db_instance.main.endpoint
}

output "rds_replica_url" {
  value = aws_db_instance.main_replica.endpoint
}

output "certificate_challenge" {
  value = aws_acm_certificate.app.domain_validation_options
}

output "ecr_app" {
  value = aws_ecr_repository.app.repository_url
}

output "ecr_pgpool" {
  value = aws_ecr_repository.pgpool.repository_url
}

output "role_github_ecr" {
  value = aws_iam_role.ecr_push.arn
}

output "role_github_terraform" {
  value = aws_iam_role.terraform.arn
}