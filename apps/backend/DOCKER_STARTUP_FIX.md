# Backend Docker Startup Fix

## Issue Summary

**Date:** December 30, 2025  
**Status:** ✅ Resolved  
**Severity:** Critical (Prevented backend from starting)

### Problem

The backend container was failing to start with the following error:

```
Error: EACCES: permission denied, open 'openapi-v1.json'
    at writeFileSync (node:fs:2368:20)
    at bootstrap (/app/dist/main.js:77:28)
```

### Root Cause

The application was attempting to write the OpenAPI specification file (`openapi-v1.json`) to the `/app` directory during startup. However, the Docker container runs as a non-root user (`nestjs`) for security reasons, and this user does not have write permissions to the `/app` directory (which is owned by `root`).

**Key Points:**
- The Dockerfile creates a non-root user `nestjs` (UID 1001) for security
- The `/app` directory is owned by `root` and is read-only for the `nestjs` user
- The `writeFileSync` call in `main.ts` was failing, causing the entire application to crash before it could start listening on port 3000

### Solution Applied

The fix involved two changes to `apps/backend/src/main.ts`:

#### 1. Made OpenAPI File Write Optional

Wrapped the `writeFileSync` operation in a try-catch block so that if the file cannot be written, the application logs a warning but continues to start:

```typescript
// Persist OpenAPI spec for client generation (optional - don't fail if write fails)
try {
  const openApiPath = join(process.cwd(), 'openapi-v1.json');
  writeFileSync(openApiPath, JSON.stringify(document, null, 2));
} catch (error) {
  // Log warning but don't fail startup if OpenAPI file can't be written
  console.warn('Warning: Could not write openapi-v1.json file:', error instanceof Error ? error.message : String(error));
}
```

#### 2. Fixed PORT Environment Variable Usage

Changed from hardcoded port to use environment variable:

```typescript
// Before
await app.listen(3000);

// After
const port = process.env.PORT || 3000;
await app.listen(port);
console.log(`Application is running on: http://localhost:${port}/api`);
```

### Verification

After applying the fix, verify the backend is running:

```bash
# Check container status
docker ps --filter "name=facility-erp-backend"

# Check logs for successful startup
docker logs facility-erp-backend --tail=50

# Test health endpoint
curl http://localhost:3000/api/v1/health

# Test Swagger UI
curl -I http://localhost:3000/api/docs
```

**Expected Output:**
- Container status: `Up X seconds (healthy)`
- Logs should show: `Nest application successfully started` and `Application is running on: http://localhost:3000/api`
- Health endpoint returns: `{"success":true,"data":{"status":"ok",...}}`
- Swagger UI returns: `HTTP/1.1 200 OK`

### Alternative Solutions Considered

1. **Write to `/app/uploads` directory** (writable by `nestjs` user)
   - **Rejected:** The OpenAPI file is not user uploads, so semantically incorrect location

2. **Change `/app` directory permissions in Dockerfile**
   - **Rejected:** Security risk - non-root user should not have write access to application directory

3. **Write to `/tmp` directory**
   - **Rejected:** File would be lost on container restart, and not accessible for client generation

4. **Make write optional (chosen solution)**
   - **Accepted:** The OpenAPI spec is already available via `/api/docs-json` endpoint, so file persistence is optional

### Impact

- ✅ Backend now starts successfully in Docker containers
- ✅ OpenAPI documentation remains accessible via `/api/docs` endpoint
- ✅ OpenAPI JSON spec available via `/api/docs-json` endpoint
- ⚠️ `openapi-v1.json` file is not written to disk in production containers (but can be generated manually if needed)

### Related Files

- `apps/backend/src/main.ts` - Main application entry point
- `apps/backend/Dockerfile` - Container build configuration
- `docker-compose.yml` - Service orchestration

### Prevention

To prevent similar issues in the future:

1. **Always test file write operations** in a try-catch block when writing to application directories
2. **Use environment variables** for configuration values (ports, paths, etc.)
3. **Test Docker builds** after making changes to startup code
4. **Consider using volumes** for files that need to persist outside the container

### Manual OpenAPI File Generation

If you need to generate the `openapi-v1.json` file manually:

```bash
# Option 1: From within the container (if you have write access to a volume)
docker exec facility-erp-backend sh -c "curl -s http://localhost:3000/api/docs-json > /app/uploads/openapi-v1.json"

# Option 2: From host machine
curl -s http://localhost:3000/api/docs-json > openapi-v1.json

# Option 3: During development (before Docker build)
cd apps/backend
npm run start:dev
# File will be written to apps/backend/openapi-v1.json
```

### References

- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [NestJS Application Lifecycle](https://docs.nestjs.com/fundamentals/lifecycle-events)
- [OpenAPI Specification](https://swagger.io/specification/)

---

**Last Updated:** December 30, 2025  
**Maintained By:** Development Team

