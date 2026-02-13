CREATE DATABASE appdb;
\c appdb;

-- Create application user
-- Note: You'll replace 'from-secrets-manager' with the actual password in practice,
-- or handle user creation via your application logic/IAM auth.
CREATE USER appuser WITH PASSWORD 'ChangeMe123!'; 

GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;

-- Create Sample Table
CREATE TABLE IF NOT EXISTS items (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Grant privileges on public schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO appuser;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO appuser;

-- Insert some dummy data
INSERT INTO items (title, description) VALUES 
('First Item', 'This is the first item in the database'),
('Second Item', 'Another item for testing pagination/listing'),
('Third Item', 'Third time is the charm');
