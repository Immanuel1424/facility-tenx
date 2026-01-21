# URGENT: Fix Architecture Mismatch (exec format error)

## The Problem

Your images were built on macOS (ARM64) but production server is Linux (AMD64/x86_64).

## Quick Fix (Do This Now)

### On Your Development Machine (macOS)

**Option 1: Use the production build script**
```bash
# Build for Linux/AMD64
./scripts/build-for-production.sh 1.0.0

# Push to Docker Hub
docker push hsense/facility-erp-backend:1.0.0
docker push hsense/facility-erp-frontend:1.0.0
```

**Option 2: Manual build with buildx**
```bash
# Enable buildx (if not already)
docker buildx create --name multiarch --use
docker buildx inspect --bootstrap

# Build backend
cd apps/backend
docker buildx build --platform linux/amd64 \
  -t hsense/facility-erp-backend:1.0.0 \
  --load -f Dockerfile .

# Build frontend
cd ../frontend
docker buildx build --platform linux/amd64 \
  -t hsense/facility-erp-frontend:1.0.0 \
  --load -f Dockerfile .

# Push both
docker push hsense/facility-erp-backend:1.0.0
docker push hsense/facility-erp-frontend:1.0.0
```

**Option 3: Build on production server directly**
```bash
# SSH to production server
ssh ubuntu@your-server-ip

# Clone repository or copy files
cd /opt/tenx

# Build directly on Linux server
docker-compose -f docker-compose.prod.yml build

# Start
docker-compose -f docker-compose.prod.yml up -d
```

### On Production Server

After pushing new images:

```bash
# Stop containers
docker-compose -f docker-compose.prod.yml down

# Remove old images
docker rmi hsense/facility-erp-backend:1.0.0
docker rmi hsense/facility-erp-frontend:1.0.0

# Pull new images (built for linux/amd64)
docker-compose -f docker-compose.prod.yml pull

# Start services
docker-compose -f docker-compose.prod.yml up -d

# Verify
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs -f
```

## Verify Architecture

**Check image architecture:**
```bash
docker inspect hsense/facility-erp-backend:1.0.0 | grep -i arch
# Should show: "Architecture": "amd64"
```

## Prevention

**Always build for linux/amd64 when deploying to Linux servers:**

```bash
# Use the production build script
./scripts/build-for-production.sh 1.0.0
```

Or set platform in docker-compose:
```yaml
services:
  backend:
    platform: linux/amd64
    image: hsense/facility-erp-backend:1.0.0
```

---

**This is the root cause of your "exec format error" - fix by rebuilding for linux/amd64!**

