# Quick Start: Running Tests

## Step 1: Install Dependencies

First, install the new testing dependencies:

```bash
cd apps/backend
npm install
```

This will install:
- `jest` - Testing framework
- `ts-jest` - TypeScript support for Jest
- `@nestjs/testing` - NestJS testing utilities
- `@types/jest` - TypeScript types for Jest

## Step 2: Run the Tests

### Run All Tests
```bash
npm test
```

### Run Specific Test File
```bash
npm test user.service.spec.ts
```

### Run Tests in Watch Mode (auto-rerun on file changes)
```bash
npm run test:watch
```

### Run Tests with Coverage Report
```bash
npm run test:cov
```

### Run Tests in Debug Mode
```bash
npm run test:debug
```

## Step 3: View Results

After running tests, you'll see output like:

```
 PASS  src/modules/iam/services/user.service.spec.ts
  UserService - Delete User
    delete
      ✓ should successfully soft delete a user without villa number (15ms)
      ✓ should successfully soft delete a tenant user with villa number (12ms)
      ✓ should handle villa sync failure gracefully (8ms)
      ...
    
Test Suites: 1 passed, 1 total
Tests:       20 passed, 20 total
```

## Troubleshooting

### Issue: "Cannot find module" errors

**Solution**: Make sure you're in the `apps/backend` directory:
```bash
cd apps/backend
npm test
```

### Issue: TypeScript compilation errors

**Solution**: The `tsconfig.json` has been updated to include Jest types. If you still see errors, try:
```bash
npm install --save-dev @types/jest
```

### Issue: Tests not found

**Solution**: Ensure test files end with `.spec.ts`:
- ✅ `user.service.spec.ts` - Will be found
- ❌ `user.service.test.ts` - Will NOT be found

### Issue: Module resolution errors

**Solution**: The Jest config uses `rootDir: 'src'`, so make sure:
- Test files are in `src/` directory
- Imports use relative paths or paths starting with `src/`

## Test File Location

The test file is located at:
```
apps/backend/src/modules/iam/services/user.service.spec.ts
```

## What the Tests Cover

The test suite includes 20+ test cases covering:

1. ✅ Basic deletion (with/without villa)
2. ✅ Error handling (not found, wrong company)
3. ✅ Edge cases (multiple villas, missing data)
4. ✅ Data integrity (soft delete preservation)
5. ✅ Villa occupancy sync
6. ✅ Cascade delete behavior
7. ✅ User visibility after deletion
8. ✅ Maintenance ticket preservation

## Next Steps

1. **Run the tests** to verify everything works
2. **Check coverage** with `npm run test:cov`
3. **Add more tests** for other service methods
4. **Create integration tests** for database cascade behavior

## Example Output

```
> facility-erp-backend@0.0.1 test
> jest

 PASS  src/modules/iam/services/user.service.spec.ts
  UserService - Delete User
    delete
      ✓ should successfully soft delete a user without villa number (23ms)
      ✓ should successfully soft delete a tenant user with villa number and mark villa as vacant (19ms)
      ✓ should handle villa sync failure gracefully without failing user deletion (15ms)
      ✓ should not update villa occupancy if villa is already vacant (12ms)
      ✓ should throw NotFoundException when user does not exist (8ms)
      ✓ should throw NotFoundException when user belongs to different company (7ms)
      ✓ should preserve user data after soft delete (for referential integrity) (11ms)
      ✓ should set deletedAt timestamp when deleting user (9ms)
      ✓ should handle user with multiple villa numbers (villaNumbers array) (14ms)
      ✓ should handle user deletion when villa does not exist (10ms)
    Cascade Delete Behavior
      ✓ should verify that user roles are cascade deleted (database constraint) (1ms)
      ✓ should verify that refresh tokens are cascade deleted (database constraint) (1ms)
      ✓ should verify that user-site assignments are cascade deleted (database constraint) (1ms)
    User Visibility After Deletion
      ✓ should verify deleted users are excluded from findByEmail queries (6ms)
      ✓ should verify deleted users cannot log in (excluded from auth queries) (1ms)
    Maintenance Tickets After User Deletion
      ✓ should verify maintenance tickets remain intact after user deletion (1ms)
      ✓ should verify maintenance tickets can still reference deleted user (1ms)

Test Suites: 1 passed, 1 total
Tests:       17 passed, 17 total
Snapshots:   0 total
Time:        2.456 s
```

## Need Help?

- Check `test/README.md` for detailed testing guide
- Check `src/modules/iam/services/README-TESTS.md` for test case documentation
- Review Jest documentation: https://jestjs.io/docs/getting-started
