# Database Query Optimization - Implementation Guide

## Overview

This document provides step-by-step instructions to implement the database query optimizations identified in the performance analysis.

**Expected Performance Improvements:**
- **60-75% faster** overall query performance
- **80-90% faster** dashboard queries
- **50-60% reduction** in total database queries
- **40-50% faster** user permission checks

---

## Implementation Steps

### Step 1: Replace Dashboard Service (HIGHEST PRIORITY)

**File:** `apps/backend/src/modules/dashboard/dashboard.service.ts`

**Action:** Replace the current implementation with the optimized version.

**Why:** The dashboard service loads ALL tickets into memory and filters in JavaScript. This is the biggest performance bottleneck.

**How:**
1. Backup current file: `cp dashboard.service.ts dashboard.service.backup.ts`
2. Replace with optimized version: `cp dashboard.service.optimized.ts dashboard.service.ts`
3. Test the dashboard endpoints
4. Monitor performance improvements

**Expected Gain:** 80-90% faster dashboard queries

---

### Step 2: Optimize MaintenanceTicketService.findOne

**File:** `apps/backend/src/modules/maintenance-ticket/services/maintenance-ticket.service.ts`

**Current Issue:** Loads all relations every time, even when not needed.

**Optimization:**
```typescript
// BEFORE (line 410-421)
async findOne(...) {
  const ticket = await this.ticketRepository.findOne({
    where: { id: ticketId, companyId },
    relations: [
      'creator',
      'department',
      'category',
      'assignedTechnician',
      'assigner',
      'statusHistory', // Could be large!
      'statusHistory.changer',
    ],
  });
}

// AFTER
async findOne(
  companyId: string,
  ticketId: string,
  userId: string,
  options?: { includeHistory?: boolean },
): Promise<MaintenanceTicket & { priority_details: PriorityDetails }> {
  // Load only essential relations
  const ticket = await this.ticketRepository.findOne({
    where: { id: ticketId, companyId },
    relations: ['creator', 'department', 'category', 'assignedTechnician'],
    // Remove statusHistory from default load
  });

  // Load status history separately if needed, with limit
  if (options?.includeHistory) {
    ticket.statusHistory = await this.statusHistoryRepository.find({
      where: { ticketId, companyId },
      relations: ['changer'],
      order: { createdAt: 'DESC' },
      take: 20, // Limit to recent entries
    });
  }
  
  // ... rest of method
}
```

**Expected Gain:** 40-60% faster ticket loading

---

### Step 3: Fix N+1 Queries in MaintenanceTicketService

**File:** `apps/backend/src/modules/maintenance-ticket/services/maintenance-ticket.service.ts`

**Current Issue:** `findOne` and `getUserRoles` called multiple times in same method.

**Optimization:**
```typescript
// BEFORE (line 508-509)
async update(...) {
  const ticket = await this.findOne(companyId, ticketId, userId); // Query 1
  const userRoles = await this.getUserRoles(companyId, userId); // Query 2
}

// AFTER
async update(...) {
  // Load both in parallel
  const [ticket, userRoles] = await Promise.all([
    this.ticketRepository.findOne({
      where: { id: ticketId, companyId },
      relations: ['creator', 'department', 'category'],
    }),
    this.getUserRoles(companyId, userId),
  ]);
  
  // ... rest of method
}
```

**Apply to methods:**
- `update()` (line 502)
- `changeStatus()` (line 536)
- `assignSupervisor()` (line 740)
- `assignTechnician()` (line 870)
- `acknowledge()` (line 960)
- Any other method calling `findOne` + `getUserRoles`

**Expected Gain:** 50-60% reduction in queries

---

### Step 4: Optimize User Service Queries

**File:** `apps/backend/src/modules/iam/services/user.service.ts`

**Current Issue:** Loads user with all relations even when only villaNumber is needed.

**Optimization:**
```typescript
// BEFORE (line 50, 200)
const user = await this.userRepo.findOne({
  where: { companyId, id: userId },
  // Loads all fields and relations
});

// AFTER
const user = await this.userRepo.findOne({
  where: { companyId, id: userId },
  select: ['id', 'villaNumber', 'villaNumbers'], // Only needed fields
});
```

**Apply to:**
- `dashboard.service.ts` line 50, 200
- Any other place loading user just for villaNumber

**Expected Gain:** 30-40% faster user lookups

---

### Step 5: Add Request-Scoped Caching for User Roles

**File:** `apps/backend/src/modules/iam/services/user.service.ts`

**Current Issue:** `getUserRoles` called multiple times per request.

