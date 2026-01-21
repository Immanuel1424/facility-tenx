#!/bin/bash

# PostgreSQL Database Export Script
# Exports the database using pg_dump with various format options

set -e  # Exit on error

# Default values
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-postgres}
DB_NAME=${DB_NAME:-facility_erp}
DB_PASSWORD=${DB_PASSWORD:-postgres}

# Export options
EXPORT_FORMAT=${EXPORT_FORMAT:-plain}  # plain, custom, directory, tar
SCHEMA_ONLY=${SCHEMA_ONLY:-false}       # true/false
DATA_ONLY=${DATA_ONLY:-false}           # true/false
COMPRESS=${COMPRESS:-false}              # true/false
NO_OWNER=${NO_OWNER:-true}               # true/false - don't output ownership commands
NO_PRIVILEGES=${NO_PRIVILEGES:-true}     # true/false - don't output privilege commands
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
        --format)
            EXPORT_FORMAT="$2"
            shift 2
            ;;
        --schema-only)
            SCHEMA_ONLY=true
            shift
            ;;
        --data-only)
            DATA_ONLY=true
            shift
            ;;
        --compress)
            COMPRESS=true
            shift
            ;;
        --with-owner)
            NO_OWNER=false
            shift
            ;;
        --with-privileges)
            NO_PRIVILEGES=false
            shift
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
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
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --format FORMAT       Export format: plain, custom, directory, tar (default: plain)"
            echo "  --schema-only         Export schema only (no data)"
            echo "  --data-only           Export data only (no schema)"
            echo "  --compress            Compress the output (gzip)"
            echo "  --with-owner          Include ownership commands (default: excluded)"
            echo "  --with-privileges     Include privilege commands (default: excluded)"
            echo "  --output-dir DIR      Output directory (default: ./exports)"
            echo "  --host HOST           Database host (default: localhost)"
            echo "  --port PORT           Database port (default: 5432)"
            echo "  --user USER           Database user (default: postgres)"
            echo "  --database DB         Database name (default: facility_erp)"
            echo "  --help                Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  DB_HOST, DB_PORT, DB_USER, DB_NAME, DB_PASSWORD"
            echo ""
            echo "Examples:"
            echo "  $0 --format custom --compress"
            echo "  $0 --schema-only --output-dir ./backups"
            echo "  $0 --data-only --format plain"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate format
if [[ ! "$EXPORT_FORMAT" =~ ^(plain|custom|directory|tar)$ ]]; then
    print_error "Invalid format: $EXPORT_FORMAT. Must be: plain, custom, directory, or tar"
    exit 1
fi

# Check if pg_dump is available
if ! command -v pg_dump &> /dev/null; then
    print_error "pg_dump is not installed or not in PATH"
    print_info "Install PostgreSQL client tools to use this script"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Build pg_dump command
DUMP_CMD="PGPASSWORD=$DB_PASSWORD pg_dump"
DUMP_CMD="$DUMP_CMD -h $DB_HOST"
DUMP_CMD="$DUMP_CMD -p $DB_PORT"
DUMP_CMD="$DUMP_CMD -U $DB_USER"
DUMP_CMD="$DUMP_CMD -d $DB_NAME"

# Add format-specific options
case $EXPORT_FORMAT in
    plain)
        OUTPUT_FILE="$OUTPUT_DIR/${DB_NAME}_${TIMESTAMP}.sql"
        DUMP_CMD="$DUMP_CMD --format=plain"
        ;;
    custom)
        OUTPUT_FILE="$OUTPUT_DIR/${DB_NAME}_${TIMESTAMP}.dump"
        DUMP_CMD="$DUMP_CMD --format=custom"
        DUMP_CMD="$DUMP_CMD --compress=9"
        DUMP_CMD="$DUMP_CMD --file=$OUTPUT_FILE"
        ;;
    directory)
        OUTPUT_DIR_SPECIFIC="$OUTPUT_DIR/${DB_NAME}_${TIMESTAMP}"
        mkdir -p "$OUTPUT_DIR_SPECIFIC"
        OUTPUT_FILE="$OUTPUT_DIR_SPECIFIC"
        DUMP_CMD="$DUMP_CMD --format=directory"
        DUMP_CMD="$DUMP_CMD --file=$OUTPUT_FILE"
        ;;
    tar)
        OUTPUT_FILE="$OUTPUT_DIR/${DB_NAME}_${TIMESTAMP}.tar"
        DUMP_CMD="$DUMP_CMD --format=tar"
        DUMP_CMD="$DUMP_CMD --file=$OUTPUT_FILE"
        ;;
