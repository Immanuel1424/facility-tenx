# Production Configuration Fix Required

## Issue Found

The application at `https://hsense-test-v1.helixsense.com` is working, but the `config.js` file is using `http://localhost:3000/api/v1` instead of the production backend URL.

## Current Status

✅ **Site is accessible**: https://hsense-test-v1.helixsense.com  
✅ **Flutter app loads**: Application initializes correctly  
✅ **Backend API works**: https://hsense-test-v1.helixsense.com/api/v1/health returns success  
❌ **API URL misconfigured**: Frontend is trying to use `http://localhost:3000/api/v1`

## Solution

Set the `API_BASE_URL` environment variable in your production deployment.

### Option 1: Update .env file

Add or update this line in your `.env` file on the production server:

```bash
API_BASE_URL=https://hsense-test-v1.helixsense.com/api/v1
```

### Option 2: Update docker-compose.prod.yml

Ensure the frontend service has:

```yaml
services:
  frontend:
    environment:
      API_BASE_URL: ${API_BASE_URL:-https://hsense-test-v1.helixsense.com/api/v1}
```

## Steps to Fix

1. **SSH into your production server**

2. **Edit your .env file**:
   ```bash
   nano .env
   # Add or update:
   API_BASE_URL=https://hsense-test-v1.helixsense.com/api/v1
   ```

3. **Restart the frontend container**:
   ```bash
   docker-compose -f docker-compose.prod.yml restart frontend
   ```

4. **Verify the fix**:
   ```bash
   # Check container logs
   docker logs facility-erp-frontend-prod | grep "config.js"
   
   # Verify config.js content
   curl https://hsense-test-v1.helixsense.com/config.js
   ```

   You should see:
   ```javascript
   window.__APP_CONFIG__ = {
     API_BASE_URL: 'https://hsense-test-v1.helixsense.com/api/v1'
   };
   ```

5. **Clear browser cache** and reload the page

## Verification

After fixing, check the browser console (F12) - you should see:
- `✅ config.js loaded successfully`
- `📋 API_BASE_URL: https://hsense-test-v1.helixsense.com/api/v1`
- `✅ Using runtime config API_BASE_URL: https://hsense-test-v1.helixsense.com/api/v1`

## Alternative: If Backend is on Different Domain

If your backend is on a different domain (e.g., `api.helixsense.com`), use:

```bash
API_BASE_URL=https://api.helixsense.com/api/v1
```

Make sure CORS is configured on the backend to allow requests from `https://hsense-test-v1.helixsense.com`.

