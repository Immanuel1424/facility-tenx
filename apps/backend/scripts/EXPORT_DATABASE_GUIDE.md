# Database Export Script Guide

This guide explains how to export your PostgreSQL database using the provided scripts.

## Quick Start

```bash
cd apps/backend
npm run export:db
```

This creates a plain SQL dump in `./exports/` directory.

## Scripts Available

### 1. TypeScript Script (Recommended)

```bash
npm run export:db [OPTIONS]
```

This is a TypeScript wrapper that calls the shell script. Use this for consistency with other npm scripts.

### 2. Shell Script (Direct)

```bash
./scripts/export-database.sh [OPTIONS]
```

Use this for direct execution or in CI/CD pipelines.

## Export Formats

### Plain SQL (Default)

Human-readable SQL file. Best for:
- Version control
- Manual inspection
- Small to medium databases

```bash
npm run export:db -- --format plain
```

**Output**: `facility_erp_YYYYMMDD_HHMMSS.sql`

### Custom Format

PostgreSQL custom format. Best for:
- Large databases
- Selective restore
- Compression built-in

```bash
npm run export:db -- --format custom
```

**Output**: `facility_erp_YYYYMMDD_HHMMSS.dump`

**Restore**:
```bash
pg_restore -h localhost -p 5432 -U postgres -d facility_erp -c facility_erp_YYYYMMDD_HHMMSS.dump
```

### Directory Format

Directory with multiple files. Best for:
- Very large databases
- Parallel restore
- Selective table restore

```bash
npm run export:db -- --format directory
```

**Output**: `facility_erp_YYYYMMDD_HHMMSS/` (directory)

**Restore**:
```bash
pg_restore -h localhost -p 5432 -U postgres -d facility_erp -c -d facility_erp_YYYYMMDD_HHMMSS/
```

### Tar Format

Tarball archive. Best for:
- Backup storage
- Transfer between systems

```bash
npm run export:db -- --format tar
```

**Output**: `facility_erp_YYYYMMDD_HHMMSS.tar`

**Restore**:
```bash
pg_restore -h localhost -p 5432 -U postgres -d facility_erp -c facility_erp_YYYYMMDD_HHMMSS.tar
```

## Export Options

### Schema Only

Export only the database structure (tables, indexes, constraints) without data:

```bash
npm run export:db -- --schema-only
```

Useful for:
- Creating empty database structure
- Version control of schema changes
- Development environment setup

### Data Only

Export only the data without schema:

```bash
npm run export:db -- --data-only
```

Useful for:
- Data migration
- Backup of data only
- Restoring data to existing schema

### Compress Output

Compress plain SQL exports (gzip):

```bash
npm run export:db -- --format plain --compress
```

**Output**: `facility_erp_YYYYMMDD_HHMMSS.sql.gz`

**Note**: Custom format already includes compression.

### Portable Dumps (Default)

By default, all exports exclude ownership and privilege commands, making them portable across different users and databases:

```bash
# Default behavior - portable dump (no ownership/privileges)
npm run export:db -- --format custom
```

To include ownership and privileges (if needed):

```bash
npm run export:db -- --format custom --with-owner --with-privileges
```

**Note**: Portable dumps (default) work with any PostgreSQL user and don't require superuser privileges to restore.

### Custom Output Directory

Specify where to save the export:

```bash
npm run export:db -- --output-dir ./backups
```

## Connection Options

Override default connection settings:

```bash
npm run export:db -- \
  --host localhost \
  --port 5432 \
  --user postgres \
  --database facility_erp
```

Or use environment variables:

```bash
DB_HOST=localhost \
DB_PORT=5432 \
DB_USER=postgres \
DB_NAME=facility_erp \
DB_PASSWORD=your_password \
npm run export:db
```

## Common Use Cases

### Full Database Backup

```bash
# Plain SQL with compression
npm run export:db -- --format plain --compress

# Custom format (recommended for production)
npm run export:db -- --format custom
```

### Schema Backup (for version control)

```bash
npm run export:db -- --schema-only --output-dir ./schema-backups
```

### Data Backup Only

