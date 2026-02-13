# Staging Environment

This directory contains the Terraform configuration for the **Staging** environment.

## Configuration

- **VPC CIDR**: `10.0.0.0/16`
- **Region**: `us-east-1`
- **NAT Gateway**: Single NAT Gateway (Cost Optimized)
- **Flow Logs**: Enabled (7 day retention)

## Deployment

1. Initialize Terraform:

   ```bash
   terraform init
   ```

2. Review the plan:

   ```bash
   terraform plan
   ```

3. Apply changes:
   ```bash
   terraform apply
   ```
