#!/bin/bash
# High-Availability Web Application User Data Script
# Installs Python, Flask, Redis, PostgreSQL client, Nginx, and starts the web application

set -e

# Redirect output to log file
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting User Data Script..."

# 1. Update packages
yum update -y

# 2. Install dependencies
yum install -y python3 python3-pip git wget nginx unzip

# 3. Install CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# 4. Global Variables
APP_DIR="/opt/webapp"
BACKEND_DIR="$APP_DIR/backend"
FRONTEND_DIR="$APP_DIR/frontend"
S3_BUCKET="${s3_bucket_name}"

mkdir -p $APP_DIR
mkdir -p $BACKEND_DIR
mkdir -p $FRONTEND_DIR

# 5. Config Files & Code
# Try to download from S3 if bucket is provided
DOWNLOAD_SUCCESS=false

if [ -n "$S3_BUCKET" ]; then
  echo "Attempting to download artifact from s3://$S3_BUCKET/app.zip"
  if aws s3 cp "s3://$S3_BUCKET/app.zip" /tmp/app.zip; then
    echo "Artifact downloaded successfully."
    unzip -o /tmp/app.zip -d $APP_DIR
    # Move files around if zip structure is flat or different
    # Assuming zip contains 'backend' and 'frontend' folders directly
    DOWNLOAD_SUCCESS=true
  else
    echo "Failed to download artifact. Falling back to embedded code."
  fi
fi

if [ "$DOWNLOAD_SUCCESS" = false ]; then
  echo "Deploying embedded Sample App..."
  
  # --- Embedded Backend ---
  cat > $BACKEND_DIR/requirements.txt << 'EOF'
flask
flask-cors
psycopg2-binary
redis
boto3
gunicorn
python-dotenv
EOF

  cat > $BACKEND_DIR/app.py << 'EOF'
import os
import json
import boto3
import psycopg2
import redis
import logging
from flask import Flask, jsonify, request
from flask_cors import CORS
from botocore.exceptions import ClientError
import socket

# Configure Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

REGION = os.environ.get('AWS_REGION', 'us-east-1')
DB_SECRET_NAME = os.environ.get('DB_SECRET_NAME', 'dev/db/credentials')
REDIS_HOST = os.environ.get('REDIS_HOST', 'localhost')
REDIS_PORT = int(os.environ.get('REDIS_PORT', 6379))
REDIS_TOKEN_SECRET = os.environ.get('REDIS_TOKEN_SECRET', 'dev/redis/auth_token')

secrets_client = boto3.client('secretsmanager', region_name=REGION)

def get_secret(secret_name):
    try:
        response = secrets_client.get_secret_value(SecretId=secret_name)
        if 'SecretString' in response:
            return response['SecretString']
    except Exception as e:
        logger.error(f"Error retrieving secret {secret_name}: {e}")
    return None

def get_db_connection():
    secret = get_secret(DB_SECRET_NAME)
    if not secret: return None
    creds = json.loads(secret)
    return psycopg2.connect(
        host=creds['host'], port=creds['port'], database='appdb',
        user=creds['username'], password=creds['password']
    )

@app.route('/api/health')
def health():
    return jsonify({"status": "healthy", "service": "backend", "host": socket.gethostname()}), 200

@app.route('/api/items', methods=['GET'])
def get_items():
    try:
        conn = get_db_connection()
        if not conn: return jsonify([{"id": 1, "name": "Fallback Item (DB unavailable)"}]), 200
        cur = conn.cursor()
        cur.execute("SELECT id, name, description FROM items;")
        rows = cur.fetchall()
        items = [{"id": r[0], "name": r[1], "description": r[2]} for r in rows]
        cur.close()
        conn.close()
        return jsonify(items), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

  # --- Embedded Frontend (Simple HTML) ---
  cat > $FRONTEND_DIR/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>3-Tier Web App</title>
    <style>
        body { font-family: sans-serif; padding: 2rem; max-width: 800px; margin: 0 auto; background: #f4f6f8; }
        .card { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; }
        ul { list-style: none; padding: 0; }
        li { padding: 0.5rem; border-bottom: 1px solid #eee; }
    </style>
</head>
<body>
    <div class="card">
        <h1>High-Availability Web Application</h1>
        <p>Status: <span id="status">Loading...</span></p>
        <h2>Items</h2>
        <ul id="items"></ul>
    </div>
    <script>
        fetch('/api/health')
            .then(res => res.json())
            .then(data => document.getElementById('status').innerText = data.status + ' on ' + data.host)
            .catch(err => document.getElementById('status').innerText = 'Backend Error');

        fetch('/api/items')
            .then(res => res.json())
            .then(items => {
                const list = document.getElementById('items');
                items.forEach(item => {
                    const li = document.createElement('li');
                    li.textContent = `${item.name} - ${item.description || ''}`;
                    list.appendChild(li);
                });
            });
    </script>
</body>
</html>
EOF

fi

# 6. Install Python Dependencies
pip3 install -r $BACKEND_DIR/requirements.txt

# 7. Configure Nginx
cat > /etc/nginx/conf.d/webapp.conf << EOF
server {
    listen 80;
    server_name _;
    
    # Frontend Static Files
    location / {
        root $FRONTEND_DIR;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }

    # Backend API Proxy
    location /api {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Remove default nginx config if present
rm -f /etc/nginx/conf.d/default.conf

# 8. Configure Systemd for Backend (Gunicorn)
cat > /etc/systemd/system/webapp.service << EOF
[Unit]
Description=Gunicorn instance to serve webapp
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=$BACKEND_DIR
ExecStart=/usr/local/bin/gunicorn --workers 3 --bind 0.0.0.0:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 9. Start Services
systemctl daemon-reload
systemctl enable nginx
systemctl enable webapp
systemctl start webapp
systemctl restart nginx

# 10. Start CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json << 'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
      "ImageId": "${aws:ImageId}",
      "InstanceId": "${aws:InstanceId}",
      "InstanceType": "${aws:InstanceType}"
    },
    "metrics_collected": {
      "mem": { "measurement": [ "mem_used_percent" ] },
      "swap": { "measurement": [ "swap_used_percent" ] }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

echo "User Data Script Completed."
