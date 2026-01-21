#!/bin/bash
# ============================================
# RUN THIS ON YOUR PRODUCTION SERVER
# ============================================
# SSH to: ubuntu@ip-10-1-22-14
# Then copy-paste the commands below

cd /opt/tenx  # or your project path

# Login to Docker Hub
docker login -u hsense

# Build backend (will be linux/amd64 automatically on Linux server)
docker build -t facility-erp-backend:latest -f apps/backend/Dockerfile apps/backend

# Build frontend
docker build -t facility-erp-frontend:latest -f apps/frontend/Dockerfile apps/frontend

# Tag with version 1.0.1
docker tag facility-erp-backend:latest hsense/facility-erp-backend:1.0.1
docker tag facility-erp-backend:latest hsense/facility-erp-backend:latest
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:latest

# Push to Docker Hub
docker push hsense/facility-erp-backend:1.0.1
docker push hsense/facility-erp-backend:latest
docker push hsense/facility-erp-frontend:1.0.1
docker push hsense/facility-erp-frontend:latest

echo "✅ Version 1.0.1 pushed to Docker Hub!"

