#!/bin/bash

# Branch Creation Script
# Creates a new branch from the current branch following project naming conventions
#
# Usage:
#   ./scripts/create-branch.sh <type> <name> [ticket-number]
#   ./scripts/create-branch.sh feature user-authentication HP-00901
#   ./scripts/create-branch.sh bugfix login-error
#   ./scripts/create-branch.sh enhancement performance-optimization
#   ./scripts/create-branch.sh hotfix critical-security-patch

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored messages
error() {
    echo -e "${RED}✗ Error: $1${NC}" >&2
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Validate branch name format (lowercase, alphanumeric, hyphens, underscores)
validate_branch_name() {
    local name=$1
    if [[ ! "$name" =~ ^[a-z0-9_-]+$ ]]; then
        error "Branch name must contain only lowercase letters, numbers, hyphens, and underscores"
        return 1
    fi
    if [[ ${#name} -lt 3 ]]; then
        error "Branch name must be at least 3 characters long"
        return 1
    fi
    if [[ ${#name} -gt 100 ]]; then
        error "Branch name must be less than 100 characters"
        return 1
    fi
    return 0
}

# Validate ticket number format (HP-XXXXX)
validate_ticket_number() {
    local ticket=$1
    if [[ ! "$ticket" =~ ^HP-[0-9]{5}$ ]]; then
        error "Ticket number must be in format HP-XXXXX (e.g., HP-00901)"
        return 1
    fi
    return 0
}

# Check if branch already exists
branch_exists() {
    local branch=$1
    git show-ref --verify --quiet refs/heads/"$branch" || \
    git show-ref --verify --quiet refs/remotes/origin/"$branch"
}

# Show usage
show_usage() {
    echo "Usage: $0 <type> <name> [ticket-number]"
    echo ""
    echo "Branch Types:"
    echo "  feature      - New feature development"
    echo "  bugfix       - Bug fixes"
    echo "  enhancement  - Enhancements to existing features"
    echo "  hotfix       - Critical production fixes"
    echo ""
    echo "Examples:"
    echo "  $0 feature user-authentication HP-00901"
    echo "  $0 bugfix login-error"
    echo "  $0 enhancement performance-optimization"
    echo "  $0 hotfix critical-security-patch HP-01000"
    echo ""
    echo "Branch Naming Patterns:"
    echo "  With ticket:    <TICKET>/<type>/<name>/<name>"
    echo "  Without ticket: <type>/<name>"
    echo ""
}

# Main script
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    error "Invalid number of arguments"
    echo ""
    show_usage
    exit 1
fi

BRANCH_TYPE=$1
BRANCH_NAME=$2
TICKET_NUMBER=${3:-}

# Validate branch type
case "$BRANCH_TYPE" in
    feature|bugfix|enhancement|hotfix)
        ;;
    *)
        error "Invalid branch type: $BRANCH_TYPE"
        echo ""
        show_usage
        exit 1
        ;;
esac

# Validate branch name
if ! validate_branch_name "$BRANCH_NAME"; then
    exit 1
fi

# Validate ticket number if provided
if [ -n "$TICKET_NUMBER" ]; then
    if ! validate_ticket_number "$TICKET_NUMBER"; then
        exit 1
    fi
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ -z "$CURRENT_BRANCH" ]; then
    error "Could not determine current branch"
    exit 1
fi

# Check if working directory is clean
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    warning "Working directory has uncommitted changes"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Branch creation cancelled"
        exit 0
    fi
fi

# Construct new branch name based on pattern
if [ -n "$TICKET_NUMBER" ]; then
    # Pattern: HP-00901/feature/feature-name/feature-name
    NEW_BRANCH="${TICKET_NUMBER}/${BRANCH_TYPE}/${BRANCH_NAME}/${BRANCH_NAME}"
else
    # Pattern: feature/feature-name or bugfix/bugfix-name
    NEW_BRANCH="${BRANCH_TYPE}/${BRANCH_NAME}"
fi

# Check if branch already exists
if branch_exists "$NEW_BRANCH"; then
    error "Branch '$NEW_BRANCH' already exists"
    info "Existing branches:"
    git branch -a | grep -E "(feature|bugfix|enhancement|hotfix)" | head -5
    exit 1
fi

# Create and checkout new branch
info "Creating branch from: $CURRENT_BRANCH"
info "New branch name: $NEW_BRANCH"

if git checkout -b "$NEW_BRANCH" 2>/dev/null; then
    success "Branch '$NEW_BRANCH' created and checked out"
    info "Current branch: $(git rev-parse --abbrev-ref HEAD)"
    echo ""
    info "Next steps:"
    echo "  1. Make your changes"
    echo "  2. Commit: git add -A && git commit -m 'your message'"
    echo "  3. Push: git push -u origin $NEW_BRANCH"
    echo "  4. Or use logging: ./scripts/log-git-push.sh origin $NEW_BRANCH"
else
    error "Failed to create branch '$NEW_BRANCH'"
    exit 1
fi
