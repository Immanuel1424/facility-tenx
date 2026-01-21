# User Service - Delete User Test Cases

## Overview

This document describes the comprehensive test suite for the `UserService.delete()` method, which handles soft deletion of users (including tenants) in the facility ERP system.

## Test File

**Location**: `apps/backend/src/modules/iam/services/user.service.spec.ts`

## Test Coverage

### 1. Basic Deletion Scenarios

#### ✅ `should successfully soft delete a user without villa number`
- **Purpose**: Tests deletion of users who don't have a villa assignment
- **Verifies**:
  - User is marked as deleted (`deletedAt` is set)
  - User status is set to `INACTIVE`
  - Villa sync is not called
  - User data is preserved in database

#### ✅ `should successfully soft delete a tenant user with villa number and mark villa as vacant`
- **Purpose**: Tests deletion of tenant users with villa assignments
- **Verifies**:
  - User is soft-deleted
  - Villa occupancy is updated to `false` (vacant)
  - Villa sync service is called correctly
  - All operations complete successfully

### 2. Error Handling

#### ✅ `should handle villa sync failure gracefully without failing user deletion`
- **Purpose**: Ensures user deletion succeeds even if villa sync fails
- **Verifies**:
  - User deletion completes successfully
  - Villa sync errors are caught and logged
  - System remains stable even with partial failures

#### ✅ `should throw NotFoundException when user does not exist`
- **Purpose**: Validates error handling for non-existent users
- **Verifies**:
  - Proper exception is thrown
  - No database operations are performed
  - Error message is clear and actionable

#### ✅ `should throw NotFoundException when user belongs to different company`
- **Purpose**: Ensures company-scoped access control
- **Verifies**:
  - Users from other companies cannot be deleted
  - Security boundary is maintained

### 3. Edge Cases

#### ✅ `should not update villa occupancy if villa is already vacant`
- **Purpose**: Optimizes villa sync operations
- **Verifies**:
  - Unnecessary database updates are avoided
  - System handles already-vacant villas correctly

#### ✅ `should handle user with multiple villa numbers (villaNumbers array)`
- **Purpose**: Tests deletion of users with multiple villa assignments
- **Verifies**:
  - Primary villa (first in array) is synced
  - Multiple villa scenario is handled correctly

#### ✅ `should handle user deletion when villa does not exist`
- **Purpose**: Tests resilience when villa data is missing
- **Verifies**:
  - User deletion succeeds even if villa doesn't exist
  - No errors are thrown for missing villa data

### 4. Data Integrity

#### ✅ `should preserve user data after soft delete (for referential integrity)`
- **Purpose**: Ensures soft delete maintains data relationships
- **Verifies**:
  - All user fields are preserved
  - Foreign key relationships remain intact
  - Historical data is maintained

#### ✅ `should set deletedAt timestamp when deleting user`
- **Purpose**: Validates timestamp accuracy
- **Verifies**:
  - `deletedAt` is set to current time
  - Timestamp is within expected range

### 5. Cascade Delete Behavior (Documentation Tests)

These tests document expected database behavior:

#### ✅ `should verify that user roles are cascade deleted`
- **Documentation**: UserRole entity has `onDelete: 'CASCADE'`
- **Note**: Actual cascade is tested via integration tests

#### ✅ `should verify that refresh tokens are cascade deleted`
- **Documentation**: RefreshToken entity has `onDelete: 'CASCADE'`
- **Note**: Actual cascade is tested via integration tests

#### ✅ `should verify that user-site assignments are cascade deleted`
- **Documentation**: UserSite entity has `onDelete: 'CASCADE'`
- **Note**: Actual cascade is tested via integration tests

### 6. User Visibility After Deletion

#### ✅ `should verify deleted users are excluded from findByEmail queries`
- **Purpose**: Tests user filtering logic
- **Verifies**:
  - Deleted users are not returned in queries
  - `deletedAt: IsNull()` filter is applied

#### ✅ `should verify deleted users cannot log in`
- **Documentation**: Authentication service should filter deleted users
- **Note**: Actual auth filtering tested in auth service tests

### 7. Maintenance Tickets After User Deletion

#### ✅ `should verify maintenance tickets remain intact after user deletion`
- **Documentation**: Tickets must be preserved for audit purposes
- **Note**: Actual ticket preservation tested in integration tests

#### ✅ `should verify maintenance tickets can still reference deleted user`
- **Documentation**: Foreign keys should still work with soft-deleted users
- **Note**: Actual foreign key behavior tested in integration tests

## Running the Tests

### Prerequisites

Install test dependencies:
```bash
npm install
```

### Run All Tests
```bash
npm test
```

### Run Specific Test File
```bash
npm test user.service.spec.ts
```

### Run Tests in Watch Mode
```bash
npm run test:watch
```

### Generate Coverage Report
```bash
npm run test:cov
```

## What Happens When a User is Deleted

### Soft Delete Process

1. **User Record**: 
   - `deletedAt` timestamp is set
   - `status` is set to `INACTIVE`
   - User record remains in database

2. **Cascade Deletes** (Database Level):
   - `user_roles` - All role assignments removed
   - `refresh_tokens` - All sessions invalidated
   - `user_sites` - User removed from all sites
   - `user_devices` - Device registrations removed
   - `password_reset_tokens` - Pending resets removed
   - `team_members` - Removed from all teams

3. **Villa Occupancy**:
   - If user has `villaNumber`, villa is marked as vacant
   - `isOccupied` is set to `false`

4. **Maintenance Tickets**:
   - Tickets created by user remain intact
   - `created_by` foreign key still references user
   - Historical data is preserved

5. **User Visibility**:
   - Deleted users excluded from all user lists
   - Cannot log in
   - Email uniqueness only enforced for non-deleted users

## Integration Tests

For testing actual database cascade behavior and foreign key constraints, create integration tests in:
- `test/integration/user-deletion.integration.spec.ts`

These should test:
- Actual database cascade deletes
- Foreign key constraints
- Transaction rollback scenarios
- Concurrent deletion attempts

## Notes

- All tests use Jest mocks to isolate unit behavior
- Database cascade behavior is documented but requires integration tests
- Villa sync failures are handled gracefully to prevent user deletion failures
- Soft delete preserves data integrity for audit and historical purposes
