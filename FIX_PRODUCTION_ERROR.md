# Fix: exec format error in Production

## Problem
Images built on macOS (ARM64) won't run on Linux (AMD64) server.

## Solution: Build on Production Server

### Step 1: On Production Server

```bash
# SSH to your server
ssh ubuntu@your-server-ip

# Navigate to project directory
cd /opt/tenx

# Update docker-compose.prod.yml to build instead of pull
# Change from:
#   image: hsense/facility-erp-backend:1.0.0
# To:
#   build:
#     context: ./apps/backend
#     dockerfile: Dockerfile
#     target: runner
```

### Step 2: Create Build Version of docker-compose

Create `docker-compose.prod-build.yml`:

```yaml
services:
  backend:
    build:
      context: ./apps/backend
      dockerfile: Dockerfile
      target: runner
    # ... rest of config same as docker-compose.prod.yml
```

### Step 3: Build and Run

```bash
# Build images (will build for linux/amd64 automatically)
docker-compose -f docker-compose.prod-build.yml build

# Start services
docker-compose -f docker-compose.prod-build.yml up -d

# Or use the existing compose file if you updated it
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
```

## Alternative: Use Pre-built Images from CI/CD

If you have CI/CD, build there for linux/amd64, then push to Docker Hub.

## Quick Fix (Recommended)

**On production server, build directly:**

```bash
# Stop current containers
docker-compose -f docker-compose.prod.yml down

# Remove old images
docker rmi hsense/facility-erp-backend:1.0.0 2>/dev/null
docker rmi hsense/facility-erp-frontend:1.0.0 2>/dev/null

# Build locally on Linux server
docker-compose -f docker-compose.prod.yml build

# Start
docker-compose -f docker-compose.prod.yml up -d
```

This will build for the correct architecture (linux/amd64) automatically.

