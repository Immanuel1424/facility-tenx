# Docker Image Cleanup Guide

## Quick Start - Use the Cleanup Script

**Recommended**: Use the automated cleanup script:

```bash
# Interactive menu
./scripts/docker-cleanup.sh

# Or use command-line options
./scripts/docker-cleanup.sh --unused      # Remove unused images (recommended)
./scripts/docker-cleanup.sh --aggressive  # Keep only final 2 images
./scripts/docker-cleanup.sh --build       # Remove specific build images
./scripts/docker-cleanup.sh --full        # Full system cleanup
./scripts/docker-cleanup.sh --help        # Show help
```

## Understanding Docker Images

### Final Runtime Images (Keep These)
- `facility-erp-backend:latest` - Your backend application (436MB)
- `facility-erp-frontend:latest` - Your frontend application (175MB)

### Build-Time Images (Can Be Removed)
- `ghcr.io/cirruslabs/flutter:stable` - Flutter SDK (5.72GB, only needed during build)
- `node:20-alpine` - Node.js base (192MB, only needed during build)
- `nginx:alpine` - Already included in frontend image (81MB)

## Manual Cleanup Commands

### Remove Unused Build Images
```bash
# Remove dangling/intermediate build images
docker image prune -a

# Remove specific unused base images
docker rmi ghcr.io/cirruslabs/flutter:stable
docker rmi node:20-alpine
```

### Keep Only Final Images
```bash
# Remove all images except your final ones
docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "facility-erp" | xargs docker rmi
```

### Full Cleanup (Removes Everything Unused)
```bash
# Remove all unused images, containers, networks, and build cache
docker system prune -a --volumes
```

## Image Size Optimization

### Current Sizes
- Backend: 436MB (can be optimized to ~150MB)
- Frontend: 175MB (already optimized)

### Why Backend is Large
The backend image includes:
- Node.js runtime (~50MB)
- Production dependencies (~200MB)
- Compiled code (~10MB)
- System packages (~10MB)

**Note**: 436MB is reasonable for a Node.js app with dependencies. The multi-stage build already optimizes it.

## Best Practices

1. **Keep base images cached** for faster rebuilds (they're shared across projects)
2. **Remove only if disk space is critical**
3. **Use `docker system prune` periodically** to clean up unused resources
4. **The final images are what matter** - those are what run in production

## Verify What's Actually Running

```bash
# See only running containers
docker ps

# See disk usage
docker system df

# See detailed image sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

