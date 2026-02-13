# Auto Scaling Group Module

This module creates an Auto Scaling Group (ASG) with a Launch Template for EC2 instances. It handles the deployment of the web tier, including security groups, IAM roles for Session Manager and CloudWatch, and scaling policies.

## Features

- **Launch Template**:
  - Uses Amazon Linux 2023 AMI (latest)
  - Configures `t3.small` instances (customizable)
  - Enables IMDSv2 and detailed monitoring
  - IAM Role for SSM Session Manager and CloudWatch
  - User Data script to install Python/Flask app
- **Auto Scaling Group**:
  - Deploys into private subnets
  - Attaches to ALB Target Group
  - Configures Instance Refresh for rolling updates
- **Scaling Policies**:
  - Target Tracking Scaling based on CPU (70%)
  - Target Tracking Scaling based on ALB Request Count (1000 requests/target)
- **Security Group**:
  - Inbound HTTP from ALB only
  - Outbound Access for updates and services

## Usage

```hcl
module "asg" {
  source = "../../modules/autoscaling"

  environment           = "dev"
  project_name          = "my-app"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_app_subnets
  alb_security_group_id = module.alb.alb_security_group_id
  alb_arn               = module.alb.alb_arn
  target_group_arn      = module.alb.target_group_arn

  min_size         = 2
  max_size         = 4
  desired_capacity = 2
}
```

## Inputs

| Name                  | Description              | Type         | Default    | Required |
| --------------------- | ------------------------ | ------------ | ---------- | :------: |
| environment           | Environment name         | string       | n/a        |   yes    |
| vpc_id                | VPC ID                   | string       | n/a        |   yes    |
| subnet_ids            | List of subnet IDs       | list(string) | n/a        |   yes    |
| alb_security_group_id | Security Group ID of ALB | string       | n/a        |   yes    |
| alb_arn               | ARN of ALB               | string       | n/a        |   yes    |
| target_group_arn      | ARN of Target Group      | string       | n/a        |   yes    |
| instance_type         | EC2 Instance Type        | string       | "t3.small" |    no    |
| min_size              | Min ASG size             | number       | 2          |    no    |
| max_size              | Max ASG size             | number       | 4          |    no    |
| desired_capacity      | Desired ASG capacity     | number       | 2          |    no    |

## Outputs

- `asg_name`: Name of the Auto Scaling Group
- `web_security_group_id`: Security Group ID of the web instances
- `web_instance_role_arn`: ARN of the IAM role
