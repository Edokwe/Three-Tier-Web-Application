#!/bin/bash
# Script to set up OIDC provider for GitHub Actions
# Allowing workflows to assume IAM roles without long-lived credentials

set -e

GITHUB_ORG="your-org"
GITHUB_REPO="high-availability-web-application"

echo "Creating OIDC Provider for GitHub Actions..."

# Create OIDC Provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# Create IAM Role for Terraform Deploy
cat > trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:${GITHUB_ORG}/${GITHUB_REPO}:*"
                }
            }
        }
    ]
}
EOF

aws iam create-role --role-name GitHubActions-TerraformDeploy --assume-role-policy-document file://trust-policy.json
aws iam attach-role-policy --role-name GitHubActions-TerraformDeploy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

rm trust-policy.json
echo "OIDC Setup Complete."
