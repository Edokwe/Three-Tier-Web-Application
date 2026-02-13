# ---------------------------------------------------------------------------------------------------------------------
# ALB Access Logs S3 Bucket
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "lb_logs" {
  bucket = "${var.environment}-${var.project_name}-alb-logs-${random_id.bucket_suffix.hex}"
  force_destroy = true # For demo purposes
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lb_logs_encryption" {
  bucket = aws_s3_bucket.lb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lb_logs_lifecycle" {
  bucket = aws_s3_bucket.lb_logs.id

  rule {
    id     = "retention"
    status = "Enabled"

    expiration {
      days = 7
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Bucket Policy for ALB Access
# ---------------------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "lb_logs_policy" {
  bucket = aws_s3_bucket.lb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.lb_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })
}
