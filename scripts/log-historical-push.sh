#!/bin/bash

# Helper script to log a historical git push
# Usage: ./scripts/log-historical-push.sh <commit-hash> <branch-name>

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <commit-hash> <branch-name>"
    echo "Example: $0 679ebbf bugfix"
    exit 1
fi

COMMIT_HASH=$1
BRANCH=$2

LOG_DIR="${GIT_PUSH_LOG_DIR:-.git-logs}"
LOG_FILE="${LOG_DIR}/git-push-$(date +%Y-%m).log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S %Z')

# Create log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Get remote URL
REMOTE_URL=$(git config --get remote.origin.url)

# Get commit message
COMMIT_MESSAGE=$(git log -1 --format="%s" "${COMMIT_HASH}" 2>/dev/null || echo "N/A")

# Get files changed
FILES_CHANGED=$(git diff --name-only "${COMMIT_HASH}~1..${COMMIT_HASH}" 2>/dev/null || echo "N/A")

# Get author info
AUTHOR_NAME=$(git log -1 --format="%an" "${COMMIT_HASH}" 2>/dev/null || echo "Unknown")
AUTHOR_EMAIL=$(git log -1 --format="%ae" "${COMMIT_HASH}" 2>/dev/null || echo "Unknown")

# Log the historical push
{
    echo "=========================================="
    echo "GIT PUSH LOG ENTRY (HISTORICAL)"
    echo "=========================================="
    echo "Timestamp: ${TIMESTAMP}"
    echo "Branch: ${BRANCH}"
    echo "Remote: ${REMOTE_URL}"
    echo "Author: ${AUTHOR_NAME} <${AUTHOR_EMAIL}>"
    echo "Commit Hash: ${COMMIT_HASH}"
    echo "Commits Pushed: 1"
    echo "---"
    echo "Commit Message(s):"
    echo "  ${COMMIT_MESSAGE}"
    echo "---"
    echo "Files Changed:"
    echo "${FILES_CHANGED}" | sed 's/^/  /'
    echo "---"
    echo "Status: SUCCESS (Historical Entry)"
    echo "=========================================="
    echo ""
} >> "${LOG_FILE}"

echo "✓ Historical push logged to ${LOG_FILE}"
