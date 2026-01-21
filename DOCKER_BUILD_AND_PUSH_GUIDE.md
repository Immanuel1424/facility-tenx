# Docker Build and Push Guide

## Quick Reference: Build and Push Images

### Prerequisites

1. **Docker must be running**

   ```bash
   docker info
   ```

2. **Logged in to Docker Hub**

   ```bash
   docker login -u hsense
   # Enter your Docker Hub password when prompted
   ```

3. **Navigate to project root**
   ```bash
   cd /Users/viveke/Developer/HelixSense/Workspace/iOS/14Aug2025/facility-erp
   ```

---

## Method 1: Build and Push Individual Images

### Frontend Only

```bash
# Step 1: Build the frontend image
docker build \
  --platform linux/amd64 \
  --tag hsense/facility-erp-frontend:latest \
  --file apps/frontend/Dockerfile \
  apps/frontend

# Step 2: Push to Docker Hub
docker push hsense/facility-erp-frontend:latest
```

### Backend Only

```bash
# Step 1: Build the backend image
docker build \
  --platform linux/amd64 \
  --tag hsense/facility-erp-backend:latest \
  --file apps/backend/Dockerfile \
  apps/backend

# Step 2: Push to Docker Hub
docker push hsense/facility-erp-backend:latest
```

### Both Images

```bash
# Build and push frontend
docker build --platform linux/amd64 --tag hsense/facility-erp-frontend:latest --file apps/frontend/Dockerfile apps/frontend
docker push hsense/facility-erp-frontend:latest

# Build and push backend
docker build --platform linux/amd64 --tag hsense/facility-erp-backend:latest --file apps/backend/Dockerfile apps/backend
docker push hsense/facility-erp-backend:latest
```

---

## Method 2: Using the Build Script (Recommended)

The project has a script that automates the process:

```bash
# Build and push both images
./scripts/build-push-latest.sh

# Or with options
./scripts/build-push-latest.sh --skip-build  # Only push existing images
./scripts/build-push-latest.sh --skip-push   # Only build, don't push
```

---

## Step-by-Step Process

### 1. Check Docker Status

```bash
# Verify Docker is running
docker info

# Check if logged in to Docker Hub
docker info | grep Username
```

### 2. Login to Docker Hub (if not already)

```bash
docker login -u hsense
# Enter password when prompted
```

### 3. Navigate to Project Root

```bash
cd /Users/viveke/Developer/HelixSense/Workspace/iOS/14Aug2025/facility-erp
```

### 4. Build Frontend Image

```bash
docker build \
  --platform linux/amd64 \
  --tag hsense/facility-erp-frontend:latest \
  --file apps/frontend/Dockerfile \
  apps/frontend
```

**What this does:**

- `--platform linux/amd64`: Builds for Linux AMD64 (production server architecture)
- `--tag hsense/facility-erp-frontend:latest`: Tags the image with repository name and `latest` tag
- `--file apps/frontend/Dockerfile`: Specifies the Dockerfile location
- `apps/frontend`: Build context (directory containing source files)

**Expected output:**

- Shows build progress
- Ends with: `writing image sha256:... done`
- `naming to docker.io/hsense/facility-erp-frontend:latest done`

### 5. Push Frontend Image

```bash
docker push hsense/facility-erp-frontend:latest
```

**What this does:**

- Uploads the image to Docker Hub
- Makes it available for pulling on production servers

**Expected output:**

- Shows layer upload progress
- Ends with: `latest: digest: sha256:... size: ...`

### 6. Build Backend Image

```bash
docker build \
  --platform linux/amd64 \
  --tag hsense/facility-erp-backend:latest \
  --file apps/backend/Dockerfile \
  apps/backend
```

### 7. Push Backend Image

```bash
docker push hsense/facility-erp-backend:latest
```

---

## Verification

### Check Images Locally

```bash
# List all images
docker images | grep hsense

# Should show:
# hsense/facility-erp-frontend   latest   <image-id>   <time>   <size>
# hsense/facility-erp-backend    latest   <image-id>   <time>   <size>
```

### Verify Push Success

```bash
# Check if images are on Docker Hub (requires docker login)
docker pull hsense/facility-erp-frontend:latest
docker pull hsense/facility-erp-backend:latest
```

---

## Common Issues and Solutions

### Issue: "denied: requested access to the resource is denied"

**Solution:**

```bash
# Login to Docker Hub
docker login -u hsense
```

### Issue: "Cannot connect to the Docker daemon"

**Solution:**

```bash
# Start Docker Desktop (macOS/Windows)
# Or start Docker service (Linux)
sudo systemctl start docker
```

### Issue: Build fails with "platform" error

**Solution:**

- Ensure Docker Desktop has "Use containerd" enabled
- Or use `docker buildx` for multi-platform builds

### Issue: Push is slow

**Solution:**

- This is normal for first push (all layers)
- Subsequent pushes are faster (only changed layers)
- Check your internet connection

---

## Quick Commands Reference

### Build Both Images

```bash
# Frontend
docker build --platform linux/amd64 --tag hsense/facility-erp-frontend:latest --file apps/frontend/Dockerfile apps/frontend

# Backend
docker build --platform linux/amd64 --tag hsense/facility-erp-backend:latest --file apps/backend/Dockerfile apps/backend
```

### Push Both Images

```bash
docker push hsense/facility-erp-frontend:latest
docker push hsense/facility-erp-backend:latest
```

### One-Liner (Build + Push Both)

```bash
# Frontend
docker build --platform linux/amd64 --tag hsense/facility-erp-frontend:latest --file apps/frontend/Dockerfile apps/frontend && docker push hsense/facility-erp-frontend:latest

# Backend
docker build --platform linux/amd64 --tag hsense/facility-erp-backend:latest --file apps/backend/Dockerfile apps/backend && docker push hsense/facility-erp-backend:latest
```

---

## Using Version Tags (Best Practice)

Instead of always using `latest`, you can tag with versions:

```bash
# Build with version tag
docker build --platform linux/amd64 --tag hsense/facility-erp-frontend:v1.0.2 --file apps/frontend/Dockerfile apps/frontend

# Push version tag
docker push hsense/facility-erp-frontend:v1.0.2

# Also push as latest
docker tag hsense/facility-erp-frontend:v1.0.2 hsense/facility-erp-frontend:latest
docker push hsense/facility-erp-frontend:latest
```

---

## Time Estimates

- **Frontend build**: ~3-5 minutes (first time), ~1-2 minutes (cached)
- **Backend build**: ~1-2 minutes (first time), ~30 seconds (cached)
- **Push**: ~1-3 minutes per image (depends on internet speed and image size)

---

## Next Steps After Pushing

On your production server:

```bash
# Pull latest images
docker-compose -f docker-compose.prod.yml pull

# Restart services
docker-compose -f docker-compose.prod.yml up -d --force-recreate

# Verify
docker-compose -f docker-compose.prod.yml ps
```

---

## Summary

**Quick Steps:**

1. `cd` to project root
2. `docker build` (frontend or backend)
3. `docker push` (same image)
4. Repeat for other image if needed
5. Deploy on production server

**Remember:**

- Always use `--platform linux/amd64` for production
- Tag as `:latest` for easy deployment
- Verify push success before deploying
