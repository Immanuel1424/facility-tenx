# Docker Containerization Guide

## 📋 Overview

This project uses a **multi-container architecture** with clear separation of concerns:

- **Backend**: NestJS API (Node.js/TypeScript)
- **Frontend**: Flutter Web (static files served via nginx)
- **Database**: PostgreSQL (external - not containerized)

## 🏗️ Architecture

```
┌─────────────────┐
│   Frontend      │  (nginx:alpine)
│   Port: 80      │
└────────┬────────┘
         │
         │ HTTP
         │
┌────────▼────────┐
│   Backend       │  (node:20-alpine)
│   Port: 3000    │
└────────┬────────┘
         │
         │ PostgreSQL (External)
         │
┌────────▼────────┐
│   PostgreSQL    │  (External Database)
│   (External)    │  RDS / Cloud SQL / On-premise
└─────────────────┘
```

## 📁 File Structure

```
facility-erp/
├── docker-compose.yml          # Development (uses local DB)
├── docker-compose.prod.yml     # Production (full containerized)
├── apps/
│   ├── backend/
│   │   ├── Dockerfile          # Multi-stage build
│   │   └── .dockerignore
│   └── frontend/
│       ├── Dockerfile          # Multi-stage build
│       ├── nginx.conf          # Nginx configuration
│       └── .dockerignore
└── .env                        # Environment variables (not in repo)
```

## 🚀 Quick Start

### Development Setup

Uses local PostgreSQL instance (via `host.docker.internal`):

```bash
# 1. Ensure PostgreSQL is running locally
# 2. Create .env file from env.example
cp env.example .env

# 3. Start services
docker-compose up -d

# 4. View logs
docker-compose logs -f

# 5. Stop services
docker-compose down
```

### Production Setup

Uses external PostgreSQL database:

```bash
# 1. Create .env file with production values
cp env.example .env

# 2. Configure database connection in .env
#    DB_HOST=your-database-host.com
#    DB_PASSWORD=your-secure-password
#    ... (other required variables)

# 3. Build and start services
docker-compose -f docker-compose.prod.yml up -d --build

# 4. View logs
docker-compose -f docker-compose.prod.yml logs -f

# 5. Stop services
docker-compose -f docker-compose.prod.yml down
```

## 🔧 Container Details

### Backend Container

**Image**: `node:20-alpine` (multi-stage build)

**Stages**:
1. **base**: Base Node.js image
2. **deps**: Production dependencies only
3. **builder**: Full dependencies + TypeScript compilation
4. **runner**: Final production image with minimal footprint

**Features**:
- ✅ Non-root user (`nestjs:nodejs`)
- ✅ Health checks via `/api/v1/health`
- ✅ Persistent uploads volume
- ✅ Optimized layer caching

**Port**: `3000`

**Volumes**:
- `backend_uploads`: `/app/uploads` (ticket attachments)

### Frontend Container

**Image**: `nginx:alpine` (serves Flutter web build)

**Stages**:
1. **build**: Flutter build using `ghcr.io/cirruslabs/flutter:stable`
2. **runner**: nginx serving static files

**Features**:
- ✅ SPA routing support (all routes → `index.html`)
- ✅ Gzip compression
- ✅ Static asset caching
- ✅ Security headers
- ✅ Health check endpoint

**Port**: `80`

### Database Configuration

**Type**: External PostgreSQL (not containerized)

**Connection**: Configured via environment variables:
- `DB_HOST`: Database hostname/IP
- `DB_PORT`: Database port (default: 5432)
- `DB_USER`: Database username
- `DB_PASSWORD`: Database password
- `DB_NAME`: Database name

**Examples**:
- Local: `DB_HOST=host.docker.internal`
- AWS RDS: `DB_HOST=your-db.region.rds.amazonaws.com`
- Google Cloud SQL: `DB_HOST=/cloudsql/project:region:instance`
- Azure: `DB_HOST=your-server.postgres.database.azure.com`

## 📝 Common Commands

### Build Commands

```bash
# Build all services
docker-compose build

# Build specific service
docker-compose build backend
docker-compose build frontend

# Build without cache (force rebuild)
docker-compose build --no-cache

# Production build
docker-compose -f docker-compose.prod.yml build
```

### Run Commands

```bash
# Start in detached mode
docker-compose up -d

# Start with logs
docker-compose up

# Start specific service
docker-compose up -d backend

# Production
docker-compose -f docker-compose.prod.yml up -d
```

### Debug Commands

```bash
# View logs
docker-compose logs -f
docker-compose logs -f backend
docker-compose logs -f frontend

# Execute commands in container
docker-compose exec backend sh
docker-compose exec frontend sh

# Check container status
docker-compose ps

# View resource usage
docker stats

# Inspect container
docker inspect facility-erp-backend-prod
```

### Cleanup Commands

```bash
# Stop containers (keeps volumes)
docker-compose down

# Stop and remove volumes (⚠️ deletes data)
docker-compose down -v

# Remove all containers, networks, volumes
docker-compose down -v --remove-orphans

# Clean up unused images
docker image prune -a

# Clean up everything (⚠️ destructive)
docker system prune -a --volumes
```

