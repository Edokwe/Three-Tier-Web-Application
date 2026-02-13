variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "The project name"
  type        = string
  default     = "web-app"
}

variable "versioning_enabled" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = "PriceClass_100"
}

variable "default_root_object" {
  description = "The default root object for the distribution"
  type        = string
  default     = "index.html"
}

variable "aliases" {
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "The ARN of the AWS Certificate Manager certificate to use (if custom domain required)"
  type        = string
  default     = ""
}
