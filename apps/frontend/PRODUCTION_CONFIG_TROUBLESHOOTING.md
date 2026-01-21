# Production Configuration Troubleshooting

## Issue: Application Using Localhost URL in Production

If your application is still using `http://localhost:3000/api/v1` after deployment, follow these steps:

## Step 1: Verify Environment Variable is Set

Check your `.env` file or `docker-compose.prod.yml`:

```bash
# In your .env file, set:
API_BASE_URL=http://backend:3000/api/v1
# OR for external backend:
API_BASE_URL=https://api.yourdomain.com/api/v1
```

**Important**: The URL must be accessible from the **browser**, not just from Docker network.

- ✅ `http://backend:3000/api/v1` - Works if backend and frontend are in same Docker network
- ✅ `https://api.yourdomain.com/api/v1` - Works for external/public backend
- ❌ `http://localhost:3000/api/v1` - Will NOT work (localhost refers to user's browser, not server)

## Step 2: Check Container Logs

After starting the container, check if config.js was generated:

```bash
docker logs facility-erp-frontend-prod
```

You should see:
```
🔧 Generating config.js with API_BASE_URL=http://backend:3000/api/v1
✅ config.js created successfully
📄 config.js contents:
window.__APP_CONFIG__ = {
  API_BASE_URL: 'http://backend:3000/api/v1'
};
```

## Step 3: Verify config.js is Accessible

Check if config.js is being served by nginx:

```bash
# From inside the container
docker exec facility-erp-frontend-prod cat /usr/share/nginx/html/config.js

# Or from browser
curl http://your-server-ip/config.js
```

You should see the JavaScript configuration object.

## Step 4: Check Browser Console

Open browser developer tools (F12) and check the console. You should see:

```
🔧 Default config set: {API_BASE_URL: "http://localhost:3000/api/v1"}
✅ config.js loaded successfully
📋 Final config after loading: {API_BASE_URL: "http://backend:3000/api/v1"}
📋 API_BASE_URL: http://backend:3000/api/v1
```

If you see "⚠️ config.js not found", the file wasn't generated or isn't accessible.

## Step 5: Verify Docker Compose Configuration

Ensure your `docker-compose.prod.yml` has:

```yaml
services:
  frontend:
    environment:
      API_BASE_URL: ${API_BASE_URL:-http://backend:3000/api/v1}
```

And your `.env` file has:

```bash
API_BASE_URL=http://backend:3000/api/v1
```

## Common Issues

### Issue 1: Backend URL Not Accessible from Browser

**Problem**: Using `http://backend:3000/api/v1` but backend is not accessible from browser.

**Solution**: 
- If backend and frontend are on same server, use the public IP/domain
- If using reverse proxy, use the proxy URL
- Example: `API_BASE_URL=https://yourdomain.com/api/v1`

### Issue 2: CORS Errors

**Problem**: Browser shows CORS errors when trying to connect.

**Solution**: Ensure backend `CORS_ORIGIN` includes your frontend URL:
```bash
CORS_ORIGIN=http://your-frontend-domain.com,https://your-frontend-domain.com
```

### Issue 3: config.js Not Generated

**Problem**: Container logs show config.js was not created.

**Solution**: 
1. Check entrypoint script has execute permissions
2. Verify environment variable is set
3. Check container has write permissions to `/usr/share/nginx/html`

### Issue 4: config.js Loads But Still Uses Localhost

**Problem**: Browser console shows config.js loaded but app still uses localhost.

**Solution**: 
1. Clear browser cache
2. Check browser console for JavaScript errors
3. Verify `window.__APP_CONFIG__` is set correctly (check in console: `window.__APP_CONFIG__`)

## Debugging Commands

```bash
# Check if environment variable is set in container
docker exec facility-erp-frontend-prod env | grep API_BASE_URL

# Check if config.js exists
docker exec facility-erp-frontend-prod ls -la /usr/share/nginx/html/config.js

# View config.js content
docker exec facility-erp-frontend-prod cat /usr/share/nginx/html/config.js

# Check nginx is serving config.js
curl -I http://your-server-ip/config.js

# Restart container to regenerate config.js
docker-compose -f docker-compose.prod.yml restart frontend
```

## Quick Fix

If nothing works, manually set the API URL in the browser console:

```javascript
window.__APP_CONFIG__ = {
  API_BASE_URL: 'https://your-actual-backend-url.com/api/v1'
};
```

Then reload the page. This is temporary - fix the root cause by setting `API_BASE_URL` in your `.env` file.

