# Technology Decisions & Rationale

This document outlines the strategic technology choices for the architecture, balancing performance, reliability, complexity, and cost.

## 1. Availability Zones: 2 vs 3

**Decision**: Utilize **2 Availability Zones (AZs)**.

**Rationale**:

- **Cost-Benefit**: While 3 AZs offer higher theoretical availability (99.99%), 2 AZs provide sufficient redundancy (99.95%) for most business applications at a significantly lower infrastructure cost (fewer NAT gateways, load balancer cross-zone charges, and standby instances).
- **Simplicity**: Managing a dual-AZ setup simplifies network configuration and troubleshooting for the initial deployment.
- **AWS Best Practice**: AWS recommends spreading critical workloads across multiple AZs. 2 AZs meet the minimum requirement for high availability.

## 2. Compute: EC2 vs ECS/Lambda

**Decision**: Use **Amazon EC2 (Elastic Compute Cloud)** with Auto Scaling.

**Rationale**:

- **Control & Flexibility**: EC2 provides full control over the operating system and software stack, which is beneficial for legacy applications or specific performance tuning requirements.
- **Learning Curve**: For teams transitioning to the cloud, EC2 offers a familiar server paradigm compared to the abstraction of containers (ECS) or serverless functions (Lambda).
- **State Management**: While stateless is ideal, EC2 simplifies handling applications that might have some local state dependencies before refactoring.

## 3. Database: RDS Multi-AZ vs Single-AZ

**Decision**: Deploy **RDS Multi-AZ**.

**Rationale**:

- **Reliability**: Multi-AZ deployments provide synchronous replication to a standby instance in a different AZ. In case of primary failure, RDS automatically fails over to the standby, minimizing downtime.
- **Data Durability**: Ensures data is persisted across multiple physical locations, critical for production data.
- **Maintenance**: Automated backups and software patching are handled with minimal impact on availability during maintenance windows.

## 4. Instance Sizing: t3.small

**Decision**: Utilize **t3.small** instances for the web/application tier.

**Rationale**:

- **Right-Sizing**: `t3.small` (2 vCPUs, 2 GiB RAM) offers a balanced resource profile for handling typical web traffic loads without over-provisioning.
- **Burstable Performance**: T3 instances are burstable, allowing them to handle traffic spikes effectively while maintaining a low baseline cost.
- **Cost Efficiency**: Significantly cheaper than larger instance types (e.g., m5.large) while sufficient for demonstration and initial production loads.

## 5. Session Management: ElastiCache (Redis)

**Decision**: Implement **Amazon ElastiCache for Redis**.

**Rationale**:

- **Performance**: Redis provides sub-millisecond latency for session retrieval, significantly faster than querying a relational database.
- **Statelessness**: Decoupling session state from the application servers allows the Auto Scaling Group to add or remove instances without disrupting active user sessions (unlike sticky sessions on the load balancer).
- **Scalability**: Redis clusters can be scaled independently of the application and database tiers.

## 6. Content Delivery: CloudFront

**Decision**: Integrate **Amazon CloudFront**.

**Rationale**:

- **Global Performance**: Caches static content (images, CSS, JS) at edge locations worldwide, reducing load times for global users.
- **Cost Savings**: Data transfer out from CloudFront is often cheaper than directly from EC2, and offloading hits reduces the load on backend servers.
- **Security**: Provides an additional layer of defense against DDoS attacks and can integrate with AWS WAF for application-layer protection.
