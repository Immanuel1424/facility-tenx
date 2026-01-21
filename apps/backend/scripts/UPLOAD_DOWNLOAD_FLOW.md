# Upload & Download Flow Documentation

## Overview

This document explains how file uploads and downloads work in the system.

## Upload Flow (Backend Upload)

### Current Implementation

**Frontend → Backend → S3**

1. **Frontend** sends file to backend via `POST /api/v1/maintenance-tickets/{ticketId}/attachments/upload`
   - Uses `multipart/form-data` with `FileInterceptor`
   - File is sent as `FormData` with field name `file`

2. **Backend** receives file via `multer` (Express middleware)
   - Validates file (size, MIME type)
   - Generates unique filename (UUID)
   - Uploads file to S3 using AWS SDK
   - Stores file metadata in database with `storagePath` (S3 key)

3. **Database** stores:
   - `storage_path`: S3 key (e.g., `tenx-attachments/maintenance-ticket/{ticketId}/{uuid}.jpg`)
   - `storage_url`: Constructed S3 URL (for reference)
   - File metadata (name, size, MIME type, etc.)

### Code Flow

```
Frontend (FileUploadService)
  ↓ POST /maintenance-tickets/{ticketId}/attachments/upload
Backend (TicketAttachmentController.upload)
  ↓ FileInterceptor (multer)
  ↓ S3StorageService.saveFile()
  ↓ S3Client.send(PutObjectCommand)
S3 Bucket
  ↓ Returns attachment metadata
Database (ticket_attachment table)
```

## Download Flow (Direct S3 Download via Presigned URLs)

### How It Works

**Frontend → Backend → S3 (Direct Download)**

Downloads work independently of upload method. Whether files are uploaded directly to S3 or via backend, the download flow is the same:

1. **Frontend** requests presigned URL using `storagePath` from database
   - Option A: `GET /api/v1/uploads/presigned-url?storagePath=...`
   - Option B: `GET /api/v1/uploads/{storagePath}` (redirect endpoint)

2. **Backend** generates S3 presigned URL
   - Validates `storagePath` format
   - Generates presigned URL with 1-hour expiry
   - Returns presigned URL (or redirects to it)

3. **Frontend/Browser** downloads directly from S3
   - Uses presigned URL to download file
   - No backend involvement in actual file transfer
   - Efficient: Direct S3 download, no backend bandwidth used

### Why Downloads Work with Backend Upload

✅ **Both methods store files in S3**
- Direct upload: Client → S3
- Backend upload: Client → Backend → S3
- **Result**: File is in S3 either way

✅ **Both methods store `storagePath` in database**
- `storagePath` = S3 key (e.g., `tenx-attachments/maintenance-ticket/123/abc.jpg`)
- Download uses `storagePath` to generate presigned URL
- **Result**: Download works the same regardless of upload method

✅ **Download is independent of upload**
- Upload method doesn't affect download
- Download always uses presigned URLs from S3
- **Result**: Consistent download experience

### Code Flow

```
Frontend (AttachmentGalleryWidget)
  ↓ GET /api/v1/uploads/presigned-url?storagePath=...
Backend (UploadController.generatePresignedDownloadUrl)
  ↓ S3StorageService.getPresignedUrl(storagePath)
  ↓ getSignedUrl(S3Client, GetObjectCommand)
S3 Presigned URL
  ↓ Frontend uses presigned URL
S3 Bucket (Direct Download)
```

## Key Points

### ✅ Upload Method Doesn't Affect Download

- **Upload**: File goes to S3 (via backend or directly)
- **Download**: Always uses presigned URLs from S3
- **Storage**: Both methods store `storagePath` in database
- **Result**: Downloads work the same way regardless of upload method

### ✅ Why Direct Download Works

1. **Files are in S3**: Whether uploaded directly or via backend, files end up in S3
2. **Storage path is known**: Database stores the S3 key (`storagePath`)
3. **Presigned URLs work**: S3 presigned URLs work for any file in the bucket
4. **No backend dependency**: Once presigned URL is generated, download is direct from S3

### ✅ Benefits of This Approach

- **Efficient**: Direct S3 download, no backend bandwidth
- **Scalable**: S3 handles download traffic
- **Secure**: Presigned URLs expire after 1 hour
- **Consistent**: Same download flow regardless of upload method

## Example Flow

### Upload (Backend Upload)
```
1. User selects image in Flutter app
2. Frontend calls: POST /api/v1/maintenance-tickets/123/attachments/upload
3. Backend receives file via multer
4. Backend uploads to S3: tenx-attachments/maintenance-ticket/123/uuid.jpg
5. Backend stores in DB: storage_path = "tenx-attachments/maintenance-ticket/123/uuid.jpg"
6. Backend returns attachment metadata
```

### Download (Presigned URL)
```
1. Frontend has attachment with storage_path
2. Frontend calls: GET /api/v1/uploads/presigned-url?storagePath=tenx-attachments/maintenance-ticket/123/uuid.jpg
3. Backend generates S3 presigned URL
4. Backend returns: { presignedUrl: "https://bucket.s3.region.amazonaws.com/...?signature" }
5. Frontend uses presigned URL to load image
6. Image loads directly from S3 (no backend involved)
```

## Testing

Run the production test to verify downloads work:

```bash
npm run test:download-production
```

This tests:
- ✅ Presigned URL generation
- ✅ Redirect endpoint
- ✅ File download from S3
- ✅ Authentication
- ✅ Error handling

## Troubleshooting

### Issue: Download fails with 404

**Check:**
1. Verify `storagePath` exists in database
2. Check S3 bucket has the file at that path
3. Verify S3 credentials are correct

### Issue: Download fails with 401

**Check:**
1. JWT token is valid and not expired
2. Authorization header is being sent
3. User has permission to access the file

### Issue: Presigned URL expires too quickly

**Solution:**
- Default expiry is 1 hour (3600 seconds)
- Can be customized via `expiresIn` parameter (max 1 hour)

## Summary

**Upload**: Backend receives file → Uploads to S3 → Stores metadata

**Download**: Frontend requests presigned URL → Backend generates → Frontend downloads from S3

**Key**: Downloads work the same way regardless of upload method because both store files in S3 and use `storagePath` for downloads.
