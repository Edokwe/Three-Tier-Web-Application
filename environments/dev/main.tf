
# ---------------------------------------------------------------------------------------------------------------------
# Use this module in environments/dev/main.tf
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "ModernWebApp"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Networking (VPC)
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  env          = var.environment
  vpc_cidr     = var.vpc_cidr
  vpc_name     = "high-availability-app-vpc"
  
  azs = ["us-east-1a", "us-east-1b"]

  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  private_app_subnets = ["10.0.10.0/23", "10.0.12.0/23"]
  data_subnets        = ["10.0.20.0/24", "10.0.21.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true # Only one NAT Gateway for cost optimization in Dev
  enable_flow_logs     = true
  flow_logs_retention  = 7
}

# ---------------------------------------------------------------------------------------------------------------------
# Application Load Balancer
# ---------------------------------------------------------------------------------------------------------------------

module "alb" {
  source = "../../modules/alb"

  environment    = var.environment
  project_name   = "high-availability-app"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets

  # SSL/TLS Configuration
  create_self_signed_cert = true
  
  # Security Group
  # Security Group
  web_security_group_id = module.autoscaling.web_security_group_id
  
  # Health Check
  health_check_path = "/api/health"
}

# ---------------------------------------------------------------------------------------------------------------------
# Auto Scaling Group (Web Tier)
# ---------------------------------------------------------------------------------------------------------------------

module "autoscaling" {
  source = "../../modules/autoscaling"

  environment           = var.environment
  project_name          = "high-availability-app"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_app_subnets
  alb_security_group_id = module.alb.alb_security_group_id
  
  alb_arn               = module.alb.alb_arn
  target_group_arn      = module.alb.target_group_arn

  min_size         = 2
  max_size         = 4
  desired_capacity = 2
  instance_type    = "t3.small"

  data_security_group_id = module.rds.db_security_group_id
  
  # Application Artifacts
  s3_bucket_name = module.cdn.s3_bucket_name
}

# ---------------------------------------------------------------------------------------------------------------------
# Data Tier (RDS PostgreSQL)
# ---------------------------------------------------------------------------------------------------------------------

module "rds" {
  source = "../../modules/rds"

  environment           = var.environment
  project_name          = "high-availability-app"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.data_subnets
  web_security_group_id = module.autoscaling.web_security_group_id

  instance_class = "db.t3.micro"
  multi_az       = false
  
  allocated_storage     = 20
  max_allocated_storage = 100

  db_name         = "appdb"
  master_username = "dbadmin"
  
  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false
}

# ---------------------------------------------------------------------------------------------------------------------
# Caching Tier (ElastiCache Redis)
# ---------------------------------------------------------------------------------------------------------------------

module "elasticache" {
  source = "../../modules/elasticache"

  environment           = var.environment
  project_name          = "high-availability-app"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.data_subnets
  web_security_group_id = module.autoscaling.web_security_group_id

  node_type           = "cache.t3.micro"
  num_cache_nodes     = 1
  automatic_failover_enabled = false
  multi_az_enabled    = false
  
  engine_version      = "7.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# Content Delivery Network (CloudFront + S3)
# ---------------------------------------------------------------------------------------------------------------------

module "cdn" {
  source = "../../modules/cdn"

  environment  = var.environment
  project_name = "high-availability-app"

  # Uses CloudFront default certificate (*.cloudfront.net) for Dev
}

# ---------------------------------------------------------------------------------------------------------------------
# Web Application Firewall (WAF)
# ---------------------------------------------------------------------------------------------------------------------

module "waf" {
  source = "../../modules/waf"

  environment  = var.environment
  project_name = "high-availability-app"
  
  alb_arn = module.alb.alb_arn
  
  # Set to true to enable WAF protection
  enabled = true
}

# ---------------------------------------------------------------------------------------------------------------------
# Monitoring & Alerting (CloudWatch)
# ---------------------------------------------------------------------------------------------------------------------

module "monitoring" {
  source = "../../modules/monitoring"

  environment  = var.environment
  project_name = "high-availability-app"
  aws_region   = var.aws_region

  # Inputs from other modules
  alb_arn                    = module.alb.alb_arn
  alb_dns_name               = module.alb.alb_dns_name
  target_group_arn           = module.alb.target_group_arn
  asg_name                   = module.autoscaling.asg_name
  rds_db_identifier          = module.rds.db_instance_identifier
  redis_replication_group_id = module.elasticache.redis_replication_group_id
  
  # Alerts
  alert_emails = ["admin@example.com"] # Replace with real email in production
}

# ---------------------------------------------------------------------------------------------------------------------
# Backup Strategy (AWS Backup)
# ---------------------------------------------------------------------------------------------------------------------

module "backup" {
  source = "../../modules/backup"

  environment  = var.environment
  project_name = "high-availability-app"
  
  # Dev Plan: Weekly backups, 7 days retention
  plan_name        = "weekly-backup-plan"
  schedule         = "cron(0 5 ? * SUN *)" # Weekly on Sunday at 5 AM
  retention_days   = 7
  
  enable_selection_by_tags = true
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "web_asg_name" {
  value = module.autoscaling.asg_name
}

output "db_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "redis_primary_endpoint" {
  value = module.elasticache.redis_primary_endpoint_address
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.cdn.cloudfront_domain_name
}

output "s3_static_assets_bucket" {
  description = "The name of the S3 bucket for static assets"
  value       = module.cdn.s3_bucket_name
}

output "waf_web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = module.waf.web_acl_arn
}

output "monitoring_dashboard_name" {
  description = "Name of the CloudWatch Dashboard"
  value       = module.monitoring.dashboard_name
}

output "backup_vault_arn" {
  description = "ARN of the AWS Backup Vault"
  value       = module.backup.backup_vault_arn
}
