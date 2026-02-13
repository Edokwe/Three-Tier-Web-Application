# GitHub Actions CI/CD Pipeline

This repository uses GitHub Actions for Continuous Integration and Continuous Deployment (CI/CD).

## Workflows

### 1. Infrastructure Deployment (`infrastructure-deploy.yml`)

- **Trigger**: Push to `main` branch (path: `terraform/**`)
- **Action**: Runs `terraform plan` and `terraform apply` for the `dev` environment.
- **Artifacts**: Stores Terraform outputs as JSON.

### 2. Application Deployment (`application-deploy.yml`)

- **Trigger**: Push to `main` branch (path: `application/**`)
- **Action**:
  1. Packages the application (`app.zip`).
  2. Uploads to S3 Bucket (`dev-deploy-bucket`).
  3. Updates Launch Template with new version.
  4. Triggers **Instance Refresh** on the Auto Scaling Group.
  5. Waits for deployment success.

### 3. PR Validation (`pr-validation.yml`)

- **Trigger**: Pull Request
- **Action**:
  - Validates Terraform code (`fmt`, `validate`).
  - Lints Python application code.

## Secrets Configuration

To use these workflows, you must configure the following **Repository Secrets** in GitHub:

| Secret Name             | Description                                                   |
| ----------------------- | ------------------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | IAM Access Key with deployment permissions.                   |
| `AWS_SECRET_ACCESS_KEY` | IAM Secret Key.                                               |
| `DEPLOYMENT_BUCKET`     | S3 bucket name for artifacts (e.g., `dev-app-deploy-bucket`). |
| `LAUNCH_TEMPLATE_ID`    | ID of the Launch Template used by ASG.                        |
| `ASG_NAME`              | Name of the Auto Scaling Group.                               |
| `ALB_DNS_NAME`          | DNS Name of the Load Balancer (for health check).             |

## Usage Guide

1. **Commit Code**: Push changes to `main`.
2. **Monitor Actions**: Go to the "Actions" tab in GitHub to see the progress.
3. **Rollback**: If deployment fails, use the provided script locally or via manual workflow dispatch.

### Manual Rollback

The script `scripts/rollback.sh` automates rolling back the ASG to the previous Launch Template version.

```bash
./scripts/rollback.sh <ASG_NAME>
```

## Security Best Practices

- **Least Privilege**: Ensure the IAM User used for CI/CD has only necessary permissions (S3, EC2, ASG, WAF, CloudWatch).
- **OIDC**: Consider using OpenID Connect (OIDC) to assume roles instead of long-lived access keys (updated in advanced configuration).
