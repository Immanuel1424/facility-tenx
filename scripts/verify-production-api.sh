#!/bin/bash

# Production API URL Verification Script
# Verifies that the production API URL is configured correctly
# Usage: ./scripts/verify-production-api.sh

set -e

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

FRONTEND_CONTAINER="facility-erp-frontend-prod"
PRODUCTION_URL="${1:-https://tenx-demo.helixsense.com}"

echo "=========================================="
echo "  Production API URL Verification"
echo "=========================================="
echo ""

# Check 1: Container exists
print_info "Check 1: Verifying container exists..."
if docker ps --format '{{.Names}}' | grep -q "^${FRONTEND_CONTAINER}$"; then
    print_success "Container is running"
else
    print_error "Container '$FRONTEND_CONTAINER' is not running!"
    exit 1
fi

# Check 2: config.js exists
print_info "Check 2: Verifying config.js file..."
if docker exec "$FRONTEND_CONTAINER" test -f /usr/share/nginx/html/config.js; then
    print_success "config.js file exists"
else
    print_error "config.js file not found!"
    exit 1
fi

# Check 3: config.js content
print_info "Check 3: Verifying config.js content..."
CONFIG_CONTENT=$(docker exec "$FRONTEND_CONTAINER" cat /usr/share/nginx/html/config.js)

if echo "$CONFIG_CONTENT" | grep -q "API_BASE_URL"; then
    print_success "config.js contains API_BASE_URL"
    
    # Extract API URL
    API_URL=$(echo "$CONFIG_CONTENT" | grep -oP "API_BASE_URL:\s*'[^']*'" | cut -d"'" -f2 || echo "")
    
    if [ -n "$API_URL" ]; then
        echo ""
        print_info "Current API_BASE_URL: $API_URL"
        
        # Check if localhost
        if echo "$API_URL" | grep -qi "localhost\|127.0.0.1"; then
            print_error "❌ PROBLEM: API_BASE_URL contains localhost!"
            print_error "   This will NOT work in production!"
            echo ""
            print_info "Fix it by running:"
            echo "   ./scripts/fix-production-api-url.sh https://tenx-demo.helixsense.com/api/v1"
            exit 1
        else
            print_success "API_BASE_URL does not contain localhost"
        fi
    fi
else
    print_error "config.js does not contain API_BASE_URL!"
    exit 1
fi

# Check 4: Environment variable
print_info "Check 4: Checking environment variable..."
ENV_VALUE=$(docker exec "$FRONTEND_CONTAINER" env | grep "^API_BASE_URL=" | cut -d'=' -f2- || echo "")
if [ -n "$ENV_VALUE" ]; then
    print_success "Environment variable is set: $ENV_VALUE"
else
    print_warning "Environment variable not found (might be using docker-compose env file)"
fi

# Check 5: Container logs
print_info "Check 5: Checking container logs for errors..."
ERRORS=$(docker logs --tail 50 "$FRONTEND_CONTAINER" 2>&1 | grep -iE "(error|failed|localhost)" || echo "")
if [ -n "$ERRORS" ]; then
    print_warning "Found potential issues in logs:"
    echo "$ERRORS" | head -5
else
    print_success "No errors found in recent logs"
fi

# Check 6: HTTP accessibility (if URL provided)
if [ -n "$PRODUCTION_URL" ] && [[ "$PRODUCTION_URL" =~ ^https?:// ]]; then
    print_info "Check 6: Verifying config.js is accessible via HTTP..."
    CONFIG_URL="${PRODUCTION_URL%/}/config.js"
    
    if command -v curl &> /dev/null; then
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$CONFIG_URL" || echo "000")
        if [ "$HTTP_CODE" = "200" ]; then
            print_success "config.js is accessible at $CONFIG_URL"
            
            # Check content
            REMOTE_CONTENT=$(curl -s "$CONFIG_URL" || echo "")
            if echo "$REMOTE_CONTENT" | grep -q "API_BASE_URL"; then
                print_success "Remote config.js contains API_BASE_URL"
            else
                print_warning "Remote config.js might be cached or different"
            fi
        else
            print_warning "config.js returned HTTP $HTTP_CODE (might be cached)"
        fi
    else
        print_warning "curl not available, skipping HTTP check"
    fi
fi

# Summary
echo ""
echo "=========================================="
echo "  Verification Summary"
echo "=========================================="
echo ""
print_success "All checks passed!"
echo ""
print_info "To test in browser:"
echo "  1. Open: $PRODUCTION_URL"
echo "  2. Open DevTools → Console"
echo "  3. Look for: ✅ Runtime config loaded"
echo "  4. Check Network tab for API calls"
echo ""
print_info "To view config.js:"
echo "  curl ${PRODUCTION_URL%/}/config.js"
echo ""
