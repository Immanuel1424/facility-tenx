# Multi-stage build for Flutter web
# Stage 1: Build stage using official Flutter image
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy dependency files first for better layer caching
COPY pubspec.yaml pubspec.lock ./

# Get dependencies (this layer will be cached if pubspec files don't change)
# Clean before pub get to reduce memory usage
RUN flutter clean || true && \
    flutter pub get

# Copy source code
COPY lib ./lib
COPY assets ./assets
COPY web ./web
COPY l10n.yaml ./

# Create minimal .env file if it doesn't exist (required by pubspec.yaml assets)
# Note: Runtime environment variables should be injected via nginx or build args
RUN if [ ! -f .env ]; then \
  echo "# Docker build .env file" > .env && \
  echo "# Runtime environment variables should be set via container environment" >> .env && \
  echo "API_BASE_URL=" >> .env && \
  echo "GEMINI_API_KEY=" >> .env; \
  fi

# Enable web platform if not already configured
RUN flutter create . --platforms web || true

# Build Flutter web app with release optimizations
# Set explicit memory limits for Dart compiler to reduce OOM errors
ENV DART_VM_OPTIONS="--old-gen-heap-size=2048"
# Clean before build to reduce memory usage
RUN flutter clean || true
RUN flutter build web --release --no-tree-shake-icons

# Stage 2: Production stage with nginx
FROM nginx:alpine

# Install curl for health checks and envsubst for environment variable substitution
RUN apk add --no-cache curl gettext

# Copy built web app to nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy entrypoint script to generate config.js at runtime
# Ensure Unix line endings (LF) and proper permissions for cross-platform compatibility
# This is critical when building on Mac (ARM64) and deploying on Linux (AMD64)
COPY docker-entrypoint.sh /tmp/docker-entrypoint.sh
RUN apk add --no-cache dos2unix && \
    # Convert line endings to Unix format (LF) - critical for cross-platform builds
    dos2unix /tmp/docker-entrypoint.sh && \
    mv /tmp/docker-entrypoint.sh /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh && \
    # Verify shebang is correct and file is executable
    head -1 /docker-entrypoint.sh | grep -q '^#!/' || (echo "ERROR: Invalid shebang" && exit 1) && \
    test -x /docker-entrypoint.sh || (echo "ERROR: Entrypoint not executable" && exit 1) && \
    # Clean up
    apk del dos2unix && \
    # Verify the script can be read by sh
    /bin/sh -n /docker-entrypoint.sh || (echo "ERROR: Entrypoint script syntax error" && exit 1)

# Create non-root user for nginx (nginx already runs as nginx user in alpine)
# But we ensure proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Expose port
EXPOSE 80

# Health check using curl
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Use entrypoint to generate config.js before starting nginx
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

