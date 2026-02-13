variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "The project name"
  type        = string
  default     = "web-app"
}

variable "plan_name" {
  description = "The name of the AWS Backup plan"
  type        = string
  default     = "daily-backup-plan"
}

variable "schedule" {
  description = "Backup schedule CRON expression (e.g. cron(0 5 * * ? *) for daily at 5 AM UTC)"
  type        = string
  default     = "cron(0 5 * * ? *)"
}

variable "retention_days" {
  description = "The number of days to retain backups"
  type        = number
  default     = 7
}

variable "enable_selection_by_tags" {
  description = "Whether to backup resources tagged with BackupEnabled=true"
  type        = bool
  default     = true
}

variable "resource_arns" {
  description = "List of specific resource ARNs to backup (optional)"
  type        = list(string)
  default     = []
}
