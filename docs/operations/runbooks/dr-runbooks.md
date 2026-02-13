# Disaster Recovery Runbooks

## Overview

This document outlines the step-by-step procedures to recover the application in case of failures.

### Target Recovery Objectives (RTO/RPO)

| Environment | RTO (Recovery Time Objective) | RPO (Recovery Point Objective) |
| ----------- | ----------------------------- | ------------------------------ |
| Production  | 4 Hours                       | 1 Hour                         |
| Staging     | 24 Hours                      | 24 Hours                       |
| Development | 72 Hours                      | 24 Hours                       |

---

## Scenario 1: EC2 Instance Failure

**Impact**: Application downtime or degraded performance.
**Mechanism**: Auto Scaling Group (ASG) should handle this automatically.

### Automated Recovery

1. The ASG Health Check detects an unhealthy instance.
2. ASG Terminates the instance.
3. ASG Launches a new instance using the Launch Template.
4. User Data configures the instance.
5. Instance registers with ALB Target Group.

### Verification

- Check CloudWatch Dashboard: `dev-application-dashboard`.
- Verify `HealthyHostCount` metric returns to key level.

---

## Scenario 2: RDS Database Failure (Corrupted Data)

**Impact**: Data loss or unavailability.
**Mechanism**: Restore from Snapshot (PITR).

### Procedure

**Note**: Restoring a database creates a _new_ instance endpoint.

1. **Identify Timestamp**: Determine the exact time of the corruption (e.g., table drop).
2. **Initiate Restore**:
   - Go to AWS Console -> RDS -> Databases.
   - Select the DB instance (`dev-app-db`).
   - Actions -> **Restore to point in time**.
   - Select "Custom" time (just before the event).
   - **Crucial**: Name the new instance `dev-app-db-restored`.
   - Ensure Subnet Group and Security Group match the original.

3. **Switch Traffic**:
   - **Option A (Update Secrets)**: Update the Secrets Manager secret `dev/db/credentials` with the new endpoint address. Restart application instances (Instance Refresh) to pick up new config.
   - **Option B (Rename Instance)**:
     - Rename the old corrupted instance to `dev-app-db-corrupt`.
     - Rename the new restored instance to `dev-app-db`.
     - Wait for DNS propagation.

4. **Verify**:
   - Connect via Bastion/Session Manager.
   - Run `test-connection.py`.
   - Verify data integrity.

---

## Scenario 3: Accidental Resource Deletion (Infrastructure)

**Impact**: Critical resource (e.g., Security Group, ALB) deleted.
**Mechanism**: Terraform State + AWS Backup.

### Procedure

1. **Re-run Terraform**:

   ```bash
   cd terraform/environments/dev
   terraform apply
   ```

   - Terraform will detect the missing resource and recreate it.
   - **Note**: Recreating stateful resources (RDS, EBS) via Terraform creates _empty_ resources. You must restore data separately.

2. **Restore Data (If Stateful)**:
   - If an EBS volume was deleted:
     - Go to AWS Backup Console -> Protected Resources.
     - Select the volume ID.
     - Choose the latest Recovery Point -> Restore.
     - Attach the new volume to the instance.

---

## Scenario 4: Region Failure (Disaster)

**Impact**: Entire US-East-1 region unavailable.
**Mechanism**: Multi-Region Redeployment (Manual / Pilot Light).
**Prerequisite**: This requires Terraform code to be region-agnostic and data replicated.

### Procedure (Future Enhancement)

1. **Change Region**: Update `aws_region = "us-west-2"` in `terraform.tfvars`.
2. **Deploy Infrastructure**: Run `terraform apply` in the new region.
3. **Restore Data**:
   - Promote Cross-Region Read Replica (RDS).
   - Restore EBS from Cross-Region snapshots.
4. **Update DNS**: Point `www.example.com` to the new ALB DNS.
