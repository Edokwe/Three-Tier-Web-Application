output "backup_vault_arn" {
  description = "The ARN of the AWS Backup vault"
  value       = aws_backup_vault.default.arn
}

output "backup_plan_id" {
  description = "The ID of the AWS Backup plan"
  value       = aws_backup_plan.default.id
}

output "backup_plan_version" {
  description = "The version of the AWS Backup plan"
  value       = aws_backup_plan.default.version
}

output "backup_role_arn" {
  description = "The ARN of the IAM role used by AWS Backup"
  value       = aws_iam_role.backup_role.arn
}
