#!/bin/bash

# Git Push Logger Script
# Logs all git push operations with detailed information

set -e

LOG_DIR="${GIT_PUSH_LOG_DIR:-.git-logs}"
LOG_FILE="${LOG_DIR}/git-push-$(date +%Y-%m).log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S %Z')

# Create log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Get current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Get commit hash before push
COMMIT_BEFORE=$(git rev-parse HEAD)

# Get remote URL
REMOTE_URL=$(git config --get remote.origin.url)

# Get list of files changed in the commit(s) being pushed
FILES_CHANGED=$(git diff --name-only origin/${BRANCH}..HEAD 2>/dev/null || git diff --name-only HEAD~1..HEAD 2>/dev/null || echo "N/A")

# Get commit message(s)
COMMIT_MESSAGES=$(git log --format="%s" origin/${BRANCH}..HEAD 2>/dev/null || git log -1 --format="%s" 2>/dev/null || echo "N/A")

# Get commit count
COMMIT_COUNT=$(git rev-list --count origin/${BRANCH}..HEAD 2>/dev/null || echo "1")

# Get author info
AUTHOR_NAME=$(git config user.name || echo "Unknown")
AUTHOR_EMAIL=$(git config user.email || echo "Unknown")

# Log the push attempt
{
    echo "=========================================="
    echo "GIT PUSH LOG ENTRY"
    echo "=========================================="
    echo "Timestamp: ${TIMESTAMP}"
    echo "Branch: ${BRANCH}"
    echo "Remote: ${REMOTE_URL}"
    echo "Author: ${AUTHOR_NAME} <${AUTHOR_EMAIL}>"
    echo "Commit Hash: ${COMMIT_BEFORE}"
    echo "Commits Pushed: ${COMMIT_COUNT}"
    echo "---"
    echo "Commit Message(s):"
    echo "${COMMIT_MESSAGES}" | sed 's/^/  /'
    echo "---"
    echo "Files Changed:"
    echo "${FILES_CHANGED}" | sed 's/^/  /'
    echo "---"
    echo ""
} >> "${LOG_FILE}"

# Execute the actual git push
if git push "$@"; then
    # Get commit hash after push
    COMMIT_AFTER=$(git rev-parse HEAD)
    
    # Log success
    {
        echo "Status: SUCCESS"
        echo "Commit Hash After: ${COMMIT_AFTER}"
        echo "=========================================="
        echo ""
    } >> "${LOG_FILE}"
    
    echo "✓ Push successful. Logged to ${LOG_FILE}"
    exit 0
else
    EXIT_CODE=$?
    # Log failure
    {
        echo "Status: FAILED (Exit Code: ${EXIT_CODE})"
        echo "=========================================="
        echo ""
    } >> "${LOG_FILE}"
    
    echo "✗ Push failed. Logged to ${LOG_FILE}"
    exit $EXIT_CODE
fi
