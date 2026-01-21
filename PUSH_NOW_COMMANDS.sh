#!/bin/bash
# ============================================
# COPY AND PASTE THESE COMMANDS ON YOUR PRODUCTION SERVER
# ============================================
# SSH to: ubuntu@ip-10-1-22-14
# Then run these commands:

cd /opt/tenx  # or your project path

# Login to Docker Hub (if not already)
docker login -u hsense

# Build frontend (will be linux/amd64 automatically)
docker build -t facility-erp-frontend:latest -f apps/frontend/Dockerfile apps/frontend

# Tag with version 1.0.1
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:latest

# Push to Docker Hub
docker push hsense/facility-erp-frontend:1.0.1
docker push hsense/facility-erp-frontend:latest

echo "✅ Version 1.0.1 pushed to Docker Hub!"

