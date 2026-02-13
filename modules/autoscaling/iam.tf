
# ---------------------------------------------------------------------------------------------------------------------
# IAM Role for Web Tier
# ---------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "web_role" {
  name               = "${var.environment}-web-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "${var.environment}-web-instance-role"
    Environment = var.environment
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Managed Policies
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.web_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.web_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# ---------------------------------------------------------------------------------------------------------------------
# Custom Inline Policy (App Specific Access)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "app_access" {
  name = "${var.environment}-web-app-policy"
  role = aws_iam_role.web_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = "*" # Restrict to specific app bucket in production
      },
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Effect   = "Allow"
        Resource = "*" # Restrict to specific secrets/params in production
      }
    ]
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# Instance Profile
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_instance_profile" "web_profile" {
  name = "${var.environment}-web-instance-profile"
  role = aws_iam_role.web_role.name
}
