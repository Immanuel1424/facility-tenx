# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.10] - 2025-01-14

### Added

- Generic upload controller with presigned URL support for direct S3 uploads
- Uploads module with entity type support (maintenance-ticket, villa, user, announcement)
- Pre-signed URL generation DTO with validation (file size, MIME type, entity type)
- Comprehensive upload/download test suite with documentation
- Frontend S3 upload service enhancements for presigned URL flow
- Villa entity and service enhancements
- Improved villa management pages (create, detail, list) with better UI/UX

### Changed

- Refactored S3 storage service with improved presigned URL generation
- Enhanced ticket attachment controller with better S3 integration
- Updated villa DTOs and mappers for improved data handling
- Improved villa BLoC with enhanced state management
- Updated frontend API client configuration

### Fixed

- Improved error handling in S3 upload flow
- Enhanced file validation in upload endpoints
- Better handling of presigned URL expiry (15-minute default)

### Testing

- Added `test-upload-download.ts` - Comprehensive test suite for upload/download flow
- Added `README-TEST-UPLOAD-DOWNLOAD.md` - Documentation for upload/download testing

---

## [1.0.9] - 2025-01-12

### ⚠️ Production Migration Required

After deploying v1.0.9, run the following script in production:

```bash
npm run assign:announcement-to-tenant
# or
npx ts-node -r tsconfig-paths/register apps/backend/scripts/assign-announcement-permissions-to-tenant.ts
```

This script assigns announcement read permissions to all TENANT roles across all companies, enabling tenant users to view announcements.

### Added

- Enhanced S3 upload service with presigned URL support and checksum validation
- SLA alert system with automated notifications to admins
- SLA functionality testing and monitoring scripts
- Announcement permissions assignment utility for tenant roles
- Admin user management utilities (find/create admin scripts)
- Enhanced maintenance ticket detail page with improved UI/UX
- Villa data model enhancements with additional fields
- Improved authentication flow with better error handling
- Enhanced announcement creation and listing pages

### Changed

- Refactored S3 storage service for better error handling and validation
- Improved SLA service with enhanced escalation logic
- Updated notification service with better template handling
- Enhanced maintenance ticket service with improved attachment handling
- Improved announcement pages with better form validation and UI

### Fixed

- Fixed platform-specific issues in authentication
- Resolved TypeScript compilation errors
- Fixed S3 upload checksum handling
- Improved error handling in various services

### Migration Scripts

- **`assign-announcement-permissions-to-tenant.ts`** ⚠️ **REQUIRED IN PRODUCTION** - Assigns announcement read permissions to tenant roles across all companies. Run this script after deploying v1.0.9 to ensure tenant users can access announcements.
- `find-admin-thorough.ts` - Utility script to find admin users with detailed information
- `find-or-create-admin.ts` - Utility script to find or create admin users
- `send-sla-alert-to-admin.ts` - Script to send test SLA alerts to admin users
- `test-presigned-upload-with-checksum.ts` - Test script for S3 presigned uploads with checksum validation
- `test-presigned-url-service.ts` - Test script for presigned URL service functionality
- `test-sla-alerts.ts` - Comprehensive test script for SLA alert functionality
- `test-sla-functionality.ts` - Test script for SLA system functionality

---

## [1.0.5] - Previous Release

### Notes

- Previous release notes would go here
