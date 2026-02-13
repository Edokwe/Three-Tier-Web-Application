# Backup Strategy and Policy

## Overview

This document outlines the backup strategy for the Three-Tier Web Application to ensure data protection and recoverability.

## Schedules and Retention

### Production

- **Frequency**: Daily
- **Schedule**: 05:00 UTC
- **Retention**: 30 Days
- **Resources**: RDS, EBS Volumes (Persistent), DynamoDB (if applicable)

### Staging

- **Frequency**: Daily
- **Schedule**: 05:00 UTC
- **Retention**: 14 Days

### Development

- **Frequency**: Weekly
- **Schedule**: Sunday 05:00 UTC
- **Retention**: 7 Days

## Backup Mechanisms

### 1. AWS Backup (Centralized)

- **Scope**: EBS Volumes, RDS Snapshots (secondary), EFS.
- **Method**: AWS Backup Plans trigger backups based on standard CRON schedules.
- **Vault**: Encrypted specific backup vaults per environment (e.g., `dev-backup-vault`).
- **Tagging**: Resources tagged with `BackupEnabled=true` are automatically accepted into the backup plan.

### 2. RDS Automated Backups (Database Native)

- **Scope**: PostgreSQL Database
- **Method**: RDS native automated snapshots.
- **Frequency**: Continuous (Transaction logs) + Daily Snapshots.
- **Point-in-Time Recovery (PITR)**: Enabled (up to retention period).
- **Retention**: Matches the environment standard (e.g., 7 days for Dev).

### 3. Terraform State

- **Scope**: Infrastructure State (`terraform.tfstate`)
- **Method**: S3 Bucket Versioning + Cross-Region Replication (Future).
- **Retention**: 90 Days for old versions.

## Monitoring

- **Alerts**: AWS Backup Events (FAIL, EXPIRED) are sent to SNS topic `backup-events`.
- **Compliance**: AWS Config rules can track if resources are compliant with backup plans.
