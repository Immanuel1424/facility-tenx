#!/bin/bash
# Build and Push to Docker Hub - Version 1.0.1
# Run this on your PRODUCTION SERVER (Linux)

set -e

VERSION="1.0.1"
DOCKER_USERNAME="hsense"

echo "🚀 Building and pushing version $VERSION to Docker Hub..."
echo ""

# Build backend
echo "📦 Building backend..."
docker build -t facility-erp-backend:latest -f apps/backend/Dockerfile apps/backend

# Build frontend
echo "📦 Building frontend..."
docker build -t facility-erp-frontend:latest -f apps/frontend/Dockerfile apps/frontend

# Tag backend
echo "🏷️  Tagging backend..."
docker tag facility-erp-backend:latest ${DOCKER_USERNAME}/facility-erp-backend:${VERSION}
docker tag facility-erp-backend:latest ${DOCKER_USERNAME}/facility-erp-backend:latest

# Tag frontend
echo "🏷️  Tagging frontend..."
docker tag facility-erp-frontend:latest ${DOCKER_USERNAME}/facility-erp-frontend:${VERSION}
docker tag facility-erp-frontend:latest ${DOCKER_USERNAME}/facility-erp-frontend:latest

# Push backend
echo "⬆️  Pushing backend..."
docker push ${DOCKER_USERNAME}/facility-erp-backend:${VERSION}
docker push ${DOCKER_USERNAME}/facility-erp-backend:latest

# Push frontend
echo "⬆️  Pushing frontend..."
docker push ${DOCKER_USERNAME}/facility-erp-frontend:${VERSION}
docker push ${DOCKER_USERNAME}/facility-erp-frontend:latest

echo ""
echo "✅ Successfully pushed version $VERSION to Docker Hub!"
echo ""
echo "Images:"
echo "  - ${DOCKER_USERNAME}/facility-erp-backend:${VERSION}"
echo "  - ${DOCKER_USERNAME}/facility-erp-frontend:${VERSION}"
echo "  - ${DOCKER_USERNAME}/facility-erp-backend:latest"
echo "  - ${DOCKER_USERNAME}/facility-erp-frontend:latest"

