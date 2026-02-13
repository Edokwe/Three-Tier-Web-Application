resource "aws_security_group" "web_sg" {
  name        = "${var.environment}-web-sg"
  description = "Security group for web tier instances"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.environment}-web-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Inbound: Allow HTTP from ALB
resource "aws_security_group_rule" "ingress_http_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = var.alb_security_group_id
  security_group_id        = aws_security_group.web_sg.id
  description              = "Allow HTTP from ALB"
}

# Inbound: Allow ICMP from VPC
resource "aws_security_group_rule" "ingress_icmp_vpc" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["10.0.0.0/16"] # Should ideally be var.vpc_cidr_block if available
  security_group_id = aws_security_group.web_sg.id
  description       = "Allow ICMP from VPC"
}

# Outbound: HTTPS to anywhere (for updates, APIs)
resource "aws_security_group_rule" "egress_https_all" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
  description       = "Allow HTTPS outbound"
}

# Outbound: PostgreSQL (Data Tier) - Placeholder
resource "aws_security_group_rule" "egress_postgres" {
  count = var.data_security_group_id != "" ? 1 : 0

  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.data_security_group_id
  security_group_id        = aws_security_group.web_sg.id
  description              = "Allow PostgreSQL to data tier"
}

# Outbound: Redis (Data Tier) - Placeholder
resource "aws_security_group_rule" "egress_redis" {
  count = var.data_security_group_id != "" ? 1 : 0

  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = var.data_security_group_id
  security_group_id        = aws_security_group.web_sg.id
  description              = "Allow Redis to data tier"
}
