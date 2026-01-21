# Building Flutter Web for Production

Since your Flutter app is **web-only** (runs in browsers), here are your options:

## Understanding the Architecture

- ✅ **Flutter web output (JS/WASM)**: Platform-agnostic - can be built anywhere
- ❌ **nginx Docker container**: Architecture-specific - must match server (AMD64)

## Option 1: Build Everything on Production Server (Simplest)

**Recommended** - Builds everything in one place with correct architecture:

```bash
# On production server
cd /opt/tenx
docker build -t facility-erp-frontend:latest -f apps/frontend/Dockerfile apps/frontend
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1
docker push hsense/facility-erp-frontend:1.0.1
```

**Pros:**
- Simple, one command
- Correct architecture automatically
- No file transfers needed

**Cons:**
- Requires source code on server
- Flutter build happens on server (slower if server is slow)

## Option 2: Build Flutter Locally, Create nginx on Server (Hybrid)

Build Flutter web locally (fast), then create nginx image on server:

```bash
# On your Mac
./scripts/build-flutter-web-local.sh 1.0.1
```

This script:
1. Builds Flutter web locally (platform-agnostic JS/WASM)
2. Copies build output to server
3. Creates nginx Docker image on server (correct architecture)
4. Tags and optionally pushes to Docker Hub

**Pros:**
- Fast Flutter build on your Mac
- Correct nginx architecture on server
- No need for full source code on server

**Cons:**
- Requires SSH access to server
- Two-step process

## Option 3: Manual Two-Step Process

**Step 1: Build Flutter web locally**
```bash
cd apps/frontend
flutter build web --release
```

**Step 2: Create nginx image on server**
```bash
# Copy build output to server
scp -r apps/frontend/build/web ubuntu@ip-10-1-22-14:/tmp/frontend-web/
scp apps/frontend/nginx.conf ubuntu@ip-10-1-22-14:/tmp/frontend-web/

# On server, create Dockerfile
cat > /tmp/frontend-web/Dockerfile << 'EOF'
FROM nginx:alpine
RUN apk add --no-cache curl
COPY web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN chown -R nginx:nginx /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost/health || exit 1
CMD ["nginx", "-g", "daemon off;"]
EOF

# Build and push
docker build -t facility-erp-frontend:latest /tmp/frontend-web/
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:1.0.1
docker push hsense/facility-erp-frontend:1.0.1
```

## Recommendation

**For web-only apps**: Use **Option 1** (build on server) because:
- Flutter web builds are fast
- Simpler workflow
- No file transfers needed
- Correct architecture guaranteed

Run this on your production server:
```bash
./scripts/build-push-frontend-only.sh 1.0.1
```

