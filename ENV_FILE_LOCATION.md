# .env File Location Guide

## Where to Place the .env File

The `.env` file should be placed at the **project root**, **OUTSIDE** the Flutter app directory.

### Correct Location

```
facility-erp/                    ← Project root
├── .env                        ← ✅ PUT IT HERE (same level as docker-compose.prod.yml)
├── docker-compose.prod.yml
├── env.example
├── apps/
│   ├── backend/
│   └── frontend/               ← ❌ NOT HERE (inside Flutter app)
│       ├── lib/
│       ├── web/
│       └── ...
└── ...
```

### Why at the Root?

1. **Docker Compose** reads `.env` from the same directory as `docker-compose.prod.yml`
2. **Both services** (backend and frontend) need environment variables
3. **Single source of truth** for all environment configuration

## How to Create/Update .env File

### Step 1: Copy the Example File

```bash
# From project root
cp env.example .env
```

### Step 2: Edit .env File

```bash
# Edit the .env file
nano .env
# or
vim .env
# or use any text editor
```

### Step 3: Set API_BASE_URL

Add or update this line in your `.env` file:

```bash
API_BASE_URL=https://hsense-test-v1.helixsense.com/api/v1
```

### Complete .env File Structure

Your `.env` file should look like this:

```bash
# Database Configuration
DB_HOST=your-database-host.com
DB_USER=postgres
DB_PASSWORD=your_secure_password
DB_NAME=facility_erp
DB_PORT=5432

# Backend Configuration
NODE_ENV=production
BACKEND_PORT=3000

# JWT Configuration
JWT_ACCESS_SECRET=your_super_secret_access_key_min_32_chars
JWT_REFRESH_SECRET=your_super_secret_refresh_key_min_32_chars
SESSION_SECRET=your_super_secret_session_key_min_32_chars

# CORS Configuration
CORS_ORIGIN=https://hsense-test-v1.helixsense.com

# Frontend Configuration
FRONTEND_PORT=80
API_BASE_URL=https://hsense-test-v1.helixsense.com/api/v1

# Firebase Configuration (if using push notifications)
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com
```

## How It Works

1. **Docker Compose** reads `.env` from project root
2. **docker-compose.prod.yml** uses `${API_BASE_URL}` to get the value
3. **Frontend container** receives `API_BASE_URL` as environment variable
4. **docker-entrypoint.sh** reads `API_BASE_URL` and generates `config.js`
5. **Flutter app** reads `config.js` at runtime

## Verification

### Check if .env file exists:

```bash
# From project root
ls -la .env
```

### Check if API_BASE_URL is set:

```bash
# From project root
grep API_BASE_URL .env
```

### Test Docker Compose can read it:

```bash
# From project root
docker-compose -f docker-compose.prod.yml config | grep API_BASE_URL
```

## Important Notes

1. **Never commit .env to git** - It's already in `.gitignore`
2. **Use env.example as template** - Copy and customize
3. **Keep it at root** - Don't put it inside `apps/frontend/` or `apps/backend/`
4. **One .env per environment** - Different `.env` files for dev/staging/prod

## Troubleshooting

### Issue: Docker Compose can't find API_BASE_URL

**Solution:**
- Ensure `.env` file is at project root (same directory as `docker-compose.prod.yml`)
- Check file name is exactly `.env` (not `.env.txt` or `.env.prod`)
- Verify `API_BASE_URL=...` line exists in `.env`

### Issue: Container uses wrong API URL

**Solution:**
- Check container logs: `docker logs facility-erp-frontend-prod | grep API_BASE_URL`
- Verify `.env` file has correct value
- Restart container: `docker-compose -f docker-compose.prod.yml restart frontend`

### Issue: Changes to .env not taking effect

**Solution:**
- Restart containers: `docker-compose -f docker-compose.prod.yml down && docker-compose -f docker-compose.prod.yml up -d`
- Or recreate frontend: `docker-compose -f docker-compose.prod.yml up -d --force-recreate frontend`

