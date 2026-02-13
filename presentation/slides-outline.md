# 1. Title Slide

- High-Availability Web Application on AWS
- Scalable 3-Tier Architecture with React, Flask, and PostgreSQL
- Your Name / Date

# 2. Problem Statement

- Challenge: Build a resilient, scalable, and secure web application.
- Requirements:
  - 99.9% Uptime (High Availability).
  - Automated Scaling to handle traffic spikes.
  - Security best practices (Least Privilege, WAF).
  - Automated Pipeline (CI/CD).

# 3. Technical Solution

- Architecture: Three-Tier Web App on AWS.
- Frontend: React SPA served via Nginx (EC2).
- Backend: Python Flask REST API (EC2).
- Data Layer: Amazon RDS (PostgreSQL) + ElastiCache (Redis).
- Infrastructure: Terraform (IaC).

# 4. Architecture Diagram

- Include `t3.micro` instances in private subnets.
- Show ALB in public subnets with WAF attached.
- Show RDS Multi-AZ architecture.

# 5. Key Features

- **Multi-Account Deployment**: Isolated environments (Dev, Staging, Prod).
- **Infrastructure as Code**: Reproducible environments via Terraform.
- **CI/CD Pipeline**: GitHub Actions for automated testing & deployment.
- **Security**: WAF protection, strict Security Groups, IAM roles.

# 6. Operational Excellence

- **Monitoring**: CloudWatch Dashboards for real-time metrics.
- **Alerting**: SNS notifications for critical errors (5xx, high CPU).
- **Disaster Recovery**: Automated backups (AWS Backup) and defined runbooks.

# 7. Metrics & Results

- **Deployment Time**: < 10 mins for full stack.
- **Cost Efficiency**: Optimized using T3 instances (~$30/mo for Dev).
- **Security**: Passed CIS Benchmark checks for IAM/VPC.

# 8. Challenges & Lessons Learned

- Challenge: Managing Terraform state across multiple environments.
- Solution: Remote state locking with DynamoDB.
- Lesson: Start with security (least privilege) from day one.

# 9. Future Enhancements

- Multi-Region Disaster Recovery (Active-Passive).
- Containerization with Amazon ECS/EKS.
- Global Accelerator for improved latency.

# 10. Thank You / Q&A

- GitHub Repository Link
- Contact Information
