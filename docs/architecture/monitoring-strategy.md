# Monitoring and Observability Strategy

This document details the monitoring strategy for our three-tier application, focusing on key metrics, alarms, dashboards, and log aggregation using Amazon CloudWatch.

## 1. Key Metrics to Track

Effective monitoring requires tracking metrics at all layers of the application stack.

### Application Tier (EC2 / ASG)

- **CPUUtilization**: Average/Maximum CPU usage. High usage indicates potential scaling needs.
- **MemoryUtilization**: Application memory usage (captured via CloudWatch Agent).
- **DiskSpaceUtilization**: Ensure root volume doesn't fill up.
- **StatusCheckFailed**: Identify failed instances.
- **RequestCount**: Total number of requests processed by instances.
- **Latency**: Average response time for application requests per instance.

### Load Balancer (ALB)

- **RequestCount**: Total requests handled by the load balancer.
- **TargetResponseTime**: Latency measured from the time the request leaves the load balancer until a response is received.
- **HTTP 4xx/5xx Errors**: Count of client-side and server-side errors.
- **HealthyHostCount**: Number of healthy targets in each target group. If this drops, immediate investigation is needed.

### Database Tier (RDS)

- **CPUUtilization**: High CPU can indicate inefficient queries or insufficient instance size.
- **FreeStorageSpace**: Critical to monitor; database will stop if storage is full.
- **DatabaseConnections**: Number of active connections. Sudden spikes can indicate issues.
- **ReadIOPS / WriteIOPS**: Throughput metrics.
- **ReadLatency / WriteLatency**: Performance of disk operations.

### Caching Tier (ElastiCache)

- **CPUUtilization**:
- **CacheHits / CacheMisses**: High miss rate might indicate configuration issues or need for larger cache size.
- **Evictions**: If high, cache is full and older items are being removed prematurely.

## 2. CloudWatch Alarms Configuration

Alarms trigger automated actions (scaling) or notifications (SNS) when metrics breach defined thresholds.

| Metric                  | Threshold               | Action                                                |
| :---------------------- | :---------------------- | :---------------------------------------------------- |
| **ASG Average CPU**     | > 70% for 3 data points | **Scale Out** (Add instance)                          |
| **ASG Average CPU**     | < 30% for 3 data points | **Scale In** (Remove instance)                        |
| **ALB Unhealthy Hosts** | < 1 for 1 data point    | **SNS Alert** (Critical: "Application Down/Degraded") |
| **RDS Free Storage**    | < 10% of alloc storage  | **SNS Alert** (Warning: "Low Storage")                |
| **RDS CPU Utilization** | > 80% for 15 mins       | **SNS Alert** (Warning: "High DB Load")               |
| **5xx Error Rate**      | > 1% of total requests  | **SNS Alert** (Critical: "High Error Rate")           |

## 3. Dashboard Layout

A centralized CloudWatch Dashboard provides a single pane of glass for operational visibility.

**Row 1: High-Level Health**

- **Overall Health Widget**: Aggregated status of ASG, RDS, and LB.
- **Total Request Count (Graph)**: Sum of requests across all zones.
- **Error Rates (Graph)**: 4xx and 5xx errors over time.

**Row 2: Application Performance**

- **Average Response Time**: Latency from ALB perspective.
- **CPU Utilization (EC2)**: Average and Max CPU across ASG.
- **Healthy Host Count**: Number of healthy instances per AZ.

**Row 3: Database & Cache**

- **RDS CPU & Connections**: Correlated graphs.
- **ElastiCache Hits/Misses**: Cache efficiency.
- **Database Latency**: Read/Write latency.

## 4. Log Aggregation Strategy

Centralized logging is essential for troubleshooting without SSH-ing into instances.

**CloudWatch Logs Agent**

- Installed on all EC2 instances via User Data or AMI customization.
- Configured to stream application logs (`/var/log/app/*.log`) and system logs (`/var/log/syslog` or `/var/log/messages`).
- **Log Groups**: Organized by environment (e.g., `/aws/ec2/app-prod`, `/aws/rds/db-prod`).
- **Log Retention**: Set to 30 days for active troublehsooting, archived to S3 for long-term compliance (Glacier).

**VPC Flow Logs**

- Enabled for the VPC to capture information about the IP traffic going to and from network interfaces.
- Useful for security audits and troubleshooting connectivity issues.
