# Branch Creation Guide

## Overview

This project uses a standardized branch naming convention to maintain consistency and traceability. Use the `create-branch.sh` script to create new branches following the project's naming patterns.

## Branch Types

### 1. Feature Branches
For new feature development.

**Pattern with ticket:**
```
HP-00901/feature/feature-name/feature-name
```

**Pattern without ticket:**
```
feature/feature-name
```

**Example:**
```bash
./scripts/create-branch.sh feature user-authentication HP-00901
# Creates: HP-00901/feature/user-authentication/user-authentication
```

### 2. Bugfix Branches
For bug fixes and corrections.

**Pattern:**
```
bugfix/bugfix-name
```

**Example:**
```bash
./scripts/create-branch.sh bugfix login-error
# Creates: bugfix/login-error
```

### 3. Enhancement Branches
For improvements to existing features.

**Pattern:**
```
enhancement/enhancement-name
```

**Example:**
```bash
./scripts/create-branch.sh enhancement performance-optimization
# Creates: enhancement/performance-optimization
```

### 4. Hotfix Branches
For critical production fixes that need immediate attention.

**Pattern:**
```
hotfix/hotfix-name
```

**Example:**
```bash
./scripts/create-branch.sh hotfix critical-security-patch HP-01000
# Creates: HP-01000/hotfix/critical-security-patch/critical-security-patch
```

## Usage

### Basic Syntax

```bash
./scripts/create-branch.sh <type> <name> [ticket-number]
```

### Parameters

- **type**: Branch type (`feature`, `bugfix`, `enhancement`, `hotfix`)
- **name**: Branch name (lowercase, alphanumeric, hyphens, underscores only)
- **ticket-number** (optional): Ticket number in format `HP-XXXXX`

### Examples

#### Feature with Ticket
```bash
./scripts/create-branch.sh feature admin-dashboard HP-00901
# Creates: HP-00901/feature/admin-dashboard/admin-dashboard
```

#### Feature without Ticket
```bash
./scripts/create-branch.sh feature notification-system
# Creates: feature/notification-system
```

#### Bugfix
```bash
./scripts/create-branch.sh bugfix memory-leak-fix
# Creates: bugfix/memory-leak-fix
```

#### Enhancement
```bash
./scripts/create-branch.sh enhancement api-response-caching
# Creates: enhancement/api-response-caching
```

#### Hotfix with Ticket
```bash
./scripts/create-branch.sh hotfix payment-gateway-fix HP-01001
# Creates: HP-01001/hotfix/payment-gateway-fix/payment-gateway-fix
```

## Branch Naming Rules

1. **Lowercase only**: All branch names must be lowercase
2. **Alphanumeric + hyphens/underscores**: Only letters, numbers, hyphens (`-`), and underscores (`_`)
3. **Minimum length**: At least 3 characters
4. **Maximum length**: Less than 100 characters
5. **Descriptive**: Use clear, descriptive names that indicate the purpose
6. **No spaces**: Use hyphens or underscores instead of spaces

### Valid Names
- `user-authentication`
- `admin_dashboard`
- `fix-login-error`
- `performance_optimization`

### Invalid Names
- `UserAuthentication` (uppercase)
- `user authentication` (spaces)
- `user@auth` (special characters)
- `ab` (too short)

## Ticket Number Format

When using ticket numbers, follow the format: `HP-XXXXX`

- **Prefix**: `HP-` (fixed)
- **Number**: 5 digits (e.g., `00901`, `01000`)

### Valid Ticket Numbers
- `HP-00901`
- `HP-01000`
- `HP-12345`

### Invalid Ticket Numbers
- `HP-901` (not 5 digits)
- `HP-00901-1` (extra characters)
- `hp-00901` (lowercase)

## Workflow

### 1. Create Branch
```bash
./scripts/create-branch.sh feature new-feature HP-00901
```

### 2. Make Changes
```bash
# Edit files, make changes
git add -A
git commit -m "feat: implement new feature"
```

### 3. Push Branch
```bash
# Option 1: Direct push
git push -u origin HP-00901/feature/new-feature/new-feature

# Option 2: With logging (recommended)
./scripts/log-git-push.sh origin HP-00901/feature/new-feature/new-feature
```

### 4. Create Pull Request
Create a pull request from your feature branch to the target branch (usually `develop` or `master`).

## Branch Strategy

### Main Branches
- **master**: Production-ready code
- **develop**: Integration branch for features
- **bugfix**: Current bugfix branch

### Feature Branches
- Created from `develop` or current working branch
- Merged back to `develop` when complete
- Deleted after merge

### Bugfix Branches
- Created from `bugfix` or `develop`
- Merged back to source branch
- Can be merged to `master` for hotfixes

### Hotfix Branches
- Created from `master`
- Merged to both `master` and `develop`
- Critical fixes only

## Validation

The script automatically validates:
- ✅ Branch type is valid
- ✅ Branch name follows naming rules
- ✅ Ticket number format (if provided)
- ✅ Branch doesn't already exist
- ✅ Working directory status

## Error Handling

### Branch Already Exists
```bash
✗ Error: Branch 'feature/my-feature' already exists
ℹ Existing branches:
  feature/my-feature
  feature/other-feature
```

### Invalid Branch Name
```bash
✗ Error: Branch name must contain only lowercase letters, numbers, hyphens, and underscores
```

### Invalid Ticket Number
```bash
✗ Error: Ticket number must be in format HP-XXXXX (e.g., HP-00901)
```

### Uncommitted Changes
```bash
⚠ Working directory has uncommitted changes
Continue anyway? (y/N):
```

## Tips

1. **Use descriptive names**: `user-authentication` is better than `auth`
2. **Include ticket numbers**: Helps with traceability and project management
3. **Keep names concise**: Long names are harder to work with
4. **Use hyphens**: More readable than underscores in branch names
5. **Check existing branches**: Avoid duplicate or similar names

## Integration with Git Push Logging

After creating a branch, use the git push logging script when pushing:

```bash
# Create branch
./scripts/create-branch.sh feature my-feature HP-00901

# Make changes and commit
git add -A
git commit -m "feat: implement my feature"

# Push with logging
./scripts/log-git-push.sh origin HP-00901/feature/my-feature/my-feature
```

This ensures all branch operations are tracked in the git push logs.
