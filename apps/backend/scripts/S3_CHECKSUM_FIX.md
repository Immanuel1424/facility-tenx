# S3 Presigned URL Checksum Parameter Fix

## Issue

The AWS SDK v3 was automatically adding checksum parameters (like `x-amz-checksum-crc32`) to presigned URLs, which caused upload failures because:

1. **Signature Mismatch**: Checksum parameters in the presigned URL are part of the signature
2. **Client Doesn't Send Checksums**: The Flutter client uploads files without calculating/sending checksums
3. **S3 Rejects Request**: S3 validates the signature and rejects requests that don't match

**Error Message:**
```
⚠️ CRITICAL: Presigned URL contains checksum parameters for tenx-attachments/...
This will cause upload failures because the client doesn't send matching checksums.
```

## Root Cause

The AWS SDK v3 (`@aws-sdk/client-s3@^3.958.0`) automatically calculates and adds checksum headers when:
- Checksum is included in metadata
- SDK configuration triggers automatic checksum calculation
- Certain request patterns trigger checksum calculation

## Solution Implemented

### 1. Removed Checksum from Metadata

**Before:**
```typescript
Metadata: {
  originalName: fileName,
  entityId: entityId,
  entityType: entityType,
  ...(checksum && { checksum }), // ❌ This could trigger SDK to add checksum headers
}
```

**After:**
```typescript
Metadata: {
  originalName: fileName,
  entityId: entityId,
  entityType: entityType,
  // ✅ Explicitly omit checksum from metadata
  // Checksum can be calculated and stored in DB after successful upload if needed
}
```

### 2. Enhanced Error Detection and Logging

Added comprehensive error logging that:
- Detects checksum parameters in presigned URLs
- Logs clear error messages with solutions
- Provides guidance on fixing the issue

### 3. Removed Invalid Configuration

Removed `requestChecksumCalculation: 'DISABLED'` option (not valid in AWS SDK v3).

## Testing

After the fix:
1. ✅ Presigned URLs should not contain checksum parameters
2. ✅ Uploads should work without signature mismatches
3. ✅ Error logs will indicate if checksum parameters still appear

## If Issue Persists

If checksum parameters still appear in presigned URLs after this fix:

### Option 1: Update AWS SDK
```bash
npm update @aws-sdk/client-s3 @aws-sdk/s3-request-presigner
```

### Option 2: Update Client to Send Checksums
Modify the Flutter `S3UploadService` to calculate and send checksums when they're present in the presigned URL.

### Option 3: Use Custom Signer
Implement a custom presigned URL generator that doesn't include checksum parameters.

## Files Modified

- `apps/backend/src/modules/maintenance-ticket/services/s3-storage.service.ts`
  - Removed checksum from metadata in `generatePresignedUploadUrl()`
  - Enhanced error detection and logging
  - Removed invalid SDK configuration option

## Verification

To verify the fix works:

1. **Generate a presigned URL:**
   ```bash
   curl -X POST http://localhost:3000/api/v1/uploads/presigned-url \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "entityType": "announcement",
       "entityId": "test-id",
       "fileName": "test.png",
       "mimeType": "image/png",
       "fileSize": 1024
     }'
   ```

2. **Check the presigned URL:**
   - Should NOT contain `x-amz-checksum` or `x-amz-sdk-checksum` parameters
   - Should work for direct uploads from Flutter client

3. **Check logs:**
   - Should NOT see the checksum warning error
   - Should see successful presigned URL generation

## Related Code

- **Backend**: `S3StorageService.generatePresignedUploadUrl()`
- **Frontend**: `S3UploadService.uploadImageToS3()`
- **Test**: `test-s3-integration-complete.ts`

## Notes

- Checksum can still be calculated and stored in the database after successful upload
- The checksum in metadata was not necessary for presigned URL generation
- Removing it prevents the SDK from automatically adding checksum headers to the request
