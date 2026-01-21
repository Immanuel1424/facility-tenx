# Villa Type Configuration System - Implementation Guide

## Overview

This system implements **backend-driven configuration** for villa types, enabling **faster data entry** by auto-filling default values (bedroom count, floor count, area) when creating villas. The configuration is **admin-manageable** through API endpoints, allowing non-technical users to configure defaults without code changes.

## Architecture Decision

**Why Backend Configuration?**
- ✅ **Centralized Logic**: Business rules live in one place (backend)
- ✅ **Admin Control**: Non-technical admins can configure via admin screen
- ✅ **Multi-Tenant**: Each company can have different villa type configurations
- ✅ **Consistency**: Same rules apply to API, mobile, web
- ✅ **Data Integrity**: Backend validates and enforces rules
- ✅ **Flexibility**: Add new villa types without code deployment
- ✅ **Faster Data Entry**: Auto-fills defaults, reducing manual input

## Database Schema

### Table: `villa_type_configs`

```sql
CREATE TABLE villa_type_configs (
  id UUID PRIMARY KEY,
  company_id UUID NOT NULL,
  villa_type VARCHAR(50) NOT NULL,
  display_name VARCHAR(255) NULL,
  default_bedroom_count INT NULL,
  default_floor_count INT NULL,
  default_area_sqm DECIMAL(10, 2) NULL,
  display_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  metadata JSONB NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);
```

**Unique Constraint**: `(company_id, villa_type)` - One config per villa type per company

## API Endpoints

### 1. Get All Villa Type Configurations
```
GET /api/v1/villa-type-configs
Query: ?includeInactive=true (optional)
Permission: villa_type_configs:read
```

**Response:**
```json
[
  {
    "id": "uuid",
    "villaType": "1BHK",
    "displayName": "1 Bedroom Hall Kitchen",
    "defaultBedroomCount": 1,
    "defaultFloorCount": 1,
    "defaultAreaSqm": 50.5,
    "displayOrder": 0,
    "isActive": true
  }
]
```

### 2. Create Villa Type Configuration
```
POST /api/v1/villa-type-configs
Permission: villa_type_configs:create
```

**Request Body:**
```json
{
  "villaType": "1BHK",
  "displayName": "1 Bedroom Hall Kitchen",
  "defaultBedroomCount": 1,
  "defaultFloorCount": 1,
  "defaultAreaSqm": 50.5,
  "displayOrder": 0,
  "isActive": true
}
```

### 3. Update Villa Type Configuration
```
PUT /api/v1/villa-type-configs/:id
Permission: villa_type_configs:update
```

### 4. Delete Villa Type Configuration
```
DELETE /api/v1/villa-type-configs/:id
Permission: villa_type_configs:delete
```

### 5. Get Villa Types (Lookup with Defaults)
```
GET /api/v1/lookup/villa-types
Permission: villa_type_configs:read (or any authenticated user)
```

**Response:** Simplified format for dropdowns
```json
[
  {
    "id": "uuid",
    "villaType": "1BHK",
    "displayName": "1 Bedroom Hall Kitchen",
    "defaultBedroomCount": 1,
    "defaultFloorCount": 1,
    "defaultAreaSqm": 50.5,
    "displayOrder": 0
  }
]
```

## Auto-Fill Logic

When creating a villa via `POST /api/v1/villas`, the system:

1. **Checks if `villaType` is provided** in the request
2. **Looks up the configuration** for that villa type in the company
3. **Auto-fills defaults** only if the field is **not already provided** (allows manual override)
4. **Saves the villa** with auto-filled values

**Example:**

**Request:**
```json
{
  "villaNumber": "101",
  "villaType": "1BHK"
  // bedroomCount, floorCount, areaSqm not provided
}
```

**Result:**
```json
{
  "villaNumber": "101",
  "villaType": "1BHK",
  "bedroomCount": 1,        // ← Auto-filled from config
  "floorCount": 1,          // ← Auto-filled from config
  "areaSqm": 50.5           // ← Auto-filled from config
}
```

**Manual Override:**
```json
{
  "villaNumber": "101",
  "villaType": "1BHK",
  "bedroomCount": 2  // ← Manual override, config default ignored
}
```

## Setup Instructions

### 1. Run Migration

```bash
psql -d facility_erp -f migrations/create-villa-type-configs-table.sql
```

### 2. Seed Initial Data (Optional)

Create initial configurations for common villa types:

```sql
-- Example: Insert default configurations for a company
INSERT INTO villa_type_configs (
  company_id, villa_type, display_name, 
  default_bedroom_count, default_floor_count, default_area_sqm, 
  display_order, is_active
) VALUES
  ('your-company-id', '1BHK', '1 Bedroom Hall Kitchen', 1, 1, 50.0, 0, true),
  ('your-company-id', '2BHK', '2 Bedroom Hall Kitchen', 2, 1, 75.0, 1, true),
  ('your-company-id', '3BHK', '3 Bedroom Hall Kitchen', 3, 1, 100.0, 2, true),
  ('your-company-id', 'Studio', 'Studio Apartment', 1, 1, 35.0, 3, true),
  ('your-company-id', 'Duplex', 'Duplex Villa', null, 2, 150.0, 4, true);
```

