# ---------------------------------------------------------------------------------------------------------------------
# Option 1: ACM Certificate (recommended)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_acm_certificate" "cert" {
  count = var.domain_name != "" && !var.create_self_signed_cert ? 1 : 0

  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.environment}-acm-cert"
    Environment = var.environment
  }
}

# DNS Validation (if Route53 Zone ID provided)
resource "aws_route53_record" "cert_validation" {
  for_each = var.domain_name != "" && var.route53_zone_id != "" && !var.create_self_signed_cert ? {
    for dvo in aws_acm_certificate.cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  count = var.domain_name != "" && var.route53_zone_id != "" && !var.create_self_signed_cert ? 1 : 0

  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# ---------------------------------------------------------------------------------------------------------------------
# Option 2: Self-signed certificate (for testing)
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "self_signed" {
  count = var.create_self_signed_cert ? 1 : 0
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "self_signed" {
  count = var.create_self_signed_cert ? 1 : 0
  
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.self_signed[0].private_key_pem

  subject {
    common_name  = var.domain_name != "" ? var.domain_name : "example.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 720 # 30 days

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "self_signed" {
  count = var.create_self_signed_cert ? 1 : 0

  private_key      = tls_private_key.self_signed[0].private_key_pem
  certificate_body = tls_self_signed_cert.self_signed[0].cert_pem
  
  tags = {
    Name        = "${var.environment}-self-signed-cert"
    Environment = var.environment
  }
}
