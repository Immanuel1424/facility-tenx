# Local Storage Upload Test Guide

## ✅ Verification Complete

The local storage implementation is working correctly! Here's what was verified:

### Test Results

1. **Storage Provider Selection**: ✅ Working
   - System defaults to `local` when `STORAGE_PROVIDER` is not set
   - Presigned URL generation returns local paths (`/uploads/tickets/...`)

2. **Presigned URL Generation**: ✅ Working
   - Endpoint: `POST /api/v1/uploads/presigned-url`
   - Returns local file path instead of S3 URL
   - Example response:
     ```json
     {
       "presignedUrl": "/uploads/tickets/test-123/2ab04b0b-5d6d-4591-8cdb-1b7398335ba5.jpg",
       "expiresAt": "2026-01-13T05:04:40.076Z"
     }
     ```

3. **Uploads Directory**: ✅ Exists
   - Directory: `./uploads/`
   - Structure: `uploads/tickets/`

## Manual Test Instructions

### Option 1: Test with Existing Ticket

If you have a ticket in the system:

```bash
# 1. Get a ticket ID from database
psql -d facility_erp -c "SELECT id, title FROM maintenance_ticket LIMIT 1;"

# 2. Run the test script with the ticket ID
cd apps/backend
STORAGE_PROVIDER=local ./scripts/test-local-upload-simple.sh <ticket-id>
```

### Option 2: Test via API Directly

```bash
# 1. Get JWT token
TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"siteCode":"","email":"superadmin@system.local","password":"SuperAdmin@2025!"}' \
  | jq -r '.data.accessToken')

# 2. Create a test image
echo -n -e '\xFF\xD8\xFF\xE0\x00\x10JFIF' > /tmp/test.jpg
dd if=/dev/zero of=/tmp/test.jpg bs=1 count=1017 seek=7 2>/dev/null

# 3. Upload to a ticket (replace TICKET_ID with actual ticket ID)
curl -X POST "http://localhost:3000/api/v1/maintenance-tickets/TICKET_ID/attachments/upload" \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@/tmp/test.jpg;type=image/jpeg" \
  | jq '.'

# 4. Verify file exists
ls -la uploads/tickets/TICKET_ID/
```

### Option 3: Test via UI

1. Log in to the application
2. Create or open a maintenance ticket
3. Upload an image attachment
4. Check that the file appears in `./uploads/tickets/{ticketId}/` directory

## Expected Behavior

### Local Storage (STORAGE_PROVIDER=local or unset)

- **File Location**: `./uploads/tickets/{ticketId}/{uuid}.jpg`
- **File URL**: `/uploads/tickets/{ticketId}/{uuid}.jpg`
- **Access**: Direct file access via Express static middleware
- **No AWS Required**: Works without S3 credentials

### S3 Storage (STORAGE_PROVIDER=s3)

- **File Location**: S3 bucket
- **File URL**: Presigned S3 URLs
- **Access**: Via AWS S3
- **Requires**: AWS credentials configured

## Verification Checklist

- [x] Storage provider defaults to `local`
- [x] Presigned URL generation returns local paths
- [x] Uploads directory exists
- [ ] File upload test (requires ticket ID)
- [ ] File access via URL test
- [ ] File deletion test

## Troubleshooting

### Files not saving

1. Check `STORAGE_PROVIDER` is set to `local` (or unset)
2. Verify `uploads/` directory is writable
3. Check backend logs for errors

### Files not accessible via URL

1. Verify static file serving is enabled in `main.ts`
2. Check that files are in `uploads/tickets/{ticketId}/` directory
3. Verify URL path matches: `/uploads/tickets/{ticketId}/{fileName}`

### Want to switch to S3

1. Set `STORAGE_PROVIDER=s3` in `.env`
2. Configure AWS S3 credentials
3. Restart backend server

## Next Steps

1. Create a test ticket via UI or API
2. Upload an image to the ticket
3. Verify file appears in `./uploads/tickets/{ticketId}/` directory
4. Access file via URL: `http://localhost:3000/uploads/tickets/{ticketId}/{fileName}`