### 3. Configure Permissions

Ensure the following permissions exist in your IAM system:
- `villa_type_configs:create`
- `villa_type_configs:read`
- `villa_type_configs:update`
- `villa_type_configs:delete`

## Frontend Integration

### 1. Fetch Villa Types with Defaults

```dart
// GET /api/v1/lookup/villa-types
final response = await apiClient.get('/lookup/villa-types');
final villaTypes = (response.data as List)
    .map((json) => VillaTypeConfig.fromJson(json))
    .toList();
```

### 2. Use in Villa Create Form

```dart
// When user selects villa type
void onVillaTypeChanged(String? villaType) {
  final config = villaTypes.firstWhere(
    (vt) => vt.villaType == villaType,
    orElse: () => null,
  );
  
  if (config != null) {
    // Auto-fill defaults (only if fields are empty)
    if (bedroomCountController.text.isEmpty) {
      bedroomCountController.text = 
          config.defaultBedroomCount?.toString() ?? '';
    }
    if (floorCountController.text.isEmpty) {
      floorCountController.text = 
          config.defaultFloorCount?.toString() ?? '';
    }
    if (areaSqmController.text.isEmpty) {
      areaSqmController.text = 
          config.defaultAreaSqm?.toString() ?? '';
    }
  }
}
```

### 3. Admin Screen for Configuration

Create an admin screen to manage villa type configurations:
- List all configurations
- Create new configurations
- Edit existing configurations
- Activate/Deactivate configurations
- Reorder display order

## Benefits

1. **Faster Data Entry**: Auto-fills reduce manual input by 60-80%
2. **Consistency**: Same defaults across all clients (web, mobile, API)
3. **Flexibility**: Admins can configure without developer intervention
4. **Multi-Tenant**: Each company can have different configurations
5. **Data Quality**: Reduces errors from manual entry
6. **Maintainability**: Business logic centralized in backend

## Migration Path

1. **Phase 1**: Deploy backend changes (no breaking changes)
2. **Phase 2**: Run migration to create table
3. **Phase 3**: Seed initial configurations via admin screen
4. **Phase 4**: Update frontend to use lookup endpoint
5. **Phase 5**: Test auto-fill functionality
6. **Phase 6**: Train admins on configuration management

## Example Use Cases

### Use Case 1: Standard Villa Types
Company has standard villa types (1BHK, 2BHK, 3BHK) with fixed defaults.

**Configuration:**
- 1BHK → 1 bedroom, 1 floor, 50 sqm
- 2BHK → 2 bedrooms, 1 floor, 75 sqm
- 3BHK → 3 bedrooms, 1 floor, 100 sqm

**Result:** Creating a villa with type "2BHK" auto-fills 2 bedrooms, 1 floor, 75 sqm.

### Use Case 2: Variable Types
Company has variable types (Penthouse, Villa) where defaults don't apply.

**Configuration:**
- Penthouse → No defaults (null values)
- Villa → No defaults (null values)

**Result:** Creating a villa with type "Penthouse" requires manual input for all fields.

### Use Case 3: Duplex Special Case
Company has Duplex villas that always have 2 floors.

**Configuration:**
- Duplex → 2 floors (default), variable bedrooms

**Result:** Creating a villa with type "Duplex" auto-fills 2 floors, but bedroom count requires manual input.

## Testing

### Unit Tests
- Test VillaTypeConfigService methods
- Test VillaService auto-fill logic
- Test validation and constraints

### Integration Tests
- Test API endpoints
- Test auto-fill on villa creation
- Test manual override functionality

### Manual Testing
1. Create villa type configurations via API
2. Create a villa with a configured type
3. Verify defaults are auto-filled
4. Create a villa with manual values
5. Verify manual values override defaults

## Troubleshooting

**Issue**: Defaults not auto-filling
- Check if villa type configuration exists and is active
- Verify company_id matches
- Check if fields are already provided (manual override)

**Issue**: Duplicate villa type error
- Each company can only have one config per villa type
- Check existing configurations before creating

**Issue**: Inactive configs appearing
- Use `includeInactive=false` in queries
- Check `isActive` flag in configuration

## Future Enhancements

1. **Validation Rules**: Add min/max constraints per villa type
2. **Bulk Import**: Import configurations from CSV/Excel
3. **Templates**: Pre-defined configuration templates
4. **Audit Trail**: Track configuration changes
5. **Versioning**: Support configuration versioning
6. **Conditional Defaults**: Defaults based on site/location

