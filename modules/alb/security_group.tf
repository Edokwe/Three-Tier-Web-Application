resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-alb-sg"
  description = "Security Group for Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Inbound Rule: HTTP (80) from anywhere (for redirect)
resource "aws_security_group_rule" "ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP from anywhere for redirection"
}

# Inbound Rule: HTTPS (443) from anywhere
resource "aws_security_group_rule" "ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTPS from anywhere"
}

# Outbound Rule: HTTP (80) to web tier security group
resource "aws_security_group_rule" "egress_http_web" {
  count = var.web_security_group_id != "" ? 1 : 0

  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = var.web_security_group_id
  security_group_id        = aws_security_group.alb_sg.id
  description              = "Allow HTTP to web tier security group"
}

# For testing/default behavior if no web SG provided, allow egress to anywhere on port 80
resource "aws_security_group_rule" "egress_http_all" {
  count = var.web_security_group_id == "" ? 1 : 0

  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP to anywhere (fallback)"
}
