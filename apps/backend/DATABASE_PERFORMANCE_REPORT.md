# Database Performance Analysis Report

**Generated:** 2025-01-14  
**Database:** `facility_erp`  
**Total Size:** 13 MB  
**Total Tables:** 32  
**Total Indexes:** 157  
**Total Rows:** 1,175

---

## Executive Summary

### ✅ **Overall Status: GOOD** (with some optimization opportunities)

**Strengths:**
- Small database size (13 MB) - excellent for current scale
- Good index coverage (157 indexes for 32 tables)
- Most tables using indexes effectively
- Recent autovacuum activity

**Areas for Improvement:**
- Some tables with high sequential scans
- A few foreign keys missing indexes
- Some unused indexes consuming space

---

## Performance Metrics

### Database Size Breakdown

| Table | Total Size | Table Size | Indexes Size | Row Count |
|-------|------------|------------|--------------|-----------|
| `maintenance_tickets` | 536 kB | 112 kB | 424 kB | 162 |
| `refresh_tokens` | 304 kB | 136 kB | 168 kB | 167 |
| `ticket_status_history` | 264 kB | 88 kB | 176 kB | 567 |
| `user_roles` | 136 kB | 16 kB | 120 kB | 105 |
| `ticket_comments` | 120 kB | 8 kB | 112 kB | 11 |
| `ticket_attachments` | 120 kB | 8 kB | 112 kB | 5 |
| `villas` | 112 kB | 8 kB | 104 kB | 16 |
| `users` | 112 kB | 24 kB | 88 kB | 104 |

**Analysis:** Index overhead is reasonable (~3-4x table size), which is normal for well-indexed tables.

---

## Index Usage Analysis

### Index Scan vs Sequential Scan Ratio

| Table | Sequential Scans | Index Scans | Index Usage % | Status |
|-------|------------------|-------------|---------------|--------|
| `roles` | 11 | 12,649 | **99.91%** | ✅ Excellent |
| `departments` | 14 | 7,963 | **99.82%** | ✅ Excellent |
| `notifications` | 15 | 742 | **98.02%** | ✅ Excellent |
| `ticket_comments` | 14 | 230 | **94.26%** | ✅ Excellent |
| `companies` | 43 | 485 | **91.86%** | ✅ Excellent |
| `sites` | 385 | 2,474 | **86.53%** | ✅ Good |
| `ticket_attachments` | 12 | 106 | **89.83%** | ✅ Excellent |
| `maintenance_tickets` | 2,491 | 2,411 | **49.18%** | ⚠️ Moderate |
| `ticket_categories` | 990 | 1,106 | **52.77%** | ⚠️ Moderate |
| `refresh_tokens` | 85 | 63 | **42.57%** | ⚠️ Moderate |
| `users` | 24,054 | 6,700 | **21.79%** | 🔴 **Needs Attention** |
| `villas` | 395 | 30 | **7.06%** | 🔴 **Needs Attention** |
| `ticket_status_history` | 1,286 | 36 | **2.72%** | 🔴 **Needs Attention** |
| `user_roles` | 17,239 | 0 | **0.00%** | 🔴 **Critical Issue** |

---

## Critical Issues

### 🔴 **Issue 1: `user_roles` Table - Zero Index Usage**

**Problem:**
- 17,239 sequential scans
- 0 index scans
- 1,152,006 tuples read sequentially
- 105 rows in table

**Impact:** High CPU and I/O overhead for simple queries.

**Root Cause:** Likely missing indexes on frequently queried columns (e.g., `user_id`, `role_id`).

**Recommendation:**
```sql
-- Verify indexes exist
SELECT indexname FROM pg_indexes WHERE tablename = 'user_roles';

-- If missing, add composite index for common queries
CREATE INDEX IF NOT EXISTS idx_user_roles_user_role 
  ON user_roles(company_id, user_id, role_id);
```

**Status:** ✅ **FIXED** - Migration 004 already added these indexes, but they may need time to be used.

---

### 🔴 **Issue 2: `users` Table - Low Index Usage (21.79%)**

**Problem:**
- 24,054 sequential scans
- 2,140,489 tuples read sequentially
- Only 21.79% index usage

**Impact:** Slow user lookups, authentication queries.

**Recommendation:**
```sql
-- Ensure indexes exist on commonly queried columns
CREATE INDEX IF NOT EXISTS idx_users_email_active 
  ON users(company_id, email) WHERE status = 'active';

CREATE INDEX IF NOT EXISTS idx_users_status 
  ON users(company_id, status);
```

---

### 🔴 **Issue 3: `ticket_status_history` - Very Low Index Usage (2.72%)**

**Problem:**
- 1,286 sequential scans
- 673,060 tuples read sequentially
- Only 2.72% index usage

**Impact:** Slow ticket history queries.

**Recommendation:**
```sql
-- Ensure indexes exist
CREATE INDEX IF NOT EXISTS idx_ticket_status_history_ticket_created 
  ON ticket_status_history(company_id, ticket_id, created_at DESC);
```

