# Application Load Balancer Setup Guide

This guide details the setup, configuration, and verification of the Application Load Balancer (ALB) infrastructure.

## Infrastructure Overview

The ALB is deployed in the public subnets across two Availability Zones. It handles incoming traffic on HTTP (80) and HTTPS (443).

- **HTTP (80)**: Redirects all traffic to HTTPS.
- **HTTPS (443)**: Terminates SSL/TLS and forwards traffic to the Target Group.
- **Target Group**: Forwards traffic to backend instances (currently empty) on port 80.

## SSL/TLS Certificate Configuration

The ALB module supports two modes for SSL/TLS certificates:

### Option 1: ACM Certificate (Production Recommended)

For production or environments with a real domain name managed in Route53.

1. Updates `environments/dev/main.tf`:
   ```hcl
   module "alb" {
     # ...
     create_self_signed_cert = false
     domain_name             = "app.yourdomain.com"
     route53_zone_id         = "Z0123456789ABCDEF" # Optional: automates validation
   }
   ```
2. If `route53_zone_id` is provided, Terraform will automatically create the validation records.
3. If not provided, you must manually add the CNAME records to your DNS provider as shown in the Terraform output / AWS Console.

### Option 2: Self-Signed Certificate (Development/Testing)

For testing ALB functionality without a domain name. This generates a self-signed certificate.

1. **Default behavior** in `environments/dev/main.tf`:
   ```hcl
   module "alb" {
     # ...
     create_self_signed_cert = true
   }
   ```
2. **Note**: Browsers will show a security warning because the certificate is self-signed. You can bypass this (e.g., type `thisisunsafe` in Chrome or click "Advanced" -> "Proceed").

## Deployment

To deploy the ALB infrastructure:

1. Navigate to the environment directory:
   ```bash
   cd terraform/environments/dev
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Apply the configuration:
   ```bash
   terraform apply
   ```
4. Confirm the changes by typing `yes`.

## Testing and Verification

After deployment, verify the ALB is functioning correctly.

### 1. Retrieve the ALB DNS Name

From the Terraform outputs:

```bash
terraform output alb_dns_name
```

Example Output: `dev-web-alb-123456789.us-east-1.elb.amazonaws.com`

### 2. Verify HTTP to HTTPS Redirect

Use `curl` to check the redirect on port 80:

```bash
curl -I http://<ALB_DNS_NAME>
```

**Expected Output:**

```
HTTP/1.1 301 Moved Permanently
Location: https://<ALB_DNS_NAME>:443/
...
```

### 3. Verify HTTPS Connection (and 503 Service Unavailable)

Since no EC2 instances are registered to the Target Group yet, the ALB should accept the connection but return a 503 error.

**Using curl (with -k to ignore self-signed cert errors):**

```bash
curl -k -I https://<ALB_DNS_NAME>
```

**Expected Output:**

```
HTTP/1.1 503 Service Unavailable
Content-Type: text/html
Content-Length: ...
```

**Using Browser:**

1. Open your browser and navigate to `https://<ALB_DNS_NAME>`.
2. Accept the security warning (if using self-signed cert).
3. You should see a generic **503 Service Temporarily Unavailable** page.

### 4. Verify Security Group Rules

- **Inbound**: Ensure ports 80 and 443 are open to 0.0.0.0/0.
- **Outbound**: Ensure outbound traffic is allowed (currently open to 0.0.0.0/0 on port 80 for testing).

## Next Steps

- **Web Tier**: Deploy EC2 instances via Auto Scaling Group.
- **Register Targets**: The ASG will automatically register instances to the `target_group_arn` output by this module.
- **Update Output Security Group**: Once the web tier SG exists, update the `alb` module to strictly allow traffic only to that SG.
