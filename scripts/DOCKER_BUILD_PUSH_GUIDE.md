# Docker Build and Push Script Guide

## Overview

The `docker-build-push.sh` script automates the complete workflow:
1. **Build** Docker images
2. **Tag** with version numbers
3. **Push** to Docker Hub

## Quick Start

### Basic Usage (Auto-detect version from git)
```bash
./scripts/docker-build-push.sh
```

### With explicit version
```bash
./scripts/docker-build-push.sh -v 1.0.0
```

### Skip build (only tag and push existing images)
```bash
./scripts/docker-build-push.sh -v 1.0.0 --skip-build
```

## Version Management

### Automatic Version Detection
The script tries to detect version in this order:
1. **Git tag** (if current commit has a tag)
2. **Latest git tag + commit hash** (e.g., `v1.0.0-abc1234`)
3. **Manual version** (via `-v` flag)
4. **Fallback to 'latest'**

### Version Formats Supported
- Semantic versioning: `1.0.0`, `v1.0.0`
- With pre-release: `1.0.0-beta`, `v1.0.0-rc1`
- With build metadata: `1.0.0+build123`
- Latest: `latest`

## Common Workflows

### 1. Release a New Version
```bash
# Tag in git first
git tag v1.0.0
git push origin v1.0.0

# Build and push with version
./scripts/docker-build-push.sh -v 1.0.0 --push-latest
```

### 2. Development Build
```bash
# Auto-detect version from git
./scripts/docker-build-push.sh
```

### 3. Quick Push (No Build)
```bash
# Use existing images, just tag and push
./scripts/docker-build-push.sh -v 1.0.1 --skip-build
```

### 4. Push Latest Tag
```bash
# Also update 'latest' tag on Docker Hub
./scripts/docker-build-push.sh -v 1.0.0 --push-latest
```

## Command Options

| Option | Description | Example |
|--------|-------------|---------|
| `-v, --version` | Version to tag and push | `-v 1.0.0` |
| `--skip-build` | Skip building, only tag/push | `--skip-build` |
| `--push-latest` | Also push 'latest' tag | `--push-latest` |
| `-f, --file` | Docker compose file | `-f docker-compose.prod.yml` |
| `-h, --help` | Show help message | `--help` |

## Examples

### Example 1: First Release
```bash
# Build, tag as 1.0.0, and push
./scripts/docker-build-push.sh -v 1.0.0 --push-latest
```

**Result:**
- Images tagged as: `hsense/facility-erp-backend:1.0.0`
- Images tagged as: `hsense/facility-erp-frontend:1.0.0`
- Also tagged as: `hsense/facility-erp-backend:latest`
- Also tagged as: `hsense/facility-erp-frontend:latest`
- All pushed to Docker Hub

### Example 2: Patch Release
```bash
# Build and push patch version
./scripts/docker-build-push.sh -v 1.0.1
```

**Result:**
- Images tagged as: `hsense/facility-erp-backend:1.0.1`
- Images tagged as: `hsense/facility-erp-frontend:1.0.1`
- Pushed to Docker Hub

### Example 3: Pre-release
```bash
# Build and push beta version
./scripts/docker-build-push.sh -v 1.1.0-beta
```

### Example 4: Using Git Tags
```bash
# Create git tag
git tag v1.2.0
git push origin v1.2.0

# Checkout the tag
git checkout v1.2.0

# Build and push (auto-detects version from git)
./scripts/docker-build-push.sh
```

## Workflow Integration

### CI/CD Pipeline
```bash
#!/bin/bash
# In your CI/CD script

VERSION=${CI_COMMIT_TAG:-"latest"}
./scripts/docker-build-push.sh -v "$VERSION" --push-latest
```

### Manual Release Process
```bash
# 1. Update version in code
# 2. Commit changes
git commit -m "Release v1.0.0"

# 3. Create git tag
git tag v1.0.0

# 4. Build and push
./scripts/docker-build-push.sh -v 1.0.0 --push-latest

# 5. Push git tag
git push origin v1.0.0
```

## Image Naming Convention

Images are tagged as:
- `hsense/facility-erp-backend:VERSION`
- `hsense/facility-erp-frontend:VERSION`

Where `VERSION` can be:
- Semantic version: `1.0.0`, `v1.0.0`
- Latest: `latest`
- Git-based: `v1.0.0-abc1234`

## Pulling Images

After pushing, you can pull images with:
```bash
# Specific version
docker pull hsense/facility-erp-backend:1.0.0
docker pull hsense/facility-erp-frontend:1.0.0

# Latest
docker pull hsense/facility-erp-backend:latest
docker pull hsense/facility-erp-frontend:latest
```

## Troubleshooting

### Error: "Docker is not running"
```bash
# Start Docker Desktop or Docker daemon
```

### Error: "Not logged in to Docker Hub"
```bash
# Login to Docker Hub
docker login -u hsense
```

### Error: "Images not found"
```bash
# Build images first (remove --skip-build flag)
./scripts/docker-build-push.sh -v 1.0.0
```

### Error: "Invalid version format"
```bash
# Use semantic versioning
./scripts/docker-build-push.sh -v 1.0.0  # ✓ Valid
./scripts/docker-build-push.sh -v v1.0.0  # ✓ Valid
./scripts/docker-build-push.sh -v 1.0     # ✗ Invalid
```

## Best Practices

1. **Use Semantic Versioning**: Follow `MAJOR.MINOR.PATCH` format
2. **Tag in Git First**: Create git tags before building images
3. **Push Latest for Stable**: Use `--push-latest` for stable releases
4. **Test Before Pushing**: Build and test locally before pushing
5. **Version Consistency**: Keep version in sync across:
   - Git tags
   - package.json (backend)
   - pubspec.yaml (frontend)
   - Docker images

## Quick Reference

```bash
# Most common commands
./scripts/docker-build-push.sh -v 1.0.0 --push-latest  # Full release
./scripts/docker-build-push.sh -v 1.0.1               # Patch release
./scripts/docker-build-push.sh --skip-build -v 1.0.2   # Quick push
./scripts/docker-build-push.sh                         # Auto-detect version
```

---

**Last Updated**: 2025-12-31
**Script**: `scripts/docker-build-push.sh`

