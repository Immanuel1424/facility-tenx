#!/bin/bash

# Database Backup Script for Facility ERP
# Supports both local PostgreSQL and Docker PostgreSQL instances
# Usage: ./backup-db.sh [--restore <backup_file>] [--format <plain|custom>]

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default configuration (can be overridden by environment variables)
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"
DB_PASSWORD="${DB_PASSWORD:-postgres}"
DB_NAME="${DB_NAME:-facility_erp}"
DOCKER_CONTAINER="${DOCKER_CONTAINER:-facility-erp-postgres}"

# Backup configuration
BACKUP_DIR="${BACKUP_DIR:-./backups}"
BACKUP_FORMAT="${BACKUP_FORMAT:-custom}" # plain or custom
COMPRESS="${COMPRESS:-true}"
KEEP_DAYS="${KEEP_DAYS:-30}" # Keep backups for 30 days

# Parse command line arguments
RESTORE_FILE=""
FORMAT="$BACKUP_FORMAT"

while [[ $# -gt 0 ]]; do
  case $1 in
    --restore)
      RESTORE_FILE="$2"
      shift 2
      ;;
    --format)
      FORMAT="$2"
      shift 2
      ;;
    --no-compress)
      COMPRESS="false"
      shift
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --restore <file>    Restore database from backup file"
      echo "  --format <format>   Backup format: plain or custom (default: custom)"
      echo "  --no-compress       Disable compression"
      echo "  --help              Show this help message"
      echo ""
      echo "Environment Variables:"
      echo "  DB_HOST             Database host (default: localhost)"
      echo "  DB_PORT             Database port (default: 5432)"
      echo "  DB_USER             Database user (default: postgres)"
      echo "  DB_PASSWORD         Database password (default: postgres)"
      echo "  DB_NAME             Database name (default: facility_erp)"
      echo "  DOCKER_CONTAINER    Docker container name (default: facility-erp-postgres)"
      echo "  BACKUP_DIR          Backup directory (default: ./backups)"
      echo "  KEEP_DAYS           Days to keep backups (default: 30)"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Function to check if PostgreSQL is running in Docker
check_docker_postgres() {
  if docker ps --format '{{.Names}}' | grep -q "^${DOCKER_CONTAINER}$"; then
    return 0
  else
    return 1
  fi
}

# Function to check if local PostgreSQL is accessible
check_local_postgres() {
  if command -v pg_isready &> /dev/null; then
    if pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" &> /dev/null; then
      return 0
    fi
  fi
  return 1
}

# Function to execute PostgreSQL command (Docker or local)
exec_pg_command() {
  local cmd="$1"
  
  if check_docker_postgres; then
    docker exec -e PGPASSWORD="$DB_PASSWORD" "$DOCKER_CONTAINER" bash -c "$cmd"
  elif check_local_postgres; then
    export PGPASSWORD="$DB_PASSWORD"
    eval "$cmd"
  else
    echo -e "${RED}Error: PostgreSQL is not accessible${NC}"
    echo "Please ensure PostgreSQL is running (locally or in Docker)"
    exit 1
  fi
}

# Function to create backup directory
create_backup_dir() {
  if [[ ! -d "$BACKUP_DIR" ]]; then
    mkdir -p "$BACKUP_DIR"
    echo -e "${GREEN}Created backup directory: $BACKUP_DIR${NC}"
  fi
}

# Function to generate backup filename
generate_backup_filename() {
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local extension="sql"
  
  if [[ "$FORMAT" == "custom" ]]; then
    extension="dump"
  fi
  
  if [[ "$COMPRESS" == "true" && "$FORMAT" == "plain" ]]; then
    extension="sql.gz"
  elif [[ "$COMPRESS" == "true" && "$FORMAT" == "custom" ]]; then
    extension="dump"
  fi
  
  echo "${BACKUP_DIR}/${DB_NAME}_${timestamp}.${extension}"
}

# Function to create backup
create_backup() {
  local backup_file=$(generate_backup_filename)
  local temp_file="${backup_file}.tmp"
  
  echo -e "${YELLOW}Creating backup of database: ${DB_NAME}${NC}"
  echo -e "Format: ${FORMAT}"
  echo -e "Output: ${backup_file}"
  
  create_backup_dir
  
  if check_docker_postgres; then
    # Docker backup
    if [[ "$FORMAT" == "custom" ]]; then
      docker exec -e PGPASSWORD="$DB_PASSWORD" "$DOCKER_CONTAINER" \
        pg_dump -U "$DB_USER" -Fc -f "/tmp/backup.dump" "$DB_NAME" || {
        echo -e "${RED}Backup failed!${NC}"
        exit 1
      }
      docker cp "${DOCKER_CONTAINER}:/tmp/backup.dump" "$backup_file"
      docker exec "$DOCKER_CONTAINER" rm -f "/tmp/backup.dump"
      
      if [[ "$COMPRESS" == "true" ]]; then
        echo -e "${YELLOW}Compressing backup...${NC}"
        gzip -f "$backup_file"
        backup_file="${backup_file}.gz"
      fi
    else
      # Plain SQL format
      docker exec -e PGPASSWORD="$DB_PASSWORD" "$DOCKER_CONTAINER" \
        pg_dump -U "$DB_USER" -Fp "$DB_NAME" > "$temp_file" || {
        echo -e "${RED}Backup failed!${NC}"
        rm -f "$temp_file"
        exit 1
      }
      
      if [[ "$COMPRESS" == "true" ]]; then
        echo -e "${YELLOW}Compressing backup...${NC}"
        gzip -f "$temp_file"
        mv "${temp_file}.gz" "$backup_file"
      else
        mv "$temp_file" "$backup_file"
      fi
    fi
  else
    # Local backup
    export PGPASSWORD="$DB_PASSWORD"
    
    if [[ "$FORMAT" == "custom" ]]; then
      pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -Fc -f "$temp_file" "$DB_NAME" || {
        echo -e "${RED}Backup failed!${NC}"
        rm -f "$temp_file"
        exit 1
      }
      mv "$temp_file" "$backup_file"
      
      if [[ "$COMPRESS" == "true" ]]; then
        echo -e "${YELLOW}Compressing backup...${NC}"
        gzip -f "$backup_file"
        backup_file="${backup_file}.gz"
      fi
    else
      pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -Fp "$DB_NAME" > "$temp_file" || {
        echo -e "${RED}Backup failed!${NC}"
        rm -f "$temp_file"
        exit 1
      }
      
      if [[ "$COMPRESS" == "true" ]]; then
        echo -e "${YELLOW}Compressing backup...${NC}"
        gzip -f "$temp_file"
        mv "${temp_file}.gz" "$backup_file"
      else
        mv "$temp_file" "$backup_file"
      fi
    fi
  fi
  
  # Get file size
  local file_size=$(du -h "$backup_file" | cut -f1)
  
  echo -e "${GREEN}✓ Backup created successfully!${NC}"
  echo -e "  File: ${backup_file}"
  echo -e "  Size: ${file_size}"
  
  # Clean up old backups
  cleanup_old_backups
}

