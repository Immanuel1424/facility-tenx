#!/bin/bash

# PostgreSQL Database Restore Script
# Restores a database from a SQL dump file

set -e  # Exit on error

# Default values
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-postgres}
DB_NAME=${DB_NAME:-facility_erp}
DB_PASSWORD=${DB_PASSWORD:-postgres}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# Parse command line arguments
DUMP_FILE=""
DROP_EXISTING=false
CREATE_DB=false
NO_OWNER=false
NO_PRIVILEGES=false
CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --file)
            DUMP_FILE="$2"
            shift 2
            ;;
        --host)
            DB_HOST="$2"
            shift 2
            ;;
        --port)
            DB_PORT="$2"
            shift 2
            ;;
        --user)
            DB_USER="$2"
            shift 2
            ;;
        --database)
            DB_NAME="$2"
            shift 2
            ;;
        --drop-existing)
            DROP_EXISTING=true
            shift
            ;;
        --create-db)
            CREATE_DB=true
            shift
            ;;
        --no-owner)
            NO_OWNER=true
            shift
            ;;
        --no-privileges)
            NO_PRIVILEGES=true
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --help)
            echo "Usage: $0 --file DUMP_FILE [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --file FILE          SQL dump file to restore (required)"
            echo "  --host HOST          Database host (default: localhost)"
            echo "  --port PORT          Database port (default: 5432)"
            echo "  --user USER          Database user (default: postgres)"
            echo "  --database DB        Database name (default: facility_erp)"
            echo "  --drop-existing      Drop existing database before restore"
            echo "  --create-db          Create database if it doesn't exist"
            echo "  --no-owner           Skip restoration of object ownership"
            echo "  --no-privileges      Skip restoration of access privileges"
            echo "  --clean              Clean (drop) database objects before restore"
            echo "  --help               Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  DB_HOST, DB_PORT, DB_USER, DB_NAME, DB_PASSWORD"
            echo ""
            echo "Examples:"
            echo "  $0 --file exports/facility_erp_20251231_145641.sql"
            echo "  $0 --file exports/facility_erp_20251231_145641.sql --drop-existing"
            echo "  $0 --file exports/facility_erp_20251231_145641.dump --clean --no-owner"
            echo "  $0 --file exports/facility_erp_20251231_145641.sql.gz --create-db"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate dump file
if [ -z "$DUMP_FILE" ]; then
    print_error "Dump file is required. Use --file option."
    echo "Use --help for usage information"
    exit 1
fi

if [ ! -f "$DUMP_FILE" ]; then
    print_error "Dump file not found: $DUMP_FILE"
    exit 1
fi

# Check if file is compressed
IS_COMPRESSED=false
if [[ "$DUMP_FILE" == *.gz ]]; then
    IS_COMPRESSED=true
    print_info "Detected compressed file (gzip)"
fi

# Print configuration
echo ""
print_info "Database Restore Configuration:"
echo "  Host:     $DB_HOST"
echo "  Port:     $DB_PORT"
echo "  User:     $DB_USER"
echo "  Database: $DB_NAME"
echo "  File:     $DUMP_FILE"
echo ""

# Test database connection
print_info "Testing database connection..."
if ! PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "SELECT 1;" > /dev/null 2>&1; then
    print_error "Cannot connect to database server"
    print_info "Check your connection settings"
    exit 1
fi
print_success "Database connection successful"

# Check if database exists
DB_EXISTS=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" 2>/dev/null || echo "")

if [ -z "$DB_EXISTS" ]; then
    if [ "$CREATE_DB" = true ]; then
        print_info "Creating database: $DB_NAME"
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME;" > /dev/null
        
        # Create extension for gen_random_uuid() if needed (PostgreSQL < 13)
        print_info "Setting up database extensions..."
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";" > /dev/null 2>&1 || true
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";" > /dev/null 2>&1 || true
        
        print_success "Database created"
    else
        print_error "Database '$DB_NAME' does not exist"
        print_info "Use --create-db to create it automatically"
        exit 1
    fi
else
    if [ "$DROP_EXISTING" = true ]; then
        print_warning "Dropping existing database: $DB_NAME"
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;" > /dev/null
        print_info "Creating fresh database: $DB_NAME"
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME;" > /dev/null
        
        # Create extension for gen_random_uuid() if needed (PostgreSQL < 13)
        print_info "Setting up database extensions..."
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";" > /dev/null 2>&1 || true
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";" > /dev/null 2>&1 || true
        
        print_success "Database recreated"
    else
        print_warning "Database '$DB_NAME' already exists"
        print_info "Existing data will be overwritten. Use --drop-existing to drop first."
        
        # Ensure extensions exist
        print_info "Ensuring database extensions are available..."
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";" > /dev/null 2>&1 || true
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";" > /dev/null 2>&1 || true
    fi
fi

# Check if file is a custom format dump
IS_CUSTOM_DUMP=false
if [[ "$DUMP_FILE" == *.dump ]]; then
    IS_CUSTOM_DUMP=true
    print_info "Detected custom format dump file"
fi

# For custom format, use pg_restore; for SQL, use psql
if [ "$IS_CUSTOM_DUMP" = true ]; then
    # Build pg_restore command
    RESTORE_CMD="PGPASSWORD=$DB_PASSWORD pg_restore"
    RESTORE_CMD="$RESTORE_CMD -h $DB_HOST"
    RESTORE_CMD="$RESTORE_CMD -p $DB_PORT"
    RESTORE_CMD="$RESTORE_CMD -U $DB_USER"
    RESTORE_CMD="$RESTORE_CMD -d $DB_NAME"
    
    if [ "$CLEAN" = true ]; then
        RESTORE_CMD="$RESTORE_CMD -c"
        print_info "Will clean (drop) existing objects before restore"
    fi
    
    if [ "$NO_OWNER" = true ]; then
        RESTORE_CMD="$RESTORE_CMD --no-owner"
        print_info "Skipping object ownership restoration"
    fi
    
    if [ "$NO_PRIVILEGES" = true ]; then
        RESTORE_CMD="$RESTORE_CMD --no-privileges"
        print_info "Skipping access privileges restoration"
    fi
    
    RESTORE_CMD="$RESTORE_CMD --verbose"
    RESTORE_CMD="$RESTORE_CMD $DUMP_FILE"
    
    print_info "Starting database restore with pg_restore..."
    echo ""
    eval "$RESTORE_CMD"
else
    # For SQL files, use psql
    print_info "Starting database restore with psql..."
    echo ""
    
    if [ "$IS_COMPRESSED" = true ]; then
        # Restore from compressed file
        print_info "Decompressing and restoring..."
        gunzip -c "$DUMP_FILE" | PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME
    else
        # Restore from plain SQL file
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME < "$DUMP_FILE"
    fi
fi

if [ $? -eq 0 ]; then
    print_success "Database restore completed successfully!"
    echo ""
    print_info "Database '$DB_NAME' has been restored from: $DUMP_FILE"
    echo ""
else
    print_error "Database restore failed"
    exit 1
fi

