# Multi-stage build for NestJS backend
# Stage 1: Base image
FROM node:20-alpine AS base

# Stage 2: Production dependencies
FROM base AS deps
WORKDIR /app

# Copy only package files for better layer caching
COPY package*.json ./
COPY tsconfig*.json ./

# Install build dependencies for native modules
RUN apk add --no-cache python3 make g++

# Install production dependencies (allow scripts for native modules like bcrypt)
RUN npm ci --only=production && \
    npm cache clean --force

# Stage 3: Build stage
FROM base AS builder
WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig*.json ./
COPY tsconfig.build.json ./

# Install build dependencies for native modules (bcrypt, etc.)
RUN apk add --no-cache python3 make g++

# Install all dependencies (including dev dependencies for build)
# Allow scripts to run for native modules compilation
RUN npm ci

# Copy source code
COPY src ./src

# Copy scripts needed for migrations
COPY scripts/migrations ./scripts/migrations

# Build the application
RUN npm run build

# Stage 4: Production runtime
FROM base AS runner
WORKDIR /app

# Set production environment
ENV NODE_ENV=production

# Install curl for health checks (lighter than wget)
RUN apk add --no-cache curl

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nestjs

# Copy production dependencies
COPY --from=deps --chown=nestjs:nodejs /app/node_modules ./node_modules

# Rebuild native modules for Alpine Linux (bcrypt, etc.)
# This ensures native modules are compiled for the correct platform
RUN npm rebuild bcrypt --build-from-source || true

# Copy built application
COPY --from=builder --chown=nestjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nestjs:nodejs /app/package*.json ./

# Copy migration files and scripts (for manual migration execution if needed)
COPY --from=builder --chown=nestjs:nodejs /app/scripts/migrations ./scripts/migrations
COPY --from=builder --chown=nestjs:nodejs /app/tsconfig*.json ./

# Create uploads directory with proper permissions
RUN mkdir -p /app/uploads/tickets && \
    chown -R nestjs:nodejs /app/uploads && \
    chmod -R 755 /app/uploads

# Switch to non-root user
USER nestjs

# Expose port
EXPOSE 3000

# Health check using curl (more reliable than wget)
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3000/api/v1/health || exit 1

# Copy entrypoint script
COPY --chown=nestjs:nodejs docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use entrypoint script (runs migrations check, then starts app)
ENTRYPOINT ["/entrypoint.sh"]
