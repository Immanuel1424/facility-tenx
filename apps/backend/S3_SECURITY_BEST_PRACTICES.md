# S3 Bucket Security Best Practices

## 🛡️ **RECOMMENDATION: Keep S3 Bucket PRIVATE**

For an ERP system handling maintenance tickets and attachments, **the S3 bucket MUST be private** for security and compliance reasons.

---

## 🔒 **Why Private Buckets are Essential**

### **1. Data Security**
- **Sensitive Information**: Maintenance tickets may contain:
  - Tenant personal information
  - Property details
  - Internal notes and comments
  - Financial information
  - Work schedules and assignments

### **2. Access Control**
- **Authorization**: Only authenticated users should access attachments
- **Role-Based Access**: Different roles (TENANT, TECHNICIAN, ADMIN) have different access levels
- **Audit Trail**: Track who accessed what and when

### **3. Compliance**
- **GDPR/Privacy Laws**: Protect personal data
- **Industry Regulations**: Meet security standards
- **Data Breach Prevention**: Reduce risk of unauthorized access

### **4. Cost Control**
- **Prevent Hotlinking**: Avoid unauthorized bandwidth usage
- **Access Monitoring**: Track and control data access

---

## ✅ **How Presigned URLs Work with Private Buckets**

### **Current Implementation**

Our system uses **presigned URLs** to provide secure, time-limited access to private S3 objects:

```
1. User requests to view an attachment
   ↓
2. Backend verifies user has permission to access the attachment
   ↓
3. Backend generates a presigned URL (valid for 1 hour)
   ↓
4. Frontend uses presigned URL to display the image
   ↓
5. Presigned URL expires after 1 hour (security)
```

### **Benefits of Presigned URLs**
- ✅ **Secure**: Only authorized users get URLs
- ✅ **Time-Limited**: URLs expire automatically
- ✅ **No Public Access**: Bucket remains private
- ✅ **Audit Trail**: Backend logs all access requests
- ✅ **Flexible**: Can set different expiration times per use case

---

## ⚠️ **When Public Buckets Might Be Acceptable**

Public buckets are **rarely recommended** and should only be used for:

1. **Public Website Assets**
   - Logos, public images
   - Marketing materials
   - Public documentation

2. **CDN Distribution**
   - Static assets served via CloudFront
   - Public content delivery

3. **Non-Sensitive Data**
   - Public datasets
   - Open-source resources

**For ERP systems: NEVER use public buckets for user-generated content or attachments.**

---

## 🔧 **S3 Bucket Configuration**

### **Recommended Settings**

```json
{
  "BlockPublicAcls": true,
  "IgnorePublicAcls": true,
  "BlockPublicPolicy": true,
  "RestrictPublicBuckets": true
}
```

### **Bucket Policy Example (Private Bucket)**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyPublicAccess",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::your-bucket-name/*",
      "Condition": {
        "StringNotEquals": {
          "aws:PrincipalServiceName": "ec2.amazonaws.com"
        }
      }
    },
    {
      "Sid": "AllowBackendAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT_ID:role/your-backend-role"
      },
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::your-bucket-name/*"
    }
  ]
}
```

---

## 📋 **Security Checklist**

- [x] **Block Public Access**: Enable all 4 Block Public Access settings
- [x] **Use Presigned URLs**: For all file access (viewing/downloading)
- [x] **IAM Roles**: Use IAM roles, not access keys when possible
- [x] **Encryption**: Enable S3 server-side encryption (SSE-S3 or SSE-KMS)
- [x] **Versioning**: Enable versioning for data recovery
- [x] **Lifecycle Policies**: Archive old files to Glacier
- [x] **Access Logging**: Enable S3 access logging
- [x] **CORS Configuration**: Restrict CORS to your domain only
- [x] **MFA Delete**: Enable MFA for bucket deletion (production)

---

## 🚀 **Current Implementation Status**

### **✅ What We Have**

1. **Private Bucket Support**: ✅ Implemented
2. **Presigned URL Generation**: ✅ Backend endpoint ready
3. **Frontend Integration**: ✅ Auto-fetches presigned URLs for S3 images
4. **Access Control**: ✅ Backend verifies user permissions before generating URLs

### **📝 Configuration Steps**

1. **Ensure S3 Bucket is Private**:
   ```bash
   aws s3api put-public-access-block \
     --bucket your-bucket-name \
     --public-access-block-configuration \
     "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
   ```

2. **Verify Block Public Access**:
   ```bash
   aws s3api get-public-access-block --bucket your-bucket-name
   ```

3. **Test Presigned URL Generation**:
   - Backend endpoint: `GET /api/v1/maintenance-tickets/:ticketId/attachments/:attachmentId/presigned-url`
   - Frontend automatically uses this for S3 URLs

---

## 🔍 **Monitoring & Alerts**

### **CloudWatch Alarms to Set**

1. **Unauthorized Access Attempts**
   - Monitor `GetObject` requests with 403 errors
   - Alert on suspicious patterns

2. **Presigned URL Usage**
   - Track presigned URL generation
   - Monitor expiration patterns

3. **Bucket Access Patterns**
   - Monitor access frequency
   - Detect unusual access patterns

---

## 📚 **References**

- [AWS S3 Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
- [S3 Block Public Access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
- [Presigned URLs](https://docs.aws.amazon.com/AmazonS3/latest/userguide/PresignedUrlUploadObject.html)

---

## ✅ **Summary**

**For your ERP system:**
- ✅ **Use PRIVATE buckets** - Required for security
- ✅ **Use presigned URLs** - Already implemented
- ✅ **Enable Block Public Access** - Critical security setting
- ✅ **Monitor access** - Track all file access
- ❌ **Never make buckets public** - Security risk

**Your current implementation is correct and follows best practices!** 🎉