# Function to restore backup
restore_backup() {
  if [[ -z "$RESTORE_FILE" ]]; then
    echo -e "${RED}Error: No backup file specified for restore${NC}"
    exit 1
  fi
  
  if [[ ! -f "$RESTORE_FILE" ]]; then
    echo -e "${RED}Error: Backup file not found: ${RESTORE_FILE}${NC}"
    exit 1
  fi
  
  # Check if file is compressed
  local is_compressed=false
  local actual_file="$RESTORE_FILE"
  
  if [[ "$RESTORE_FILE" == *.gz ]]; then
    is_compressed=true
    actual_file="${RESTORE_FILE%.gz}"
    echo -e "${YELLOW}Decompressing backup file...${NC}"
    gunzip -c "$RESTORE_FILE" > "$actual_file" || {
      echo -e "${RED}Failed to decompress backup file${NC}"
      exit 1
    }
  fi
  
  # Determine backup format
  local format="plain"
  if [[ "$actual_file" == *.dump ]] || file "$actual_file" | grep -q "PostgreSQL custom database dump"; then
    format="custom"
  fi
  
  echo -e "${YELLOW}Restoring database: ${DB_NAME}${NC}"
  echo -e "Backup file: ${RESTORE_FILE}"
  echo -e "Format: ${format}"
  echo -e "${RED}WARNING: This will overwrite the existing database!${NC}"
  read -p "Are you sure you want to continue? (yes/no): " confirm
  
  if [[ "$confirm" != "yes" ]]; then
    echo "Restore cancelled"
    [[ "$is_compressed" == true ]] && rm -f "$actual_file"
    exit 0
  fi
  
  if check_docker_postgres; then
    # Docker restore
    if [[ "$format" == "custom" ]]; then
      docker cp "$actual_file" "${DOCKER_CONTAINER}:/tmp/restore.dump"
      docker exec -e PGPASSWORD="$DB_PASSWORD" "$DOCKER_CONTAINER" \
        pg_restore -U "$DB_USER" -d "$DB_NAME" --clean --if-exists "/tmp/restore.dump" || {
        echo -e "${RED}Restore failed!${NC}"
        docker exec "$DOCKER_CONTAINER" rm -f "/tmp/restore.dump"
        [[ "$is_compressed" == true ]] && rm -f "$actual_file"
        exit 1
      }
      docker exec "$DOCKER_CONTAINER" rm -f "/tmp/restore.dump"
    else
      docker exec -i -e PGPASSWORD="$DB_PASSWORD" "$DOCKER_CONTAINER" \
        psql -U "$DB_USER" -d "$DB_NAME" < "$actual_file" || {
        echo -e "${RED}Restore failed!${NC}"
        [[ "$is_compressed" == true ]] && rm -f "$actual_file"
        exit 1
      }
    fi
  else
    # Local restore
    export PGPASSWORD="$DB_PASSWORD"
    
    if [[ "$format" == "custom" ]]; then
      pg_restore -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" --clean --if-exists "$actual_file" || {
        echo -e "${RED}Restore failed!${NC}"
        [[ "$is_compressed" == true ]] && rm -f "$actual_file"
        exit 1
      }
    else
      psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" < "$actual_file" || {
        echo -e "${RED}Restore failed!${NC}"
        [[ "$is_compressed" == true ]] && rm -f "$actual_file"
        exit 1
      }
    fi
  fi
  
  # Clean up temporary file if decompressed
  [[ "$is_compressed" == true ]] && rm -f "$actual_file"
  
  echo -e "${GREEN}✓ Database restored successfully!${NC}"
}

# Function to cleanup old backups
cleanup_old_backups() {
  if [[ -d "$BACKUP_DIR" && "$KEEP_DAYS" -gt 0 ]]; then
    echo -e "${YELLOW}Cleaning up backups older than ${KEEP_DAYS} days...${NC}"
    find "$BACKUP_DIR" -name "${DB_NAME}_*.sql*" -o -name "${DB_NAME}_*.dump*" | \
      while read -r file; do
        if [[ $(find "$file" -mtime +$KEEP_DAYS) ]]; then
          echo "  Removing: $(basename "$file")"
          rm -f "$file"
        fi
      done
  fi
}

# Main execution
main() {
  if [[ -n "$RESTORE_FILE" ]]; then
    restore_backup
  else
    create_backup
  fi
}

# Run main function
main
