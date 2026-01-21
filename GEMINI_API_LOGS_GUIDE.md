# Gemini API - Checking Logs Guide

## How to Check Logs for Gemini API Issues

### 1. Check Frontend Container Logs

```bash
# View all logs
docker logs facility-erp-frontend-prod

# Follow logs in real-time
docker logs -f facility-erp-frontend-prod

# View last 100 lines
docker logs --tail=100 facility-erp-frontend-prod

# Filter for Gemini-related logs
docker logs facility-erp-frontend-prod 2>&1 | grep -i gemini
```

### 2. Check if config.js Contains Gemini API Key

```bash
# Check config.js content (key will be visible)
docker exec facility-erp-frontend-prod cat /usr/share/nginx/html/config.js

# Check if key is set (hidden)
docker exec facility-erp-frontend-prod cat /usr/share/nginx/html/config.js | grep GEMINI_API_KEY
```

### 3. Check Container Environment Variables

```bash
# Check all environment variables
docker exec facility-erp-frontend-prod env

# Check specifically for GEMINI_API_KEY
docker exec facility-erp-frontend-prod env | grep GEMINI_API_KEY

# Check if it's set (should show the key)
docker exec facility-erp-frontend-prod sh -c 'echo "GEMINI_API_KEY length: ${#GEMINI_API_KEY}"'
```

### 4. Check Browser Console Logs

1. Open the deployed application in a browser
2. Open Developer Tools (F12)
3. Go to **Console** tab
4. Look for messages like:
   - `✅ Using runtime config GEMINI_API_KEY`
   - `⚠️ Error reading GEMINI_API_KEY from config`
   - `Gemini API key is not configured`

### 5. Check Browser Network Tab

1. Open Developer Tools (F12)
2. Go to **Network** tab
3. Try using the AI ticket creation feature
4. Look for requests to:
   - `generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent`
5. Check the request:
   - **Status**: Should be 200 (success) or 400/401 (error)
   - **Request URL**: Should include `?key=...`
   - **Response**: Check for error messages

### 6. Verify config.js is Accessible

```bash
# From your local machine (replace with your domain)
curl http://your-domain.com/config.js

# Or from within the container
docker exec facility-erp-frontend-prod curl -s http://localhost/config.js
```

### 7. Check Docker Compose Configuration

```bash
# View docker-compose config
docker-compose -f docker-compose.prod.yml config

# Check frontend service environment
docker-compose -f docker-compose.prod.yml config | grep -A 20 "frontend:"
```

### 8. Common Error Messages and Solutions

#### Error: "Gemini API key is not configured"

**Check:**
```bash
# 1. Check .env file
grep GEMINI_API_KEY .env

# 2. Check container logs for config.js generation
docker logs facility-erp-frontend-prod | grep config.js

# 3. Check if config.js has the key
docker exec facility-erp-frontend-prod cat /usr/share/nginx/html/config.js
```

**Fix:**
- Add `GEMINI_API_KEY=your_key` to `.env` file
- Restart container: `docker-compose -f docker-compose.prod.yml restart frontend`

#### Error: "All endpoints failed" or HTTP 400/401

**Check:**
```bash
# Check browser console for specific error
# Look in Network tab for the API response
```

**Possible causes:**
- Invalid API key
- API key doesn't have Generative Language API enabled
- API key restrictions blocking the request
- API quota exceeded

**Fix:**
- Verify API key at https://makersuite.google.com/app/apikey
- Check API key restrictions in Google Cloud Console
- Verify API is enabled in Google Cloud Console

#### Error: CORS errors

**Check:**
```bash
# Check browser console for CORS errors
# Should not happen with Gemini API (it supports CORS)
```

**Fix:**
- Usually not a CORS issue with Gemini API
- Check if the API key is correct

### 9. Testing Gemini API Directly

```bash
# Test API key directly (replace YOUR_API_KEY)
curl -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Hello, how are you?"
      }]
    }]
  }'
```

If this works, the API key is valid. If not, check the error message.

### 10. Quick Diagnostic Script

Create a diagnostic script:

```bash
#!/bin/bash
echo "=== Gemini API Diagnostic ==="
echo ""
echo "1. Checking .env file..."
grep GEMINI_API_KEY .env 2>/dev/null || echo "❌ GEMINI_API_KEY not found in .env"
echo ""
echo "2. Checking container environment..."
docker exec facility-erp-frontend-prod env | grep GEMINI_API_KEY || echo "❌ GEMINI_API_KEY not in container env"
echo ""
echo "3. Checking config.js..."
docker exec facility-erp-frontend-prod cat /usr/share/nginx/html/config.js | grep -q GEMINI_API_KEY && echo "✅ GEMINI_API_KEY found in config.js" || echo "❌ GEMINI_API_KEY not in config.js"
echo ""
echo "4. Checking container logs..."
docker logs facility-erp-frontend-prod 2>&1 | tail -20 | grep -i gemini || echo "No Gemini logs in last 20 lines"
echo ""
echo "5. Checking container status..."
docker ps | grep facility-erp-frontend-prod || echo "❌ Frontend container not running"
```

Save as `check-gemini.sh`, make executable: `chmod +x check-gemini.sh`, run: `./check-gemini.sh`

## Log Locations Summary

| Location | Command | Purpose |
|----------|---------|---------|
| Container logs | `docker logs facility-erp-frontend-prod` | Startup logs, config.js generation |
| Browser console | F12 → Console tab | Runtime errors, API key loading |
| Browser network | F12 → Network tab | API request/response details |
| config.js file | `docker exec ... cat /usr/share/nginx/html/config.js` | Verify key is in config |
| Container env | `docker exec ... env \| grep GEMINI` | Verify env var is set |
| .env file | `grep GEMINI_API_KEY .env` | Source configuration |

## Next Steps After Checking Logs

1. **If key is missing**: Follow the fix in `GEMINI_API_DEPLOYMENT_FIX.md`
2. **If key is invalid**: Verify at https://makersuite.google.com/app/apikey
3. **If API calls fail**: Check API key permissions and restrictions
4. **If config.js is missing**: Check docker-entrypoint.sh logs and permissions

