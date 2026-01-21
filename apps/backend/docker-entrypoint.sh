#!/bin/sh
# Docker entrypoint script for backend
# Runs database migrations before starting the application

# Don't exit on error for migration check - we want to start the app even if migrations fail
# (migrations can be run manually later)

echo "=========================================="
echo "  Facility ERP Backend - Starting"
echo "=========================================="
echo ""

# Run database migrations
echo "🔍 Checking for pending database migrations..."
if [ -f "node_modules/.bin/ts-node" ]; then
  # Development mode - use ts-node
  npm run migrate:auto || {
    echo "⚠️  Migration check failed, but continuing..."
  }
else
  # Production mode - migrations should be run separately or via init container
  # For now, we'll skip automatic migrations in production Docker
  # Migrations should be run manually or via deployment script
  echo "ℹ️  Skipping automatic migrations in production container"
  echo "   Run migrations manually: npm run migrate:run"
  echo "   Or use deployment script to run migrations before starting containers"
fi

echo ""
echo "🚀 Starting application..."
echo ""

# Start the application
exec node dist/main.js
