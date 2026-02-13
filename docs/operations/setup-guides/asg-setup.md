# Auto Scaling Group Setup & Testing Guide

This guide details the deployment and testing of the Auto Scaling Group (ASG) and web tier.

## Deployment Steps

1. **Deploy Terraform**:
   Navigate to `terraform/environments/dev` and apply:

   ```bash
   cd terraform/environments/dev
   terraform init
   terraform apply
   ```

   Confirm with `yes`.

2. **Wait for Instances**:
   The ASG will launch 2 instances. It takes 2-3 minutes for the User Data script to:
   - Install packages (Python, Flask, CloudWatch Agent)
   - Start the web service
   - Register with the Target Group

## Verification

### 1. Check ALB Response

Get the `alb_dns_name` from outputs and verify the application is running:

```bash
# Verify Health Check Endpoint
curl -k https://<ALB_DNS_NAME>/health

# Verify Main Page (Load Balancing)
curl -k https://<ALB_DNS_NAME>/
```

**Expected Output:**

```json
{ "status": "healthy", "timestamp": "2023-10-27T10:00:00.000000" }
```

```json
{"message": "Hello from High-Availability Web App!", "hostname": "ip-10-0-10-123.ec2.internal", ...}
```

Run the command multiple times. You should see different `hostname` values as the ALB balances traffic between instances.

### 2. Verify Auto Scaling (Scale Out)

**Simulate High Load:**
You can simulate CPU load on an instance using `stress` or a simple loop. Connect to an instance via Session Manager (AWS Console) or if you set up SSH keys.

Alternatively, manipulate the scaling policy or desired capacity manually to test:

1. Go to AWS Console -> EC2 -> Auto Scaling Groups.
2. Select the ASG.
3. Edit "Desired capacity" to 3.
4. Watch as a new instance launches and registers.

### 3. Verify Auto Healing (Self-Healing)

1. Identify an instance ID in the ASG.
2. Terminate it via AWS Console or CLI:
   ```bash
   aws ec2 terminate-instances --instance-ids i-0123456789abcdef0
   ```
3. Monitor the ASG activity history using the console.
4. The ASG should detect the unhealthy/missing instance and launch a replacement automatically.

### 4. CloudWatch Metrics

1. Go to CloudWatch -> Metrics.
2. Browse `CWAgent` namespace.
3. Verify you can see memory and swap utilization metrics for your instances.

## Troubleshooting

- **503 Service Unavailable**:
  - Instances might still be initializing. Wait 5 minutes.
  - Check Target Group health in EC2 Console. If "Unhealthy", check the instance User Data logs (`/var/log/cloud-init-output.log`).

- **Instance Not Launching**:
  - Check ASG "Activity" tab for errors (e.g., insufficient capacity, launch template errors).

- **Cannot Connect**:
  - Verify Security Groups: ALB allows 0.0.0.0/0 (80/443), Web Tier allows ALB (80).
