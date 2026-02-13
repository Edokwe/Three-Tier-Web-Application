
# ---------------------------------------------------------------------------------------------------------------------
# RDS PostgreSQL Instance
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_instance" "main" {
  identifier = "${var.environment}-app-db"

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class
  
  db_name  = var.db_name
  username = var.master_username
  password = random_password.db_password.result # From secrets.tf

  port = 5432

  # Subnets and Security
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az               = var.multi_az
  
  # Storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # Backup
  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = var.skip_final_snapshot # Set to false in prod
  final_snapshot_identifier = "${var.environment}-app-db-final-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  
  # Maintenance
  auto_minor_version_upgrade  = true
  maintenance_window          = "Sun:04:00-Sun:05:00"
  apply_immediately           = false
  deletion_protection         = var.deletion_protection

  # Parameters
  parameter_group_name = aws_db_parameter_group.default.name
  
  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled    = true
  performance_insights_retention_period = 7 # Free tier eligible

  tags = {
    Name        = "${var.environment}-app-db"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Role for Enhanced Monitoring
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "rds_monitoring" {
  name = "${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
