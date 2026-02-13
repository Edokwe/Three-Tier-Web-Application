output "db_instance_endpoint" {
  description = "The connection endpoint for the database"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.main.port
}

output "db_instance_identifier" {
  description = "The RDS instance identifier"
  value       = aws_db_instance.main.identifier
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_security_group_id" {
  description = "The security group ID of the database"
  value       = aws_security_group.db_sg.id
}

output "db_secret_manager_name" {
  description = "The name of the Secret in Secrets Manager"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "db_secret_manager_arn" {
  description = "The ARN of the Secret in Secrets Manager"
  value       = aws_secretsmanager_secret.db_credentials.arn
}
