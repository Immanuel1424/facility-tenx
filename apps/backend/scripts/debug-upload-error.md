# Debugging 500 Error on File Upload

## Error Details
- **Endpoint**: `POST /api/v1/maintenance-tickets/{ticketId}/attachments/upload`
- **Status**: 500 Internal Server Error
- **Environment**: Production (tenx-demo.helixsense.com)

## Potential Causes

### 1. Storage Provider Not Set
- Check if `STORAGE_PROVIDER` is set in production `.env`
- Should be `STORAGE_PROVIDER=local` for local storage
- If not set, defaults to `local` but verify

### 2. Directory Permissions
- The `uploads/` directory must be writable by the Node.js process
- In Docker, check volume mount permissions
- Verify: `ls -la uploads/` shows writable permissions

### 3. Directory Creation Failure
- The service tries to create `uploads/tickets/{ticketId}/` directory
- If this fails, upload will fail with 500 error
- Check server logs for directory creation errors

### 4. File Write Failure
- File write to disk might fail due to:
  - Disk space full
  - Permission denied
  - Path too long
  - Invalid file buffer

## Debugging Steps

### 1. Check Server Logs
Look for error messages in production logs:
```bash
# In production, check Docker logs
docker logs facility-erp-backend-prod | grep -i "upload\|error\|failed"
```

### 2. Verify Storage Provider
```bash
# Check environment variable
docker exec facility-erp-backend-prod env | grep STORAGE_PROVIDER
```

### 3. Check Directory Permissions
```bash
# Check if uploads directory exists and is writable
docker exec facility-erp-backend-prod ls -la /app/uploads
docker exec facility-erp-backend-prod touch /app/uploads/test.txt
```

### 4. Test Upload Endpoint Locally
```bash
# Test with a real file
curl -X POST http://localhost:3000/api/v1/maintenance-tickets/{ticketId}/attachments/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@test.jpg;type=image/jpeg"
```

## Recent Changes Made

1. **Added error handling** in `FileStorageService.saveFile()`:
   - Try-catch around directory creation
   - Try-catch around file write
   - Better error messages

2. **Added logging** in `FileStorageService`:
   - Logs directory initialization
   - Logs file save success/failure
   - Logs errors with details

3. **Improved error handling** in `TicketAttachmentController`:
   - Changed `throw new Error()` to `BadRequestException`
   - Added try-catch around `saveFile()` call
   - Better error messages

## Next Steps

1. **Deploy updated code** with better error handling
2. **Check production logs** for specific error messages
3. **Verify environment variables** are set correctly
4. **Check directory permissions** in Docker container
5. **Test upload** after deployment

## Expected Behavior

With local storage:
- File should be saved to `/app/uploads/tickets/{ticketId}/{uuid}.jpg`
- Directory should be created automatically
- File should be accessible at `/api/uploads/tickets/{ticketId}/{uuid}.jpg`

If any step fails, check logs for the specific error message.
