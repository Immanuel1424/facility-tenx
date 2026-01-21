#!/bin/bash
# Script to run database migrations
# Usage: ./scripts/run-migration.sh <migration-file.sql>

if [ -z "$1" ]; then
    echo "Usage: ./scripts/run-migration.sh <migration-file.sql>"
    echo "Example: ./scripts/run-migration.sh migrations/add-department-id-to-users.sql"
    exit 1
fi

MIGRATION_FILE=$1

# Load environment variables from .env if it exists
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Default values if not in .env
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-postgres}
DB_NAME=${DB_NAME:-facility_erp}
DB_PASSWORD=${DB_PASSWORD:-postgres}

echo "Running migration: $MIGRATION_FILE"
echo "Database: $DB_NAME on $DB_HOST:$DB_PORT"

# Run migration using psql
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f $MIGRATION_FILE

if [ $? -eq 0 ]; then
    echo "✅ Migration completed successfully"
else
    echo "❌ Migration failed"
    exit 1
fi

