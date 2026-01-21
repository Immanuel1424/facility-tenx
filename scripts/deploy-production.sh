#!/bin/bash

# Production Deployment Script
# Automates the deployment process on a production server

set +e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Configuration
COMPOSE_FILE="docker-compose.prod.yml"

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
    
    # Check .env file
    if [ ! -f .env ]; then
        print_error ".env file not found"
        print_info "Create .env file from env.example"
        exit 1
    fi
    
    # Check required environment variables
    if [ -f .env ]; then
        # Source .env file to check variables (handle comments and empty lines)
        set -a
        source .env 2>/dev/null || true
        set +a
        
        # Check API_BASE_URL
        if [ -z "$API_BASE_URL" ]; then
            print_error "API_BASE_URL is not set in .env file"
            print_info "This is REQUIRED for production deployment"
            print_info "Add to .env: API_BASE_URL=https://api.yourdomain.com/api/v1"
            exit 1
        fi
        
        # Warn if localhost is detected
        if echo "$API_BASE_URL" | grep -qi "localhost\|127.0.0.1"; then
            print_error "API_BASE_URL contains localhost/127.0.0.1: $API_BASE_URL"
            print_error "This will NOT work in production!"
            print_info "localhost refers to the user's browser, not your server"
            print_info "Set API_BASE_URL to your actual backend URL:"
            print_info "  Example: API_BASE_URL=https://api.yourdomain.com/api/v1"
            exit 1
        fi
        
        print_success "API_BASE_URL is configured: $API_BASE_URL"
    fi
    
    # Check compose file
    if [ ! -f "$COMPOSE_FILE" ]; then
        print_error "$COMPOSE_FILE not found"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Check migration status
check_migrations() {
    print_info "Checking database migration status..."
    
    # Check if we can connect to database and check migrations
    # This requires the backend code to be available locally or in a container
    if [ -d "apps/backend" ] && [ -f "apps/backend/package.json" ]; then
        cd apps/backend
        
        # Check if node_modules exists (for npm scripts)
        if [ ! -d "node_modules" ]; then
            print_warning "node_modules not found - skipping migration check"
            print_info "Run migrations manually: cd apps/backend && npm run migrate:status"
            cd ../..
            return 0
        fi
        
        # Run migration status check
        if npm run migrate:status > /dev/null 2>&1; then
            local pending=$(npm run migrate:status 2>/dev/null | grep -c "Pending migrations" || echo "0")
            if [ "$pending" != "0" ]; then
                print_warning "Pending database migrations detected!"
                print_info "Run migrations before deployment:"
                print_info "  cd apps/backend && npm run migrate:run"
                echo ""
                read -p "Continue deployment anyway? (y/N): " -n 1 -r
                echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    print_error "Deployment cancelled"
                    cd ../..
                    exit 1
                fi
            else
                print_success "All migrations are up to date"
            fi
        else
            print_warning "Could not check migration status (database may not be accessible)"
            print_info "Verify migrations manually before deployment"
        fi
        
        cd ../..
    else
        print_warning "Backend directory not found - skipping migration check"
        print_info "Verify migrations manually before deployment"
    fi
}

# Pull images
pull_images() {
    print_info "Pulling latest images..."
    
    docker pull "hsense/facility-erp-backend:latest" || {
        print_error "Failed to pull backend image"
        return 1
    }
    
    docker pull "hsense/facility-erp-frontend:latest" || {
        print_error "Failed to pull frontend image"
        return 1
    }
    
    print_success "Images pulled successfully"
}

# Deploy services
deploy_services() {
    print_info "Deploying services..."
    
    # Stop existing containers
    docker-compose -f "$COMPOSE_FILE" down
    
    # Start new containers
    if docker-compose -f "$COMPOSE_FILE" up -d; then
        print_success "Services deployed successfully"
        return 0
    else
        print_error "Deployment failed"
        return 1
    fi
}

# Wait for health checks
wait_for_health() {
    print_info "Waiting for services to become healthy..."
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker-compose -f "$COMPOSE_FILE" ps | grep -q "healthy"; then
            print_success "Services are healthy"
            return 0
        fi
        
        attempt=$((attempt + 1))
        sleep 2
    done
    
    print_warning "Health checks taking longer than expected"
    return 1
}

# Show status
show_status() {
    echo ""
    print_info "Deployment Status:"
    docker-compose -f "$COMPOSE_FILE" ps
    
    echo ""
    print_info "Service URLs:"
    echo "  Frontend: http://localhost:${FRONTEND_PORT:-80}"
    echo "  Backend:  http://localhost:${BACKEND_PORT:-3000}/api"
    echo "  Health:   http://localhost:${BACKEND_PORT:-3000}/api/v1/health"
    echo ""
}

# Main deployment
main() {
    local skip_pull=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-pull)
                skip_pull=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --skip-pull              Skip pulling images"
                echo "  -h, --help               Show this help"
                echo ""
                echo "Examples:"
                echo "  $0                       Deploy latest images"
                echo "  $0 --skip-pull            Deploy without pulling images"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    echo "=========================================="
    echo "  Production Deployment"
    echo "=========================================="
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Check migration status (warns if pending migrations exist)
    check_migrations
    
    # Pull images if not skipped
    if [ "$skip_pull" = false ]; then
        pull_images
    else
        print_info "Skipping image pull"
    fi
    
    # Deploy
    if deploy_services; then
        # Wait for health
        wait_for_health
        
        # Show status
        show_status
        
        print_success "Deployment completed! 🚀"
    else
        print_error "Deployment failed"
        exit 1
    fi
}

# Run main
main "$@"

