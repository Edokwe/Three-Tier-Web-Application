# Production Environment

This directory contains the Terraform configuration for the **Production** environment.

## Configuration

- **VPC CIDR**: `10.0.0.0/16`
- **Region**: `us-east-1`
- **NAT Gateway**: **Multi-AZ (High Availability)** - One NAT Gateway per AZ.
- **Flow Logs**: Enabled (30 day retention)

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

## Note

This environment is configured for High Availability. It will provision multiple NAT Gateways (one per availability zone), which incurs higher costs but ensures resilience.
