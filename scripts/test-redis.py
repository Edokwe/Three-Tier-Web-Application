import redis
import boto3
import os
import sys

def get_secret(secret_name, region_name="us-east-1"):
    client = boto3.client('secretsmanager', region_name=region_name)
    try:
        response = client.get_secret_value(SecretId=secret_name)
        return response['SecretString']
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        return None

def test_redis_connection(host, port, auth_secret_name):
    print(f"Retrieving Redis Auth Token from: {auth_secret_name}")
    auth_token = get_secret(auth_secret_name)
    
    if not auth_token:
        print("Failed to retrieve auth token. Exiting.")
        sys.exit(1)

    try:
        print(f"Connecting to Redis at {host}:{port} (TLS enabled)...")
        r = redis.StrictRedis(
            host=host,
            port=port,
            password=auth_token,
            ssl=True,  # Important: ElastiCache with encryption enabled requires SSL
            decode_responses=True,
            socket_timeout=5
        )
        
        # Test basic SET/GET
        print("Setting key 'test_key'...")
        r.set('test_key', 'Hello from Python!')
        
        value = r.get('test_key')
        print(f"Retrieved key 'test_key': {value}")
        
        if value == 'Hello from Python!':
            print("SUCCESS: Redis connection and operations working.")
        else:
            print("FAILURE: Value mismatch.")
            
    except redis.exceptions.ConnectionError as e:
        print(f"Connection Error: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    # Get configuration from environment variables
    redis_host = os.environ.get("REDIS_HOST")
    redis_port = int(os.environ.get("REDIS_PORT", 6379))
    auth_secret_name = os.environ.get("REDIS_SECRET_NAME", "dev/redis/auth-token")
    
    if not redis_host:
        print("Please set REDIS_HOST environment variable.")
        sys.exit(1)

    test_redis_connection(redis_host, redis_port, auth_secret_name)
