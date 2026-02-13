# ALB Module

This module creates an Application Load Balancer with listeners for HTTP (redirect to HTTPS) and HTTPS, along with a Target Group and Security Group.

## Features

- Application Load Balancer (Internet-facing)
- HTTP Listener (Port 80) - Redirects to HTTPS
- HTTPS Listener (Port 443) - Forwards to Target Group
- Target Group (HTTP, Port 80)
- Security Group (ALB)
  - Allow Inbound HTTP/HTTPS from anywhere
  - Allow Outbound HTTP to Web Tier (or all if not specified)
- SSL/TLS Certificate Management
  - Option 1: ACM Certificate (Requires Route53 Hosted Zone)
  - Option 2: Self-signed Certificate (For testing)

## Usage

```hcl
module "alb" {
  source = "../../modules/alb"

  environment    = "dev"
  project_name   = "my-app"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets

  # Option 1: Use ACM (Requires Route53 Zone)
  # domain_name     = "app.example.com"
  # route53_zone_id = "Z1234567890"

  # Option 2: Use Self-Signed Cert (For testing without domain)
  create_self_signed_cert = true
}
```

## Inputs

| Name                    | Description                    | Type         | Default | Required |
| ----------------------- | ------------------------------ | ------------ | ------- | :------: |
| environment             | Environment name               | string       | n/a     |   yes    |
| vpc_id                  | VPC ID                         | string       | n/a     |   yes    |
| public_subnets          | List of public subnet IDs      | list(string) | n/a     |   yes    |
| domain_name             | Domain name for ACM cert       | string       | ""      |    no    |
| route53_zone_id         | Route53 Zone ID for validation | string       | ""      |    no    |
| create_self_signed_cert | Create self-signed cert        | bool         | false   |    no    |
| web_security_group_id   | Security Group ID of web tier  | string       | ""      |    no    |

## Outputs

- `alb_dns_name`: The DNS name of the load balancer
- `alb_arn`: The ARN of the load balancer
- `target_group_arn`: The ARN of the target group
- `alb_security_group_id`: The Security Group ID of the ALB
