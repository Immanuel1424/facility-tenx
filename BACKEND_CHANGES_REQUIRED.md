# Backend Changes Required Since Last Docker Push

## Overview

This document outlines all backend changes required to support the frontend application after the latest Docker push.

---

## 1. Database Migrations (CRITICAL)

The following SQL migrations **MUST** be executed on the production database:

### Migration 1: Create Announcements Tables

**File:** `apps/backend/migrations/create-announcements-tables.sql`

**Purpose:** Creates the core announcement system tables and enums.

**Tables Created:**

- `announcements` - Stores announcement records
- `announcement_reads` - Tracks user read status

**Enums Created:**

- `announcement_category` - ('maintenance', 'emergency', 'general', 'info')
- `announcement_priority` - ('low', 'medium', 'high', 'urgent')
- `announcement_target_audience` - ('all', 'roles')

**Run Command:**

```bash
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f apps/backend/migrations/create-announcements-tables.sql
```

### Migration 2: Add Updated At to Announcement Reads

**File:** `apps/backend/migrations/add-updated-at-to-announcement-reads.sql`

**Purpose:** Adds missing `updated_at` column to `announcement_reads` table.

**Run Command:**

```bash
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f apps/backend/migrations/add-updated-at-to-announcement-reads.sql
```

---

## 2. API Endpoints Required

The following endpoints are being called by the frontend and must be available:

### Base Path: `/api/v1/announcements`

| Method   | Endpoint                      | Permission Required    | Description                                         |
| -------- | ----------------------------- | ---------------------- | --------------------------------------------------- |
| `GET`    | `/announcements`              | `announcement:read`    | List announcements (filtered by user role)          |
| `GET`    | `/announcements/admin`        | `announcement:read`    | List all announcements for admin (including drafts) |
| `GET`    | `/announcements/:id`          | `announcement:read`    | Get announcement details                            |
| `POST`   | `/announcements`              | `announcement:create`  | Create new announcement (ADMIN only)                |
| `PATCH`  | `/announcements/:id`          | `announcement:update`  | Update announcement (ADMIN only)                    |
| `DELETE` | `/announcements/:id`          | `announcement:delete`  | Delete announcement (ADMIN only)                    |
| `POST`   | `/announcements/:id/publish`  | `announcement:publish` | Publish announcement immediately (ADMIN only)       |
| `POST`   | `/announcements/:id/read`     | `announcement:read`    | Mark announcement as read                           |
| `GET`    | `/announcements/unread/count` | `announcement:read`    | Get unread announcement count                       |
| `GET`    | `/announcements/unread/list`  | `announcement:read`    | Get unread announcements list                       |

### Query Parameters (for list endpoints)

All list endpoints support:

- `category` (string, optional) - Filter by category
- `priority` (string, optional) - Filter by priority
- `search` (string, optional) - Search in title/message
- `page` (number, default: 1) - Page number
- `limit` (number, default: 20) - Items per page
- `sortBy` (string, optional) - Field to sort by
- `sortOrder` (string, optional) - 'ASC' or 'DESC'

---

## 3. Permissions Required

The following permissions must be seeded in the database:

**File Reference:** `apps/backend/scripts/seed.ts` (lines 125-130)

```typescript
// Announcement management
{ resource: 'announcement', action: 'create', roles: ['ADMIN'] },
{ resource: 'announcement', action: 'read', roles: ['ADMIN', 'SITE_COORDINATOR', 'SUPERVISOR', 'TECHNICIAN', 'TENANT'] },
{ resource: 'announcement', action: 'update', roles: ['ADMIN'] },
{ resource: 'announcement', action: 'delete', roles: ['ADMIN'] },
{ resource: 'announcement', action: 'publish', roles: ['ADMIN'] },
```

**Action Required:**

1. Verify these permissions exist in the database
2. If not, run the seed script or manually insert these permissions
3. Ensure roles are properly assigned to users

---

## 4. Module Registration

**File:** `apps/backend/src/app.module.ts`

Verify that `AnnouncementModule` is imported (line 16) and included in the imports array (line 40).

**Current Status:** ✅ Already registered

---

## 5. Response Format Requirements

The frontend expects responses in the following format:

### List Endpoints Response:

```json
{
  "data": [
    {
      "id": "uuid",
      "title": "string",
      "message": "string",
      "category": "maintenance|emergency|general|info",
      "priority": "low|medium|high|urgent",
      "targetAudience": "all|roles",
      "targetRoles": ["role1", "role2"] | null,
      "scheduledAt": "ISO8601 datetime" | null,
      "expiresAt": "ISO8601 datetime" | null,
      "isPublished": boolean,
      "publishedAt": "ISO8601 datetime" | null,
      "createdAt": "ISO8601 datetime",
      "updatedAt": "ISO8601 datetime",
      "createdByUserId": "uuid"
    }
  ],
  "total": number
}
```

### Single Item Response:

