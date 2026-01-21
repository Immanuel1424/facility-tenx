#!/bin/bash

# Build Flutter Web Locally (Platform-Agnostic)
# Then create nginx image on production server
# 
# This approach:
# 1. Builds Flutter web locally (fast, platform-agnostic output)
# 2. Creates nginx container on production server (correct architecture)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

VERSION="${1:-1.0.1}"
SERVER_USER="${2:-ubuntu@ip-10-1-22-14}"
SERVER_PATH="${3:-/opt/tenx}"

print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

print_info "Building Flutter web locally (platform-agnostic)..."
echo ""

# Step 1: Build Flutter web locally
cd apps/frontend

if ! command -v flutter &> /dev/null; then
    print_error "Flutter not found. Please install Flutter first."
    exit 1
fi

print_info "Running: flutter build web --release"
if flutter build web --release; then
    print_success "Flutter web built successfully!"
else
    print_error "Flutter build failed!"
    exit 1
fi

# Step 2: Create temporary directory for Docker build context
TEMP_DIR=$(mktemp -d)
print_info "Creating Docker build context in: $TEMP_DIR"

# Copy built web files
cp -r build/web "$TEMP_DIR/"
cp nginx.conf "$TEMP_DIR/" 2>/dev/null || print_warning "nginx.conf not found, will use default"

# Create Dockerfile for nginx
cat > "$TEMP_DIR/Dockerfile" << 'EOF'
FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Copy built web app to nginx
COPY web /usr/share/nginx/html

# Copy nginx configuration if it exists, otherwise use default
COPY nginx.conf /etc/nginx/conf.d/default.conf 2>/dev/null || true

# Set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create .dockerignore
cat > "$TEMP_DIR/.dockerignore" << 'EOF'
node_modules
.git
*.md
EOF

print_success "Docker build context created"
echo ""

# Step 3: Copy to server and build
print_info "Copying build context to server..."
print_info "Server: $SERVER_USER"
print_info "Path: $SERVER_PATH"

# Create remote directory
ssh "$SERVER_USER" "mkdir -p $SERVER_PATH/tmp/frontend-build"

# Copy files
scp -r "$TEMP_DIR"/* "$SERVER_USER:$SERVER_PATH/tmp/frontend-build/"

print_success "Files copied to server"
echo ""

# Step 4: Build Docker image on server
print_info "Building Docker image on server (will be linux/amd64)..."
echo ""

ssh "$SERVER_USER" << EOF
cd $SERVER_PATH/tmp/frontend-build
docker build -t facility-erp-frontend:latest .
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:${VERSION}
docker tag facility-erp-frontend:latest hsense/facility-erp-frontend:latest
echo "✅ Images tagged on server"
EOF

print_success "Docker image built on server!"
echo ""

# Step 5: Ask to push
read -p "Push to Docker Hub? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Pushing to Docker Hub..."
    ssh "$SERVER_USER" << EOF
docker push hsense/facility-erp-frontend:${VERSION}
docker push hsense/facility-erp-frontend:latest
EOF
    print_success "Pushed to Docker Hub!"
else
    print_info "Skipped push. Images are ready on server."
    print_info "To push manually, SSH to server and run:"
    echo "  docker push hsense/facility-erp-frontend:${VERSION}"
    echo "  docker push hsense/facility-erp-frontend:latest"
fi

# Cleanup
rm -rf "$TEMP_DIR"
print_info "Cleaned up temporary files"

echo ""
print_success "All done! 🚀"
print_info "Version: $VERSION"
print_info "Image: hsense/facility-erp-frontend:$VERSION"

