# Production Quick Start Guide

## 🚀 Fastest Way to Deploy

### On Your Production Server

```bash
# 1. Create directory
mkdir -p /opt/facility-erp
cd /opt/facility-erp

# 2. Download docker-compose.prod.yml
# (Copy from your repository or use the one provided)

# 3. Create .env file with your configuration
nano .env
# (Add all required environment variables)

# 4. Deploy
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

# 5. Check status
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs -f
```

## 📝 Required .env Variables

**Minimum required:**

```bash
# Database
DB_HOST=your-database-host.com
DB_PASSWORD=your_secure_password

# Security
JWT_ACCESS_SECRET=<generate with: openssl rand -base64 32>
JWT_REFRESH_SECRET=<generate with: openssl rand -base64 32>
SESSION_SECRET=<generate with: openssl rand -base64 32>

# Frontend API Configuration
# For same-server deployment (backend and frontend on same host):
API_BASE_URL=http://backend:3000/api/v1
# For external backend:
# API_BASE_URL=https://api.yourdomain.com/api/v1
# For domain-based deployment:
# API_BASE_URL=https://yourdomain.com/api/v1
```

## 🎯 One-Line Deployment

```bash
# Using the deployment script
./scripts/deploy-production.sh
```

## 📋 Complete Checklist

1. ✅ Server has Docker & Docker Compose installed
2. ✅ PostgreSQL database is accessible
3. ✅ `.env` file created with all required variables
4. ✅ `docker-compose.prod.yml` configured
5. ✅ Images pulled from Docker Hub
6. ✅ Services started and healthy
7. ✅ Firewall configured (ports 80, 443)
8. ✅ Reverse proxy configured (optional but recommended)

## 🔗 Access Your Application

- **Frontend**: http://your-server-ip:80
- **Backend API**: http://your-server-ip:3000/api
- **Health Check**: http://your-server-ip:3000/api/v1/health

## 🔄 Update to Latest Version

```bash
# Pull latest images and restart
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

---

**For detailed instructions, see**: `PRODUCTION_DEPLOYMENT.md`
