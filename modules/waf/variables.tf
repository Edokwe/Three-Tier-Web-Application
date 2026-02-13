variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "The project name"
  type        = string
  default     = "web-app"
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer to associate the WAF with"
  type        = string
}

variable "enabled" {
  description = "Whether to create the WAF resources"
  type        = bool
  default     = true
}

variable "metric_name" {
  description = "The name of the CloudWatch metric for the WAF"
  type        = string
  default     = "WebApplicationFirewall"
}

variable "log_retention_days" {
  description = "Number of days to retain WAF logs in CloudWatch"
  type        = number
  default     = 7
}
