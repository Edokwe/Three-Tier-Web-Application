#!/bin/bash
# Generic Deployment Script
# Usage: ./deploy.sh [infrastructure|application] [environment]

TARGET=$1
ENV=$2

if [ -z "$TARGET" ]; then
  echo "Usage: ./deploy.sh [infrastructure|application] [environment]"
  exit 1
fi

if [ "$TARGET" == "infrastructure" ]; then
  echo "Deploying Infrastructure to $ENV..."
  cd environments/$ENV || exit
  terraform init
  terraform apply -auto-approve
  
elif [ "$TARGET" == "application" ]; then
  echo "Deploying Application to $ENV..."
  BUCKET=$(cd environments/$ENV && terraform output -raw s3_static_assets_bucket)
  ./scripts/deploy-app.sh $BUCKET
  
  # Trigger Instance Refresh
  ASG_NAME=$(cd environments/$ENV && terraform output -raw web_asg_name)
  aws autoscaling start-instance-refresh --auto-scaling-group-name $ASG_NAME
  
else
  echo "Invalid target. Use 'infrastructure' or 'application'."
  exit 1
fi
