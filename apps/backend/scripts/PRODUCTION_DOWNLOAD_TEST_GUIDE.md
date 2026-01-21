# Production Download Test Guide

This guide helps you test the file download functionality in production to ensure it works correctly.

## Quick Test

Run the production test script:

```bash
npm run test:download-production
```

Or with a specific file:

```bash
npm run test:download-production -- "tenx-attachments/maintenance-ticket/{ticketId}/{fileId}.jpg"
```

## Test Against Production Domain

To test against the actual production domain:

1. Set the production domain in `.env`:
   ```bash
   PRODUCTION_DOMAIN=tenx-demo.helixsense.com
   ```

2. Get a valid JWT token from production:
   ```bash
   curl -X POST https://tenx-demo.helixsense.com/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"siteCode":"","email":"superadmin@system.local","password":"SuperAdmin@2025!"}'
   ```

3. Set the token in `.env`:
   ```bash
   TEST_JWT_TOKEN=your-token-here
   ```

4. Run the test:
   ```bash
   npm run test:download-production
   ```

## What the Test Covers

### ✅ Test 1: Redirect Endpoint via API Route
- Tests: `GET /api/v1/uploads/{storagePath}`
- Expected: 302 redirect to S3 presigned URL
- **This is what nginx proxies to in production**

### ✅ Test 2: Follow Redirect and Download
- Follows the redirect to S3
- Downloads and validates the file
- Verifies it's a valid image

### ✅ Test 3: Generic Presigned URL Endpoint
- Tests: `GET /api/v1/uploads/presigned-url?storagePath=...`
- Expected: Returns presigned URL JSON response
- **This is the new pattern for frontend**

### ✅ Test 4: Authentication Check
- Tests without JWT token
- Expected: 401 Unauthorized

### ✅ Test 5: Invalid Path Validation
- Tests with invalid storage path
- Expected: 404 or 400 error

### ✅ Test 6: Full End-to-End Flow
- Simulates browser behavior
- Requests redirect endpoint
- Follows redirect to S3
- Downloads file successfully

### ✅ Test 7: Production Domain Test (if configured)
- Tests actual production domain
- Simulates: Frontend -> Nginx -> Backend -> S3

## Production Deployment Checklist

Before deploying to production, verify:

- [ ] Backend redirect endpoint is working (`GET /api/v1/uploads/*`)
- [ ] Generic presigned URL endpoint is working (`GET /api/v1/uploads/presigned-url`)
- [ ] Nginx is configured to proxy `/uploads/` to `/api/v1/uploads/`
- [ ] Nginx passes `Authorization` header to backend
- [ ] S3 credentials are configured correctly
- [ ] Files exist in S3 at the expected paths
- [ ] JWT authentication is working

## Common Production Issues

### Issue: 404 Not Found on `/uploads/...`

**Cause:** Nginx not proxying correctly or route not matching

**Solution:**
1. Check nginx configuration:
   ```nginx
   location /uploads/ {
       proxy_pass http://localhost:3000/api/v1/uploads/;
       proxy_set_header Authorization $http_authorization;
   }
   ```

2. Verify the backend route is registered:
   - Check that `UploadsModule` is imported in `AppModule`
   - Verify `@Get('*')` route in `UploadController`

### Issue: 401 Unauthorized

**Cause:** JWT token not being passed or expired

**Solution:**
1. Check that frontend includes `Authorization: Bearer {token}` header
2. Verify token is not expired
3. Check that `JwtAuthGuard` is applied to the route

### Issue: 302 Redirect but File Doesn't Load

**Cause:** S3 presigned URL expired or invalid

**Solution:**
1. Check S3 credentials are correct
2. Verify the storage path exists in S3
3. Check that presigned URL expiry is reasonable (1 hour default)

### Issue: CORS Errors

**Cause:** S3 bucket CORS configuration

**Solution:**
1. Configure S3 bucket CORS to allow your domain
2. Or use backend redirect (which we're doing)

## Manual Production Test

You can also test manually:

```bash
# 1. Get JWT token
TOKEN=$(curl -s -X POST https://tenx-demo.helixsense.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"siteCode":"","email":"superadmin@system.local","password":"SuperAdmin@2025!"}' \
  | jq -r '.data.accessToken')

# 2. Test redirect endpoint
curl -I -H "Authorization: Bearer $TOKEN" \
  "https://tenx-demo.helixsense.com/uploads/tenx-attachments/maintenance-ticket/{ticketId}/{fileId}.jpg"

# Should return: HTTP/1.1 302 Found
# With Location header pointing to S3 presigned URL

# 3. Follow redirect and download
curl -L -H "Authorization: Bearer $TOKEN" \
  "https://tenx-demo.helixsense.com/uploads/tenx-attachments/maintenance-ticket/{ticketId}/{fileId}.jpg" \
  -o /tmp/test-download.jpg

# 4. Verify file
file /tmp/test-download.jpg
# Should show: JPEG image data, ...
```

## Debugging in Production

If tests pass locally but fail in production:

1. **Check nginx logs:**
   ```bash
   sudo tail -f /var/log/nginx/error.log
   ```

2. **Check backend logs:**
   ```bash
   # If using PM2
   pm2 logs facility-erp-backend
   
   # If using systemd
   sudo journalctl -u facility-erp-backend -f
   ```

3. **Test nginx proxy directly:**
   ```bash
   curl -I -H "Authorization: Bearer $TOKEN" \
     "http://localhost:3000/api/v1/uploads/tenx-attachments/.../file.jpg"
   ```

4. **Verify route registration:**
   - Check backend startup logs for route registration
   - Verify `UploadsModule` is loaded

5. **Check S3 connectivity:**
   ```bash
   npm run test:s3
   ```

## Expected Behavior

### ✅ Working Flow:
1. Frontend requests: `https://domain.com/uploads/tenx-attachments/.../file.jpg`
2. Nginx proxies to: `http://localhost:3000/api/v1/uploads/tenx-attachments/.../file.jpg`
3. Backend generates S3 presigned URL
4. Backend returns: `302 Found` with `Location: https://bucket.s3.region.amazonaws.com/...?presigned-params`
5. Browser follows redirect and downloads from S3

### ❌ Common Failures:
- **404**: Route not found (nginx or backend issue)
- **401**: Authentication failed (token missing/invalid)
- **500**: Backend error (check logs)
- **403**: S3 access denied (credentials issue)

## Next Steps

After running tests:

1. If all tests pass locally but fail in production:
   - Check nginx configuration
   - Verify backend is running
   - Check S3 credentials in production environment

2. If redirect works but file doesn't download:
   - Check S3 bucket permissions
   - Verify file exists at the path
   - Check presigned URL expiry

3. If authentication fails:
   - Verify JWT token is valid
   - Check token expiry
   - Verify Authorization header is being passed
