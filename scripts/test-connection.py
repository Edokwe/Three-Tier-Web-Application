import boto3
import json
import psycopg2
import os

def get_secret(secret_name, region_name="us-east-1"):
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        raise e
    else:
        if 'SecretString' in get_secret_value_response:
            return json.loads(get_secret_value_response['SecretString'])
        else:
            print("SecretString not found in response")
            return None

def get_db_connection(secret_name):
    print(f"Retrieving secret: {secret_name}")
    secret = get_secret(secret_name)
    
    if not secret:
        print("Failed to get credentials.")
        return None

    try:
        print(f"Connecting to {secret['host']}:{secret['port']} as {secret['username']}...")
        conn = psycopg2.connect(
            host=secret['host'],
            port=secret['port'],
            database=secret['dbname'],
            user=secret['username'],
            password=secret['password'],
            connect_timeout=5,
            sslmode='require'
        )
        return conn
    except Exception as e:
        print(f"Connection failed: {e}")
        return None

if __name__ == "__main__":
    # Get secret name from environment variable or interactive input
    secret_name = os.environ.get("DB_SECRET_NAME")
    if not secret_name:
        print("Please set DB_SECRET_NAME environment variable or modify the script.")
        # Example: dev/db/credentials
        secret_name = "dev/db/credentials"

    conn = get_db_connection(secret_name)
    
    if conn:
        print("Connection successful!")
        cur = conn.cursor()
        cur.execute("SELECT version();")
        db_version = cur.fetchone()
        print(f"PostgreSQL Version: {db_version[0]}")
        cur.close()
        conn.close()
    else:
        print("Connection failed.")
