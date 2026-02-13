# Architecture Decision Records (ADR)

## ADR-001: Four-Account Structure

- **Status**: Accepted
- **Context**: AWS Organizations best practices recommend separating workloads.
- **Decision**: Implemented 4 accounts: Management, Dev, Staging, Production.
- **Consequences**: Enhanced security isolation, simplified billing, but increased management overhead.
- **Alternatives**: Single account (too risky), 6+ accounts (too complex for current team size).

## ADR-002: VPC Peering vs Transit Gateway

- **Status**: Accepted
- **Context**: Need to connect VPCs (e.g., Shared Services to Workloads).
- **Decision**: Used **VPC Peering**.
- **Reasoning**: Lower cost and sufficient for < 10 VPCs. Transit Gateway is overkill and expensive ($0.05/hr/attachment).
- **Consequences**: Mesh topology management required if scaling beyond 10 VPCs.

## ADR-003: Single Region Deployment

- **Status**: Accepted
- **Context**: High Availability within a region vs. Multi-Region Disaster Recovery.
- **Decision**: **US-East-1 (N. Virginia)** only.
- **Reasoning**: Latency is acceptable, cost is lower, and complexity of multi-region data replication is avoided for this phase.
- **Consequences**: Regional outage would cause downtime (RTO > 4h).

## ADR-004: Terraform as IaC Tool

- **Status**: Accepted
- **Context**: Need reproducible infrastructure.
- **Decision**: **Terraform** with S3 backend.
- **Reasoning**: Cloud-agnostic syntax (HCL), robust state management, immense community module support.
- **Alternatives**: CloudFormation (AWS specific), CDK (Code-based, higher learning curve).

## ADR-005: GitHub Actions for CI/CD

- **Status**: Accepted
- **Context**: Need automated pipelines for Infra and App.
- **Decision**: **GitHub Actions**.
- **Reasoning**: Integrated with code repository, free tier available, simple YAML syntax.
- **Alternatives**: Jenkins (Maintenance heavy), AWS CodePipeline (Less flexible for non-AWS tasks).

## ADR-006: EC2 Auto Scaling vs ECS/EKS

- **Status**: Accepted
- **Context**: Hosting a 3-tier web app.
- **Decision**: **EC2 with Auto Scaling Groups**.
- **Reasoning**: Simpler to understand underlying networking/OS concepts. Fits "Lift and Shift" scenarios.
- **Alternatives**: ECS Fargate (Lower operational overhead but abstract), EKS (Too complex for simple app).

## ADR-007: RDS PostgreSQL

- **Status**: Accepted
- **Context**: Relational database requirement.
- **Decision**: **Amazon RDS for PostgreSQL**.
- **Reasoning**: Managed service (backups, patching), open-source engine compatibility, Multi-AZ support.
- **Optimization**: `db.t3.micro` for Dev (Free Tier), `db.t3.medium` for Prod.

## ADR-008: Cost Optimization Strategy

- **Status**: Accepted
- **Context**: Limited budget for learning project.
- **Decisions**:
  - NAT Gateway: Single AZ in Dev.
  - RDS: Single AZ in Dev, stop on weekends (script).
  - Spot Instances: Not used yet (stability priority), maybe future.
  - Data Transfer: Regional restrictions.
