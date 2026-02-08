
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
# Outputs for use in other layers (State, etc)
# ---------------------------------------------------------------------------------------------------------------------

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_app_subnets" {
  value = module.vpc.private_app_subnets
}

output "data_subnets" {
  value = module.vpc.data_subnets
}
