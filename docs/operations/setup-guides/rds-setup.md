# RDS PostgreSQL Setup & Management Guide

This guide covers the deployment, initialization, and management of the RDS PostgreSQL database.

## Architecture

- **Engine**: PostgreSQL 15
- **Deploy**: Private Data Subnets (Isolated from public internet)
- **Security**:
  - Inbound: Port 5432 allowed only from Web Tier Security Group.
  - Encryption: Storage encrypted (KMS) and SSL enforced.
- **Authentication**: Master credentials stored in AWS Secrets Manager.

## Deployment

1. **Deploy Terraform**:
   Navigate to `terraform/environments/dev` and apply:

   ```bash
   cd terraform/environments/dev
   terraform apply
   ```

   Confirm with `yes`.

2. **Retrieve Outputs**:
   Note the following outputs:
   - `db_endpoint`: The host address (e.g., `dev-app-db.cluster-xyz.us-east-1.rds.amazonaws.com:5432`)
   - `db_secret_arn`: ARN of the secret containing credentials.

## Database Initialization

Since the database is in a private subnet, you cannot connect directly from your local machine unless you use a VPN or a Bastion Host.

### Option A: Via Bastion Host (Recommended for Admin)

1. **Launch a Bastion Host** (t2.micro) in a Public Subnet with a Security Group allowing SSH from your IP.
2. **Authorize Bastion**: Update `modules/rds/security_group.tf` or manually add an inbound rule to the RDS Security Group allowing port 5432 from the Bastion SG.
3. **Connect & Init**:

   ```bash
   # SSH into Bastion
   ssh -i key.pem ec2-user@<BASTION_IP>

   # Install PostgreSQL client
   sudo dnf install postgresql15

   # Connect to RDS
   psql -h <RDS_ENDPOINT> -U dbadmin -d appdb
   # Parameter 1: Enter password from Secrets Manager

   # Run Initialization SQL
   # (Copy-paste content from scripts/init-database.sql)
   ```

### Option B: Via Web Tier Instance (Session Manager)

1. Connect to an ASG instance via SSM Session Manager.
2. Install postgres: `sudo dnf install postgresql15`.
3. Connect and run SQL as above.

## Testing Connectivity

A Python script is provided in `scripts/test-connection.py` to verify connectivity using Secrets Manager.

**Prerequisites**:

- Run this on an EC2 instance with an IAM role that has `secretsmanager:GetSecretValue` permission (The Web Tier IAM role has this).
- Install dependencies: `pip3 install boto3 psycopg2-binary`.

**Run Test**:

```bash
export DB_SECRET_NAME="dev/db/credentials"
python3 test-connection.py
```

## Backup & Restore Procedures

### Automated Backups

- **Frequency**: Daily (03:00-04:00 UTC).
- **Retention**: 7 days (Configured in Terraform).
- **Transaction Logs**: Archived every 5 minutes (Point-in-Time Recovery enabled).

### Manual Snapshot (Before Major Changes)

1. Go to AWS Console -> RDS -> Databases.
2. Select the instance -> Actions -> Take snapshot.
3. Name it (e.g., `pre-migration-backup`).

### Point-in-Time Recovery (PITR)

To restore to a specific time (e.g., to undo an accidental drop table):

1. Go to RDS Console -> Automated Backups.
2. Select the DB instance -> Actions -> Restore to point in time.
3. Select "Latest Restorable Time" or "Custom".
4. **Important**: This creates a NEW RDS instance. You must update your Terraform `db_identifier` or Application Config (Secrets Manager) to point to the new endpoint.

## Maintenance

- **Minor Version Upgrades**: Automatically applied during maintenance window (Sunday 04:00-05:00 UTC).
- **Storage Autoscaling**: Enabled. Storage will increase automatically if free space is low, up to 100GB.