## 🔐 Security Best Practices

### ✅ Implemented

1. **Non-root users**: Both backend and frontend run as non-root
2. **Minimal base images**: Using Alpine Linux variants
3. **Health checks**: All services have health checks
4. **Environment variables**: Secrets via `.env` file (not in image)
5. **Multi-stage builds**: No build tools in production images
6. **Resource limits**: CPU and memory limits in production

### ⚠️ Required Actions

1. **Set strong secrets** in `.env`:
   ```bash
   # Generate secrets
   openssl rand -base64 32  # For JWT_ACCESS_SECRET
   openssl rand -base64 32  # For JWT_REFRESH_SECRET
   openssl rand -base64 32  # For SESSION_SECRET
   ```

2. **Secure `.env` file**:
   - Never commit `.env` to git
   - Use secrets management in production (AWS Secrets Manager, etc.)
   - Restrict file permissions: `chmod 600 .env`

3. **Database security**:
   - Use strong `DB_PASSWORD`
   - Use SSL/TLS for database connections (configure in TypeORM)
   - Restrict database access via firewall/security groups
   - Use connection pooling for production workloads
   - Consider using managed database services (RDS, Cloud SQL, etc.)

4. **Network security**:
   - Use reverse proxy (nginx/traefik) in front of containers
   - Enable HTTPS/TLS
   - Restrict CORS origins

## 🔄 Scaling

### Horizontal Scaling

**Backend** (stateless, can scale):
```bash
docker-compose -f docker-compose.prod.yml up -d --scale backend=3
```

**Frontend** (stateless, can scale):
```bash
docker-compose -f docker-compose.prod.yml up -d --scale frontend=3
```

**Note**: For production scaling, use:
- Load balancer (nginx, traefik, AWS ALB)
- Session store (Redis) if using sticky sessions
- Database connection pooling

### Vertical Scaling

Adjust resource limits in `docker-compose.prod.yml`:
```yaml
deploy:
  resources:
    limits:
      cpus: '4'      # Increase CPU
      memory: 4G     # Increase memory
```

## 🐛 Troubleshooting

### Backend won't start

```bash
# Check logs
docker-compose logs backend

# Common issues:
# 1. Database connection failed
#    → Check DB_HOST, DB_PASSWORD in .env
# 2. Missing environment variables
#    → Ensure JWT_ACCESS_SECRET, SESSION_SECRET are set
# 3. Port already in use
#    → Change BACKEND_PORT in .env
```

### Frontend shows blank page

```bash
# Check nginx logs
docker-compose logs frontend

# Verify build
docker-compose exec frontend ls -la /usr/share/nginx/html

# Check nginx config
docker-compose exec frontend cat /etc/nginx/conf.d/default.conf
```

### Database connection issues

```bash
# Check backend logs for connection errors
docker-compose logs backend

# Test connection from container
docker-compose exec backend sh
# Inside container:
# apk add postgresql-client
# psql -h $DB_HOST -U $DB_USER -d $DB_NAME

# Verify environment variables
docker-compose exec backend env | grep DB_

# Common issues:
# 1. DB_HOST not set or incorrect
# 2. Firewall blocking connection
# 3. Database credentials incorrect
# 4. Network connectivity (if remote DB)
```

### Health checks failing

```bash
# Manually test health endpoint
curl http://localhost:3000/api/v1/health
curl http://localhost/health

# Check container health status
docker inspect facility-erp-backend-prod | grep -A 10 Health
```

## 📊 Performance Optimization

### Build Time Optimization

1. **Layer caching**: Dependencies are cached separately from source code
2. **Multi-stage builds**: Only production artifacts in final image
3. **.dockerignore**: Excludes unnecessary files from build context

### Runtime Optimization

1. **Alpine images**: Smaller footprint (~5MB base vs ~100MB)
2. **Resource limits**: Prevents resource exhaustion
3. **Health checks**: Automatic restart on failure
4. **Volume mounts**: Persistent data outside containers

### Image Size Comparison

- **Backend**: ~150MB (with dependencies)
- **Frontend**: ~25MB (nginx + static files)
- **Database**: External (not included in container images)

## 🔄 Development Workflow

### Hot Reload (Development)

For development with hot reload, run services locally:

```bash
# Backend (local)
cd apps/backend
npm run start:dev

# Frontend (local)
cd apps/frontend
flutter run -d chrome
```

### Database Migrations

```bash
# Run migrations in container
docker-compose exec backend npm run migrate

# Or run locally (if DB is accessible)
cd apps/backend
npm run migrate
```

## 📚 Additional Resources

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [NestJS Deployment](https://docs.nestjs.com/recipes/deployment)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [PostgreSQL Docker](https://hub.docker.com/_/postgres)

## 🆘 Support

If you encounter issues:

1. Check logs: `docker-compose logs -f`
2. Verify environment variables: `docker-compose config`
3. Test health endpoints manually
4. Review this guide's troubleshooting section

---

**Last Updated**: 2025-01-14
**Maintained By**: DevOps Team

