#!/bin/bash

# PostgreSQL Database Backup Script
# Backs up the facility_erp database with all data

set -e

# Configuration (can be overridden by environment variables)
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-postgres}
DB_PASSWORD=${DB_PASSWORD:-postgres}
DB_NAME=${DB_NAME:-facility_erp}

# Create backups directory if it doesn't exist
BACKUP_DIR="$(dirname "$0")/../backups"
mkdir -p "$BACKUP_DIR"

# Generate backup filename with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/facility_erp_backup_${TIMESTAMP}.sql"

echo "Starting database backup..."
echo "Database: $DB_NAME"
echo "Host: $DB_HOST:$DB_PORT"

# Check if database is running in Docker container
if docker ps --filter "name=facility-erp-postgres" --format "{{.Names}}" | grep -q "facility-erp-postgres"; then
    echo "Backing up from Docker container: facility-erp-postgres"
    docker exec facility-erp-postgres pg_dump -U postgres "$DB_NAME" > "$BACKUP_FILE"
else
    echo "Backing up from local PostgreSQL instance..."
    export PGPASSWORD="$DB_PASSWORD"
    pg_dump \
        -h "$DB_HOST" \
        -p "$DB_PORT" \
        -U "$DB_USER" \
        -d "$DB_NAME" \
        -F p \
        --verbose \
        > "$BACKUP_FILE"
    unset PGPASSWORD
fi

# Verify backup file was created and has content
if [ -f "$BACKUP_FILE" ] && [ -s "$BACKUP_FILE" ]; then
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "✓ Backup completed successfully!"
    echo "  File: $BACKUP_FILE"
    echo "  Size: $FILE_SIZE"
    
    # Optionally compress the backup
    if command -v gzip &> /dev/null; then
        echo "Compressing backup..."
        gzip "$BACKUP_FILE"
        COMPRESSED_FILE="${BACKUP_FILE}.gz"
        COMPRESSED_SIZE=$(du -h "$COMPRESSED_FILE" | cut -f1)
        echo "  Compressed: $COMPRESSED_FILE"
        echo "  Compressed Size: $COMPRESSED_SIZE"
    fi
else
    echo "✗ Backup failed! File is missing or empty."
    exit 1
fi
