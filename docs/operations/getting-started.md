# Getting Started Guide

## Prerequisites

1. **AWS Account**: A valid AWS account with administrative access.
2. **Terraform**: v1.6.0+ installed (`terraform -version`).
3. **AWS CLI**: v2+ configured (`aws configure`).
4. **Git**: Installed locally.

## Initial Setup

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/your-username/high-availability-web-application.git
   cd high-availability-web-application
   ```

2. **Configure AWS Credentials**:
   Ensure your local environment has `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` set, or use `aws sso login` if using SSO.

3. **Initialize Terraform Backend (State)**:
   - Navigate to `terraform/bootstrap` (create this folder if not present, containing backend S3 logic).
   - Run `terraform init` and `terraform apply`.
   - Update `terraform/backend.tf` in other modules with the new bucket name.

## Deploying the Landing Zone

1. **Deploy Management Account**:

   ```bash
   cd terraform/environments/management
   terraform init
   terraform apply
   ```

   _This sets up IAM, Organizations, and SCPs._

2. **Deploy Dev Environment**:
   ```bash
   cd ../dev
   terraform init
   terraform apply
   ```
   _This provisions VPC, EC2, RDS, etc._

## Accessing the Environment

1. **Web Application**:
   - Get the ALB DNS Name: `terraform output alb_dns_name`
   - Open in browser: `http://<ALB_DNS_NAME>`

2. **Database Access**:
   - Use Systems Manager Session Manager (SSM) to connect to the Bastion Host (or Web Server).
   - Run `psql -h <RDS_ENDPOINT> -U dbadmin -d appdb`.

## Where to Find What

- **Infrastructure Code**: `terraform/`
- **Application Code**: `application/`
- **Documentation**: `docs/`
- **Scripts**: `scripts/`
