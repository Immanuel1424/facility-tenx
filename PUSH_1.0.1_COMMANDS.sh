#!/bin/bash
# Commands to run on PRODUCTION SERVER to build and push version 1.0.1
# Copy and paste these commands on: ubuntu@ip-10-1-22-14

# 1. Login to Docker Hub
docker login -u hsense

# 2. Build backend (will build for linux/amd64 automatically on Linux server)
docker build -t facility-erp-backend:latest -f apps/backend/Dockerfile apps/backend

# 3. Build frontend
docker build -t facility-erp-frontend:latest -f apps/frontend/Dockerfile apps/frontend

# 4. Tag with version 1.0.1
docker tag facility-erp-backend:latest hsense/facility-erp-backend:1.0.1
docker tag facility-erp-backend:latest hsense/facility-erp-backend:latest
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:latest

# 5. Push to Docker Hub
docker push hsense/facility-erp-backend:1.0.1
docker push hsense/facility-erp-backend:latest
docker push hsense/facility-erp-frontend:1.0.1
docker push hsense/facility-erp-frontend:latest

echo "Done! Version 1.0.1 pushed to Docker Hub"

