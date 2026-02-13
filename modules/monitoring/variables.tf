variable "environment" {
  description = "The environment name"
  type        = string
}

variable "project_name" {
  description = "The project name"
  type        = string
  default     = "web-app"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

# ALB Variables
variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
  default     = ""
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
  default     = ""
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
  default     = ""
}

# ASG Variables
variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
  default     = ""
}

# RDS Variables
variable "rds_db_identifier" {
  description = "RDS DB Instance Identifier"
  type        = string
  default     = ""
}

# Redis Variables
variable "redis_replication_group_id" {
  description = "Redis Replication Group ID"
  type        = string
  default     = ""
}

# Alerting
variable "alert_emails" {
  description = "List of email addresses for critical alerts"
  type        = list(string)
  default     = []
}

variable "alarm_prefix" {
  description = "Prefix for alarm names"
  type        = string
  default     = "monitoring"
}

variable "log_retention_days" {
  description = "Retention period for CloudWatch Logs"
  type        = number
  default     = 7
}
