# Cleanup Script Safety Improvements

## ✅ What Changed

The cleanup script has been updated to **always preserve** your final production images:
- `facility-erp-backend:latest`
- `facility-erp-frontend:latest`

## 🛡️ Safety Features

### 1. **Protected Images**
All cleanup functions now automatically exclude your final production images from removal.

### 2. **Smart Cleanup**
- `--unused`: Removes unused images but preserves facility-erp images
- `--build`: Removes specific build images but preserves facility-erp images
- `--full`: Full system cleanup but preserves facility-erp images
- `--aggressive`: Explicitly removes all except facility-erp images (unchanged)

### 3. **Error Handling**
- Script no longer exits on errors
- Gracefully handles images that can't be removed (e.g., in use)
- Shows clear warnings when images are protected

## 📋 Usage Examples

### Safe Cleanup (Recommended)
```bash
# Removes unused images, keeps your production images
./scripts/docker-cleanup.sh --unused
```

### Remove Build Images Only
```bash
# Removes Flutter, Node.js, nginx base images
# Keeps your production images safe
./scripts/docker-cleanup.sh --build
```

### Full Cleanup
```bash
# Removes everything unused except your production images
./scripts/docker-cleanup.sh --full
```

## 🔒 What's Protected

The following images are **always preserved**:
- ✅ `facility-erp-backend:latest`
- ✅ `facility-erp-frontend:latest`

## ⚠️ What Can Be Removed

These images can be safely removed (they're only needed for building):
- `ghcr.io/cirruslabs/flutter:stable` (~5.72GB)
- `node:20-alpine` (~192MB)
- `nginx:alpine` (~81MB)
- Any other unused images

## 🎯 Best Practice

1. **For Development**: Keep build images cached for faster rebuilds
2. **For Production**: Remove build images to save space
3. **Always Safe**: Your production images are never removed

## 📊 Expected Results

After cleanup with `--unused`:
- **Kept**: 2 images (~611MB total)
  - facility-erp-backend:latest (436MB)
  - facility-erp-frontend:latest (175MB)
- **Removed**: Build images (~6GB reclaimed)

---

**Last Updated**: 2025-12-31
**Status**: ✅ Production images are now always protected

