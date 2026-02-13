# Redis Setup & Integration Guide

This guide details the deployment, testing, and application integration for the ElastiCache Redis cluster.

## Architecture

- **Engine**: Redis 7.0
- **Deployment**: Private Data Subnets (Isolated from public internet)
- **Security**:
  - Inbound: Port 6379 allowed only from Web Tier Security Group.
  - Encryption:
    - **At-rest**: Encrypted using AWS KMS.
    - **In-transit**: TLS/SSL enforced.
  - Authentication: Redis Auth Token (stored in Secrets Manager).

## Deployment

1. **Deploy Terraform**:
   Navigate to `terraform/environments/dev` and apply:

   ```bash
   cd terraform/environments/dev
   terraform apply
   ```

   Confirm with `yes`.

2. **Retrieve Outputs**:
   Note the following outputs:
   - `redis_primary_endpoint`: The connection endpoint (e.g., `dev-redis.xyz.use1.cache.amazonaws.com`)
   - `redis_auth_token_arn`: ARN of the secret containing the auth token.
   - Secret Name (Convention): `dev/redis/auth-token`

## Testing Connectivity

Since Redis is in a private subnet, you must test from an EC2 instance (Bastion or Web Tier) or via VPN.

**Prerequisites**:

- Python and Redis libraries: `pip3 install redis boto3`.
- Instance IAM Role must have `secretsmanager:GetSecretValue` permission.

**Run Test Script**:

```bash
export REDIS_HOST="<REDIS_PRIMARY_ENDPOINT>"
export REDIS_SECRET_NAME="dev/redis/auth-token"

python3 scripts/test-redis.py
```

**Expected Output**:

```
Connecting to Redis at ... (TLS enabled)...
Setting key 'test_key'...
Retrieved key 'test_key': Hello from Python!
SUCCESS: Redis connection and operations working.
```

## Application Integration

### Python (Flask)

Use `flask-session` with `redis` provider. Note that `ssl=True` is **mandatory** because `transit_encryption_enabled` is set to true in Terraform.

```python
import redis
import boto3
from flask import Flask, session
from flask_session import Session

app = Flask(__name__)

# 1. Retrieve Secret
def get_redis_auth():
    client = boto3.client('secretsmanager', region_name='us-east-1')
    response = client.get_secret_value(SecretId='dev/redis/auth-token')
    return response['SecretString']

# 2. Configure Session
app.config['SESSION_TYPE'] = 'redis'
app.config['SESSION_PERMANENT'] = False
app.config['SESSION_USE_SIGNER'] = True
app.config['SESSION_REDIS'] = redis.StrictRedis(
    host='<REDIS_ENDPOINT>',
    port=6379,
    password=get_redis_auth(),
    ssl=True,            # CRITICAL: Must be True for ElastiCache with Encryption
    ssl_cert_reqs=None   # Optional: Bypass cert verification if needed internally
)

Session(app)
```

### Node.js (Express)

Use `connect-redis` and `redis` client.

```javascript
const redis = require("redis");
const session = require("express-session");
const RedisStore = require("connect-redis")(session);

// Create Client
const redisClient = redis.createClient({
  url: `rediss://:<PASSWORD>@<REDIS_ENDPOINT>:6379`, // Note 'rediss://' for SSL
  socket: {
    tls: true,
    rejectUnauthorized: false, // Optional: simplify internal cert validation
  },
});

await redisClient.connect();

// Configure Middleware
app.use(
  session({
    store: new RedisStore({ client: redisClient }),
    secret: "your-app-secret",
    resave: false,
    saveUninitialized: false,
  }),
);
```

## Cost Optimization (Dev vs Prod)

- **Dev Environment**:
  - **Single Node**: `num_cache_nodes = 1`
  - **Multi-AZ**: Disabled.
  - **Failover**: Disabled.
  - **Instance Type**: `cache.t3.micro`.

- **Production Environment**:
  - **Replication Group**: `num_cache_nodes = 2` (or more).
  - **Multi-AZ**: Enabled.
  - **Failover**: Enabled.
  - **Instance Type**: `cache.t3.small` or larger based on memory needs.
