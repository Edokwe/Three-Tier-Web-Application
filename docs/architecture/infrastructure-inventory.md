# Infrastructure Inventory

## Overview

This document lists the core AWS resources provisioned by Terraform across the four accounts. Costs are estimates based on US-East-1 pricing.

| Account        | Resource Type       | Name / ID         | Purpose                               | Estimated Cost/Mo            | Owner   |
| -------------- | ------------------- | ----------------- | ------------------------------------- | ---------------------------- | ------- |
| **Management** | AWS Organization    | `root`            | Centralized Billing & Access          | Free                         | Admin   |
| Management     | IAM Identity Center | `aws-sso`         | Single Sign-On                        | Free                         | Admin   |
| Management     | S3 Bucket           | `terraform-state` | Remote State Storage                  | < $1.00                      | DevOps  |
| **Dev**        | VPC                 | `vpc-dev`         | Network isolation (10.0.0.0/16)       | Free (Data transfer applies) | DevTeam |
| Dev            | NAT Gateway         | `nat-gw-dev-1a`   | Outbound Internet for Private Subnets | ~$32.00                      | DevTeam |
| Dev            | EC2 (ASG)           | `dev-web-asg`     | Web Servers (t3.small x 2)            | ~$30.00                      | DevTeam |
| Dev            | ALB                 | `dev-web-alb`     | Load Balancing                        | ~$16.00 + LCU                | DevTeam |
| Dev            | RDS                 | `dev-app-db`      | Database (db.t3.micro)                | ~$12.00 (or Free Tier)       | DevTeam |
| Dev            | ElastiCache         | `dev-redis`       | Caching (cache.t3.micro)              | ~$12.00                      | DevTeam |
| Dev            | CloudWatch          | `dev-dashboard`   | Monitoring & Logs                     | ~$5.00                       | DevOps  |
| **Staging**    | VPC                 | `vpc-staging`     | Pre-prod testing                      | Free                         | QA      |
| Staging        | EC2 (ASG)           | `staging-web-asg` | Web Servers (t3.small x 2)            | ~$30.00                      | QA      |
| **Production** | VPC                 | `vpc-prod`        | Live Traffic                          | Free                         | Ops     |
| Production     | EC2 (ASG)           | `prod-web-asg`    | Web Servers (t3.medium x 2)           | ~$60.00                      | Ops     |
| Production     | RDS (Multi-AZ)      | `prod-app-db`     | Database (db.t3.medium)               | ~$120.00                     | Ops     |
| Production     | WAF                 | `prod-web-acl`    | Security Firewall                     | ~$5.00 + Requests            | SecPos  |

## Total Estimated Monthly Cost: ~$325.00

_(Note: Dev environment costs can be reduced by stopping instances during non-working hours)_
