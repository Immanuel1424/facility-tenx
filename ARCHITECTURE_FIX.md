# Architecture Mismatch Fix

## Problem

**Error**: `exec format error`

This occurs when Docker images are built for a different architecture than the production server.

- **Development**: macOS (ARM64/M1/M2)
- **Production**: Linux Ubuntu (x86_64/AMD64)

## Solution

### Option 1: Rebuild for Linux/AMD64 (Recommended)

**On your development machine:**

```bash
# Build for Linux/AMD64 architecture
./scripts/build-for-production.sh 1.0.0

# Tag and push
docker push hsense/facility-erp-backend:1.0.0
docker push hsense/facility-erp-frontend:1.0.0
```

### Option 2: Use Docker Buildx in Build Script

```bash
# Build with platform specification
DOCKER_PLATFORM=linux/amd64 ./scripts/docker-build-push.sh -v 1.0.0
```

### Option 3: Build Directly with Buildx

```bash
# Backend
cd apps/backend
docker buildx build --platform linux/amd64 \
  -t hsense/facility-erp-backend:1.0.0 \
  --load -f Dockerfile .

# Frontend
cd ../frontend
docker buildx build --platform linux/amd64 \
  -t hsense/facility-erp-frontend:1.0.0 \
  --load -f Dockerfile .

# Push
docker push hsense/facility-erp-backend:1.0.0
docker push hsense/facility-erp-frontend:1.0.0
```

## Verify Architecture

**Check image architecture:**
```bash
docker inspect hsense/facility-erp-backend:1.0.0 | grep Architecture
# Should show: "Architecture": "amd64"
```

**Check server architecture:**
```bash
# On production server
uname -m
# Should show: x86_64
```

## Quick Fix for Current Issue

**On production server:**

1. **Stop containers:**
   ```bash
   docker-compose -f docker-compose.prod.yml down
   ```

2. **Remove old images:**
   ```bash
   docker rmi hsense/facility-erp-backend:1.0.0
   docker rmi hsense/facility-erp-frontend:1.0.0
   ```

3. **Rebuild on development machine for linux/amd64:**
   ```bash
   ./scripts/build-for-production.sh 1.0.0
   docker push hsense/facility-erp-backend:1.0.0
   docker push hsense/facility-erp-frontend:1.0.0
   ```

4. **Pull and restart on production:**
   ```bash
   docker-compose -f docker-compose.prod.yml pull
   docker-compose -f docker-compose.prod.yml up -d
   ```

## Prevention

Always build for `linux/amd64` when deploying to Linux servers:

```bash
# Add to your build script
export DOCKER_PLATFORM=linux/amd64
./scripts/docker-build-push.sh -v 1.0.0
```

Or use the production build script:
```bash
./scripts/build-for-production.sh 1.0.0
```

---

**Last Updated**: 2025-12-31

