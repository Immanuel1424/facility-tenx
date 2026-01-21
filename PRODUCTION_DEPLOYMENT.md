# Production Deployment Guide

## 📋 Prerequisites

### 1. Server Requirements
- **OS**: Linux (Ubuntu 20.04+ recommended)
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **RAM**: Minimum 2GB (4GB+ recommended)
- **CPU**: 2+ cores
- **Disk**: 20GB+ free space

### 2. External Services
- **PostgreSQL Database**: Running and accessible
- **Domain Name**: (Optional) For production URL
- **SSL Certificate**: (Optional) For HTTPS

## 🚀 Quick Start

### Step 1: Prepare Server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

### Step 2: Create Project Directory

```bash
# Create directory
sudo mkdir -p /opt/facility-erp
sudo chown $USER:$USER /opt/facility-erp
cd /opt/facility-erp
```

### Step 3: Create Production Files

Create `docker-compose.prod.yml`:

```yaml
services:
  backend:
    image: hsense/facility-erp-backend:1.0.0
    container_name: facility-erp-backend-prod
    environment:
      DB_HOST: ${DB_HOST}
      DB_PORT: ${DB_PORT:-5432}
      DB_USER: ${DB_USER:-postgres}
      DB_PASSWORD: ${DB_PASSWORD}
      DB_NAME: ${DB_NAME:-facility_erp}
      NODE_ENV: production
      PORT: ${BACKEND_PORT:-3000}
      JWT_ACCESS_SECRET: ${JWT_ACCESS_SECRET}
      JWT_ACCESS_EXPIRES_IN: ${JWT_ACCESS_EXPIRES_IN:-15m}
      JWT_REFRESH_SECRET: ${JWT_REFRESH_SECRET}
      JWT_REFRESH_EXPIRES_IN_DAYS: ${JWT_REFRESH_EXPIRES_IN_DAYS:-30}
      SESSION_SECRET: ${SESSION_SECRET}
      CORS_ORIGIN: ${CORS_ORIGIN}
      AWS_SES_ACCESS_KEY_ID: ${AWS_SES_ACCESS_KEY_ID}
      AWS_SES_SECRET_ACCESS_KEY: ${AWS_SES_SECRET_ACCESS_KEY}
      AWS_SES_REGION: ${AWS_SES_REGION:-ap-south-1}
      AWS_SES_FROM_EMAIL: ${AWS_SES_FROM_EMAIL}
      AWS_SES_FROM_NAME: ${AWS_SES_FROM_NAME:-Helixsense}
      FIREBASE_PROJECT_ID: ${FIREBASE_PROJECT_ID}
      FIREBASE_PRIVATE_KEY: ${FIREBASE_PRIVATE_KEY}
      FIREBASE_CLIENT_EMAIL: ${FIREBASE_CLIENT_EMAIL}
    ports:
      - "${BACKEND_PORT:-3000}:3000"
    volumes:
      - backend_uploads:/app/uploads
    extra_hosts:
      - "host.docker.internal:host-gateway"
    networks:
      - facility-erp-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/v1/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 40s
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          cpus: '0.25'
          memory: 256M

  frontend:
    image: hsense/facility-erp-frontend:1.0.0
    container_name: facility-erp-frontend-prod
    ports:
      - "${FRONTEND_PORT:-80}:80"
    depends_on:
      - backend
    networks:
      - facility-erp-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 256M
        reservations:
          cpus: '0.1'
          memory: 64M

volumes:
  backend_uploads:
    driver: local
    name: facility-erp-backend-uploads

networks:
  facility-erp-network:
    driver: bridge
    name: facility-erp-network
```

### Step 4: Configure Environment Variables

Create `.env` file:

```bash
# Database Configuration
DB_HOST=your-database-host.com
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_secure_password
DB_NAME=facility_erp

# Backend Configuration
BACKEND_PORT=3000
NODE_ENV=production

# JWT Configuration (REQUIRED - Generate strong secrets)
JWT_ACCESS_SECRET=your_super_secret_access_key_min_32_chars
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_SECRET=your_super_secret_refresh_key_min_32_chars
JWT_REFRESH_EXPIRES_IN_DAYS=30

# Session Secret (REQUIRED - Generate strong secret)
SESSION_SECRET=your_super_secret_session_key_min_32_chars

# CORS Configuration
CORS_ORIGIN=https://yourdomain.com,https://www.yourdomain.com

# Email Configuration (AWS SES)
AWS_SES_ACCESS_KEY_ID=your_aws_ses_access_key_id
AWS_SES_SECRET_ACCESS_KEY=your_aws_ses_secret_access_key
AWS_SES_REGION=ap-south-1
AWS_SES_FROM_EMAIL=no-reply@yourdomain.com
AWS_SES_FROM_NAME=Helixsense

# Firebase Configuration (for Push Notifications)
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY=your-firebase-private-key
FIREBASE_CLIENT_EMAIL=your-service-account-email@project-id.iam.gserviceaccount.com

# Frontend Port
FRONTEND_PORT=80

# Gemini AI API Key (OPTIONAL - for AI ticket analysis feature)
# Get your key from: https://makersuite.google.com/app/apikey
# This key is used by the backend service, not the frontend
GEMINI_API_KEY=your_gemini_api_key_here
```

