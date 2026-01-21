# Build and Push Version 1.0.1

## Problem
You're on macOS (ARM64) but need to build for Linux (AMD64) production server.

## Solution: Build on Production Server

### Option 1: Build on Production Server (Recommended)

**On your production server (`ubuntu@ip-10-1-22-14`):**

```bash
# 1. SSH to server
ssh ubuntu@ip-10-1-22-14

# 2. Navigate to project directory
cd /opt/tenx  # or wherever your code is

# 3. Make sure you have the latest code
git pull  # or copy files manually

# 4. Login to Docker Hub
docker login -u hsense

# 5. Run the build script
./scripts/build-push-production.sh 1.0.1

# Or manually:
docker build -t facility-erp-backend:latest -f apps/backend/Dockerfile apps/backend
docker build -t facility-erp-frontend:latest -f apps/frontend/Dockerfile apps/frontend

docker tag facility-erp-backend:latest hsense/facility-erp-backend:1.0.1
docker tag facility-erp-backend:latest hsense/facility-erp-backend:latest
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:latest

docker push hsense/facility-erp-backend:1.0.1
docker push hsense/facility-erp-backend:latest
docker push hsense/facility-erp-frontend:1.0.1
docker push hsense/facility-erp-frontend:latest
```

### Option 2: Use Docker Compose Build (On Production Server)

```bash
# On production server
cd /opt/tenx

# Use the build version of compose file
docker-compose -f docker-compose.prod-build.yml build

# Tag and push
docker tag facility-erp-backend:latest hsense/facility-erp-backend:1.0.1
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1
docker push hsense/facility-erp-backend:1.0.1
docker push hsense/facility-erp-frontend:1.0.1
```

### Option 3: Install Buildx on macOS (For Future)

```bash
# Install buildx plugin
mkdir -p ~/.docker/cli-plugins
curl -L https://github.com/docker/buildx/releases/latest/download/buildx-v0.12.0.darwin-arm64 -o ~/.docker/cli-plugins/docker-buildx
chmod +x ~/.docker/cli-plugins/docker-buildx

# Create builder
docker buildx create --name multiarch --use
docker buildx inspect --bootstrap

# Then use:
docker buildx build --platform linux/amd64 -t hsense/facility-erp-backend:1.0.1 --push -f apps/backend/Dockerfile apps/backend
```

## After Pushing

Update `docker-compose.prod.yml` on production server:

```yaml
backend:
  image: hsense/facility-erp-backend:${BACKEND_VERSION:-1.0.1}
  
frontend:
  image: hsense/facility-erp-frontend:${FRONTEND_VERSION:-1.0.1}
```

Or set environment variable:
```bash
export BACKEND_VERSION=1.0.1
export FRONTEND_VERSION=1.0.1
docker-compose -f docker-compose.prod.yml up -d
```

