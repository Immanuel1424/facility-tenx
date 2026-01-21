#!/bin/bash

# Production API URL Fix Script
# This script helps fix the API_BASE_URL configuration in production
# Usage: ./scripts/fix-production-api-url.sh [API_URL]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
FRONTEND_CONTAINER="facility-erp-frontend-prod"
ENV_FILE=".env"

# Get API URL from argument or prompt
if [ -n "$1" ]; then
    API_BASE_URL="$1"
else
    # Auto-detect from current domain or prompt
    print_info "Detecting production domain..."
    
    # Try to get from docker-compose or environment
    if [ -f "$ENV_FILE" ]; then
        CURRENT_URL=$(grep "^API_BASE_URL=" "$ENV_FILE" | cut -d'=' -f2- | tr -d '"' | tr -d "'" || echo "")
    fi
    
    if [ -z "$CURRENT_URL" ]; then
        # Prompt for API URL
        echo ""
        print_info "Please provide the production API URL:"
        echo "  Examples:"
        echo "    - Same domain: https://tenx-demo.helixsense.com/api/v1"
        echo "    - Separate API: https://api.helixsense.com/api/v1"
        echo "    - Docker internal: http://backend:3000/api/v1"
        echo ""
        read -p "API_BASE_URL: " API_BASE_URL
        
        if [ -z "$API_BASE_URL" ]; then
            print_error "API_BASE_URL is required!"
            exit 1
        fi
    else
        API_BASE_URL="$CURRENT_URL"
        print_info "Found existing API_BASE_URL: $API_BASE_URL"
        read -p "Use this URL? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            read -p "Enter new API_BASE_URL: " API_BASE_URL
        fi
    fi
fi

# Validate URL
if echo "$API_BASE_URL" | grep -qi "localhost\|127.0.0.1"; then
    print_error "ERROR: API_BASE_URL contains localhost/127.0.0.1!"
    print_error "This will NOT work in production!"
    print_info "localhost refers to the user's browser, not your server."
    exit 1
fi

# Validate URL format
if [[ ! "$API_BASE_URL" =~ ^https?:// ]]; then
    print_error "ERROR: API_BASE_URL must start with http:// or https://"
    exit 1
fi

echo ""
echo "=========================================="
echo "  Production API URL Fix"
echo "=========================================="
echo ""
print_info "API_BASE_URL: $API_BASE_URL"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${FRONTEND_CONTAINER}$"; then
    print_error "Frontend container '$FRONTEND_CONTAINER' not found!"
    print_info "Make sure the container is running: docker-compose -f $COMPOSE_FILE ps"
    exit 1
fi

# Step 1: Update .env file
print_info "Step 1: Updating .env file..."
if [ -f "$ENV_FILE" ]; then
    # Remove existing API_BASE_URL line if present
    sed -i.bak '/^API_BASE_URL=/d' "$ENV_FILE"
    # Add new API_BASE_URL
    echo "API_BASE_URL=$API_BASE_URL" >> "$ENV_FILE"
    print_success "Updated .env file"
else
    # Create .env file
    echo "API_BASE_URL=$API_BASE_URL" > "$ENV_FILE"
    print_success "Created .env file"
fi

# Step 2: Update docker-compose.prod.yml (if needed)
print_info "Step 2: Checking docker-compose.prod.yml..."
if grep -q "API_BASE_URL: \${API_BASE_URL}" "$COMPOSE_FILE"; then
    print_success "docker-compose.prod.yml is correctly configured"
else
    print_warning "docker-compose.prod.yml might need manual update"
fi

# Step 3: Restart frontend container
print_info "Step 3: Restarting frontend container..."
if docker-compose -f "$COMPOSE_FILE" restart frontend; then
    print_success "Frontend container restarted"
else
    print_error "Failed to restart container"
    print_info "Trying alternative method..."
    docker restart "$FRONTEND_CONTAINER" || {
        print_error "Failed to restart container"
        exit 1
    }
fi

# Wait for container to be ready
print_info "Waiting for container to be ready..."
sleep 5

# Step 4: Verify config.js was generated
print_info "Step 4: Verifying config.js generation..."
if docker exec "$FRONTEND_CONTAINER" test -f /usr/share/nginx/html/config.js; then
    print_success "config.js file exists"
    
    # Check contents
    CONFIG_CONTENT=$(docker exec "$FRONTEND_CONTAINER" cat /usr/share/nginx/html/config.js)
    
    if echo "$CONFIG_CONTENT" | grep -q "$API_BASE_URL"; then
        print_success "config.js contains correct API_BASE_URL"
        echo ""
        print_info "config.js contents:"
        echo "$CONFIG_CONTENT" | head -10
    else
        print_warning "config.js exists but might have different URL"
        print_info "Contents:"
        echo "$CONFIG_CONTENT" | head -10
    fi
else
    print_error "config.js file not found!"
    print_info "Check container logs: docker logs $FRONTEND_CONTAINER"
    exit 1
fi

# Step 5: Check container logs
print_info "Step 5: Checking container logs..."
echo ""
print_info "Recent container logs (last 20 lines):"
docker logs --tail 20 "$FRONTEND_CONTAINER" | grep -E "(config.js|API_BASE_URL|ERROR|WARNING)" || {
    print_warning "No relevant log entries found"
    print_info "Full logs: docker logs $FRONTEND_CONTAINER"
}

# Step 6: Verify environment variable
print_info "Step 6: Verifying environment variable..."
ENV_VALUE=$(docker exec "$FRONTEND_CONTAINER" env | grep "^API_BASE_URL=" | cut -d'=' -f2- || echo "")
if [ -n "$ENV_VALUE" ]; then
    print_success "Environment variable is set: $ENV_VALUE"
else
    print_warning "Environment variable not found in container"
    print_info "This might be normal if using docker-compose env file"
fi

# Summary
echo ""
echo "=========================================="
echo "  Summary"
echo "=========================================="
echo ""
print_success "Configuration updated!"
echo ""
print_info "Next steps:"
echo "  1. Clear browser cache and hard refresh (Ctrl+Shift+R)"
echo "  2. Open browser DevTools → Console"
echo "  3. Check for: ✅ Runtime config loaded"
echo "  4. Verify API calls in Network tab"
echo ""
print_info "To verify config.js is accessible:"
echo "  curl https://tenx-demo.helixsense.com/config.js"
echo ""
print_info "To check container logs:"
echo "  docker logs $FRONTEND_CONTAINER"
echo ""
print_info "To restart if needed:"
echo "  docker-compose -f $COMPOSE_FILE restart frontend"
echo ""
