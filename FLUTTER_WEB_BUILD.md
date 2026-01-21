# Flutter Web Build - Architecture Considerations

## Understanding the Architecture Issue

For Flutter web builds:
- ✅ **Flutter web output (JS/WASM)** is platform-agnostic - can be built anywhere
- ❌ **nginx container** is architecture-specific - must match production server

## The Problem

When you build on macOS:
- Flutter compiles to JS/WASM (platform-agnostic) ✅
- But `nginx:alpine` base image is pulled for ARM64 ❌
- The nginx binary won't run on AMD64 production server ❌

## Solutions

### Option 1: Build Entire Image on Production Server (Recommended)

```bash
# On production server
docker build -t facility-erp-frontend:latest -f apps/frontend/Dockerfile apps/frontend
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1
docker push hsense/facility-erp-frontend:1.0.1
```

### Option 2: Build Flutter Web Locally, Create nginx Image on Server

**Step 1: Build Flutter web locally (platform-agnostic output)**
```bash
# On your Mac
cd apps/frontend
flutter build web --release
```

**Step 2: Create nginx image on production server**
```bash
# On production server - create a simple Dockerfile
cat > Dockerfile.frontend << 'EOF'
FROM nginx:alpine
RUN apk add --no-cache curl
COPY build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN chown -R nginx:nginx /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost/health || exit 1
CMD ["nginx", "-g", "daemon off;"]
EOF

# Copy build output from Mac to server
scp -r apps/frontend/build/web ubuntu@ip-10-1-22-14:/tmp/frontend-web/
scp apps/frontend/nginx.conf ubuntu@ip-10-1-22-14:/tmp/frontend-web/

# On server, build image
docker build -t facility-erp-frontend:latest -f Dockerfile.frontend /tmp/frontend-web/
```

### Option 3: Use Multi-Stage Build with Buildx (If Available)

If you have buildx on macOS:
```bash
docker buildx build --platform linux/amd64 \
  -t hsense/facility-erp-frontend:1.0.1 \
  --push \
  -f apps/frontend/Dockerfile \
  apps/frontend
```

## Recommendation

**For Flutter web only**: Build on production server is simplest because:
1. Flutter web build is fast
2. nginx image will be correct architecture
3. No need to transfer files

Run this on your production server:
```bash
./scripts/build-push-frontend-only.sh 1.0.1
```

