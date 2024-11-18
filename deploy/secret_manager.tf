resource "aws_secretsmanager_secret" "app" {
  name = provider::slugify::slug("${local.application_name}-${var.environment}")
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    PGPOOL_BACKEND_NODES     = "0:${aws_db_instance.main.endpoint},1:${aws_db_instance.main_replica.endpoint}"
    PGPOOL_SR_CHECK_USER     = aws_db_instance.main.username
    PGPOOL_SR_CHECK_PASSWORD = aws_db_instance.main.password
    PGPOOL_POSTGRES_USERNAME = aws_db_instance.main.username
    PGPOOL_POSTGRES_PASSWORD = aws_db_instance.main.password
    PGPOOL_ADMIN_USERNAME    = aws_db_instance.main.username
    PGPOOL_ADMIN_PASSWORD    = aws_db_instance.main.password
    DATABASE_URL             = "postgres://${aws_db_instance.main.username}:${aws_db_instance.main.password}@localhost:5432/${aws_db_instance.main.db_name}?sslmode=disable&pool_max_conns=1000000"
    GOOSE_DBSTRING           = "postgres://${aws_db_instance.main.username}:${aws_db_instance.main.password}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
  })
}
