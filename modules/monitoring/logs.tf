
# ---------------------------------------------------------------------------------------------------------------------
# Application Logs
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/ec2/${var.environment}/application"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# System Logs
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/aws/ec2/${var.environment}/system"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
