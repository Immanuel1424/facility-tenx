#!/bin/bash

# Docker Cleanup Script for Facility ERP
# Removes unused build images while keeping final runtime images
# SAFE: Always preserves facility-erp-backend and facility-erp-frontend images

# Don't exit on error - we handle errors gracefully
set +e

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
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to show current disk usage
show_disk_usage() {
    echo ""
    print_info "Current Docker disk usage:"
    docker system df
    echo ""
}

# Function to show images that will be kept
show_kept_images() {
    echo ""
    print_info "Images that will be KEPT:"
    docker images --format "  {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep -E "facility-erp-(backend|frontend):latest" || echo "  (none found)"
    echo ""
}

# Function to show images that will be removed (excluding final images)
show_removed_images() {
    echo ""
    print_info "Images that will be REMOVED (excluding facility-erp images):"
    docker images --format "  {{.Repository}}:{{.Tag}}\t{{.Size}}" | \
        grep -vE "facility-erp-(backend|frontend):latest|REPOSITORY" || echo "  (none found)"
    echo ""
}

# Function to calculate space that will be reclaimed
calculate_reclaimable_space() {
    local total=$(docker system df --format "{{.Reclaimable}}" | head -1 | sed 's/GB//' | awk '{print $1}')
    echo "$total"
}

# Main cleanup function - SAFE: Preserves final production images
cleanup_unused_images() {
    print_info "Starting SAFE cleanup (will preserve facility-erp images)..."
    echo ""
    
    # Show what will be kept
    show_kept_images
    
    # Show what will be removed (excluding our final images)
    print_info "Images that will be REMOVED (excluding facility-erp images):"
    docker images --format "  {{.Repository}}:{{.Tag}}\t{{.Size}}" | \
        grep -vE "facility-erp-(backend|frontend):latest|REPOSITORY" || echo "  (none found)"
    echo ""
    
    # Ask for confirmation
    read -p "Do you want to proceed? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Cleanup cancelled."
        exit 0
    fi
    
    # Get list of images to remove (everything except our final images)
    local images_to_remove=$(docker images --format "{{.Repository}}:{{.Tag}}" | \
        grep -vE "facility-erp-(backend|frontend):latest|^REPOSITORY")
    
    if [ -z "$images_to_remove" ]; then
        print_info "No images to remove (all images are protected)."
    else
        print_info "Removing unused images (preserving facility-erp images)..."
        # Remove images one by one to avoid removing our final images
        echo "$images_to_remove" | while read -r image; do
            if [ -n "$image" ]; then
                docker rmi "$image" 2>/dev/null || true
            fi
        done
        
        # Also run prune to clean up dangling images
        docker image prune -f
        
        print_success "Cleanup completed! Final images preserved."
    fi
    
    echo ""
    show_disk_usage
}

# Aggressive cleanup - removes all except final images
cleanup_aggressive() {
    print_warning "AGGRESSIVE MODE: Will remove ALL images except facility-erp-backend and facility-erp-frontend"
    echo ""
    
    show_kept_images
    show_removed_images
    
    read -p "Are you sure? This will remove ALL other images. (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Cleanup cancelled."
        exit 0
    fi
    
    print_info "Removing all images except final runtime images..."
    
    # Get list of images to remove (everything except our final images)
    local images_to_remove=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -vE "facility-erp-(backend|frontend):latest|REPOSITORY")
    
    if [ -z "$images_to_remove" ]; then
        print_info "No images to remove."
    else
        echo "$images_to_remove" | xargs -r docker rmi -f
        print_success "Aggressive cleanup completed!"
    fi
    
    echo ""
    show_disk_usage
}

