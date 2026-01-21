#!/bin/bash

# Docker Build and Push Script
# Builds and pushes Docker images to Docker Hub
# Supports semantic versioning (e.g., 1.0.0) or 'latest' tag
# Usage: ./scripts/docker-build-push.sh [--version VERSION] [--skip-build]

set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOCKER_USERNAME="hsense"
BACKEND_IMAGE="facility-erp-backend"
FRONTEND_IMAGE="facility-erp-frontend"
COMPOSE_FILE="docker-compose.prod.yml"
PLATFORM="linux/amd64"

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

# Function to check if Docker is logged in
check_docker_login() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    
    # Check if logged in to Docker Hub
    if ! docker info 2>/dev/null | grep -q "Username"; then
        print_warning "Not logged in to Docker Hub."
        print_info "Please run: docker login -u $DOCKER_USERNAME"
        exit 1
    fi
}

# Function to validate semantic version
validate_version() {
    local version="$1"
    # Semantic version regex: MAJOR.MINOR.PATCH (e.g., 1.0.0, 2.1.3)
    if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$ ]]; then
        return 0
    else
        print_error "Invalid version format: $version"
        print_info "Version must follow semantic versioning (e.g., 1.0.0, 2.1.3)"
        return 1
    fi
}

# Function to build images
build_images() {
    local compose_file="$1"
    local platform="${DOCKER_PLATFORM:-$PLATFORM}"
    local version="$2"
    
    print_info "Building Docker images for platform: $platform"
    print_info "Using compose file: $compose_file"
    print_info "Version: $version"
    
    # Check if buildx is available
    if docker buildx version &> /dev/null; then
        print_info "Using Docker Buildx for cross-platform build"
        
        # Create builder if it doesn't exist
        if ! docker buildx ls | grep -q "facility-erp-builder"; then
            print_info "Creating new buildx builder..."
            docker buildx create --name facility-erp-builder --use 2>/dev/null || true
            docker buildx inspect --bootstrap 2>/dev/null || true
        else
            print_info "Using existing buildx builder..."
            docker buildx use facility-erp-builder 2>/dev/null || true
        fi
        
        # Ensure builder supports the target platform
        print_info "Setting up buildx builder for platform: $platform"
        docker buildx inspect --bootstrap > /dev/null 2>&1 || true
        
        # Check if QEMU is needed for cross-platform builds
        local host_arch=$(uname -m)
        local target_arch=$(echo "$platform" | cut -d'/' -f2)
        if [[ "$host_arch" != "$target_arch" ]] && [[ "$host_arch" == "arm64" ]] && [[ "$target_arch" == "amd64" ]]; then
            print_info "Cross-platform build detected (ARM64 -> AMD64)"
            print_info "QEMU emulation should be handled automatically by Docker Desktop"
            print_info "If build fails, ensure Docker Desktop has emulation enabled"
        fi
        
        # Build backend
        print_info "Building backend for platform: $platform..."
        # Try --load first (works on Docker Desktop with QEMU for cross-platform)
        # Fall back to --output type=docker if --load fails
        if docker buildx build \
            --platform "$platform" \
            --tag "${DOCKER_USERNAME}/${BACKEND_IMAGE}:${version}" \
            --load \
            -f apps/backend/Dockerfile \
            apps/backend 2>&1; then
            print_success "Backend built successfully!"
        elif docker buildx build \
            --platform "$platform" \
            --tag "${DOCKER_USERNAME}/${BACKEND_IMAGE}:${version}" \
            --output type=docker \
            -f apps/backend/Dockerfile \
            apps/backend 2>&1; then
            print_success "Backend built successfully (using type=docker)!"
        else
            print_error "Backend build failed!"
            print_info "Cross-platform build troubleshooting:"
            print_info "  1. Ensure Docker Desktop has emulation enabled (Settings > Features in development)"
            print_info "  2. Try: docker run --rm --privileged multiarch/qemu-user-static --reset -p yes"
            print_info "  3. Or build directly on Linux server"
            return 1
        fi
        
        # Build frontend
        print_info "Building frontend for platform: $platform..."
        if docker buildx build \
            --platform "$platform" \
            --tag "${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${version}" \
            --load \
            -f apps/frontend/Dockerfile \
            apps/frontend 2>&1; then
            print_success "Frontend built successfully!"
        elif docker buildx build \
            --platform "$platform" \
            --tag "${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${version}" \
            --output type=docker \
            -f apps/frontend/Dockerfile \
            apps/frontend 2>&1; then
            print_success "Frontend built successfully (using type=docker)!"
        else
            print_error "Frontend build failed!"
            print_info "Cross-platform build troubleshooting:"
            print_info "  1. Ensure Docker Desktop has emulation enabled (Settings > Features in development)"
            print_info "  2. Try: docker run --rm --privileged multiarch/qemu-user-static --reset -p yes"
            print_info "  3. Or build directly on Linux server"
            return 1
        fi
    else
        print_warning "Docker Buildx not available, using standard build"
        
        # Build backend
        print_info "Building backend..."
        if docker build -t "${DOCKER_USERNAME}/${BACKEND_IMAGE}:${version}" -f apps/backend/Dockerfile apps/backend; then
            print_success "Backend built successfully!"
        else
            print_error "Backend build failed!"
            return 1
        fi
        
        # Build frontend
        print_info "Building frontend..."
        if docker build -t "${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${version}" -f apps/frontend/Dockerfile apps/frontend; then
            print_success "Frontend built successfully!"
        else
            print_error "Frontend build failed!"
            return 1
        fi
    fi
    
    return 0
}

