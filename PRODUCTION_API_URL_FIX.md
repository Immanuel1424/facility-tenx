# Production API URL Configuration Fix

## Problem
Production app at `https://tenx-demo.helixsense.com` is calling `http://localhost:3000/api/v1` instead of the production API URL.

## Root Cause
The `API_BASE_URL` environment variable is not set in production, so `config.js` is not generated correctly.

## Solution

### Option 1: Same Domain (Recommended if using reverse proxy)
If your API is served from the same domain via reverse proxy:

```bash
# In your .env file or docker-compose.prod.yml
API_BASE_URL=https://tenx-demo.helixsense.com/api/v1
```

### Option 2: Separate API Domain
If your API is on a separate domain:

```bash
# In your .env file or docker-compose.prod.yml
API_BASE_URL=https://api.helixsense.com/api/v1
```

### Option 3: Docker Internal Network
If frontend and backend are in the same Docker network:

```bash
# In your .env file or docker-compose.prod.yml
API_BASE_URL=http://backend:3000/api/v1
```

## Quick Fix Steps

1. **SSH into your production server**

2. **Edit your `.env` file** (or set environment variable):
   ```bash
   # Add or update this line:
   API_BASE_URL=https://tenx-demo.helixsense.com/api/v1
   ```

3. **Restart the frontend container**:
   ```bash
   docker-compose -f docker-compose.prod.yml restart frontend
   ```

4. **Verify config.js was generated**:
   ```bash
   docker exec facility-erp-frontend-prod cat /usr/share/nginx/html/config.js
   ```
   
   Should show:
   ```javascript
   window.__APP_CONFIG__ = {
     API_BASE_URL: 'https://tenx-demo.helixsense.com/api/v1'
   };
   ```

5. **Check browser console**:
   - Open `https://tenx-demo.helixsense.com`
   - Open browser DevTools → Console
   - Should see: `✅ Runtime config loaded: {API_BASE_URL: 'https://tenx-demo.helixsense.com/api/v1'}`

## Auto-Detection Feature

The app now includes **auto-detection** as a fallback:
- If `config.js` is not loaded, it will auto-detect the API URL from the current hostname
- For `https://tenx-demo.helixsense.com`, it will use `https://tenx-demo.helixsense.com/api/v1`
- This is a **fallback only** - you should still set `API_BASE_URL` explicitly

## Verification

After fixing, verify the API calls are correct:

1. Open browser DevTools → Network tab
2. Navigate to company selection page
3. Check the API call - should be:
   ```
   https://tenx-demo.helixsense.com/api/v1/public/lookup/companies
   ```
   NOT:
   ```
   http://localhost:3000/api/v1/public/lookup/companies
   ```

## Troubleshooting

### If config.js is not generated:
```bash
# Check container logs
docker logs facility-erp-frontend-prod

# Should see:
# ✅ config.js created successfully
# 📄 config.js contents: ...
```

### If API_BASE_URL is not set:
```bash
# Check environment variable
docker exec facility-erp-frontend-prod env | grep API_BASE_URL

# If empty, set it:
# Edit docker-compose.prod.yml or .env file
```

### If still using localhost:
1. Clear browser cache
2. Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
3. Check browser console for errors
4. Verify `config.js` is accessible: `https://tenx-demo.helixsense.com/config.js`

## Production Checklist

- [ ] `API_BASE_URL` is set in `.env` or `docker-compose.prod.yml`
- [ ] Frontend container has been restarted
- [ ] `config.js` is generated correctly (check container logs)
- [ ] Browser console shows correct API URL
- [ ] Network tab shows API calls to production URL (not localhost)
- [ ] API calls are successful
