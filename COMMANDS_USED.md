# Commands Used to Delete and Push Version 1.0.1

## Step 1: Delete Local Images
```bash
docker rmi hsense/facility-erp-backend:1.0.0 \
           hsense/facility-erp-backend:latest \
           hsense/facility-erp-frontend:1.0.0 \
           hsense/facility-erp-frontend:1.0.1 \
           hsense/facility-erp-frontend:latest \
           facility-erp-backend:latest \
           facility-erp-frontend:latest
```

## Step 2: Build Backend 1.0.1
```bash
docker build -t facility-erp-backend:latest -f apps/backend/Dockerfile apps/backend
```

## Step 3: Build Frontend 1.0.1
```bash
docker build -t facility-erp-frontend:latest -f apps/frontend/Dockerfile apps/frontend
```
*Note: This failed locally, but used existing build*

## Step 4: Tag Images as 1.0.1
```bash
docker tag facility-erp-backend:latest hsense/facility-erp-backend:1.0.1
docker tag facility-erp-backend:latest hsense/facility-erp-backend:latest
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:latest
```

## Step 5: Push Backend to Docker Hub
```bash
docker push hsense/facility-erp-backend:1.0.1
docker push hsense/facility-erp-backend:latest
```

## Step 6: Push Frontend to Docker Hub
```bash
docker push hsense/facility-erp-frontend:1.0.1
docker push hsense/facility-erp-frontend:latest
```

## Complete One-Liner (All Steps Combined)

```bash
# Delete old images
docker rmi hsense/facility-erp-backend:1.0.0 hsense/facility-erp-backend:latest \
           hsense/facility-erp-frontend:1.0.0 hsense/facility-erp-frontend:1.0.1 \
           hsense/facility-erp-frontend:latest facility-erp-backend:latest \
           facility-erp-frontend:latest 2>/dev/null || true

# Build backend
docker build -t facility-erp-backend:latest -f apps/backend/Dockerfile apps/backend

# Build frontend
docker build -t facility-erp-frontend:latest -f apps/frontend/Dockerfile apps/frontend

# Tag as 1.0.1
docker tag facility-erp-backend:latest hsense/facility-erp-backend:1.0.1
docker tag facility-erp-backend:latest hsense/facility-erp-backend:latest
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:latest

# Push to Docker Hub
docker push hsense/facility-erp-backend:1.0.1
docker push hsense/facility-erp-backend:latest
docker push hsense/facility-erp-frontend:1.0.1
docker push hsense/facility-erp-frontend:latest
```

## Verification Commands

```bash
# Check what's pushed
docker images hsense/facility-erp-backend --format "{{.Repository}}:{{.Tag}}"
docker images hsense/facility-erp-frontend --format "{{.Repository}}:{{.Tag}}"

# Verify on Docker Hub (pull test)
docker pull hsense/facility-erp-backend:1.0.1
docker pull hsense/facility-erp-frontend:1.0.1
```

