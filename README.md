# High-Availability Web Application on AWS

A complete, production-ready implementation of a three-tier web application architecture on AWS, using Terraform for Infrastructure as Code (IaC) and GitHub Actions for CI/CD.

![Architecture Diagram](docs/architecture/diagrams/overview.png) _(Placeholder for your diagram)_

## Features

- **Multi-Account Strategy**: Management, Dev, Staging, and Production environments isolated via AWS Organizations.
- **Three-Tier Architecture**:
  - **Frontend**: React SPA served by Nginx on EC2 Auto Scaling Group.
  - **Backend**: Python Flask REST API on the same EC2 instances (or separate ASG).
  - **Data**: Amazon RDS (PostgreSQL) and ElastiCache (Redis).
- **High Availability**: Multi-AZ deployment (ALB + ASG), RDS Multi-AZ for production.
- **Security**:
  - WAF (Web Application Firewall) for application protection.
  - VPC Network Segmentation (Public/Private/Data subnets).
  - Least Privilege IAM Roles.
  - Encrypted Data at Rest (KMS) and In Transit (TLS).
- **DevOps**:
  - **IaC**: Terraform with remote state (S3 + DynamoDB).
  - **CI/CD**: GitHub Actions pipelines for infrastructure and application deployment.
  - **Monitoring**: CloudWatch Dashboards, Alarms, and Logs.

## Tech Stack

- **Cloud Provider**: AWS (EC2, VPC, RDS, ElastiCache, ALB, S3, CloudWatch, WAF, Route53)
- **Infrastructure as Code**: Terraform
- **CI/CD**: GitHub Actions
- **Application**: React (Frontend), Python Flask (Backend), PostgreSQL, Redis

## Quick Start

### Prerequisites

- AWS Account with Admin Access
- Terraform v1.6+
- AWS CLI v2
- Git

### Deployment

1.  **Clone the Repository**

    ```bash
    git clone https://github.com/your-username/high-availability-web-application.git
    cd high-availability-web-application
    ```

2.  **Bootstrap Infrastructure (S3 Backend)**

    ````bash
    ```bash
    cd environments/bootstrap
    terraform init && terraform apply
    ````

3.  **Deploy Development Environment**

    ````bash
    ```bash
    cd ../dev
    terraform init && terraform apply
    ````

4.  **Deploy Application**
    ```bash
    # Get bucket name
    BUCKET=$(terraform output -raw s3_static_assets_bucket)
    # Run deploy script
    ../../scripts/deploy-app.sh $BUCKET
    ```
5.  **Access the App**
    Get the Load Balancer DNS:
    ```bash
    terraform output alb_dns_name
    ```
    Open in browser: `http://<ALB_DNS_NAME>`

## Documentation

- **[Architecture Decisions (ADRs)](docs/architecture/ADR.md)**
- **[Infrastructure Inventory](docs/architecture/infrastructure-inventory.md)**
- **[Operational Runbooks](docs/operations/runbooks/deploy-changes.md)**
- **[Disaster Recovery](docs/operations/runbooks/dr-runbooks.md)**
- **[Application Deployment](docs/operations/runbooks/app-deployment.md)**
- **[Project Summary](docs/project-summary.md)**

## Architecture Overview

The solution leverages a **Hub-and-Spoke** network topology (simulated via VPC Peering for simplicity) or isolated VPCs per environment.

- **Public Subnets**: NAT Gateways, Load Balancers.
- **Private App Subnets**: Web/App Servers (EC2 ASG).
- **Private Data Subnets**: RDS Database, ElastiCache Redis.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

_Created by [Your Name] for Cloud Engineering Portfolio._
