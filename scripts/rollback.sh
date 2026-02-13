#!/bin/bash
# Rollback Script
# Usage: ./rollback.sh <ASG_NAME>

ASG_NAME=$1

if [ -z "$ASG_NAME" ]; then
  echo "Usage: ./rollback.sh <ASG_NAME>"
  echo "Example: ./rollback.sh dev-high-availability-app-web-asg"
  exit 1
fi

echo "Starting rollback for $ASG_NAME..."

# 1. Cancel any ongoing refresh
echo "[1] Cancelling ongoing instance refresh..."
aws autoscaling cancel-instance-refresh --auto-scaling-group-name $ASG_NAME

# 2. Get current Launch Template
LAUNCH_TEMPLATE_ID=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].LaunchTemplate.LaunchTemplateId' \
  --output text)

CURRENT_VERSION=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $ASG_NAME \
  --query 'AutoScalingGroups[0].LaunchTemplate.Version' \
  --output text)

echo "Current Launch Template Version: $CURRENT_VERSION"

# 3. Rollback to Previous Version (Simple Logic: Version - 1)
# In production, you might store versions in Parameter Store or use specific tags.
PREVIOUS_VERSION=$((CURRENT_VERSION - 1))

if [ "$PREVIOUS_VERSION" -lt "1" ]; then
  echo "Cannot rollback, no previous version exists."
  exit 1
fi

echo "Rolling back to version: $PREVIOUS_VERSION"

# 4. Update ASG to use Previous Version
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name $ASG_NAME \
  --launch-template LaunchTemplateId=$LAUNCH_TEMPLATE_ID,Version=$PREVIOUS_VERSION

# 5. Start Instance Refresh
echo "[5] Starting Instance Refresh using version $PREVIOUS_VERSION..."
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name $ASG_NAME \
  --preferences '{"MinHealthyPercentage": 50, "InstanceWarmup": 300}' \
  --strategy Rolling

echo "Rollback initiated. Monitor progress in AWS Console."
