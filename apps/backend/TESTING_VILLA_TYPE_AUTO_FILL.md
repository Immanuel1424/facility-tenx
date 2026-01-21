# Testing Villa Type Auto-Fill Functionality

## ✅ Step 1: Database Seeding - COMPLETED

Villa type configurations have been seeded successfully:

```
✅ 11 villa type configurations created
✅ Company ID: eb75a65b-055f-4408-a58c-71d233443c17
✅ All configurations are active
```

**Seeded Configurations:**
- 1BHK → 1 bedroom, 1 floor, 50 sqm
- 2BK → 2 bedrooms, 1 floor, 65 sqm
- 2BHK → 2 bedrooms, 1 floor, 75 sqm
- 3BK → 3 bedrooms, 1 floor, 90 sqm
- 3BHK → 3 bedrooms, 1 floor, 100 sqm
- 4BK → 4 bedrooms, 1 floor, 120 sqm
- 4BHK → 4 bedrooms, 1 floor, 130 sqm
- Studio → 1 bedroom, 1 floor, 35 sqm
- Penthouse → No defaults
- Duplex → 2 floors, 150 sqm (no bedroom default)
- Villa → No defaults

## 🧪 Step 2: Testing Methods

### Method 1: API Testing (Recommended)

#### Prerequisites
1. Backend server running (`npm run start:dev` in `apps/backend`)
2. Valid JWT token (login first)

#### Test 1: Get Villa Types (Lookup Endpoint)

```bash
curl -X GET "http://localhost:3000/api/v1/lookup/villa-types" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
[
  {
    "id": "uuid",
    "villaType": "1BHK",
    "displayName": "1 Bedroom Hall Kitchen",
    "defaultBedroomCount": 1,
    "defaultFloorCount": 1,
    "defaultAreaSqm": 50.0,
    "displayOrder": 0
  },
  ...
]
```

#### Test 2: Create Villa with Auto-Fill (Backend)

```bash
curl -X POST "http://localhost:3000/api/v1/villas" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "villaNumber": "TEST-101",
    "villaType": "1BHK"
  }'
```

**Expected Response:**
```json
{
  "id": "uuid",
  "villaNumber": "TEST-101",
  "villaType": "1BHK",
  "bedroomCount": 1,    // ← Auto-filled
  "floorCount": 1,      // ← Auto-filled
  "areaSqm": 50.0       // ← Auto-filled
}
```

#### Test 3: Manual Override (User Values Take Precedence)

```bash
curl -X POST "http://localhost:3000/api/v1/villas" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "villaNumber": "TEST-102",
    "villaType": "1BHK",
    "bedroomCount": 2,
    "floorCount": 2,
    "areaSqm": 60.0
  }'
```

**Expected Response:**
```json
{
  "villaNumber": "TEST-102",
  "villaType": "1BHK",
  "bedroomCount": 2,    // ← User value (not default 1)
  "floorCount": 2,      // ← User value (not default 1)
  "areaSqm": 60.0       // ← User value (not default 50.0)
}
```

#### Test 4: Duplex (Partial Defaults)

```bash
curl -X POST "http://localhost:3000/api/v1/villas" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "villaNumber": "TEST-103",
    "villaType": "Duplex"
  }'
```

**Expected Response:**
```json
{
  "villaNumber": "TEST-103",
  "villaType": "Duplex",
  "bedroomCount": null,  // ← No default
  "floorCount": 2,       // ← Auto-filled
  "areaSqm": 150.0       // ← Auto-filled
}
```

### Method 2: Frontend Testing

#### Steps:

1. **Start Backend:**
   ```bash
   cd apps/backend
   npm run start:dev
   ```

2. **Start Frontend:**
   ```bash
   cd apps/frontend
   flutter run
   ```

3. **Test Auto-Fill:**
   - Navigate to Villa Create Page
   - Wait for villa types to load (loading indicator should appear)
   - Select "1BHK" from dropdown
   - **Verify:** Bedroom Count auto-fills to "1"
   - **Verify:** Floor Count auto-fills to "1"
   - **Verify:** Area (sqm) auto-fills to "50.0"
   - **Verify:** You can still manually change any value

4. **Test Manual Override:**
   - Select "1BHK"
   - Manually change Bedroom Count to "2"
   - Select "2BHK" (should not overwrite your "2")
   - **Verify:** Your manual value "2" is preserved

5. **Test Duplex:**
   - Select "Duplex"
   - **Verify:** Floor Count auto-fills to "2"
   - **Verify:** Area auto-fills to "150.0"
   - **Verify:** Bedroom Count remains empty (no default)

6. **Test Penthouse:**
   - Select "Penthouse"
   - **Verify:** No fields auto-fill (no defaults configured)

### Method 3: Database Verification

```sql
-- Check configurations
SELECT villa_type, default_bedroom_count, default_floor_count, default_area_sqm
FROM villa_type_configs
WHERE company_id = 'eb75a65b-055f-4408-a58c-71d233443c17'
ORDER BY display_order;

-- Check created villa (after API test)
SELECT villa_number, villa_type, bedroom_count, floor_count, area_sqm
FROM villas
WHERE villa_number LIKE 'TEST-%'
ORDER BY created_at DESC;
```

## ✅ Test Checklist

### Backend Tests
- [x] Villa type configurations seeded
- [ ] GET `/lookup/villa-types` returns correct data
- [ ] POST `/villas` with `villaType` auto-fills defaults
- [ ] Manual values override defaults
- [ ] Partial defaults work (Duplex)
- [ ] No defaults work (Penthouse)

### Frontend Tests
- [ ] Villa types load from API
- [ ] Dropdown shows display names
- [ ] Auto-fill works on villa type selection
- [ ] Manual override works
- [ ] Loading indicator shows
- [ ] Fallback works if API fails

## 🐛 Troubleshooting

### Issue: Auto-fill not working
**Solution:**
1. Check backend logs for errors
2. Verify villa type config exists in database
3. Check company_id matches
4. Verify villa type code matches exactly (case-sensitive)

### Issue: Frontend not loading villa types
**Solution:**
1. Check network tab for API call
2. Verify backend is running
3. Check JWT token is valid
4. Verify CORS is configured

### Issue: Defaults not applying
**Solution:**
1. Check if fields are already filled (auto-fill only works on empty fields)
2. Verify backend service is calling `getDefaults()`
3. Check backend logs for errors

## 📊 Expected Results Summary

| Villa Type | Bedroom Count | Floor Count | Area (sqm) |
|------------|---------------|-------------|------------|
| 1BHK       | 1             | 1           | 50.0       |
| 2BHK       | 2             | 1           | 75.0       |
| 3BHK       | 3             | 1           | 100.0      |
| Duplex     | null          | 2           | 150.0      |
| Penthouse  | null          | null        | null       |

## 🎯 Success Criteria

✅ **Backend Auto-Fill:**
- Creates villa with defaults when `villaType` provided
- Respects manual values (doesn't override)
- Handles partial defaults correctly
- Handles no defaults correctly

✅ **Frontend Auto-Fill:**
- Loads villa types from API
- Auto-fills empty fields on selection
- Preserves manual values
- Shows helpful UI feedback

✅ **Integration:**
- Backend and frontend auto-fill work independently
- Both respect user input
- System is resilient (fallbacks work)

