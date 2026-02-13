# Monitoring and Alerting Setup (CloudWatch)

This guide details the monitoring infrastructure deployed for the application, including dashboards, alarms, and logging.

## Overview

- **Service**: Amazon CloudWatch
- **Dashboard**: `<environment>-application-dashboard`
- **Log Groups**:
  - Application: `/aws/ec2/<environment>/application`
  - System: `/aws/ec2/<environment>/system`
  - WAF: `aws-waf-logs-<environment>-web-acl`
- **Alerts**: Sent via SNS to configured email addresses.

## CloudWatch Dashboard

A unified dashboard is created to visualize the health of the entire stack.

**Widgets:**

1. **ALB Overview**: Request Count, Latency, 4xx/5xx Errors.
2. **EC2/ASG**: CPU Utilization of the Web Tier.
3. **Database**: RDS CPU Utilization, Connections.
4. **Cache**: Redis CPU Utilization, Memory.

To view: Go to CloudWatch -> Dashboards -> Select `dev-application-dashboard`.

## Alarms & Thresholds

The following alarms are configured to trigger notifications:

| Resource  | Metric           | Threshold  | Severity |
| --------- | ---------------- | ---------- | -------- |
| **ALB**   | 5xx Errors       | > 10 / min | High     |
| **ALB**   | Latency          | > 2.0 s    | High     |
| **ALB**   | Unhealthy Hosts  | > 0        | High     |
| **EC2**   | CPU Utilization  | > 80%      | High     |
| **EC2**   | Memory (Agent)\* | > 85%      | High     |
| **RDS**   | CPU Utilization  | > 80%      | High     |
| **RDS**   | Free Storage     | < 2 GB     | High     |
| **RDS**   | Connections      | > 80%      | Medium   |
| **Redis** | CPU Utilization  | > 75%      | Medium   |

_\*Note: Memory metrics require the CloudWatch Agent to be installed and configured on EC2 instances._

## Logs

### 1. Application Logs

Application logs should be directed to `/var/log/application/`. The CloudWatch Agent (configured in User Data) pushes these to `/aws/ec2/<env>/application`.

### 2. Log Insights Queries

Use **CloudWatch Log Insights** to analyze logs.

**Query: Find Recent Errors**

```
fields @timestamp, @message
| filter @message like /Error/ or @message like /Exception/
| sort @timestamp desc
| limit 20
```

**Query: Top Client IPs (WAF Logs)**

```
fields httpRequest.clientIp, action
| filter action = "BLOCK"
| stats count(*) as requestCount by httpRequest.clientIp
| sort requestCount desc
```

## SNS Notifications

- **Topic**: `<environment>-alerts`
- **Subscribers**: Defined in `terraform/environments/dev/main.tf` variable `alert_emails`.
- **Action**: When an alarm breaches, an email is sent to the subscribers.
- **Verification**: You must confirm the subscription by clicking the link in the email received from AWS.

## Testing Alarms

To test the **EC2 High CPU** alarm:

1. Connect to an instance.
2. Run `stress --cpu 2 --timeout 300` (Install `stress` if needed).
3. Wait 5 minutes.
4. Verify Alarm state changes to `ALARM` and email is received.
