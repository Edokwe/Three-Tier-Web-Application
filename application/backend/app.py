
import os
import json
import boto3
import psycopg2
import redis
import logging
from flask import Flask, jsonify, request
from flask_cors import CORS
from botocore.exceptions import ClientError

# Configure Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for frontend

# Configuration
REGION = os.environ.get('AWS_REGION', 'us-east-1')
DB_SECRET_NAME = os.environ.get('DB_SECRET_NAME', 'dev/db/credentials')
REDIS_HOST = os.environ.get('REDIS_HOST', 'localhost')
REDIS_PORT = int(os.environ.get('REDIS_PORT', 6379))
REDIS_TOKEN_SECRET = os.environ.get('REDIS_TOKEN_SECRET', 'dev/redis/auth_token')

# AWS Clients
secrets_client = boto3.client('secretsmanager', region_name=REGION)

def get_secret(secret_name):
    try:
        response = secrets_client.get_secret_value(SecretId=secret_name)
        if 'SecretString' in response:
            return response['SecretString']
        return None
    except ClientError as e:
        logger.error(f"Error retrieving secret {secret_name}: {e}")
        return None

def get_db_connection():
    secret = get_secret(DB_SECRET_NAME)
    if not secret:
        raise Exception("Database credentials not found")
    
    creds = json.loads(secret)
    conn = psycopg2.connect(
        host=creds['host'],
        port=creds['port'],
        database='appdb', # Hardcoded or passed via creds/env
        user=creds['username'],
        password=creds['password']
    )
    return conn

def get_redis_client():
    token = get_secret(REDIS_TOKEN_SECRET)
    if not token:
        logger.warning("Redis token not found, trying without auth")
        return redis.Redis(host=REDIS_HOST, port=REDIS_PORT, ssl=True, decode_responses=True)
    
    return redis.Redis(host=REDIS_HOST, port=REDIS_PORT, password=token, ssl=True, decode_responses=True)

# Cache Client
try:
    cache = get_redis_client()
except Exception as e:
    logger.error(f"Redis connection failed: {e}")
    cache = None

@app.route('/api/health')
def health():
    return jsonify({"status": "healthy", "service": "backend"}), 200

@app.route('/api/items', methods=['GET'])
def get_items():
    # Try Cache
    if cache:
        try:
            cached_data = cache.get('all_items')
            if cached_data:
                logger.info("Serving from cache")
                return jsonify(json.loads(cached_data)), 200
        except Exception as e:
            logger.error(f"Cache read error: {e}")

    # Fetch from DB
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id, name, description FROM items;")
        rows = cur.fetchall()
        items = [{"id": r[0], "name": r[1], "description": r[2]} for r in rows]
        cur.close()
        conn.close()

        # Set Cache
        if cache:
            try:
                cache.setex('all_items', 60, json.dumps(items))
            except Exception as e:
                logger.error(f"Cache write error: {e}")
                
        return jsonify(items), 200
    except Exception as e:
        logger.error(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/api/items', methods=['POST'])
def add_item():
    data = request.json
    if not data or 'name' not in data:
        return jsonify({"error": "Name is required"}), 400
    
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO items (name, description) VALUES (%s, %s) RETURNING id;",
            (data['name'], data.get('description', ''))
        )
        new_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()

        # Invalidate Cache
        if cache:
            try:
                cache.delete('all_items')
            except Exception as e:
                logger.error(f"Cache delete error: {e}")

        return jsonify({"id": new_id, "message": "Item added"}), 201
    except Exception as e:
        logger.error(f"Database error: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