**Generate secrets:**
```bash
# Generate JWT secrets
openssl rand -base64 32  # For JWT_ACCESS_SECRET
openssl rand -base64 32  # For JWT_REFRESH_SECRET
openssl rand -base64 32  # For SESSION_SECRET
```

**Secure the .env file:**
```bash
chmod 600 .env
```

### Step 5: Deploy

```bash
# Pull latest images
docker-compose -f docker-compose.prod.yml pull

# Start services
docker-compose -f docker-compose.prod.yml up -d

# Check status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f
```

## 🔒 Security Best Practices

### 1. Firewall Configuration

```bash
# Allow only necessary ports
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP (or 443 for HTTPS)
sudo ufw allow 3000/tcp  # Backend (only if needed externally)
sudo ufw enable
```

### 2. Use Reverse Proxy (Recommended)

**Nginx Configuration** (`/etc/nginx/sites-available/facility-erp`):

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000" always;

    # Frontend
    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. Database Security

- Use SSL/TLS for database connections
- Restrict database access via firewall
- Use strong passwords
- Enable connection pooling
- Regular backups

### 4. Environment Variables

- Never commit `.env` to git
- Use secrets management (AWS Secrets Manager, HashiCorp Vault)
- Rotate secrets regularly
- Restrict file permissions: `chmod 600 .env`

## 📊 Monitoring & Maintenance

### Health Checks

```bash
# Check container health
docker-compose -f docker-compose.prod.yml ps

# Test backend health
curl http://localhost:3000/api/v1/health

# Test frontend health
curl http://localhost/health
```

### Logs

```bash
# View all logs
docker-compose -f docker-compose.prod.yml logs -f

# View specific service logs
docker-compose -f docker-compose.prod.yml logs -f backend
docker-compose -f docker-compose.prod.yml logs -f frontend

# View last 100 lines
docker-compose -f docker-compose.prod.yml logs --tail=100
```

### Updates

```bash
# Pull new version
docker-compose -f docker-compose.prod.yml pull

# Update to new version (edit docker-compose.prod.yml first)
docker-compose -f docker-compose.prod.yml up -d

# Or update specific service
docker-compose -f docker-compose.prod.yml up -d backend
```

### Backup

```bash
# Backup uploads volume
docker run --rm -v facility-erp-backend-uploads:/data -v $(pwd):/backup \
  alpine tar czf /backup/uploads-backup-$(date +%Y%m%d).tar.gz -C /data .

# Backup database (external - use pg_dump)
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > backup-$(date +%Y%m%d).sql
```

## 🔄 Update Process

### Update to New Version

1. **Update docker-compose.prod.yml**:
   ```yaml
   backend:
     image: hsense/facility-erp-backend:1.0.1  # New version
   frontend:
     image: hsense/facility-erp-frontend:1.0.1  # New version
   ```

2. **Pull and restart**:
   ```bash
   docker-compose -f docker-compose.prod.yml pull
   docker-compose -f docker-compose.prod.yml up -d
   ```

3. **Verify**:
   ```bash
   docker-compose -f docker-compose.prod.yml ps
   docker-compose -f docker-compose.prod.yml logs -f
   ```

## 🐛 Troubleshooting

### Backend won't start

```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs backend

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
docker-compose -f docker-compose.prod.yml logs frontend

# Verify build
docker-compose -f docker-compose.prod.yml exec frontend ls -la /usr/share/nginx/html
```

### Database connection issues

```bash
# Test connection from server
psql -h $DB_HOST -U $DB_USER -d $DB_NAME

# Check firewall
sudo ufw status

# Verify environment variables
docker-compose -f docker-compose.prod.yml exec backend env | grep DB_
```

## 📈 Scaling

### Horizontal Scaling

```bash
# Scale backend (requires load balancer)
docker-compose -f docker-compose.prod.yml up -d --scale backend=3

# Scale frontend
docker-compose -f docker-compose.prod.yml up -d --scale frontend=3
```

**Note**: For production scaling, use:
- Load balancer (nginx, AWS ALB, etc.)
- Session store (Redis) if using sticky sessions
- Database connection pooling

## 🔐 Production Checklist

- [ ] Strong secrets generated and set in `.env`
- [ ] `.env` file permissions set to `600`
- [ ] Database SSL/TLS enabled
- [ ] Firewall configured
- [ ] Reverse proxy configured (nginx/traefik)
- [ ] SSL certificate installed
- [ ] Health checks passing
- [ ] Logs being monitored
- [ ] Backup strategy in place
- [ ] Resource limits configured
- [ ] Auto-restart enabled (`restart: unless-stopped`)

## 📞 Support

For issues:
1. Check logs: `docker-compose -f docker-compose.prod.yml logs -f`
2. Verify health: `curl http://localhost:3000/api/v1/health`
3. Check container status: `docker-compose -f docker-compose.prod.yml ps`

---

**Last Updated**: 2025-12-31
**Version**: 1.0.0

