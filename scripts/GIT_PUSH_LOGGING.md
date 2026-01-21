# Git Push Logging System

## Overview

This project includes an automated logging system that tracks all git push operations. This helps maintain an audit trail of code deployments and changes.

## Usage

### Standard Workflow

When committing and pushing code, use the logging script:

```bash
# Stage changes
git add -A

# Commit changes
git commit -m "feat: your commit message"

# Push with logging
./scripts/log-git-push.sh origin <branch-name>
```

### Direct Git Push (with logging)

If you use `git push` directly, you can still log it by running the script:

```bash
# After a successful push
./scripts/log-git-push.sh origin <branch-name>
```

The script will detect the current branch and log the push operation.

## Log File Location

Logs are stored in: `.git-logs/git-push-YYYY-MM.log`

- **Directory**: `.git-logs/` (created automatically)
- **File Format**: Monthly rotation (one file per month)
- **Example**: `git-push-2025-01.log` for January 2025

## Log Entry Format

Each log entry includes:

```
==========================================
GIT PUSH LOG ENTRY
==========================================
Timestamp: 2025-01-14 10:30:45 UTC
Branch: bugfix
Remote: git@github.com:HelixSense/facility-erp.git
Author: John Doe <john@example.com>
Commit Hash: abc123def456...
Commits Pushed: 2
---
Commit Message(s):
  feat: update IAM services
  fix: resolve notification bug
---
Files Changed:
  apps/backend/src/modules/iam/services/user.service.ts
  apps/frontend/lib/src/features/iam/presentation/pages/user_detail_page.dart
---
Status: SUCCESS
Commit Hash After: abc123def456...
==========================================
```

## Logged Information

- **Timestamp**: Date and time with timezone
- **Branch**: Current branch name
- **Remote**: Git remote URL
- **Author**: Git user name and email
- **Commit Hash**: SHA of the commit(s) being pushed
- **Commits Pushed**: Number of commits in the push
- **Commit Messages**: All commit messages in the push
- **Files Changed**: List of modified files
- **Status**: SUCCESS or FAILED (with exit code)

## Benefits

1. **Audit Trail**: Track when and what code was pushed
2. **Debugging**: Identify which push introduced issues
3. **Compliance**: Maintain records for regulatory requirements
4. **Team Coordination**: See who pushed what and when

## Configuration

The log directory can be customized by setting the `GIT_PUSH_LOG_DIR` environment variable:

```bash
export GIT_PUSH_LOG_DIR=/custom/path/to/logs
./scripts/log-git-push.sh origin main
```

Default: `.git-logs/`

## Notes

- Log files are **not committed** to the repository (see `.gitignore`)
- Logs are stored locally for audit purposes
- The script handles both successful and failed push attempts
- Monthly log rotation keeps files manageable

## Troubleshooting

### Script Permission Denied

If you get a permission error, make the script executable:

```bash
chmod +x scripts/log-git-push.sh
```

### Log Directory Not Created

The script automatically creates the log directory. If it fails, check write permissions in the project root.

### Missing Information in Logs

The script uses standard git commands. Ensure you have:
- Git configured with user name and email
- Proper remote configuration
- Access to the remote repository
