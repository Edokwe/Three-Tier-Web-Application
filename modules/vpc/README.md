# Terraform AWS Networking Module

This module provisions a highly available network infrastructure on AWS, following best practices for VPC design as per the project requirements.

## Architecture

![Architecture Diagram](https://d2908q01vomql2.cloudfront.net/1b6453892473a467d07372d45eb05abc2031647a/2019/10/17/Web-App-Reference-Architecture-1024x560.png)
_(Note: Diagram is illustrative of a Multi-AZ VPC architecture)_

### Components

- **VPC Configuration**:
  - CIDR: `10.0.0.0/16` (Default)
  - 2 Availability Zones (`us-east-1a`, `us-east-1b`)
  - DNS Hostnames Enabled
  - VPC Flow Logs to CloudWatch for troubleshooting

- **Subnet Design**:
  - **Public Subnets**: Direct Internet access via IGW. Auto-assign public IPs enabled.
    - Ranges: `10.0.1.0/24`, `10.0.2.0/24`
  - **Private Application Subnets**: Egress via NAT Gateway. Route table associated with NAT.
    - Ranges: `10.0.10.0/23`, `10.0.12.0/23`
  - **Private Data Subnets**: Isolated subnets for databases (RDS/ElastiCache). No default internet route.
    - Ranges: `10.0.20.0/24`, `10.0.21.0/24`

- **Gateways & Routing**:
  - **Internet Gateway (IGW)**: For public subnets.
  - **NAT Gateway**:
    - **Dev/Staging**: Single NAT Gateway in `us-east-1a` for cost optimization.
    - **Production**: High Availability Multi-AZ NAT Gateways (one per AZ).
  - **Route Tables**: Separate tables for Public, Private App (per AZ or shared), and Data (Isolated).

- **Security & Logging**:
  - **NaCls**: Default allows all traffic (security groups control access).
  - **Flow Logs**: All traffic accepted/rejected logged to CloudWatch Logs with retention.

## Prerequisities

1.  **Terraform**: Install Terraform (v1.0+).
2.  **AWS CLI**: Install and configure AWS CLI with valid credentials.
    ```bash
    aws configure
    ```

## Module Setup

The project is structured as follows:

```
terraform/
├── modules/
│   └── vpc/                  # Reusable VPC module
└── environments/
    ├── dev/                  # Development environment (Single NAT)
    ├── staging/              # Staging environment (Single NAT)
    └── production/           # Production environment (Multi-AZ NAT)
```

## Deployment Guide

### 1. Initialize and Validate

Navigate to the environment you wish to deploy (e.g., `dev`).

```bash
cd terraform/environments/dev
terraform init
terraform validate
```

### 2. Plan Deployment

Generate an execution plan to preview changes.

```bash
terraform plan -out=tfplan
```

Review the output to ensure 18+ resources (VPC, Subnets, Gateways, Routes, Logs) will be created.

### 3. Apply Configuration

Apply the changes to your AWS account.

```bash
terraform apply tfplan
```

Type `yes` if prompted (or it will auto-apply if using the plan file).

### 4. Verify Deployment (AWS CLI)

You can verify the created resources using the AWS CLI.

**List VPCs:**

```bash
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=ModernWebApp"
```

**Verify Subnets:**

```bash
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<VPC_ID>" --query "Subnets[*].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,MapPublicIp:MapPublicIpOnLaunch}" --output table
```

**Check NAT Gateways:**

```bash
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=<VPC_ID>" --query "NatGateways[*].{ID:NatGatewayId,State:State,PublicIP:NatGatewayAddresses[0].PublicIp}"
```

**Verify Route Tables:**

```bash
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<VPC_ID>" --query "RouteTables[*].{ID:RouteTableId,Routes:Routes}"
```

### 5. Destroy Resources (Cleanup)

To remove all resources created by this configuration:

```bash
terraform destroy
```

## Inputs

| Name                  | Description                                         | Type           | Default                            |
| --------------------- | --------------------------------------------------- | -------------- | ---------------------------------- |
| `env`                 | Environment name (dev, staging, prod)               | `string`       | n/a                                |
| `vpc_cidr`            | CIDR block for the VPC                              | `string`       | `10.0.0.0/16`                      |
| `azs`                 | List of Availability Zones                          | `list(string)` | `["us-east-1a", "us-east-1b"]`     |
| `public_subnets`      | CIDR blocks for public subnets                      | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]`   |
| `private_app_subnets` | CIDR blocks for app subnets                         | `list(string)` | `["10.0.10.0/23", "10.0.12.0/23"]` |
| `data_subnets`        | CIDR blocks for data subnets                        | `list(string)` | `["10.0.20.0/24", "10.0.21.0/24"]` |
| `enable_nat_gateway`  | Enable NAT Gateway                                  | `bool`         | `true`                             |
| `single_nat_gateway`  | Use single NAT Gateway (true) or one per AZ (false) | `bool`         | `true`                             |
| `enable_flow_logs`    | Enable VPC Flow Logs                                | `bool`         | `true`                             |
