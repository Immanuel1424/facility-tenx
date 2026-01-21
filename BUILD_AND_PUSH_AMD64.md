# Build Frontend (nginx) for AMD64 and Push

## ✅ Good News: Flutter Web Build Succeeded Locally!

The Flutter web build completed successfully. Now we need to create the nginx Docker image on your production server (AMD64).

## Option 1: Use the Automated Script (Recommended)

The script builds Flutter locally, then creates nginx image on server:

```bash
# Update the server address in the script or pass it as argument
./scripts/build-push-frontend-amd64.sh 1.0.1 ubuntu@YOUR_SERVER_IP /opt/tenx
```

Replace `YOUR_SERVER_IP` with your actual server IP or hostname.

## Option 2: Manual Two-Step Process

### Step 1: Build Flutter Web Locally (Already Done ✅)

```bash
cd apps/frontend
flutter build web --release
```

### Step 2: Create nginx Image on Production Server

**On your production server, run:**

```bash
# 1. Copy build output to server (from your Mac)
scp -r apps/frontend/build/web ubuntu@YOUR_SERVER_IP:/tmp/frontend-web/
scp apps/frontend/nginx.conf ubuntu@YOUR_SERVER_IP:/tmp/frontend-web/ 2>/dev/null || echo "nginx.conf optional"

# 2. SSH to server
ssh ubuntu@YOUR_SERVER_IP

# 3. Create Dockerfile on server
cat > /tmp/frontend-web/Dockerfile << 'EOF'
FROM nginx:alpine
RUN apk add --no-cache curl
COPY web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf 2>/dev/null || true
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost/health || exit 1
CMD ["nginx", "-g", "daemon off;"]
EOF

# 4. Build image (will be AMD64 on Linux server)
cd /tmp/frontend-web
docker build -t facility-erp-frontend:latest .

# 5. Tag and push
docker login -u hsense
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:latest
docker push hsense/facility-erp-frontend:1.0.1
docker push hsense/facility-erp-frontend:latest

echo "✅ Version 1.0.1 pushed to Docker Hub!"
```

## Option 3: Build Everything on Server (Simplest)

If you have the source code on the server:

```bash
# On production server
cd /opt/tenx
docker build -t facility-erp-frontend:latest -f apps/frontend/Dockerfile apps/frontend
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:latest
docker push hsense/facility-erp-frontend:1.0.1
docker push hsense/facility-erp-frontend:latest
```

## Quick One-Liner for Server

```bash
cd /opt/tenx && docker build -t facility-erp-frontend:latest -f apps/frontend/Dockerfile apps/frontend && docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1 && docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:latest && docker push hsense/facility-erp-frontend:1.0.1 && docker push hsense/facility-erp-frontend:latest && echo "✅ Pushed!"
```

