# Create Ticket Categories SQL Script Guide

This guide explains how to use the SQL script to create ticket categories for maintenance tickets.

## 📋 Overview

The script `014-create-ticket-categories.sql` creates **8 ticket categories** for maintenance tickets:
- Plumbing
- Electrical
- HVAC
- Cleaning
- Security
- General Maintenance
- Landscaping
- Miscellaneous

It is **idempotent** - safe to run multiple times.

## 🚀 Quick Start

### 1. Run the Script

```bash
cd apps/backend
psql -U postgres -d facility_erp -f scripts/migrations/014-create-ticket-categories.sql
```

### 2. Customize Company Code (Optional)

Edit the script to target a specific company:

```sql
-- In the script, change this line:
target_company_code VARCHAR(100) := NULL;  -- Uses first company found

-- To:
target_company_code VARCHAR(100) := 'ALOS';  -- Uses specific company
```

## 📝 Script Details

### Categories Created

| Code | Name | Description | Display Order | Default SLA (hours) | Color |
|------|------|------------|---------------|---------------------|-------|
| `PLUMBING` | Plumbing | Plumbing related issues | 1 | 24 | #2196F3 (Blue) |
| `ELECTRICAL` | Electrical | Electrical related issues | 2 | 24 | #FF9800 (Orange) |
| `HVAC` | HVAC | Heating, ventilation, and air conditioning | 3 | 24 | #4CAF50 (Green) |
| `CLEANING` | Cleaning | Cleaning and maintenance requests | 4 | 48 | #9C27B0 (Purple) |
| `SECURITY` | Security | Security related issues | 5 | 12 | #F44336 (Red) |
| `GENERAL` | General Maintenance | General maintenance and repairs | 6 | 48 | #607D8B (Blue Grey) |
| `LANDSCAPING` | Landscaping | Landscaping and outdoor maintenance | 7 | 72 | #8BC34A (Light Green) |
| `MISCELLANEOUS` | Miscellaneous | Miscellaneous related issues | 8 | 48 | #795548 (Brown) |

### Category Fields

- **`code`**: Unique category code (max 50 characters, uppercase)
- **`name`**: Display name (max 100 characters)
- **`description`**: Category description (optional)
- **`parent_category_id`**: Parent category for hierarchical structure (optional)
- **`display_order`**: Order for display in dropdowns/lists
- **`is_active`**: Whether category is active
- **`icon`**: Icon identifier (optional)
- **`color_code`**: Hex color code for UI (optional)
- **`default_sla_hours`**: Default SLA in hours (optional)
- **`default_department_id`**: Default department assignment (optional)

## 🔄 Idempotency

The script is **idempotent** - it checks if each category already exists:

- ✅ **If exists**: Uses the existing category (no error)
- ✅ **If not exists**: Creates a new category

This makes it safe to run multiple times.

## 📊 Example Output

```
========================================
🚀 CREATING TICKET CATEGORIES
========================================

✅ Using existing company: eb75a65b-055f-4408-a58c-71d233443c17 (Code: ALOS, Name: Villa Maintenance Company)

📋 Creating Ticket Categories...
  ✅ Created category: PLUMBING - Plumbing
  ✅ Created category: ELECTRICAL - Electrical
  ...

========================================
✅ TICKET CATEGORIES CREATION COMPLETE
========================================
Company ID: eb75a65b-055f-4408-a58c-71d233443c17
Company Code: ALOS
Company Name: Villa Maintenance Company

Created/Verified:
  - 8 Ticket Categories (Plumbing, Electrical, HVAC, Cleaning, Security, General, Landscaping, Miscellaneous)
========================================
```

## 🔍 Verify Category Creation

After running the script, verify the categories were created:

```sql
-- View all categories for a company
SELECT 
  code,
  name,
  description,
  display_order,
  is_active,
  color_code,
  default_sla_hours
FROM ticket_categories
WHERE company_id = 'your-company-id'
ORDER BY display_order ASC;
```

