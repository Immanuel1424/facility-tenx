# S3 CORS Configuration - Manual Setup Instructions

## ⚠️ IMPORTANT: CORS Error Fix Required

Your S3 bucket needs CORS configuration to allow the Flutter web app to load images. The current error is:

```
Access to image at 'https://user1-bucket-test.s3.ap-south-1.amazonaws.com/...' 
from origin 'http://localhost:XXXX' has been blocked by CORS policy: 
No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

## Solution: Configure CORS on S3 Bucket

### Step 1: Access AWS S3 Console

1. Go to: https://s3.console.aws.amazon.com/
2. Sign in with an account that has **bucket admin permissions**
3. Navigate to bucket: **`user1-bucket-test`**

### Step 2: Configure CORS

1. Click on the bucket name: **`user1-bucket-test`**
2. Go to the **Permissions** tab
3. Scroll down to **Cross-origin resource sharing (CORS)**
4. Click **Edit**
5. **Delete any existing CORS configuration** (if present)
6. **Paste the following JSON configuration**:

```json
[
  {
    "AllowedOrigins": [
      "http://localhost:*",
      "https://tenx-demo.helixsense.com",
      "https://*.helixsense.com"
    ],
    "AllowedMethods": [
      "GET",
      "HEAD",
      "PUT",
      "POST"
    ],
    "AllowedHeaders": [
      "*"
    ],
    "ExposeHeaders": [
      "ETag",
      "x-amz-server-side-encryption",
      "x-amz-request-id",
      "x-amz-id-2",
      "Content-Length",
      "Content-Type"
    ],
    "MaxAgeSeconds": 3000
  }
]
```

7. Click **Save changes**

### Step 3: Verify Configuration

After saving, you should see the CORS configuration displayed in the Permissions tab.

### Step 4: Test

1. **Clear browser cache** (important!)
2. **Reload your Flutter web application**
3. **Try loading an image attachment**
4. **Check browser console** - CORS errors should be gone

## Alternative: Using AWS CLI (if you have permissions)

If you have AWS CLI installed and have bucket admin permissions:

```bash
# Create cors-config.json file with the configuration above
cat > cors-config.json << 'EOF'
{
  "CORSRules": [
    {
      "AllowedOrigins": [
        "http://localhost:*",
        "https://tenx-demo.helixsense.com",
        "https://*.helixsense.com"
      ],
      "AllowedMethods": ["GET", "HEAD", "PUT", "POST"],
      "AllowedHeaders": ["*"],
      "ExposeHeaders": [
        "ETag",
        "x-amz-server-side-encryption",
        "x-amz-request-id",
        "x-amz-id-2",
        "Content-Length",
        "Content-Type"
      ],
      "MaxAgeSeconds": 3000
    }
  ]
}
EOF

# Apply CORS configuration
aws s3api put-bucket-cors \
  --bucket user1-bucket-test \
  --cors-configuration file://cors-config.json \
  --region ap-south-1

# Verify
aws s3api get-bucket-cors --bucket user1-bucket-test --region ap-south-1
```

## What This Configuration Does

- **AllowedOrigins**: Allows requests from:
  - `http://localhost:*` - Any localhost port (for development)
  - `https://tenx-demo.helixsense.com` - Your production domain
  - `https://*.helixsense.com` - All HelixSense subdomains

- **AllowedMethods**: 
  - `GET` - For viewing/downloading images
  - `HEAD` - For checking if files exist
  - `PUT` - For direct client-side uploads (if needed)
  - `POST` - For multipart uploads (if needed)

- **AllowedHeaders**: `["*"]` - Allows all headers (needed for presigned URLs with query parameters)

- **ExposeHeaders**: Headers that the browser can read from the response

- **MaxAgeSeconds**: How long browsers cache preflight OPTIONS requests (3000 seconds = 50 minutes)

## Security Notes

1. **For Production**: Consider restricting `AllowedOrigins` to only your production domains
2. **Wildcard Origins**: `http://localhost:*` is safe for development but should be removed in production
3. **Headers**: `AllowedHeaders: ["*"]` is permissive but necessary for presigned URLs

## Troubleshooting

If CORS errors persist after configuration:

1. **Verify CORS was saved**: Check the Permissions tab in S3 console
2. **Clear browser cache**: CORS headers are cached by browsers
3. **Check exact origin**: Make sure the origin in the error matches what's in `AllowedOrigins`
4. **Wait a few seconds**: S3 CORS changes can take a moment to propagate
5. **Check browser console**: Look for the exact CORS error message

## After CORS is Configured

Once CORS is properly configured, your Flutter web app should be able to:
- ✅ Load images from S3 using presigned URLs
- ✅ Display attachments in both tenant and admin views
- ✅ Show image previews without CORS errors

---

**Note**: The AWS user `tenx-user` does not have permissions to configure CORS. This needs to be done by someone with bucket admin/owner permissions.
