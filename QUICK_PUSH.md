# Quick Push to Docker Hub - Version 1.0.1

## ⚠️ Must Build on Production Server

Since you're on macOS (ARM64) and need linux/amd64 images, build on your Linux production server.

## Option 1: Copy Script to Server

```bash
# On your Mac, copy the script to server
scp push-to-dockerhub.sh ubuntu@ip-10-1-22-14:/opt/tenx/

# SSH to server
ssh ubuntu@ip-10-1-22-14

# Navigate to project
cd /opt/tenx

# Make executable and run
chmod +x push-to-dockerhub.sh
./push-to-dockerhub.sh
```

## Option 2: Copy-Paste Commands

SSH to your production server and run:

```bash
# Login (if not already)
docker login -u hsense

# Build and push
docker build -t facility-erp-backend:latest -f apps/backend/Dockerfile apps/backend && \
docker build -t facility-erp-frontend:latest -f apps/frontend/Dockerfile apps/frontend && \
docker tag facility-erp-backend:latest hsense/facility-erp-backend:1.0.1 && \
docker tag facility-erp-backend:latest hsense/facility-erp-backend:latest && \
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1 && \
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:latest && \
docker push hsense/facility-erp-backend:1.0.1 && \
docker push hsense/facility-erp-backend:latest && \
docker push hsense/facility-erp-frontend:1.0.1 && \
docker push hsense/facility-erp-frontend:latest && \
echo "✅ Version 1.0.1 pushed successfully!"
```

## After Pushing

On production server, update and restart:

```bash
export BACKEND_VERSION=1.0.1
export FRONTEND_VERSION=1.0.1
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