## 🛠️ Common Use Cases

### Create for Specific Company

1. Find your company ID:
   ```sql
   SELECT id, code, name FROM companies;
   ```

2. Edit the script and set:
   ```sql
   target_company_code VARCHAR(100) := 'ALOS';
   ```

3. Run the script

### Create for New Company

1. First create the company using `011-create-company.sql`
2. Note the company code from the output
3. Edit `014-create-ticket-categories.sql` and set `target_company_code`
4. Run the script

### Customize Categories

Edit the category creation sections in the script to change:
- Category code and name
- Description
- Display order
- Default SLA hours
- Color code
- Icon

Example:
```sql
-- Change Plumbing default SLA from 24 to 12 hours
INSERT INTO ticket_categories (..., default_sla_hours, ...)
VALUES (..., 12, ...);
```

### Create Sub-Categories

To create sub-categories (child categories), modify the script to set `parent_category_id`:

```sql
-- Create a sub-category under Plumbing
INSERT INTO ticket_categories (
  id, company_id, code, name, description,
  parent_category_id, display_order, is_active, ...
)
VALUES (
  gen_random_uuid(), company_id_var,
  'PLUMBING_LEAK', 'Water Leak', 'Water leak repairs',
  (SELECT id FROM ticket_categories WHERE company_id = company_id_var AND code = 'PLUMBING'),
  1, TRUE, ...
);
```

## ⚠️ Important Notes

1. **Company Required**: A company must exist before running this script. Use `011-create-company.sql` first if needed.

2. **Company-Scoped**: Categories are company-scoped. Each company has its own set.

3. **Unique Constraints**:
   - `(company_id, code)` must be unique
   - `(company_id, name)` is indexed for faster lookups

4. **Hierarchical Support**: Categories support parent-child relationships for organizing sub-categories.

5. **Default SLA**: The `default_sla_hours` field sets the default Service Level Agreement time for tickets in this category.

6. **Color Codes**: Use hex color codes (e.g., `#2196F3`) for UI theming.

## 🔗 Related Scripts

- `011-create-company.sql` - Create a new company
- `013-create-villa-types-and-roles.sql` - Create villa types and user roles
- `010-create-users.sql` - Create users with roles

## 📚 Database Schema

### Ticket Categories Table

```sql
CREATE TABLE ticket_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL,
  code VARCHAR(50) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  parent_category_id UUID,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  icon VARCHAR(50),
  color_code VARCHAR(7),
  default_sla_hours INTEGER,
  default_department_id UUID,
  created_by_id UUID,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE(company_id, code)
);
```

## 🐛 Troubleshooting

### Error: "No companies found"

**Solution**: Create a company first using `011-create-company.sql`.

### Error: "Company with code 'X' does not exist"

**Solution**: Verify the company code is correct:
```sql
SELECT id, code, name FROM companies WHERE code = 'YOUR_CODE';
```

### Categories Already Exist

**Solution**: This is normal! The script is idempotent and will skip existing categories. No action needed.

### Want to Update Existing Categories

**Solution**: Update directly via SQL:
```sql
-- Update a category's default SLA
UPDATE ticket_categories
SET default_sla_hours = 12
WHERE company_id = 'your-company-id'
  AND code = 'PLUMBING';

-- Update a category's color
UPDATE ticket_categories
SET color_code = '#FF5722'
WHERE company_id = 'your-company-id'
  AND code = 'ELECTRICAL';
```

### Want to Deactivate a Category

**Solution**: Soft-deactivate (keeps existing tickets valid):
```sql
UPDATE ticket_categories
SET is_active = FALSE
WHERE company_id = 'your-company-id'
  AND code = 'MISCELLANEOUS';
```

## 📞 Support

If you encounter issues:
1. Check the script output for error messages
2. Verify database connection and permissions
3. Ensure PostgreSQL extensions (`uuid-ossp`, `pgcrypto`) are installed
4. Check the database logs for detailed error information

