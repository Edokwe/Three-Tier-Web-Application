variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "The project name to use for resource naming"
  type        = string
  default     = "web-app"
}

variable "vpc_id" {
  description = "The VPC ID where the ALB will be deployed"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
  default     = false # Default to false for easy destruction in dev, override in prod
}

variable "internal" {
  description = "Whether the ALB is internal or internet-facing"
  type        = bool
  default     = false
}

variable "target_group_port" {
  description = "The port for the target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "The protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "The path for the health check"
  type        = string
  default     = "/health"
}

variable "domain_name" {
  description = "The domain name for the ACM certificate (required for Option 1)"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "The Route 53 Hosted Zone ID for DNS validation (required for Option 1)"
  type        = string
  default     = ""
}

variable "create_self_signed_cert" {
  description = "Create a self-signed certificate for testing if no domain is provided"
  type        = bool
  default     = false
}

variable "web_security_group_id" {
  description = "The security group ID of the web tier (for outbound rules)"
  type        = string
  default     = ""
}
