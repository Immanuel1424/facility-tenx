# Containerization & Deployment Guide

This guide covers containerizing and deploying the Facility ERP application using Docker and Docker Compose.

## Architecture Overview

The application consists of three main components:

1. **PostgreSQL Database** - Data persistence layer
2. **NestJS Backend API** - RESTful API server
3. **Flutter Web Frontend** - SPA served via Nginx

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- 4GB+ RAM available
- 10GB+ disk space

## Quick Start

### 1. Environment Setup

Copy the example environment file and configure it:

```bash
cp env.example .env
```

Edit `.env` and set the following **REQUIRED** variables:

```env
# Generate strong secrets (minimum 32 characters)
JWT_ACCESS_SECRET=$(openssl rand -base64 32)
JWT_REFRESH_SECRET=$(openssl rand -base64 32)
SESSION_SECRET=$(openssl rand -base64 32)

# Database credentials
DB_PASSWORD=your_secure_password_here

# Email configuration
SMTP2GO_API_KEY=your_smtp2go_api_key
SMTP2GO_FROM_EMAIL=noreply@yourdomain.com
```

### 2. Build and Start Services

```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Check service status
docker-compose ps
```

### 3. Initialize Database

After the services are running, initialize the database:

```bash
# Run migrations
docker-compose exec backend npm run migrate

# Seed initial data (optional)
docker-compose exec backend npm run seed:all
```

### 4. Access Services

- **Frontend**: http://localhost:80
- **Backend API**: http://localhost:3000
- **API Documentation**: http://localhost:3000/api/docs
- **Health Check**: http://localhost:3000/api/v1/health

## Docker Compose Services

### PostgreSQL

- **Image**: `postgres:16-alpine`
- **Port**: 5432 (configurable via `DB_PORT`)
- **Data Volume**: `postgres_data` (persistent)
- **Health Check**: PostgreSQL readiness check

### Backend (NestJS)

- **Build Context**: `./apps/backend`
- **Port**: 3000 (configurable via `BACKEND_PORT`)
- **Uploads Volume**: `backend_uploads` (persistent)
- **Health Check**: HTTP GET `/api/v1/health`
- **Dependencies**: Waits for PostgreSQL to be healthy

### Frontend (Flutter Web)

- **Build Context**: `./apps/frontend`
- **Port**: 80 (configurable via `FRONTEND_PORT`)
- **Web Server**: Nginx Alpine
- **Health Check**: HTTP GET `/health`
- **Dependencies**: Waits for backend to start

## Environment Variables

### Database Configuration

| Variable      | Default        | Description                    |
| ------------- | -------------- | ------------------------------ |
| `DB_USER`     | `postgres`     | PostgreSQL username            |
| `DB_PASSWORD` | -              | PostgreSQL password (REQUIRED) |
| `DB_NAME`     | `facility_erp` | Database name                  |
| `DB_PORT`     | `5432`         | PostgreSQL port                |

### Backend Configuration

| Variable                      | Default      | Description                         |
| ----------------------------- | ------------ | ----------------------------------- |
| `NODE_ENV`                    | `production` | Node environment                    |
| `BACKEND_PORT`                | `3000`       | Backend API port                    |
| `JWT_ACCESS_SECRET`           | -            | JWT access token secret (REQUIRED)  |
| `JWT_ACCESS_EXPIRES_IN`       | `15m`        | Access token expiration             |
| `JWT_REFRESH_SECRET`          | -            | JWT refresh token secret (REQUIRED) |
| `JWT_REFRESH_EXPIRES_IN_DAYS` | `30`         | Refresh token expiration            |
| `SESSION_SECRET`              | -            | Session secret (REQUIRED)           |
| `CORS_ORIGIN`                 | -            | Comma-separated allowed origins     |

### Email Configuration (SMTP2GO)

| Variable               | Default                      | Description          |
| ---------------------- | ---------------------------- | -------------------- |
| `SMTP2GO_API_KEY`      | -                            | SMTP2GO API key      |
| `SMTP2GO_API_BASE_URL` | `https://api.smtp2go.com/v3` | SMTP2GO API base URL |
| `SMTP2GO_FROM_EMAIL`   | -                            | Sender email address |
| `SMTP2GO_FROM_NAME`    | `Facility ERP`               | Sender display name  |

### Frontend Configuration

