
resource "aws_security_group" "redis_sg" {
  name        = "${var.environment}-redis-sg"
  description = "Security Group for the Redis Cluster"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.environment}-redis-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Inbound Rule: Redis (6379) from the Web Tier Security Group
resource "aws_security_group_rule" "ingress_redis_web" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = var.web_security_group_id
  security_group_id        = aws_security_group.redis_sg.id
  description              = "Allow Redis from Web Tier"
}
