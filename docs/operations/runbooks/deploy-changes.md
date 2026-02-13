# Infrastructure Deployment Runbook

## Deploying Infrastructure Changes

This runbook outlines the process for making changes to the infrastructure using Terraform.

### Prerequisites

1.  **Access**: IAM permissions to run Terraform (S3 Backend Access, EC2 full access, RDS full access, etc.).
2.  **Environment**: `AWS_PROFILE` or environment variables set for the target account.

### Step 1: Clone and Checkout Branch

```bash
git clone ...
git checkout -b feature/update-infra
```

### Step 2: Make Terraform Changes

Edit the `.tf` files in `terraform/modules/` or `terraform/environments/<env>/`.

### Step 3: Local Validation

1.  **Initialize**:
    ```bash
    cd terraform/environments/dev
    terraform init
    ```
2.  **Format**:
    ```bash
    terraform fmt -recursive
    ```
3.  **Validate**:
    ```bash
    terraform validate
    ```
4.  **Plan**:
    ```bash
    terraform plan -out=tfplan
    ```
    _Review the plan carefully. Ensure only intended resources are changed._

### Step 4: Apply Changes (Manual)

If satisfied with the plan:

```bash
terraform apply tfplan
```

_Wait for completion._

### Step 5: Commit and Push (CI/CD)

For production environments, changes should be applied via the CI/CD pipeline.

1.  **Commit**:
    ```bash
    git add .
    git commit -m "feat: updated instance type for web servers"
    git push origin feature/update-infra
    ```
2.  **Open Pull Request**:
    - GitHub Actions will run `terraform plan`.
    - Review the plan in the PR comments or Actions logs.
3.  **Merge**:
    - Once merged to `main`, GitHub Actions will run `terraform apply` automatically.

### Verification

1.  **Check Output**: Ensure `Apply complete!` message in logs.
2.  **Check Console**: Verify resources in AWS Console (EC2 -> Instances).
3.  **Check Metrics**: Monitor CloudWatch Dashboard for any anomalies.
