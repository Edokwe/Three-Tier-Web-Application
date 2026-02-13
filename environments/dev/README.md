# Terraform Environment: Dev

This configuration deploys the develop environment for the High-Availability Web Application.

## Configuration Details

- **Region**: `us-east-1`
- **VPC CIDR**: `10.0.0.0/16`
- **Availability Zones**: `us-east-1a`, `us-east-1b`
- **NAT Gateway**: Single NAT Gateway (Cost Optimized) in `us-east-1a`

## Usage

1.  Initialize Terraform:

    ```bash
    terraform init
    ```

2.  Review Plan:

    ```bash
    terraform plan
    ```

3.  Apply Configuration:
    ```bash
    terraform apply
    ```

## Outputs

- `vpc_id`: The ID of the created VPC.
- `public_subnets`: List of Public Subnet IDs.
- `private_app_subnets`: List of Private App Subnet IDs.
- `data_subnets`: List of Private Data Subnet IDs.
