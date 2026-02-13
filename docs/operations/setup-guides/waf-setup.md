# AWS WAF Setup & Security Guide

This guide details the deployment, configuration, and testing of the AWS Web Application Firewall (WAF) for the Application Load Balancer.

## Architecture

- **Scope**: REGIONAL (US-East-1)
- **Association**: Application Load Balancer
- **Default Action**: Allow (Block bad requests)

## Rule Sets

The WAF is configured with the following priority rules:

1. **AWS Managed Core Rule Set (CRS)**:
   - Protects against OWASP Top 10 (SQLi, XSS, RFI, LFI, etc.).
   - Action: BLOCK

2. **Rate Limiting**:
   - Limit: 2000 requests per 5 minutes per IP.
   - Action: BLOCK (temporary ban)
   - Protects against: DDoS, brute force scanning.

3. **IP Reputation List**:
   - Managed by Amazon Intelligence.
   - Blocks known malicious IPs (botnets, open proxies).

4. **Known Bad Inputs**:
   - Blocks malformed requests (e.g., bad headers, evasion attempts).

5. **Custom User-Agent Blocking**:
   - Blocks requests with User-Agent containing "scanner", "bot", or "crawler".

## Logging & Monitoring

- **Logs**: Stored in CloudWatch Logs (`aws-waf-logs-<env>-web-acl`).
- **Retention**: 7 days.
- **Metrics**: Detailed metrics enabled for all rules.
- **Dashboard**: A CloudWatch Dashboard (`<env>-waf-dashboard`) is created automatically.

## Deployment

1. **Deploy Terraform**:
   Navigate to `terraform/environments/dev` and apply:

   ```bash
   cd terraform/environments/dev
   terraform apply
   ```

   Confirm with `yes`.

2. **Verify Resources**:
   - Check AWS WAF console to see the Web ACL.
   - Check CloudWatch Dashboards to see the new dashboard.

## Testing

Use the provided script to validate WAF functionality:

```bash
chmod +x scripts/test-waf.sh
./scripts/test-waf.sh <ALB_DNS_NAME>
```

### Manual Tests

**1. Normal Request (Allowed)**

```bash
curl -I https://<ALB_DNS_NAME>/
# Expect: HTTP 200 or 503 (if app not running)
```

**2. SQL Injection (Blocked)**

```bash
curl -I "https://<ALB_DNS_NAME>/?id=1' OR '1'='1"
# Expect: HTTP 403 Forbidden
```

**3. XSS Attack (Blocked)**

```bash
curl -I "https://<ALB_DNS_NAME>/?q=<script>alert(1)</script>"
# Expect: HTTP 403 Forbidden
```

**4. Rate Limiting**
Use a load testing tool like `ab` (Apache Bench) to trigger the rate limit:

```bash
ab -n 3000 -c 10 https://<ALB_DNS_NAME>/
# Expect: Failures/403s after ~2000 requests
```

## Troubleshooting

- **False Positives**:
  - If legitimate functionality is blocked, check WAF CloudWatch Logs.
  - Find the `ruleId` causing the block.
  - You may need to create an excluded rule or modify the specific managed rule group configuration in Terraform.

- **Emergency Disable**:
  - To quickly disable WAF without destroying it, set `enabled = false` in `environments/dev/main.tf` and apply.
  - Or manually disassociate the ALB in the WAF Console.
