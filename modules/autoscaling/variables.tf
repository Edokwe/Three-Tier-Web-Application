variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "The project name"
  type        = string
  default     = "web-app"
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnet IDs to deploy the ASG into"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "The ID of the ALB security group"
  type        = string
}

variable "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the target group to attach to the ASG"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "The AMI ID to use for the launch template (if empty, latest Amazon Linux 2023 will be used)"
  type        = string
  default     = ""
}

variable "min_size" {
  description = "The minimum size of the ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "The maximum size of the ASG"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "The desired capacity of the ASG"
  type        = number
  default     = 2
}

variable "health_check_type" {
  description = "The type of health check to use (EC2 or ELB)"
  type        = string
  default     = "ELB"
}

variable "health_check_grace_period" {
  description = "The health check grace period"
  type        = number
  default     = 300
}

variable "data_security_group_id" {
  description = "The ID of the data tier security group (optional)"
  type        = string
  default     = ""
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "The key name for SSH access (optional)"
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket containing application artifacts"
  type        = string
  default     = ""
}
