
resource "aws_security_group" "db_sg" {
  name        = "${var.environment}-db-sg"
  description = "Security Group for the RDS PostgreSQL database"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Inbound Rule: PostgreSQL (5432) from the Web Tier Security Group
resource "aws_security_group_rule" "ingress_postgres_web" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.web_security_group_id
  security_group_id        = aws_security_group.db_sg.id
  description              = "Allow PostgreSQL from Web Tier"
}

# Add outbound rule to allow traffic if needed (e.g., for updates/metrics if public, though typically restricted)
# For now, locking it down is best practice unless outbound access is required (e.g., to S3 for specialized plugins).
# We won't add outbound rules by default to enforce security unless requested.

