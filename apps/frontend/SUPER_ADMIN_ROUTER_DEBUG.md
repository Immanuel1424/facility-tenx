# Super Admin Router Navigation Debug Guide

## Router Configuration Status

### ✅ Fixed Issues

1. **Role Detection Logic** - Updated to check for SUPER_ADMIN first
   - Previously: Used `user.roles.first` (could miss SUPER_ADMIN if not first)
   - Now: Checks if `SUPER_ADMIN` exists in roles array first, then falls back to first role

2. **Dashboard Route** - Correctly configured
   - Import: ✅ `SuperAdminDashboardPage` imported
   - Switch case: ✅ `SUPER_ADMIN` case returns `SuperAdminDashboardPage()`
   - Role detection: ✅ Now checks for SUPER_ADMIN specifically

### Router Flow

```
Login Success
    ↓
AuthBloc emits AuthAuthenticated(user)
    ↓
LoginPage redirects to /dashboard
    ↓
Router _handleRedirect checks auth state
    ↓
Dashboard route builder extracts role
    ↓
_buildDashboardForRole() checks for SUPER_ADMIN
    ↓
Returns SuperAdminDashboardPage()
```

## Debugging Steps

### 1. Check Role in JWT Token

After login, check browser console for:
```
🏠 Building dashboard for role: SUPER_ADMIN
🏠 User roles: [SUPER_ADMIN]
```

If you see a different role or empty roles, the issue is in:
- JWT token generation (backend)
- Role extraction from JWT (frontend)

### 2. Verify JWT Token Contains SUPER_ADMIN

In browser console (after login):
```javascript
// Get token from localStorage
const token = localStorage.getItem('access_token') || 
               sessionStorage.getItem('access_token');

// Decode JWT (base64 decode the payload)
const parts = token.split('.');
const payload = JSON.parse(atob(parts[1]));
console.log('Roles in JWT:', payload.roles);
```

Should show: `["SUPER_ADMIN"]` or `["SUPER_ADMIN", ...]`

### 3. Check Router Navigation

Add breakpoint or print statements in:
- `apps/frontend/lib/src/core/router/app_router.dart` line 503-507
- Check if `role` variable equals `"SUPER_ADMIN"`

### 4. Verify Dashboard Page Loads

Check if you see:
- "Super Admin Dashboard" header
- System-Wide Statistics section
- Company Management section
- Quick Actions section

If you see "Admin Dashboard" instead, the role detection failed.

## Common Issues

### Issue: Wrong Dashboard Shows

**Symptoms:**
- See Admin Dashboard instead of Super Admin Dashboard
- Console shows role as something other than "SUPER_ADMIN"

**Possible Causes:**
1. JWT token doesn't contain SUPER_ADMIN role
2. Role extraction from JWT failed
3. Role array is empty

**Solution:**
1. Check backend logs to verify SUPER_ADMIN role is in JWT
2. Verify user has SUPER_ADMIN role in database
3. Check JWT token payload in browser console

### Issue: Dashboard Not Loading

**Symptoms:**
- Blank screen
- Loading spinner never stops
- Error message

**Possible Causes:**
1. DashboardBloc not provided (should be fixed now)
2. API call failing
3. Data format mismatch

**Solution:**
1. Check browser console for errors
2. Check Network tab for failed API calls
3. Verify backend is running and accessible

### Issue: Redirect Loop

**Symptoms:**
- Page keeps redirecting
- Can't reach dashboard

**Possible Causes:**
1. Auth state not persisting
2. Token expired immediately
3. Redirect logic conflict

**Solution:**
1. Check AuthBloc state
2. Verify token is valid
3. Check redirect logic in `_handleRedirect`

## Testing Checklist

- [ ] Login as Super Admin (`superadmin@system.local`)
- [ ] Check browser console for role logs
- [ ] Verify JWT token contains `SUPER_ADMIN` in roles array
- [ ] Confirm redirect to `/dashboard`
- [ ] Verify `SuperAdminDashboardPage` is rendered (not AdminDashboardPage)
- [ ] Check dashboard shows "Super Admin Dashboard" header
- [ ] Verify all sections are visible:
  - [ ] System-Wide Statistics
  - [ ] Company Management
  - [ ] Quick Actions
  - [ ] Recent Activity

## Code Locations

### Router Configuration
- File: `apps/frontend/lib/src/core/router/app_router.dart`
- Role detection: Lines 143-152
- Dashboard builder: Lines 503-520

### Role Detection Fix
```dart
// OLD (line 148):
userRole = user.roles.first;

// NEW (lines 147-151):
if (user.roles.any((role) => role.toUpperCase() == 'SUPER_ADMIN')) {
  userRole = 'SUPER_ADMIN';
} else {
  userRole = user.roles.first;
}
```

### Dashboard Route
- Path: `/dashboard`
- Builder: Lines 142-160
- Role-based routing: Line 158 calls `_buildDashboardForRole(userRole)`

## Next Steps if Still Not Working

1. **Add more debug logging:**
   ```dart
   print('🔍 Auth State: $authState');
   print('🔍 User Roles: ${user.roles}');
   print('🔍 Selected Role: $userRole');
   ```

2. **Check backend JWT generation:**
   - Verify `SUPER_ADMIN` is in roles array when generating token
   - Check `apps/backend/src/modules/auth/services/auth.service.ts` line 70

3. **Verify database:**
   ```sql
   SELECT u.email, r.name as role_name 
   FROM users u 
   JOIN user_roles ur ON u.id = ur.user_id 
   JOIN roles r ON ur.role_id = r.id 
   WHERE u.email = 'superadmin@system.local';
   ```
   Should return: `SUPER_ADMIN`