| Variable        | Default | Description              |
| --------------- | ------- | ------------------------ |
| `FRONTEND_PORT` | `80`    | Frontend web server port |

## Production Deployment

### 1. Security Hardening

#### Generate Strong Secrets

```bash
# Generate JWT secrets
openssl rand -base64 32  # For JWT_ACCESS_SECRET
openssl rand -base64 32  # For JWT_REFRESH_SECRET
openssl rand -base64 32  # For SESSION_SECRET

# Generate database password
openssl rand -base64 24  # For DB_PASSWORD
```

#### Update CORS Origins

Set `CORS_ORIGIN` to your production domain(s):

```env
CORS_ORIGIN=https://yourdomain.com,https://www.yourdomain.com
```

#### Use HTTPS

In production, use a reverse proxy (Nginx/Traefik) with SSL certificates:

```nginx
# Example Nginx reverse proxy configuration
server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://frontend:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api {
        proxy_pass http://backend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 2. Resource Limits

Add resource limits to `docker-compose.yml`:

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: "2"
          memory: 2G
        reservations:
          cpus: "1"
          memory: 1G

  postgres:
    deploy:
      resources:
        limits:
          cpus: "1"
          memory: 1G
        reservations:
          cpus: "0.5"
          memory: 512M
```

### 3. Database Backups

Set up automated backups:

```bash
# Backup script
#!/bin/bash
docker-compose exec -T postgres pg_dump -U postgres facility_erp > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore
docker-compose exec -T postgres psql -U postgres facility_erp < backup_file.sql
```

### 4. Logging

Configure log rotation:

```yaml
services:
  backend:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## Development vs Production

### Development

Use `docker-compose.local.yml` for local development:

```bash
docker-compose -f docker-compose.local.yml up
```

### Production

Use `docker-compose.yml` for production:

```bash
docker-compose up -d
```

## Troubleshooting

### Backend Startup Issues

If the backend container fails to start or crashes immediately:

**Common Issue: Permission Denied Error**
- **Symptom:** Container exits with `EACCES: permission denied, open 'openapi-v1.json'`
- **Solution:** See detailed fix documentation: [`apps/backend/DOCKER_STARTUP_FIX.md`](../apps/backend/DOCKER_STARTUP_FIX.md)
- **Quick Fix:** The issue has been resolved in the codebase. Rebuild the backend image:
  ```bash
  docker-compose build backend
  docker-compose up -d backend
  ```

### Check Service Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f postgres
docker-compose logs -f frontend
```

### Check Service Health

```bash
# Check health status
docker-compose ps

# Manual health check
curl http://localhost:3000/api/v1/health
curl http://localhost/health
```

### Database Connection Issues

```bash
# Test database connection
docker-compose exec backend node -e "require('pg').connect('postgresql://postgres:password@postgres:5432/facility_erp', (err) => console.log(err || 'Connected'))"

# Access PostgreSQL CLI
docker-compose exec postgres psql -U postgres -d facility_erp
```

### Rebuild Services

```bash
# Rebuild specific service
docker-compose build backend
docker-compose up -d backend

# Rebuild all services
docker-compose build --no-cache
docker-compose up -d
```

### Clean Up

```bash
# Stop and remove containers
docker-compose down

# Remove volumes (WARNING: Deletes data)
docker-compose down -v

# Remove images
docker-compose down --rmi all
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build and push images
        run: |
          docker-compose build
          # Push to registry if needed

      - name: Deploy
        run: |
          docker-compose pull
          docker-compose up -d
          docker-compose exec backend npm run migrate
```

## Monitoring

### Health Checks

All services include health checks. Monitor them:

```bash
# Check health status
docker inspect --format='{{.State.Health.Status}}' facility-erp-backend
```

### Resource Usage

```bash
# Container stats
docker stats

# Specific container
docker stats facility-erp-backend
```

## Scaling

### Horizontal Scaling (Backend)

```yaml
services:
  backend:
    deploy:
      replicas: 3
```

Note: Ensure session storage is externalized (Redis) for multiple instances.

### Database Connection Pooling

Configure TypeORM connection pool in `typeorm.config.ts`:

```typescript
max: 20, // Maximum connections
min: 5,  // Minimum connections
```

## Support

For issues or questions:

1. Check service logs: `docker-compose logs -f`
2. Verify environment variables: `docker-compose config`
3. Check health endpoints
4. Review this documentation