esac

# Add schema/data options
if [ "$SCHEMA_ONLY" = true ]; then
    DUMP_CMD="$DUMP_CMD --schema-only"
    print_info "Exporting schema only (no data)"
elif [ "$DATA_ONLY" = true ]; then
    DUMP_CMD="$DUMP_CMD --data-only"
    print_info "Exporting data only (no schema)"
fi

# Add ownership/privilege options (default: exclude for portability)
if [ "$NO_OWNER" = true ]; then
    DUMP_CMD="$DUMP_CMD --no-owner"
    print_info "Excluding ownership commands (portable dump)"
fi

if [ "$NO_PRIVILEGES" = true ]; then
    DUMP_CMD="$DUMP_CMD --no-privileges"
    print_info "Excluding privilege commands (portable dump)"
fi

# Add verbose output
DUMP_CMD="$DUMP_CMD --verbose"

# For plain format, redirect to file
if [ "$EXPORT_FORMAT" = "plain" ]; then
    DUMP_CMD="$DUMP_CMD > $OUTPUT_FILE"
fi

# Print configuration
echo ""
print_info "Database Export Configuration:"
echo "  Host:     $DB_HOST"
echo "  Port:     $DB_PORT"
echo "  User:     $DB_USER"
echo "  Database: $DB_NAME"
echo "  Format:   $EXPORT_FORMAT"
echo "  Output:   $OUTPUT_FILE"
echo ""

# Test database connection
print_info "Testing database connection..."
if ! PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;" > /dev/null 2>&1; then
    print_error "Cannot connect to database"
    print_info "Check your connection settings and ensure the database exists"
    exit 1
fi
print_success "Database connection successful"

# Perform the export
print_info "Starting database export..."
echo ""

if [ "$EXPORT_FORMAT" = "plain" ]; then
    # For plain format, we need to execute the command differently
    eval "$DUMP_CMD"
else
    # For other formats, pg_dump handles the file output
    eval "$DUMP_CMD"
fi

# Compress plain SQL if requested
if [ "$EXPORT_FORMAT" = "plain" ] && [ "$COMPRESS" = true ]; then
    print_info "Compressing output..."
    gzip "$OUTPUT_FILE"
    OUTPUT_FILE="${OUTPUT_FILE}.gz"
    print_success "Compressed to: $OUTPUT_FILE"
fi

# Get file size
if [ -f "$OUTPUT_FILE" ] || [ -d "$OUTPUT_FILE" ]; then
    if [ -f "$OUTPUT_FILE" ]; then
        FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    else
        FILE_SIZE=$(du -sh "$OUTPUT_FILE" | cut -f1)
    fi
    print_success "Export completed successfully!"
    echo ""
    echo "  File: $OUTPUT_FILE"
    echo "  Size: $FILE_SIZE"
    echo ""
    
    # Show restore instructions
    print_info "To restore this backup:"
    case $EXPORT_FORMAT in
        plain)
            if [ "$COMPRESS" = true ]; then
                echo "  gunzip < $OUTPUT_FILE | PGPASSWORD=\$DB_PASSWORD psql -h \$DB_HOST -p \$DB_PORT -U \$DB_USER -d \$DB_NAME"
            else
                echo "  PGPASSWORD=\$DB_PASSWORD psql -h \$DB_HOST -p \$DB_PORT -U \$DB_USER -d \$DB_NAME < $OUTPUT_FILE"
            fi
            ;;
        custom)
            echo "  PGPASSWORD=\$DB_PASSWORD pg_restore -h \$DB_HOST -p \$DB_PORT -U \$DB_USER -d \$DB_NAME -c $OUTPUT_FILE"
            ;;
        directory)
            echo "  PGPASSWORD=\$DB_PASSWORD pg_restore -h \$DB_HOST -p \$DB_PORT -U \$DB_USER -d \$DB_NAME -c -d $OUTPUT_FILE"
            ;;
        tar)
            echo "  PGPASSWORD=\$DB_PASSWORD pg_restore -h \$DB_HOST -p \$DB_PORT -U \$DB_USER -d \$DB_NAME -c $OUTPUT_FILE"
            ;;
    esac
    echo ""
else
    print_error "Export file not found. Export may have failed."
    exit 1
fi