# Function to push images
push_images() {
    local version="$1"
    print_info "Pushing images to Docker Hub..."
    
    # Push backend
    print_info "Pushing backend: ${DOCKER_USERNAME}/${BACKEND_IMAGE}:${version}"
    if docker push "${DOCKER_USERNAME}/${BACKEND_IMAGE}:${version}"; then
        print_success "Backend (${version}) pushed successfully!"
    else
        print_error "Failed to push backend image (${version})"
        return 1
    fi
    
    # Push frontend
    print_info "Pushing frontend: ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${version}"
    if docker push "${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${version}"; then
        print_success "Frontend (${version}) pushed successfully!"
    else
        print_error "Failed to push frontend image (${version})"
        return 1
    fi
    
    return 0
}

# Function to show previous versions
show_previous_versions() {
    print_info "Fetching previous versions from Docker Hub..."
    echo ""
    echo "Previous Backend Versions:"
    echo "  (Use: docker search ${DOCKER_USERNAME}/${BACKEND_IMAGE} --limit 10)"
    echo "  Or check: https://hub.docker.com/r/${DOCKER_USERNAME}/${BACKEND_IMAGE}/tags"
    echo ""
    echo "Previous Frontend Versions:"
    echo "  (Use: docker search ${DOCKER_USERNAME}/${FRONTEND_IMAGE} --limit 10)"
    echo "  Or check: https://hub.docker.com/r/${DOCKER_USERNAME}/${FRONTEND_IMAGE}/tags"
    echo ""
}

# Function to show summary
show_summary() {
    local version="$1"
    echo ""
    echo "=========================================="
    echo "  Build and Push Summary"
    echo "=========================================="
    echo ""
    echo "Version: $version"
    echo ""
    echo "Backend Image:"
    echo "  ${DOCKER_USERNAME}/${BACKEND_IMAGE}:${version}"
    echo ""
    echo "Frontend Image:"
    echo "  ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${version}"
    echo ""
    echo "Pull commands:"
    echo "  docker pull ${DOCKER_USERNAME}/${BACKEND_IMAGE}:${version}"
    echo "  docker pull ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${version}"
    echo ""
    show_previous_versions
}

# Main function
main() {
    local skip_build=false
    local version=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --version|-v)
                if [ -z "$2" ]; then
                    print_error "Version value required for --version option"
                    exit 1
                fi
                version="$2"
                shift 2
                ;;
            --skip-build)
                skip_build=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --version, -v VERSION    Semantic version to tag images (e.g., 1.0.0, 2.1.3) [REQUIRED]"
                echo "  --skip-build             Skip building, only push existing images"
                echo "  -h, --help               Show this help message"
                echo ""
                echo "Examples:"
                echo "  $0 --version 1.0.0       Build and push with version 1.0.0"
                echo "  $0 -v 2.1.3              Build and push with version 2.1.3"
                echo ""
                echo "Note: Version is required. Use semantic versioning (e.g., 1.0.0, 2.1.3)"
                echo ""
                echo "This script builds and pushes:"
                echo "  - ${DOCKER_USERNAME}/${BACKEND_IMAGE}:<version>"
                echo "  - ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:<version>"
                echo ""
                echo "Note: Only version tags are pushed (no 'latest' tag)"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Validate version is provided
    if [ -z "$version" ]; then
        print_error "Version is required"
        echo ""
        echo "Usage: $0 --version VERSION"
        echo "Example: $0 --version 1.0.0"
        echo ""
        echo "Use --help for more information"
        exit 1
    fi
    
    # Validate version format
    if ! validate_version "$version"; then
        exit 1
    fi
    
    # Check Docker login
    check_docker_login
    
    # Build images if not skipped
    if [ "$skip_build" = false ]; then
        if ! build_images "$COMPOSE_FILE" "$version"; then
            exit 1
        fi
    else
        print_info "Skipping build (using existing images)"
        
        # Verify images exist
        if ! docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${DOCKER_USERNAME}/${BACKEND_IMAGE}:${version}$"; then
            print_error "Backend image not found: ${DOCKER_USERNAME}/${BACKEND_IMAGE}:${version}"
            print_info "Run without --skip-build to build images first"
            exit 1
        fi
        
        if ! docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${version}$"; then
            print_error "Frontend image not found: ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${version}"
            print_info "Run without --skip-build to build images first"
            exit 1
        fi
    fi
    
    # Ask for confirmation before pushing
    echo ""
    print_warning "Ready to push images to Docker Hub"
    print_info "Backend: ${DOCKER_USERNAME}/${BACKEND_IMAGE}:${version}"
    print_info "Frontend: ${DOCKER_USERNAME}/${FRONTEND_IMAGE}:${version}"
    echo ""
    read -p "Push to Docker Hub? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Push cancelled. Images are built but not pushed."
        show_summary "$version"
        exit 0
    fi
    
    # Push images
    if ! push_images "$version"; then
        exit 1
    fi
    
    # Show summary
    show_summary "$version"
    
    print_success "All done! 🚀"
}

# Run main function
main "$@"
