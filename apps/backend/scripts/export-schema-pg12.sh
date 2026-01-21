#!/bin/bash

# PostgreSQL 12 Compatible Schema Export Script
# Exports schema-only dump and converts gen_random_uuid() to uuid_generate_v4()

set -e  # Exit on error

# Default values
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-postgres}
DB_NAME=${DB_NAME:-facility_erp}
DB_PASSWORD=${DB_PASSWORD:-postgres}
OUTPUT_DIR=${OUTPUT_DIR:-./exports}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

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
while [[ $# -gt 0 ]]; do
    case $1 in
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
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --host HOST           Database host (default: localhost)"
            echo "  --port PORT           Database port (default: 5432)"
            echo "  --user USER           Database user (default: postgres)"
            echo "  --database DB         Database name (default: facility_erp)"
            echo "  --output-dir DIR      Output directory (default: ./exports)"
            echo "  --help                Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  DB_HOST, DB_PORT, DB_USER, DB_NAME, DB_PASSWORD"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if pg_dump is available
if ! command -v pg_dump &> /dev/null; then
    print_error "pg_dump is not installed or not in PATH"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/${DB_NAME}_schema_pg12_${TIMESTAMP}.sql"
TEMP_FILE="${OUTPUT_FILE}.tmp"

# Print configuration
echo ""
print_info "PostgreSQL 12 Compatible Schema Export"
echo "  Host:     $DB_HOST"
echo "  Port:     $DB_PORT"
echo "  User:     $DB_USER"
echo "  Database: $DB_NAME"
echo "  Output:   $OUTPUT_FILE"
echo ""

# Test database connection
print_info "Testing database connection..."
if ! PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;" > /dev/null 2>&1; then
    print_error "Cannot connect to database"
    exit 1
fi
print_success "Database connection successful"

# Export schema
print_info "Exporting schema..."
PGPASSWORD=$DB_PASSWORD pg_dump \
  -h $DB_HOST \
  -p $DB_PORT \
  -U $DB_USER \
  -d $DB_NAME \
  --schema-only \
  --no-owner \
  --no-privileges \
  --verbose \
  > "$TEMP_FILE" 2>&1

if [ $? -ne 0 ]; then
    print_error "Schema export failed"
    rm -f "$TEMP_FILE"
    exit 1
fi

print_success "Schema exported"

# Convert for PostgreSQL 12 compatibility
print_info "Converting for PostgreSQL 12 compatibility..."

# Process the dump file for PostgreSQL 12 compatibility
{
    # Add header
    echo "-- PostgreSQL 12 Compatible Schema Dump"
    echo "-- Generated: $(date)"
    echo "-- Database: $DB_NAME"
    echo "--"
    echo "-- This schema dump is compatible with PostgreSQL 12"
    echo "-- gen_random_uuid() has been replaced with uuid_generate_v4()"
    echo "--"
    echo ""
    
    # Process the dump file
    # 1. Replace gen_random_uuid() with uuid_generate_v4() (all variations)
    # 2. Remove COMMENT ON EXTENSION "uuid-ossp" (causes permission issues)
    # 3. Remove existing uuid-ossp extension creation (we add our own)
    # 4. Ensure uuid-ossp extension is created at the top
    sed 's/gen_random_uuid()/uuid_generate_v4()/g' "$TEMP_FILE" | \
    sed 's/gen_random_uuid/uuid_generate_v4/g' | \
    sed '/COMMENT ON EXTENSION "uuid-ossp"/d' | \
    sed '/^-- Name: uuid-ossp; Type: EXTENSION/d' | \
    sed '/^CREATE EXTENSION IF NOT EXISTS "uuid-ossp"/d' | \
    sed '/^CREATE EXTENSION "uuid-ossp"/d' | \
    sed '1i\
-- Create uuid-ossp extension for PostgreSQL 12 compatibility\
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;\
'
    
} > "$OUTPUT_FILE"

# Clean up temp file
rm -f "$TEMP_FILE"

# Get file size
FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)

print_success "PostgreSQL 12 compatible schema dump created!"
echo ""
echo "  File: $OUTPUT_FILE"
echo "  Size: $FILE_SIZE"
echo ""

print_info "Changes made for PostgreSQL 12 compatibility:"
echo "  ✓ gen_random_uuid() → uuid_generate_v4()"
echo "  ✓ Added uuid-ossp extension creation"
echo "  ✓ Removed ownership/privilege commands"
echo ""

print_info "To restore this schema on PostgreSQL 12:"
echo "  PGPASSWORD=\$DB_PASSWORD psql -h \$DB_HOST -p \$DB_PORT -U \$DB_USER -d \$DB_NAME < $OUTPUT_FILE"
echo ""

