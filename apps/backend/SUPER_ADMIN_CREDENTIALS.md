# Super Admin Login Credentials

## Exact Credentials

**Company Code:** `SYSTEM`

**Email:** `superadmin@system.local`

**Password:** `SuperAdmin@2025!`

⚠️ **Important:** 
- The password is exactly: `SuperAdmin@2025!` (no spaces, no prefix)
- Company code must be exactly: `SYSTEM` (uppercase)
- Email is case-sensitive: `superadmin@system.local`

## Login Steps

1. **Company Selection Page:**
   - Enter company code: `SYSTEM`
   - Click Continue

2. **Login Page:**
   - Email: `superadmin@system.local`
   - Password: `SuperAdmin@2025!`
   - Click Login

## Troubleshooting

### If login fails with "Invalid credentials":

1. **Verify password is correct:**
   - Make sure you're typing: `SuperAdmin@2025!`
   - No spaces before or after
   - Capital S, capital A, @ symbol, 2025!, no prefix

2. **Verify company code:**
   - Must be exactly: `SYSTEM` (all uppercase)
   - No spaces

3. **Check user exists in database:**
   ```sql
   SELECT u.email, u.status, c.code as company_code, r.name as role_name 
   FROM users u 
   JOIN companies c ON u.company_id = c.id 
   JOIN user_roles ur ON u.id = ur.user_id 
   JOIN roles r ON ur.role_id = r.id 
   WHERE u.email = 'superadmin@system.local';
   ```
   Should return: `superadmin@system.local | active | SYSTEM | SUPER_ADMIN`

4. **Reset password if needed:**
   ```sql
   -- Generate new password hash (replace 'YourNewPassword' with actual password)
   -- Then update:
   UPDATE users 
   SET "passwordHash" = '$2b$10$...' -- Use bcrypt hash
   WHERE email = 'superadmin@system.local';
   ```

### If you get "Invalid company id or code":

1. **Verify SYSTEM company exists:**
   ```sql
   SELECT id, code, name FROM companies WHERE code = 'SYSTEM';
   ```
   Should return the SYSTEM company

2. **Check backend logs** for errors during company code resolution

3. **Verify frontend is sending "SYSTEM"** in the `x-company-id` header

### Common Issues

- **Copy-paste error:** Make sure you're not copying the comment `-- Password: SuperAdmin@2025!` from the SQL file
- **Case sensitivity:** Company code must be `SYSTEM` (uppercase)
- **Spaces:** No leading or trailing spaces in password or company code
- **Special characters:** Password contains `@` and `!` - make sure your keyboard/input method handles these correctly

## Test Password Hash

To verify the password hash is correct, you can test it:

```bash
cd apps/backend
node -e "const bcrypt = require('bcrypt'); const hash = '\$2b\$10\$OKihApIjCWv9pkuNRIFZu.7BSb2xBATiYwtE1eurj.ERH1pOvIj1e'; bcrypt.compare('SuperAdmin@2025!', hash).then(match => console.log('Password match:', match));"
```

Should output: `Password match: true`

## Change Password

After first login, **immediately change the password** for security.

