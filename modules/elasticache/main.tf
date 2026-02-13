
# ---------------------------------------------------------------------------------------------------------------------
# Subnet Group
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_elasticache_subnet_group" "default" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = var.subnet_ids
  description = "Subnet group for ${var.environment} Redis"

  tags = {
    Name        = "${var.environment}-redis-subnet-group"
    Environment = var.environment
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Parameter Group (Optional Customizations)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_elasticache_parameter_group" "default" {
  name   = "${var.environment}-redis-params"
  family = "redis7"
  description = "Custom parameter group for ${var.environment} Redis"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "timeout"
    value = "300"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Redis Replication Group (Cluster Mode Disabled)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_elasticache_replication_group" "default" {
  replication_group_id = "${var.environment}-redis-group"
  description          = "Redis replication group for ${var.environment}"
  
  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = 6379
  
  # High Availability Settings
  num_cache_clusters          = var.num_cache_nodes # e.g. 2 for 1 Primary + 1 Replica
  automatic_failover_enabled  = var.automatic_failover_enabled
  multi_az_enabled            = var.multi_az_enabled
  
  subnet_group_name    = aws_elasticache_subnet_group.default.name
  security_group_ids   = [aws_security_group.redis_sg.id]
  parameter_group_name = aws_elasticache_parameter_group.default.name
  
  # Encryption & Security
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = random_password.redis_auth_token.result
  
  # Maintenance & Backup
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = "02:00-03:00"
  maintenance_window       = "sun:05:00-sun:06:00"
  auto_minor_version_upgrade = true
  
  apply_immediately = false

  tags = {
    Name        = "${var.environment}-redis"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
