# S3 Checksum Fix - Applied

## ✅ Fix Applied

The S3Client has been configured to disable automatic checksum calculation using the correct AWS SDK v3 options:

```typescript
this.s3Client = new S3Client({
  region: this.region,
  credentials: {
    accessKeyId,
    secretAccessKey,
  },
  // Disable automatic checksum calculation
  requestChecksumMode: 'DISABLED',
  responseChecksumMode: 'DISABLED',
});
```

## ⚠️ IMPORTANT: Restart Required

**The backend server MUST be restarted for this fix to take effect.**

The changes are in:
- `apps/backend/src/modules/maintenance-ticket/services/s3-storage.service.ts`

## How to Restart

1. **If running with `npm run start:dev`:**
   - Stop the current process (Ctrl+C)
   - Restart: `npm run start:dev`

2. **If running in Docker:**
   ```bash
   docker-compose restart backend
   # or
   docker restart <container-name>
   ```

3. **If running as a service:**
   ```bash
   systemctl restart facility-erp-backend
   # or your service management command
   ```

## Verification After Restart

After restarting, verify the fix:

```bash
# Get JWT token
TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"siteCode": "COM0001", "email": "your-email", "password": "your-password"}' \
  | jq -r '.data.accessToken')

# Generate presigned URL
PRESIGNED_URL=$(curl -s -X POST http://localhost:3000/api/v1/uploads/presigned-url \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "entityType": "announcement",
    "entityId": "test-123",
    "fileName": "test.png",
    "mimeType": "image/png",
    "fileSize": 1024
  }' | jq -r '.data.presignedUrl')

# Check for checksum parameters (should return nothing)
echo "$PRESIGNED_URL" | grep -o 'x-amz-checksum\|x-amz-sdk-checksum' || echo "✅ No checksum parameters - Fix working!"
```

## Expected Result

After restart:
- ✅ Presigned URLs should NOT contain `x-amz-checksum` or `x-amz-sdk-checksum` parameters
- ✅ Uploads should work without signature mismatches
- ✅ No checksum warning errors in logs

## Test Suite

Run the full test suite after restart:

```bash
cd apps/backend
TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"siteCode": "COM0001", "email": "your-email", "password": "your-password"}' \
  | jq -r '.data.accessToken')

TEST_JWT_TOKEN="$TOKEN" npm run test:s3-integration
```

All tests should pass and presigned URLs should not contain checksum parameters.

## What Changed

1. **S3Client Configuration:**
   - Added `requestChecksumMode: 'DISABLED'`
   - Added `responseChecksumMode: 'DISABLED'`

2. **Metadata:**
   - Removed checksum from metadata when generating presigned URLs
   - Checksum can still be calculated and stored in DB after upload

3. **Error Handling:**
   - Enhanced error detection and logging
   - Clear guidance on solutions

## Notes

- The fix uses official AWS SDK v3 configuration options
- This is the recommended approach for disabling checksums
- Checksums can still be calculated client-side or server-side after upload if needed
- The fix maintains compatibility with all entity types (maintenance-ticket, villa, user, announcement)
