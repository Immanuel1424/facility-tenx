#!/bin/bash

# Check and configure Colima resources for Docker builds
# This script helps diagnose and fix resource limit issues

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

# Check if Colima is running
if ! colima status &>/dev/null; then
    print_error "Colima is not running or not installed"
    echo ""
    echo "To start Colima with recommended settings:"
    echo "  colima start --cpu 4 --memory 8 --disk 60"
    exit 1
fi

print_info "Checking Colima resource configuration..."
echo ""

# Get current Colima config
COLIMA_CONFIG=$(colima status --json 2>/dev/null || echo "{}")
CPU_COUNT=$(echo "$COLIMA_CONFIG" | grep -o '"cpu":[0-9]*' | cut -d: -f2 || echo "unknown")
MEMORY_GB=$(echo "$COLIMA_CONFIG" | grep -o '"memory":[0-9]*' | cut -d: -f2 || echo "unknown")

if [ "$CPU_COUNT" != "unknown" ] && [ "$MEMORY_GB" != "unknown" ]; then
    print_info "Current Colima configuration:"
    echo "  CPU: $CPU_COUNT cores"
    echo "  Memory: ${MEMORY_GB}GB"
    echo ""
    
    # Check if resources are sufficient
    MEMORY_INT=${MEMORY_GB}
    CPU_INT=${CPU_COUNT}
    
    if [ "$MEMORY_INT" -lt 8 ]; then
        print_warning "Memory is less than 8GB. Flutter builds may fail."
        echo ""
        print_info "Recommended: At least 8GB memory for Flutter web builds"
        echo ""
        echo "To increase memory, stop and restart Colima:"
        echo "  colima stop"
        echo "  colima start --cpu 4 --memory 8 --disk 60"
    else
        print_success "Memory configuration looks good (${MEMORY_GB}GB)"
    fi
    
    if [ "$CPU_INT" -lt 2 ]; then
        print_warning "CPU count is less than 2. Builds may be slow."
        echo ""
        print_info "Recommended: At least 2-4 CPU cores"
    else
        print_success "CPU configuration looks good (${CPU_COUNT} cores)"
    fi
else
    print_warning "Could not parse Colima configuration"
    echo ""
    print_info "Run 'colima status' to see current configuration"
fi

echo ""
print_info "Docker build recommendations:"
echo "  1. Ensure Colima has at least 8GB memory: colima start --memory 8"
echo "  2. Use buildx with memory limits: docker buildx build --memory=6g ..."
echo "  3. Build locally first, then copy to Docker (see build-push-frontend-amd64.sh)"
echo ""

# Check Docker buildx
if docker buildx version &>/dev/null; then
    print_success "Docker buildx is available"
    echo ""
    print_info "You can use buildx with memory limits:"
    echo "  docker buildx build --memory=6g --platform linux/amd64 ..."
else
    print_warning "Docker buildx not found. Consider installing for better resource control."
fi

