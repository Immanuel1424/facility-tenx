# Docker Build & Run Guide

## Prerequisites

1. **Docker & Docker Compose** installed
2. **`.env` file** configured (copy from `env.example` and fill in values)

## Quick Start

### 1. Build Both Images

Build both backend and frontend images:

```bash
docker-compose build
```

Or build specific service:

```bash
# Build only backend
docker-compose build backend

# Build only frontend
docker-compose build frontend
```

### 2. Build and Run in One Command

```bash
docker-compose up --build
```

### 3. Run in Detached Mode (Background)

```bash
docker-compose up -d --build
```

## Detailed Commands

### Build Images Only (No Run)

```bash
# Build all services
docker-compose build

# Build with no cache (fresh build)
docker-compose build --no-cache

# Build specific service
docker-compose build backend frontend
```

### Run Containers

```bash
# Start containers (uses existing images)
docker-compose up

# Start in background
docker-compose up -d

# Start with rebuild
docker-compose up --build

# Start specific services
docker-compose up backend frontend
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Stop Containers

```bash
# Stop all
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Check Status

```bash
# List running containers
docker-compose ps

# Check health
docker-compose ps --format json | jq '.[] | {name: .Name, status: .State, health: .Health}'
```

## Environment Variables

Ensure your `.env` file has all required variables:

**Required:**

- `JWT_ACCESS_SECRET` (min 32 chars)
- `JWT_REFRESH_SECRET` (min 32 chars)
- `SESSION_SECRET` (min 32 chars)
- `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`

**Optional:**

- `SMTP2GO_API_KEY` (for email)
- `CORS_ORIGIN` (comma-separated URLs)
- `OIDC_*` (for OAuth)

## Troubleshooting

### Rebuild from Scratch

```bash
# Remove containers, volumes, and images
docker-compose down -v --rmi all

# Rebuild everything
docker-compose build --no-cache

# Start fresh
docker-compose up -d
```

### Check Build Logs

```bash
# Build with verbose output
docker-compose build --progress=plain
```

### Inspect Images

```bash
# List images
docker images | grep facility-erp

# Inspect image
docker inspect facility-erp-backend
docker inspect facility-erp-frontend
```

### Access Container Shell

```bash
# Backend
docker exec -it facility-erp-backend sh

# Frontend
docker exec -it facility-erp-frontend sh
```

## Production Deployment

For production, tag and push images to a registry:

```bash
# Tag images
docker tag facility-erp-backend:latest your-registry/facility-erp-backend:v1.0.0
docker tag facility-erp-frontend:latest your-registry/facility-erp-frontend:v1.0.0

# Push to registry
docker push your-registry/facility-erp-backend:v1.0.0
docker push your-registry/facility-erp-frontend:v1.0.0
```

## Ports

- **Backend**: `http://localhost:3000` (or `BACKEND_PORT` from `.env`)
- **Frontend**: `http://localhost:80` (or `FRONTEND_PORT` from `.env`)

## Health Checks

Both services have health checks configured:

- Backend: `http://localhost:3000/api/v1/health`
- Frontend: `http://localhost/health`

Check health status:

```bash
docker-compose ps
```
