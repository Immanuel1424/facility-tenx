# Create Admin User Script

This script creates an admin user for a newly created company account.

## Prerequisites

1. **Company must exist**: Run `011-create-company.sql` first to create the company
2. **Database access**: PostgreSQL database must be accessible
3. **Company code**: Know the company code from the company creation script

## Usage

### Step 1: Edit Configuration

Open `012-create-admin-user.sql` and edit the configuration variables at the top:

```sql
company_code_var VARCHAR(100) := 'ALOS';  -- Must match your company code
admin_email_var VARCHAR(255) := 'admin@company.com';  -- Admin email
admin_password_var VARCHAR(255) := 'password123';  -- Admin password
admin_first_name_var VARCHAR(100) := 'Admin';  -- First name
admin_last_name_var VARCHAR(100) := 'User';  -- Last name
admin_phone_var VARCHAR(20) := NULL;  -- Optional phone
```

### Step 2: Generate Password Hash (Optional)

If you want to use a different password, generate a bcrypt hash:

```bash
cd apps/backend
node -e "const bcrypt=require('bcrypt');bcrypt.hash('yourpassword',10).then(h=>console.log(h))"
```

Then replace the `password_hash_var` value in the script.

### Step 3: Run the Script

```bash
cd apps/backend
psql -U postgres -d facility_erp -f scripts/migrations/012-create-admin-user.sql
```

Or with custom connection:

```bash
psql -h localhost -U postgres -d facility_erp -f scripts/migrations/012-create-admin-user.sql
```

## What the Script Does

1. ✅ Validates company exists (by code)
2. ✅ Creates admin user with hashed password
3. ✅ Creates ADMIN role (if it doesn't exist)
4. ✅ Assigns ADMIN role to the user
5. ✅ Idempotent - safe to run multiple times

## Output

The script will display:

- Company information
- User creation status
- Role assignment status
- Login credentials for testing

## Example Output

```
========================================
👤 CREATING ADMIN USER
========================================

✅ Found company: ALOS (ID: 123e4567-e89b-12d3-a456-426614174000)
✅ Using pre-hashed password
✅ Created admin user: Admin User (admin@company.com)
   User ID: 987fcdeb-51a2-43f7-8b9c-123456789abc
✅ Created ADMIN role (ID: 456e7890-f12a-34b5-c678-901234567def)
✅ Assigned ADMIN role to user

========================================
✅ ADMIN USER CREATION COMPLETE
========================================
Company Code: ALOS
Company ID: 123e4567-e89b-12d3-a456-426614174000
User Email: admin@company.com
User ID: 987fcdeb-51a2-43f7-8b9c-123456789abc
User Name: Admin User
Password: password123 (hashed)
Role: ADMIN (ID: 456e7890-f12a-34b5-c678-901234567def)
========================================

📝 Next Steps:
   1. Assign permissions to ADMIN role (if needed)
   2. Test login with: admin@company.com / password123
========================================
```

## Next Steps

After creating the admin user:

1. **Test Login**: Use the credentials to log in via the API or frontend
2. **Assign Permissions**: The ADMIN role is created but may need permissions assigned
3. **Create Additional Users**: Use the same pattern for other users

## Troubleshooting

### Error: Company not found

- Make sure you ran `011-create-company.sql` first
- Verify the company code matches exactly

### Error: User already exists

- The script will use the existing user
- To create a different user, change the email

### Error: Permission denied

- Check database user has INSERT permissions
- Verify you're using the correct database

## Notes

- **Password**: Default password is `password123` (pre-hashed)
- **Idempotent**: Safe to run multiple times - won't create duplicates
- **Role**: ADMIN role is created with hierarchy level 100
- **Permissions**: You may need to assign permissions to the ADMIN role separately