# Remove specific large build images (SAFE: preserves final images)
cleanup_build_images() {
    print_info "Removing specific build-time images (preserving facility-erp images)..."
    echo ""
    
    show_kept_images
    
    local removed=0
    
    # Remove Flutter build image
    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "ghcr.io/cirruslabs/flutter:stable"; then
        print_info "Removing ghcr.io/cirruslabs/flutter:stable (~5.72GB)..."
        if docker rmi ghcr.io/cirruslabs/flutter:stable 2>/dev/null; then
            removed=1
            print_success "Removed Flutter image"
        else
            print_warning "Could not remove Flutter image (may be in use)"
        fi
    fi
    
    # Remove Node.js base image (if not used by other projects)
    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "node:20-alpine"; then
        print_warning "node:20-alpine might be used by other projects."
        read -p "Remove it? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Removing node:20-alpine..."
            if docker rmi node:20-alpine 2>/dev/null; then
                removed=1
                print_success "Removed Node.js image"
            else
                print_warning "Could not remove Node.js image (may be in use)"
            fi
        fi
    fi
    
    # Remove nginx:alpine if not needed (it's already in frontend image)
    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^nginx.*alpine"; then
        print_info "nginx:alpine is already included in frontend image."
        read -p "Remove nginx:alpine base image? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if docker rmi nginx:alpine 2>/dev/null; then
                removed=1
                print_success "Removed nginx image"
            else
                print_warning "Could not remove nginx image (may be in use)"
            fi
        fi
    fi
    
    if [ $removed -eq 0 ]; then
        print_info "No build images removed."
    else
        print_success "Build images cleanup completed!"
    fi
    
    echo ""
    show_disk_usage
}

# Full system cleanup (SAFE: preserves final images)
cleanup_full_system() {
    print_warning "FULL SYSTEM CLEANUP: Will remove ALL unused containers, networks, and build cache"
    print_warning "IMAGES: Will preserve facility-erp-backend and facility-erp-frontend"
    echo ""
    
    show_kept_images
    show_disk_usage
    
    read -p "Are you absolutely sure? This is irreversible. (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Cleanup cancelled."
        exit 0
    fi
    
    print_info "Performing full system cleanup (preserving facility-erp images)..."
    
    # First, tag our images to protect them
    local backend_id=$(docker images -q facility-erp-backend:latest 2>/dev/null)
    local frontend_id=$(docker images -q facility-erp-frontend:latest 2>/dev/null)
    
    # Remove all unused images except our final ones
    local images_to_remove=$(docker images --format "{{.Repository}}:{{.Tag}}" | \
        grep -vE "facility-erp-(backend|frontend):latest|^REPOSITORY")
    
    if [ -n "$images_to_remove" ]; then
        echo "$images_to_remove" | xargs -r docker rmi -f 2>/dev/null || true
    fi
    
    # Clean up containers, networks, and build cache (but not volumes with -v flag removed)
    docker system prune -f
    
    print_success "Full system cleanup completed! Final images preserved."
    echo ""
    
    show_disk_usage
}

# Show menu
show_menu() {
    echo ""
    echo "=========================================="
    echo "  Docker Cleanup Script - Facility ERP"
    echo "=========================================="
    echo ""
    show_disk_usage
    echo "Options:"
    echo "  1) Cleanup unused images (recommended)"
    echo "  2) Aggressive cleanup (keep only final images)"
    echo "  3) Remove specific build images (Flutter, Node.js)"
    echo "  4) Full system cleanup (everything unused)"
    echo "  5) Show current images"
    echo "  6) Exit"
    echo ""
    read -p "Select option [1-6]: " choice
    echo ""
    
    case $choice in
        1)
            cleanup_unused_images
            ;;
        2)
            cleanup_aggressive
            ;;
        3)
            cleanup_build_images
            ;;
        4)
            cleanup_full_system
            ;;
        5)
            echo "Current Docker images:"
            docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
            echo ""
            show_menu
            ;;
        6)
            print_info "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid option. Please select 1-6."
            show_menu
            ;;
    esac
}

# Main execution
main() {
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    
    # If argument provided, run that option directly
    case "${1:-}" in
        --unused|-u)
            cleanup_unused_images
            ;;
        --aggressive|-a)
            cleanup_aggressive
            ;;
        --build|-b)
            cleanup_build_images
            ;;
        --full|-f)
            cleanup_full_system
            ;;
        --help|-h)
            echo "Usage: $0 [OPTION]"
            echo ""
            echo "Options:"
            echo "  -u, --unused     Remove unused images (SAFE - preserves facility-erp images)"
            echo "  -a, --aggressive Remove all except final images"
            echo "  -b, --build      Remove specific build images (SAFE - preserves facility-erp images)"
            echo "  -f, --full       Full system cleanup (SAFE - preserves facility-erp images)"
            echo "  -h, --help       Show this help message"
            echo ""
            echo "SAFETY: All cleanup options now preserve facility-erp-backend and facility-erp-frontend images."
            echo ""
            echo "If no option is provided, an interactive menu will be shown."
            exit 0
            ;;
        "")
            show_menu
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

