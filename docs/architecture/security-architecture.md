# Security Architecture & Best Practices

This document outlines the security architecture and best practices implemented within our high-availability three-tier web application, ensuring confidentiality, integrity, and availability.

## 1. Network Security: Security Groups & NACLs

We employ a defense-in-depth strategy using a combination of Security Groups (stateful) and Network ACLs (stateless) to control traffic flow.

### Security Groups (Stateful)

| Tier                        | Security Group Name | Inbound Rules                                                                        | Outbound Rules                                       | Purpose                                                     |
| :-------------------------- | :------------------ | :----------------------------------------------------------------------------------- | :--------------------------------------------------- | :---------------------------------------------------------- |
| **Web/App (Instance)**      | `web-sg`            | `HTTP (80)` from **Load Balancer SG**<br>`SSH (22)` from **Bastion SG** (optional)   | `All Traffic` to **Anywhere** (for updates/services) | Allows only traffic from the ALB.                           |
| **Load Balancer (ALB)**     | `alb-sg`            | `HTTPS (443)` from `0.0.0.0/0` (Internet)<br>`HTTP (80)` from `0.0.0.0/0` (Internet) | `HTTP (80)` to **Web SG**                            | Controls public access to the application.                  |
| **Database (RDS)**          | `db-sg`             | `MySQL/PostgreSQL` from **Web SG** ONLY                                              | None                                                 | Restricts database access strictly to the application tier. |
| **Bastion Host (Optional)** | `bastion-sg`        | `SSH (22)` from **Admin IP** ONLY                                                    | `SSH (22)` to **Web/App/DB SGs**                     | Secure entry point for administration.                      |

### Network ACLs (Stateless)

Network Access Control Lists (NACLs) act as a secondary firewall at the subnet level.

- **Public Tier NACL**: Allows inbound HTTP/HTTPS from `0.0.0.0/0` and ephemeral ports for return traffic. blocks specific suspicious IPs.
- **Private Tier NACL**: Allows inbound traffic on application ports from the Public Subnet range only. Deny all direct internet traffic.
- **Database Tier NACL**: Strict inbound rules allowing database port access only from the Private App Subnet range.

## 2. Encryption Strategy

Data protection is critical both at rest and in transit.

### Encryption within Transit

- **TLS/SSL**: Enforced for all external communications.
  - **ALB Listener**: HTTPS listener on port 443 with a valid SSL certificate from AWS Certificate Manager (ACM).
  - **End-to-End Encryption**: Traffic from ALB to EC2 instances can also be encrypted if required by compliance (though commonly terminated at ALB for performance).
  - **Database Connections**: Enabled SSL/TLS for connections between the application and RDS.

### Encryption at Rest

- **Amazon EBS Volumes**: Encrypted using AWS KMS (Key Management Service) keys.
- **Amazon RDS**: Encrypted storage, backups, and snapshots using KMS keys.
- **Amazon S3**: Server-Side Encryption (SSE-S3 or SSE-KMS) enabled for all S3 buckets storing application assets or logs.

## 3. Identity and Access Management (IAM)

We follow the principle of least privilege for all IAM roles and policies.

- **EC2 Instance Role**:
  - Created specifically for the application instances.
  - **Permissions**:
    - `AmazonSSMManagedInstanceCore` (for Systems Manager use instead of SSH keys).
    - Custom policy to read secrets from **Secrets Manager**.
    - Custom policy to write logs to **CloudWatch Logs**.
  - **No Access Keys**: Prevent hardcoded credentials on instances.

## 4. Secrets Management

Sensitive information such as database credentials, API keys, and third-party tokens are **never** stored in code or configuration files.

- **AWS Secrets Manager**:
  - Stores `DB_PASSWORD`, `API_KEY`, etc.
  - Automatically rotates database credentials on a schedule (e.g., every 30 days).
  - Application retrieves secrets at runtime via the AWS SDK/CLI using the EC2 Instance Role.

## 5. Additional Security Measures

- **AWS WAF (Web Application Firewall)**:
  - Deployed on the ALB or CloudFront distribution.
  - Rules to block SQL injection, Cross-Site Scripting (XSS), and known bad IP addresses.
- **AWS Shield Standard**:
  - Automatically enabled to protect against common DDoS attacks.
- **CloudTrail**:
  - Enabled to log all API activity within the AWS account for audit and compliance.
