# Terraform AWS Networking Module

This module provisions a highly available network infrastructure on AWS, including VPC, Subnets (Public, Private App, Private Data), Internet Gateway, NAT Gateway(s), and Route Tables.

## Resources Created

- **VPC**: Custom CIDR block with DNS hostnames enabled.
- **Subnets**:
  - **Public**: For Load Balancers and NAT Gateways (Direct Internet Access).
  - **Private App**: For Application Servers (Egress via NAT Gateway).
  - **Private Data**: For Databases and Caches (Isolated, No Internet Access).
- **Gateways**:
  - **Internet Gateway**: Attached to VPC for public subnets.
  - **NAT Gateway**: Provisioned in public subnets for private subnet egress. Configurable for Single AZ (Cost) or Multi-AZ (High Availability).
- **Route Tables**:
  - **Public**: Routes `0.0.0.0/0` to IGW.
  - **Private App**: Routes `0.0.0.0/0` to NAT Gateway.
  - **Private Data**: Local route only.
- **Flow Logs**: Optional VPC Flow Logs sent to CloudWatch Logs.

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

## Outputs

| Name                   | Description                          |
| ---------------------- | ------------------------------------ |
| `vpc_id`               | The ID of the VPC                    |
| `public_subnets`       | List of IDs of public subnets        |
| `private_app_subnets`  | List of IDs of private app subnets   |
| `private_data_subnets` | List of IDs of private data subnets  |
| `nat_gateway_ips`      | List of Elastic IPs for NAT Gateways |
