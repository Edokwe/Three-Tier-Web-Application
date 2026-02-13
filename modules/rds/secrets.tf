
# ---------------------------------------------------------------------------------------------------------------------
# Database Password Generation
# ---------------------------------------------------------------------------------------------------------------------

resource "random_password" "db_password" {
  length  = 32
  special = false
}

# ---------------------------------------------------------------------------------------------------------------------
# Secrets Manager Secret
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.environment}/db/credentials"
  description = "Credentials for ${var.environment} RDS PostgreSQL database"

  recovery_window_in_days = 0 
  # Set to 0 for immediate deletion during dev/test cycles. In prod, default is typically 30.

  tags = {
    Name        = "${var.environment}-db-credentials"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = var.db_name
  })
}
