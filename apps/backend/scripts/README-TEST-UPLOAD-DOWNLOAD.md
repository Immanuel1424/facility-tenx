# Upload and Download Test Suite

This test suite validates the complete upload and download flow using pre-signed S3 URLs.

## Prerequisites

1. **AWS S3 Credentials** (required):
   ```env
   AWS_S3_ACCESS_KEY_ID=your-access-key
   AWS_S3_SECRET_ACCESS_KEY=your-secret-key
   AWS_S3_REGION=ap-south-1
   AWS_S3_BUCKET_NAME=your-bucket-name
   AWS_S3_BASE_PREFIX=tenx-attachments
   ```

2. **JWT Token** (optional but recommended):
   ```env
   TEST_JWT_TOKEN=your-jwt-token
   ```
   
   To get a JWT token:
   - Login via the API: `POST /api/v1/auth/login`
   - Copy the `accessToken` from the response
   - Set it as `TEST_JWT_TOKEN` in your `.env` file

3. **API Base URL** (optional):
   ```env
   API_BASE_URL=http://localhost:3000/api/v1
   ```

## Running the Tests

```bash
npm run test:upload-download
```

Or directly:
```bash
ts-node -r tsconfig-paths/register scripts/test-upload-download.ts
```

## Test Coverage

The test suite covers:

1. **Generate Pre-signed URL via Backend API**
   - Tests `POST /api/v1/uploads/presigned-url`
   - Validates response structure
   - Verifies 15-minute expiry enforcement

2. **Upload File to S3 Using Pre-signed URL**
   - Uploads file directly to S3 using HTTP PUT
   - Verifies file exists in S3 after upload
   - Validates file size matches

3. **Generate Pre-signed URL for Download/Viewing**
   - Tests GET pre-signed URL generation
   - Downloads file using pre-signed URL
   - Verifies file content integrity

4. **File Size Validation**
   - Tests rejection of files exceeding 10MB limit
   - Validates error response

5. **MIME Type Validation**
   - Tests rejection of disallowed MIME types
   - Validates allowed types (image/jpeg, image/png, image/webp)

6. **Different Entity Types**
   - Tests uploads for: maintenance-ticket, villa, user, announcement
   - Verifies S3 key structure includes entity type

7. **Pre-signed URL Expiry Enforcement**
   - Verifies URLs expire in 15 minutes (900 seconds)
   - Validates expiry timestamp

## Expected Output

```
🧪 Starting Upload and Download Test Suite

============================================================
TEST: Pre-signed URL Upload and Download Flow
============================================================

📋 Configuration:
   API Base URL: http://localhost:3000/api/v1
   S3 Bucket: your-bucket-name
   S3 Region: ap-south-1
   Base Prefix: tenx-attachments

📋 Test 1: Generate Pre-signed URL via Backend API
------------------------------------------------------------
   ✅ Pre-signed URL generated
   ✅ Expiry is correct (15 minutes)

📋 Test 2: Upload File to S3 Using Pre-signed URL
------------------------------------------------------------
   ✅ Upload successful
   ✅ File verified in S3

... (more tests)

============================================================
TEST SUMMARY
============================================================
✅ Passed: 7
❌ Failed: 0
⏭️  Skipped: 0
📊 Total: 7
============================================================

✅ All tests passed!
```

## Troubleshooting

### "AWS S3 credentials are missing"
- Ensure `AWS_S3_ACCESS_KEY_ID` and `AWS_S3_SECRET_ACCESS_KEY` are set in `.env`

### "TEST_JWT_TOKEN not set"
- Some tests will be skipped without a JWT token
- To test authenticated endpoints, get a token from login and set it in `.env`

### "Upload failed: HTTP 403"
- Check S3 bucket permissions
- Verify CORS configuration allows PUT requests
- Ensure pre-signed URL hasn't expired

### "Download failed: HTTP 403"
- Verify S3 bucket is accessible
- Check that the file was uploaded successfully
- Ensure pre-signed URL hasn't expired

## Architecture

The test suite validates the industry-standard flow:

```
1. Client → Backend API: Request pre-signed URL
   POST /api/v1/uploads/presigned-url
   { entityType, entityId, fileName, mimeType, fileSize }

2. Backend → Client: Return pre-signed URL
   { presignedUrl, s3Key, expiresAt }

3. Client → S3: Upload file directly
   PUT <presignedUrl>
   Body: file bytes
   Headers: Content-Type: <mimeType>

4. Client → S3: Download file (optional)
   GET <presignedDownloadUrl>
```

## Security Notes

- ✅ No AWS credentials in Flutter/client code
- ✅ Pre-signed URLs expire in 15 minutes
- ✅ File validation (size, MIME type) enforced
- ✅ JWT authentication required for URL generation
- ✅ Direct upload to S3 (no backend proxy)
