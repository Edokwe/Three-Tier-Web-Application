output "redis_primary_endpoint_address" {
  description = "The endpoint of the primary node in the Redis replication group"
  value       = aws_elasticache_replication_group.default.primary_endpoint_address
}

output "redis_port" {
  description = "The Redis port"
  value       = aws_elasticache_replication_group.default.port
}

output "redis_configuration_endpoint_address" {
  description = "The configuration endpoint address to allow host discovery"
  value       = aws_elasticache_replication_group.default.configuration_endpoint_address
}

output "redis_replication_group_id" {
  description = "ID of the Redis Replication Group"
  value       = aws_elasticache_replication_group.default.id
}

output "redis_security_group_id" {
  description = "ID of the Redis Security Group"
  value       = aws_security_group.redis_sg.id
}

output "auth_token_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the Redis Auth Token"
  value       = aws_secretsmanager_secret.redis_auth.arn
}
