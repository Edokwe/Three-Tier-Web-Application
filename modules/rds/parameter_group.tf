
resource "aws_db_parameter_group" "default" {
  name        = "${var.environment}-pg-postgres15"
  family      = "postgres15"
  description = "Custom parameter group for ${var.environment}"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }
  
  parameter {
    name  = "log_duration"
    value = "1" # Log slow queries > 1ms (set higher in prod)
  }

  lifecycle {
    create_before_destroy = true
  }
}
