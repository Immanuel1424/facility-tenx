# Scripts Quick Reference

## Git Operations

### Create Branch
```bash
# Feature with ticket
./scripts/create-branch.sh feature feature-name HP-00901

# Feature without ticket
./scripts/create-branch.sh feature feature-name

# Bugfix
./scripts/create-branch.sh bugfix bug-name

# Enhancement
./scripts/create-branch.sh enhancement enhancement-name

# Hotfix
./scripts/create-branch.sh hotfix hotfix-name HP-01000
```

### Commit and Push (with logging)
```bash
git add -A
git commit -m "feat: your message"
./scripts/log-git-push.sh origin <branch-name>
```

### Log Historical Push
```bash
./scripts/log-historical-push.sh <commit-hash> <branch-name>
```

## Branch Naming Patterns

| Type | With Ticket | Without Ticket |
|------|-------------|----------------|
| Feature | `HP-00901/feature/name/name` | `feature/name` |
| Bugfix | `HP-00901/bugfix/name/name` | `bugfix/name` |
| Enhancement | `HP-00901/enhancement/name/name` | `enhancement/name` |
| Hotfix | `HP-00901/hotfix/name/name` | `hotfix/name` |

## Rules

- ✅ Lowercase only
- ✅ Alphanumeric + hyphens/underscores
- ✅ 3-100 characters
- ✅ Descriptive names
- ❌ No uppercase
- ❌ No spaces
- ❌ No special characters

## Ticket Format

- Format: `HP-XXXXX`
- Example: `HP-00901`, `HP-01000`