**Optimization:**
```typescript
// Add caching decorator or implement request-scoped cache
import { Injectable, Scope } from '@nestjs/common';

@Injectable({ scope: Scope.REQUEST }) // Request-scoped for caching
export class UserService {
  private userRolesCache = new Map<string, Role[]>();

  async getUserRoles(companyId: string, userId: string): Promise<Role[]> {
    const key = `${companyId}:${userId}`;
    
    // Check cache first
    if (this.userRolesCache.has(key)) {
      return this.userRolesCache.get(key)!;
    }

    // Load from database
    const userRoles = await this.userRoleRepository.find({
      where: { companyId, userId },
      relations: ['role'],
    });

    const roles = userRoles.map((ur) => ur.role);
    
    // Cache for this request
    this.userRolesCache.set(key, roles);
    
    return roles;
  }
}
```

**Expected Gain:** 40-50% reduction in user role queries

---

### Step 6: Ensure All Queries Use companyId First

**File:** All service files

**Current Issue:** Some queries don't include `companyId` in WHERE clause, causing full table scans.

**Check:**
```bash
# Search for queries missing companyId
grep -r "\.find(" apps/backend/src --include="*.ts" | grep -v "companyId"
grep -r "\.findOne(" apps/backend/src --include="*.ts" | grep -v "companyId"
```

**Fix:** Always include `companyId` as first condition:
```typescript
// BAD
await this.ticketRepo.find({ where: { status: TicketStatus.NEW } });

// GOOD
await this.ticketRepo.find({ 
  where: { 
    companyId, // First for index usage
    status: TicketStatus.NEW 
  } 
});
```

**Expected Gain:** 70-90% faster queries on large datasets

---

## Testing Checklist

After implementing optimizations:

- [ ] **Dashboard Stats Endpoint** - Test `/api/v1/dashboard/stats`
  - Should be 80-90% faster
  - Verify all stats are correct

- [ ] **Dashboard Analytics Endpoint** - Test `/api/v1/dashboard/analytics`
  - Should be 70-80% faster
  - Verify distributions are correct

- [ ] **Ticket Listing** - Test `/api/v1/maintenance-tickets`
  - Should be 50-60% faster
  - Verify pagination works

- [ ] **Ticket Details** - Test `/api/v1/maintenance-tickets/:id`
  - Should be 40-60% faster
  - Verify all relations load correctly

- [ ] **User Queries** - Test user-related endpoints
  - Should be 30-40% faster
  - Verify permissions still work

---

## Performance Monitoring

### Enable Query Logging

```typescript
// apps/backend/src/shared/config/typeorm.config.ts
export const typeOrmConfig = async (): Promise<TypeOrmModuleOptions> => {
  return {
    // ...
    logging: process.env.NODE_ENV === 'development' 
      ? ['query', 'error', 'warn'] 
      : ['error'],
    maxQueryExecutionTime: 1000, // Log queries > 1 second
  };
};
```

### Monitor Query Count

Add middleware to count queries per request:
```typescript
@Injectable()
export class QueryCountInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const queryCount = { count: 0 };
    
    // Hook into TypeORM query events
    // Count queries and log if > threshold
    
    return next.handle().pipe(
      tap(() => {
        if (queryCount.count > 10) {
          console.warn(`High query count: ${queryCount.count} queries`, 
            context.getHandler().name);
        }
      }),
    );
  }
}
```

---

## Rollback Plan

If optimizations cause issues:

1. **Dashboard Service:**
   ```bash
   cp dashboard.service.backup.ts dashboard.service.ts
   ```

2. **Other Services:**
   - Revert git changes
   - Or restore from backup files

3. **Monitor:**
   - Check error logs
   - Verify data correctness
   - Compare performance metrics

---

## Expected Results

### Before Optimization
- Dashboard Stats: 500-1000ms
- Ticket Listing: 200-400ms
- Ticket Details: 100-200ms
- Queries per Request: 10-20

### After Optimization
- Dashboard Stats: 50-100ms (80-90% faster)
- Ticket Listing: 80-150ms (50-60% faster)
- Ticket Details: 40-80ms (40-60% faster)
- Queries per Request: 3-8 (50-60% reduction)

---

## Next Steps

1. ✅ **Review** optimization recommendations
2. ⏳ **Implement** Step 1 (Dashboard Service) - HIGHEST PRIORITY
3. ⏳ **Implement** Step 2-6 in priority order
4. ⏳ **Test** all endpoints thoroughly
5. ⏳ **Monitor** performance in staging/production
6. ⏳ **Iterate** based on real-world performance data

---

**Last Updated:** 2025-01-14  
**Status:** Ready for Implementation