```json
{
  "id": "uuid",
  "title": "string",
  "message": "string"
  // ... same fields as above
}
```

### Mark as Read Response:

```json
{
  "id": "uuid",
  "companyId": "uuid",
  "announcementId": "uuid",
  "userId": "uuid",
  "readAt": "ISO8601 datetime",
  "createdAt": "ISO8601 datetime"
}
```

### Unread Count Response:

```json
{
  "count": number
}
```

**Note:** The frontend API client handles both wrapped (`{data: ...}`) and unwrapped responses.

---

## 6. Create Announcement DTO Format

**Endpoint:** `POST /api/v1/announcements`

**Request Body:**

```json
{
  "title": "string (required)",
  "message": "string (required)",
  "category": "maintenance|emergency|general|info (required)",
  "priority": "low|medium|high|urgent (required)",
  "target_audience": "all|roles (required)",
  "target_roles": ["role1", "role2"] | null (required if target_audience = 'roles'),
  "scheduled_at": "ISO8601 datetime" | null (optional),
  "expires_at": "ISO8601 datetime" | null (optional),
  "publish_immediately": boolean (optional)
}
```

---

## 7. Update Announcement DTO Format

**Endpoint:** `PATCH /api/v1/announcements/:id`

**Request Body (all fields optional):**

```json
{
  "title": "string",
  "message": "string",
  "category": "maintenance|emergency|general|info",
  "priority": "low|medium|high|urgent",
  "targetAudience": "all|roles",
  "targetRoles": ["role1", "role2"],
  "scheduledAt": "ISO8601 datetime",
  "expiresAt": "ISO8601 datetime"
}
```

---

## 8. Business Logic Requirements

### Access Control:

1. **Tenants** - Can only see published announcements that are:

   - Not expired (`expiresAt IS NULL OR expiresAt > NOW()`)
   - Either `targetAudience = 'all'` OR user has a role in `targetRoles` array

2. **Admins** - Can see all announcements (including drafts) via `/announcements/admin` endpoint

3. **Other Roles** (SITE_COORDINATOR, SUPERVISOR, TECHNICIAN) - Can see published announcements filtered by their roles

### Publishing Rules:

- Only admins can create/update/delete/publish announcements
- Published announcements cannot be updated (must be unpublished first)
- Scheduled announcements are published automatically when `scheduledAt <= NOW()`

### Read Tracking:

- When a user marks an announcement as read, a record is created in `announcement_reads` table
- Unread count excludes announcements the user has already read
- Unread list only returns announcements the user hasn't read

---

## 9. Verification Checklist

Before deploying, verify:

- [ ] Database migrations have been executed successfully
- [ ] Announcement module is registered in `app.module.ts`
- [ ] All permissions are seeded in the database
- [ ] All 10 API endpoints are accessible and return correct format
- [ ] Permission guards are working correctly
- [ ] Multi-tenant isolation is enforced (company_id scoping)
- [ ] Role-based filtering works correctly
- [ ] Read tracking functionality works
- [ ] Scheduled announcements are being processed (if scheduler service is implemented)

---

## 10. Testing Endpoints

Use the following curl commands to test (replace tokens and IDs):

```bash
# List announcements (user filtered)
curl -X GET "http://localhost:3000/api/v1/announcements" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "x-company-id: YOUR_COMPANY_ID"

# List all announcements (admin)
curl -X GET "http://localhost:3000/api/v1/announcements/admin" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "x-company-id: YOUR_COMPANY_ID"

# Get unread count
curl -X GET "http://localhost:3000/api/v1/announcements/unread/count" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "x-company-id: YOUR_COMPANY_ID"

# Create announcement (admin only)
curl -X POST "http://localhost:3000/api/v1/announcements" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "x-company-id: YOUR_COMPANY_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Announcement",
    "message": "This is a test",
    "category": "general",
    "priority": "medium",
    "target_audience": "all",
    "publish_immediately": false
  }'
```

---

## 11. Additional Notes

1. **Versioning:** All endpoints use API versioning (`@Version('1')`), so they're available at `/api/v1/announcements`

2. **Authentication:** All endpoints require JWT authentication and company ID header

3. **Error Handling:** Ensure proper error responses for:

   - 401 Unauthorized (missing/invalid token)
   - 403 Forbidden (insufficient permissions)
   - 404 Not Found (announcement doesn't exist or user doesn't have access)
   - 400 Bad Request (validation errors)

4. **Soft Delete:** Announcements use soft delete (`deletedAt` column), so deleted announcements should be filtered out in queries

---

## Contact

If you need clarification on any of these requirements, please refer to:

- Backend controller: `apps/backend/src/modules/announcement/controllers/announcement.controller.ts`
- Backend service: `apps/backend/src/modules/announcement/services/announcement.service.ts`
- Frontend API client: `apps/frontend/lib/src/core/network/api_client.dart` (lines 1925-2120)