```bash
npm run export:db -- --data-only --format custom
```

### Production Backup Script

Create a cron job or scheduled task:

```bash
#!/bin/bash
cd /path/to/apps/backend
npm run export:db -- --format custom --output-dir /backups/database
```

### Development Database Snapshot

```bash
npm run export:db -- --format plain --output-dir ./snapshots
```

## Restore Examples

### Restore Plain SQL

```bash
# Uncompressed
PGPASSWORD=postgres psql \
  -h localhost \
  -p 5432 \
  -U postgres \
  -d facility_erp \
  < exports/facility_erp_20250114_120000.sql

# Compressed
gunzip < exports/facility_erp_20250114_120000.sql.gz | \
  PGPASSWORD=postgres psql \
    -h localhost \
    -p 5432 \
    -U postgres \
    -d facility_erp
```

### Restore Custom Format

```bash
PGPASSWORD=postgres pg_restore \
  -h localhost \
  -p 5432 \
  -U postgres \
  -d facility_erp \
  -c \
  exports/facility_erp_20250114_120000.dump
```

### Restore Directory Format

```bash
PGPASSWORD=postgres pg_restore \
  -h localhost \
  -p 5432 \
  -U postgres \
  -d facility_erp \
  -c \
  -d exports/facility_erp_20250114_120000/
```

### Restore Tar Format

```bash
PGPASSWORD=postgres pg_restore \
  -h localhost \
  -p 5432 \
  -U postgres \
  -d facility_erp \
  -c \
  exports/facility_erp_20250114_120000.tar
```

## Best Practices

### 1. Regular Backups

Set up automated backups:

```bash
# Daily full backup
0 2 * * * cd /path/to/apps/backend && npm run export:db -- --format custom --output-dir /backups/daily

# Weekly schema backup
0 3 * * 0 cd /path/to/apps/backend && npm run export:db -- --schema-only --output-dir /backups/schema
```

### 2. Backup Retention

Implement a retention policy:

```bash
# Keep last 7 days of backups
find ./exports -name "*.dump" -mtime +7 -delete
```

### 3. Secure Storage

- Store backups in secure, encrypted storage
- Use different credentials for backup user (read-only)
- Test restore procedures regularly

### 4. Before Major Changes

Always backup before:
- Running migrations
- Major data updates
- Schema changes
- System upgrades

### 5. Compression

For large databases:
- Use `custom` format (built-in compression)
- Or use `plain` format with `--compress` flag

## Troubleshooting

### Error: pg_dump not found

Install PostgreSQL client tools:

```bash
# macOS
brew install postgresql

# Ubuntu/Debian
sudo apt-get install postgresql-client

# CentOS/RHEL
sudo yum install postgresql
```

### Error: Cannot connect to database

Check:
1. Database is running
2. Connection credentials are correct
3. Network/firewall allows connection
4. Database exists

Test connection:
```bash
PGPASSWORD=postgres psql -h localhost -p 5432 -U postgres -d facility_erp -c "SELECT 1;"
```

### Error: Permission denied

Ensure:
1. User has read access to database
2. Output directory is writable
3. Shell script is executable: `chmod +x scripts/export-database.sh`

### Large Database Export

For very large databases:
1. Use `custom` or `directory` format
2. Export during low-traffic periods
3. Consider using `pg_dump` with `--jobs` option (directory format only)

## Environment Variables

The script uses these environment variables (with defaults):

- `DB_HOST` (default: `localhost`)
- `DB_PORT` (default: `5432`)
- `DB_USER` (default: `postgres`)
- `DB_PASSWORD` (default: `postgres`)
- `DB_NAME` (default: `facility_erp`)

## Output Location

By default, exports are saved to:
- `./exports/` (relative to `apps/backend/`)

Files are named with timestamp:
- `{database_name}_{YYYYMMDD}_{HHMMSS}.{extension}`

Example:
- `facility_erp_20250114_143022.sql`
- `facility_erp_20250114_143022.dump`
- `facility_erp_20250114_143022/` (directory)

## Help

Get help with:

```bash
npm run export:db -- --help
# or
./scripts/export-database.sh --help
```