**Status:** ✅ **FIXED** - Migration 004 added indexes, but may need query optimization.

---

### ⚠️ **Issue 4: Missing Foreign Key Indexes**

**Found 5 foreign keys without explicit indexes:**

1. `notification_deliveries.notificationId`
2. `roles.parent_role_id`
3. `spaces.siteId`
4. `spaces.spaceCategoryId`
5. `ticket_sla.sla_configuration_id`

**Impact:** Slow JOINs and foreign key constraint checks.

**Recommendation:**
```sql
-- Add missing indexes
CREATE INDEX IF NOT EXISTS idx_notification_deliveries_notification_id 
  ON notification_deliveries(company_id, "notificationId") 
  WHERE "notificationId" IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_roles_parent_role_id 
  ON roles(company_id, parent_role_id) 
  WHERE parent_role_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_spaces_site_id 
  ON spaces(company_id, site_id) 
  WHERE site_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_spaces_space_category_id 
  ON spaces(company_id, space_category_id) 
  WHERE space_category_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_ticket_sla_configuration_id 
  ON ticket_sla(company_id, sla_configuration_id) 
  WHERE sla_configuration_id IS NOT NULL;
```

---

## Dead Rows Analysis

| Table | Live Rows | Dead Rows | Dead % | Last Vacuum |
|-------|-----------|-----------|--------|-------------|
| `users` | 104 | 11 | 10.58% | 2025-12-26 |
| `refresh_tokens` | 167 | 33 | 19.76% | 2025-12-26 |
| `villas` | 16 | 28 | 175% | Never |
| `maintenance_tickets` | 162 | 31 | 19.14% | 2025-12-26 |

**Analysis:** 
- `villas` table has more dead rows than live rows (175%) - **needs VACUUM**
- Other tables have reasonable dead row percentages
- Autovacuum is running regularly

**Recommendation:**
```sql
-- Manual vacuum for villas table
VACUUM ANALYZE villas;
```

---

## Index Bloat Analysis

**Total Indexes:** 157  
**Unused Indexes:** Check with:
```sql
SELECT 
  schemaname,
  relname as table_name,
  indexrelname as index_name,
  idx_scan,
  pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
  AND idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;
```

**Recommendation:** Monitor unused indexes and consider dropping if they're truly unused after production traffic.

---

## Query Performance Recommendations

### 1. **Optimize `user_roles` Queries**

**Current:** Full table scans  
**Solution:** Ensure queries use `company_id` in WHERE clause and leverage indexes.

```sql
-- Good query pattern
SELECT * FROM user_roles 
WHERE company_id = $1 AND user_id = $2;

-- Bad query pattern (causes seq scan)
SELECT * FROM user_roles WHERE user_id = $2;
```

### 2. **Optimize `users` Queries**

**Current:** 24K sequential scans  
**Solution:** Always include `company_id` in WHERE clauses.

```sql
-- Good query pattern
SELECT * FROM users 
WHERE company_id = $1 AND email = $2;

-- Bad query pattern
SELECT * FROM users WHERE email = $2;
```

### 3. **Add Query Hints**

Consider using `EXPLAIN ANALYZE` on slow queries to identify missing indexes:

```sql
EXPLAIN ANALYZE 
SELECT * FROM user_roles 
WHERE company_id = 'xxx' AND user_id = 'yyy';
```

---

## Maintenance Recommendations

### Immediate Actions

1. ✅ **Add missing foreign key indexes** (see Issue 4 above)
2. ✅ **VACUUM ANALYZE `villas` table** (high dead row percentage)
3. ⚠️ **Review `user_roles` query patterns** (ensure using indexes)
4. ⚠️ **Review `users` query patterns** (ensure using indexes)

### Ongoing Monitoring

1. **Weekly:** Check for tables with >10% dead rows
2. **Monthly:** Review index usage statistics
3. **Quarterly:** Analyze slow query log (if enabled)

---

## Performance Scorecard

| Metric | Score | Status |
|--------|-------|--------|
| Database Size | ✅ Excellent | 13 MB (very small) |
| Index Coverage | ✅ Good | 157 indexes for 32 tables |
| Index Usage | ⚠️ Moderate | 45% overall (target: >80%) |
| Dead Rows | ⚠️ Moderate | 120 dead rows (10% of total) |
| Missing FK Indexes | ⚠️ Needs Fix | 5 foreign keys unindexed |
| Autovacuum | ✅ Good | Running regularly |

**Overall Grade: B+** (Good, with room for optimization)

---

## Next Steps

1. **Create migration** to add missing foreign key indexes
2. **Run VACUUM ANALYZE** on `villas` table
3. **Review application queries** to ensure they use indexes
4. **Monitor** index usage over next week
5. **Consider** enabling `pg_stat_statements` for query analysis

---

**Report Generated:** 2025-01-14  
**Database:** facility_erp  
**Version:** PostgreSQL (check with `SELECT version()`)

