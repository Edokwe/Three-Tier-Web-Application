
# ---------------------------------------------------------------------------------------------------------------------
# AWS Backup Vault
# ---------------------------------------------------------------------------------------------------------------------

# Create KMS Key for Vault Encryption
resource "aws_kms_key" "backup" {
  description             = "KMS Key for ${var.environment} AWS Backup Vault"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "${var.environment}-backup-key"
    Environment = var.environment
  }
}

resource "aws_backup_vault" "default" {
  name        = "${var.environment}-backup-vault"
  kms_key_arn = aws_kms_key.backup.arn

  tags = {
    Name        = "${var.environment}-backup-vault"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS Backup Plan
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_backup_plan" "default" {
  name = "${var.environment}-${var.plan_name}"

  # Daily (or Weekly) Backup Rule
  rule {
    rule_name         = "scheduled-backup"
    target_vault_name = aws_backup_vault.default.name
    schedule          = var.schedule
    start_window      = 60     # Start within 1 hour
    completion_window = 180    # Complete within 3 hours

    lifecycle {
      delete_after = var.retention_days
      # Optionally transition to cold storage after X days
    }
  }
  
  tags = {
    Name        = "${var.environment}-backup-plan"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Backup Selection
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_backup_selection" "default" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "${var.environment}-backup-selection"
  plan_id      = aws_backup_plan.default.id

  # Selection by Tag (BackupEnabled = true)
  dynamic "selection_tag" {
    for_each = var.enable_selection_by_tags ? [1] : []
    content {
      type  = "STRINGEQUALS"
      key   = "BackupEnabled"
      value = "true"
    }
  }

  # Selection by Resource ARN (if provided)
  resources = var.resource_arns
}
