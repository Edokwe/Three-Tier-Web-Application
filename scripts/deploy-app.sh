#!/bin/bash
# Deploy Application Script
# Usage: ./deploy-app.sh <S3_BUCKET_NAME>

S3_BUCKET=$1

if [ -z "$S3_BUCKET" ]; then
  echo "Usage: ./deploy-app.sh <S3_BUCKET_NAME>"
  exit 1
fi

echo "Deploying to bucket: $S3_BUCKET"

# 1. Build Frontend
echo "Building Frontend..."
cd application/frontend
if [ ! -d "node_modules" ]; then
  npm install
fi
npm run build
cd ../..

# 2. Package Application
echo "Packaging Application..."
mkdir -p dist
rm -rf dist/*
mkdir -p dist/backend
mkdir -p dist/frontend

# Copy Backend
cp -r application/backend/* dist/backend/

# Copy Frontend Build
cp -r application/frontend/dist/* dist/frontend/

# Create Archive
cd dist
zip -r ../app.zip .
cd ..

# 3. Upload to S3
echo "Uploading to S3..."
aws s3 cp app.zip "s3://$S3_BUCKET/app.zip"

echo "Deployment Package Uploaded."
echo "Ensure your EC2 instances allow access to this bucket."
echo "If using Auto Scaling, start an instance refresh to pick up the new code."
