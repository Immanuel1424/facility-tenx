# Testing Super Admin Login

## Issue: Empty Response

If you're getting an empty response when trying to login with Super Admin credentials, check the following:

## 1. Verify Backend Server is Running

```bash
# Check if backend is running on port 3000
lsof -ti:3000

# If not running, start it:
cd apps/backend
npm run start:dev
```

## 2. Test Login with curl

```bash
# Test with SYSTEM company code
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "x-company-id: SYSTEM" \
  -d '{
    "email": "superadmin@system.local",
    "password": "SuperAdmin@2025!"
  }' \
  -v
```

Expected response:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "expiresIn": 900,
    "tokenType": "Bearer"
  },
  "message": "Operation successful",
  "timestamp": "2025-01-02T..."
}
```

## 3. Verify Database Setup

```sql
-- Check user exists
SELECT u.id, u.email, u.status, c.code as company_code 
FROM users u 
JOIN companies c ON u.company_id = c.id 
WHERE u.email = 'superadmin@system.local';

-- Check role assignment
SELECT r.name as role_name 
FROM user_roles ur 
JOIN roles r ON ur.role_id = r.id 
WHERE ur.user_id = (SELECT id FROM users WHERE email = 'superadmin@system.local');
```

Should return:
- User: `superadmin@system.local` | `active` | `SYSTEM`
- Role: `SUPER_ADMIN`

## 4. Common Issues

### Issue: Empty Response

**Possible Causes:**
1. **Backend not running** - Start with `npm run start:dev`
2. **CORS error** - Check browser console for CORS errors
3. **Network error** - Check if backend URL is correct
4. **Response interceptor issue** - Check backend logs

**Solution:**
- Check backend logs for errors
- Verify backend is accessible at `http://localhost:3000`
- Check browser network tab for actual response

### Issue: "Invalid credentials"

**Possible Causes:**
1. Wrong password
2. User not found
3. Company code not resolved

**Solution:**
- Verify password: `SuperAdmin@2025!` (exact, no spaces)
- Verify company code: `SYSTEM` (uppercase)
- Check database for user existence

### Issue: "Invalid company id or code"

**Possible Causes:**
1. SYSTEM company doesn't exist
2. Company code resolution failing

**Solution:**
```sql
-- Verify SYSTEM company exists
SELECT id, code, name FROM companies WHERE code = 'SYSTEM';
```

## 5. Debug Steps

1. **Check Backend Logs:**
   ```bash
   cd apps/backend
   npm run start:dev
   # Watch for errors in console
   ```

2. **Test with curl (bypasses frontend):**
   ```bash
   curl -X POST http://localhost:3000/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -H "x-company-id: SYSTEM" \
     -d '{"email":"superadmin@system.local","password":"SuperAdmin@2025!"}' \
     -v
   ```

3. **Check Browser Network Tab:**
   - Open DevTools → Network tab
   - Try login
   - Check the login request:
     - Status code
     - Response headers
     - Response body
     - Request headers (especially `x-company-id`)

4. **Check Backend Console:**
   - Look for error messages
   - Check if request reaches the controller
   - Verify company code resolution

## 6. Expected Behavior

1. **Request:**
   - Method: `POST`
   - URL: `/api/v1/auth/login`
   - Headers: `Content-Type: application/json`, `x-company-id: SYSTEM`
   - Body: `{"email":"superadmin@system.local","password":"SuperAdmin@2025!"}`

2. **Backend Processing:**
   - Resolves "SYSTEM" to company UUID
   - Finds user by email and company
   - Validates password
   - Gets roles (should return `["SUPER_ADMIN"]`)
   - Gets permissions (may return empty array `[]` - this is OK)
   - Generates JWT tokens
   - Returns response

3. **Response:**
   - Status: `200 OK`
   - Body: Wrapped in standard format with `success: true` and `data` containing tokens

## 7. Notes

- **Empty permissions array is OK** - Super Admin doesn't need explicit permissions, the role check handles it
- **Response is wrapped** - The `ResponseTransformInterceptor` wraps the response in standard format
- **Company code resolution** - "SYSTEM" is resolved to UUID before user lookup

## 8. Quick Fix Script

If login fails, re-run the setup script:

```bash
cd apps/backend
psql -U postgres -d facility_erp -f scripts/migrations/015-create-system-company-and-super-admin.sql
```

This will:
- Ensure SYSTEM company exists
- Ensure SUPER_ADMIN role exists
- Ensure Super Admin user exists
- Update password hash if needed

