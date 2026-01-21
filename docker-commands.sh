#!/bin/bash

# Docker Compose Management Script for Facility ERP
# Usage: ./docker-commands.sh [command]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env file exists
check_env() {
    if [ ! -f .env ]; then
        print_warn ".env file not found. Creating from env.example..."
        if [ -f env.example ]; then
            cp env.example .env
            print_info "Created .env file. Please update it with your configuration."
        else
            print_error "env.example not found. Please create .env manually."
            exit 1
        fi
    fi
}

# Build and start all services
start() {
    print_info "Starting Facility ERP services..."
    check_env
    docker-compose up -d
    print_info "Services started. Waiting for health checks..."
    sleep 10
    docker-compose ps
}

# Stop all services
stop() {
    print_info "Stopping Facility ERP services..."
    docker-compose down
    print_info "Services stopped."
}

# Restart all services
restart() {
    print_info "Restarting Facility ERP services..."
    docker-compose restart
    print_info "Services restarted."
}

# View logs
logs() {
    SERVICE=${1:-""}
    if [ -z "$SERVICE" ]; then
        docker-compose logs -f
    else
        docker-compose logs -f "$SERVICE"
    fi
}

# Build services
build() {
    print_info "Building Docker images..."
    docker-compose build --no-cache --platform linux/amd64
    print_info "Build complete."
}

# Rebuild and restart
rebuild() {
    print_info "Rebuilding and restarting services..."
    docker-compose build --no-cache --platform linux/amd64
    docker-compose up -d
    print_info "Rebuild complete."
}

# Check service status
status() {
    print_info "Service status:"
    docker-compose ps
    echo ""
    print_info "Health check status:"
    docker inspect --format='{{.Name}}: {{.State.Health.Status}}' $(docker-compose ps -q) 2>/dev/null || echo "Health checks not available"
}

# Run database migrations
migrate() {
    print_info "Running database migrations..."
    docker-compose exec backend npm run migrate
    print_info "Migrations complete."
}

# Seed database
seed() {
    print_info "Seeding database..."
    docker-compose exec backend npm run seed:all
    print_info "Seeding complete."
}

# Access backend shell
backend_shell() {
    docker-compose exec backend sh
}

# Access database shell
db_shell() {
    docker-compose exec postgres psql -U postgres -d facility_erp
}

# Backup database
backup() {
    BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
    print_info "Creating database backup: $BACKUP_FILE"
    docker-compose exec -T postgres pg_dump -U postgres facility_erp > "$BACKUP_FILE"
    print_info "Backup created: $BACKUP_FILE"
}

# Restore database
restore() {
    if [ -z "$1" ]; then
        print_error "Please provide backup file: ./docker-commands.sh restore backup_file.sql"
        exit 1
    fi
    print_info "Restoring database from: $1"
    docker-compose exec -T postgres psql -U postgres facility_erp < "$1"
    print_info "Database restored."
}

# Clean up (remove containers, volumes, images)
clean() {
    print_warn "This will remove all containers, volumes, and images. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_info "Cleaning up..."
        docker-compose down -v --rmi all
        print_info "Cleanup complete."
    else
        print_info "Cleanup cancelled."
    fi
}

# Show resource usage
stats() {
    docker stats $(docker-compose ps -q)
}

# Test health endpoints
health() {
    print_info "Testing health endpoints..."
    echo ""
    echo "Backend Health:"
    curl -s http://localhost:3000/api/v1/health | jq . || curl -s http://localhost:3000/api/v1/health
    echo ""
    echo ""
    echo "Frontend Health:"
    curl -s http://localhost/health || echo "Frontend not responding"
    echo ""
}

# Show help
help() {
    echo "Facility ERP Docker Management Script"
    echo ""
    echo "Usage: ./docker-commands.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start          Start all services"
    echo "  stop           Stop all services"
    echo "  restart        Restart all services"
    echo "  logs [service] View logs (optionally for specific service)"
    echo "  build          Build Docker images"
    echo "  rebuild        Rebuild and restart services"
    echo "  status         Show service status"
    echo "  migrate        Run database migrations"
    echo "  seed           Seed database with initial data"
    echo "  backend_shell  Access backend container shell"
    echo "  db_shell       Access PostgreSQL shell"
    echo "  backup         Create database backup"
    echo "  restore [file] Restore database from backup"
    echo "  clean          Remove all containers, volumes, and images"
    echo "  stats          Show resource usage"
    echo "  health         Test health endpoints"
    echo "  help           Show this help message"
    echo ""
}

# Main command handler
case "${1:-help}" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    logs)
        logs "$2"
        ;;
    build)
        build
        ;;
    rebuild)
        rebuild
        ;;
    status)
        status
        ;;
    migrate)
        migrate
        ;;
    seed)
        seed
        ;;
    backend_shell)
        backend_shell
        ;;
    db_shell)
        db_shell
        ;;
    backup)
        backup
        ;;
    restore)
        restore "$2"
        ;;
    clean)
        clean
        ;;
    stats)
        stats
        ;;
    health)
        health
        ;;
    help|--help|-h)
        help
        ;;
    *)
        print_error "Unknown command: $1"
        help
        exit 1
        ;;
esac

