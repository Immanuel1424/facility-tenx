# Production Readiness Checklist

## ✅ Configuration Loading Solution

### Issues Fixed

1. **Script Loading Order**
   - ✅ `config.js` loads synchronously before Flutter
   - ✅ `flutter_bootstrap.js` uses `async` (Flutter requirement)
   - ✅ Proper execution order guaranteed

2. **Error Handling**
   - ✅ Graceful fallback if `config.js` fails to load
   - ✅ Validation in entrypoint script
   - ✅ Input sanitization to prevent script injection

3. **Logging**
   - ✅ Console logs only in debug mode (using `assert`)
   - ✅ Production builds won't show debug messages
   - ✅ Entrypoint script logs for container debugging

4. **Security**
   - ✅ Input validation in entrypoint script
   - ✅ Script injection prevention (quote escaping)
   - ✅ Security headers in nginx config
   - ✅ No sensitive data in client-side config

5. **Reliability**
   - ✅ Multiple fallback layers
   - ✅ Container fails to start if API_BASE_URL not set
   - ✅ Clear error messages for debugging

## Production Deployment Steps

### 1. Environment Configuration

Set in `.env` file:
```bash
API_BASE_URL=https://hsense-test-v1.helixsense.com/api/v1
```

### 2. Build and Deploy

```bash
# Build frontend image
docker build --platform linux/amd64 \
  --tag hsense/facility-erp-frontend:latest \
  --file apps/frontend/Dockerfile \
  apps/frontend

# Push to registry
docker push hsense/facility-erp-frontend:latest

# On production server
docker-compose -f docker-compose.prod.yml pull frontend
docker-compose -f docker-compose.prod.yml up -d --force-recreate frontend
```

### 3. Verification

**Check Container Logs:**
```bash
docker logs facility-erp-frontend-prod | grep -E "(config.js|API_BASE_URL)"
```

Should show:
```
🔧 Generating config.js with API_BASE_URL=https://...
✅ config.js created successfully
```

**Check Browser Console:**
- Open DevTools → Console
- Should NOT see debug messages in production build
- Network tab should show API calls to correct endpoint

**Test API Endpoint:**
```bash
curl http://your-domain/config.js
```

Should return:
```javascript
window.__APP_CONFIG__ = {
  API_BASE_URL: 'https://hsense-test-v1.helixsense.com/api/v1'
};
```

## Security Considerations

### ✅ Implemented

1. **Input Validation**: Entrypoint script validates API_BASE_URL is set
2. **Script Injection Prevention**: Quotes are escaped in API_BASE_URL
3. **Security Headers**: nginx adds X-Content-Type-Options
4. **No Sensitive Data**: Only API endpoint, no secrets

### ⚠️ Additional Recommendations

1. **HTTPS Only**: Ensure API_BASE_URL uses HTTPS in production
2. **CORS Configuration**: Backend should validate origin
3. **Rate Limiting**: Implement on backend API
4. **Monitoring**: Set up alerts for config.js generation failures

## Fallback Chain

The app tries configuration sources in this order:

1. **Runtime Config** (`config.js` from docker-entrypoint.sh) ← **Production**
2. **Build-time Env Var** (`--dart-define=API_BASE_URL=...`)
3. **.env File** (development only)
4. **Hardcoded Fallback** (last resort, should never be used in production)

## Troubleshooting

### Issue: API calls go to localhost

**Check:**
1. Container logs for config.js generation
2. Browser console for config loading errors
3. Network tab to see if config.js loaded

**Fix:**
```bash
# Restart container to regenerate config.js
docker-compose -f docker-compose.prod.yml restart frontend
```

### Issue: Container fails to start

**Check:**
```bash
docker logs facility-erp-frontend-prod
```

**Fix:**
- Ensure `API_BASE_URL` is set in `.env` file
- Check docker-compose.prod.yml has environment variable

### Issue: config.js not accessible

**Check:**
```bash
# Inside container
docker exec facility-erp-frontend-prod ls -la /usr/share/nginx/html/config.js

# From host
curl http://localhost/config.js
```

**Fix:**
- Check nginx is running
- Verify file permissions
- Check nginx error logs

## Performance

- ✅ `config.js` is small (< 200 bytes)
- ✅ Loads synchronously (minimal impact)
- ✅ No blocking network requests
- ✅ Cached by nginx with no-cache headers (always fresh)

## Browser Compatibility

- ✅ Works in all modern browsers
- ✅ Graceful degradation if config.js fails
- ✅ No external dependencies for config loading

## Monitoring

### Key Metrics to Monitor

1. **Container Startup Success Rate**
   - Alert if config.js generation fails
   - Alert if API_BASE_URL not set

2. **API Call Success Rate**
   - Monitor if calls go to wrong endpoint
   - Track fallback usage (should be 0% in production)

3. **Error Rates**
   - Track config loading errors
   - Monitor API connection failures

## Conclusion

✅ **This solution is production-ready** with:
- Proper error handling
- Security measures
- Performance optimization
- Clear fallback chain
- Production-safe logging

The hardcoded URL is only a last-resort fallback and should never be used in production if `config.js` is properly generated.

