# Application Deployment Guide

This guide details how to build and deploy the 3-Tier Web Application (React + Python Flask) to the infrastructure.

## Architecture

- **Frontend**: React Single Page Application (SPA).
- **Backend**: Python Flask REST API.
- **Serving**:
  - Nginx running on EC2 instances serves the React static files.
  - Nginx reverse proxies API requests (`/api/*`) to the Flask app running on port 5000.
  - Flask app communicates with RDS (PostgreSQL) and ElastiCache (Redis).

## Directory Structure

```
application/
├── frontend/       # React App (Vite)
├── backend/        # Flask App
storage/            # (Optional)
scripts/
└── deploy-app.sh   # Deployment script
```

## Prerequisites

1. **Node.js**: Installed locally (for building React).
2. **AWS CLI**: Configured with appropriate permissions.
3. **Infrastructure Deployed**: Terraform apply must be complete.

## Deployment Steps

1. **Get the Deployment Bucket Name**:
   Run the following command to get the bucket name from Terraform outputs:

   ```bash
   cd terraform/environments/dev
   terraform output -raw s3_static_assets_bucket
   cd ../../..
   ```

   _Note: In this setup, we reuse the static assets bucket for deployment artifacts._

2. **Run Deployment Script**:

   ```bash
   ./scripts/deploy-app.sh <BUCKET_NAME>
   ```

   This script will:
   - Build the React frontend (`npm run build`).
   - Package the backend and frontend build into `app.zip`.
   - Upload `app.zip` to the specified S3 bucket.

3. **Update Infrastructure (Instance Refresh)**:
   The AWS Auto Scaling Group needs to pick up the new artifact.

   **Option A: Trigger Instance Refresh (Zero Downtime)**

   ```bash
   aws autoscaling start-instance-refresh \
     --auto-scaling-group-name <ASG_NAME> \
     --preferences '{"MinHealthyPercentage": 50, "InstanceWarmup": 300}'
   ```

   _(Get `<ASG_NAME>` from `terraform output web_asg_name`)_

   **Option B: Manual Terminate (Dev)**
   Manually terminate instances in the specific ASG via the Console. The ASG will launch new ones which will download the new `app.zip` on startup.

## Validation

1. **Access the Application**:
   Open the ALB DNS Name in your browser.
   - You should see the React UI.
   - The "Status" should show "healthy" (fetched from API).
   - You should be able to add and list items (persisted in RDS).

2. **Troubleshooting**:
   - **Logs**:
     - User Data Log: `/var/log/user-data.log`
     - Backend Logs: `journalctl -u webapp`
     - Nginx Logs: `/var/log/nginx/error.log`
   - **Connection**:
     - Connect via Session Manager to an instance.
     - Check services: `systemctl status webapp`, `systemctl status nginx`.
     - Check connectivity to RDS: `telnet <RDS_ENDPOINT> 5432`.

## Local Development

To run locally:

1. **Backend**:
   ```bash
   cd application/backend
   pip install -r requirements.txt
   export DB_SECRET_NAME=... # Set env vars
   python app.py
   ```
2. **Frontend**:
   ```bash
   cd application/frontend
   npm install
   npm run dev
   ```
   _Note: You'll need to configure proxy in `vite.config.js` or CORS to talk to backend._
