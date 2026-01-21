# Production Configuration Guide

## API Base URL Configuration

The Flutter web app supports **runtime configuration** for the API base URL in production, allowing you to configure it without rebuilding the Docker image.

## How It Works

1. **Runtime Configuration (Production)**: The app reads `API_BASE_URL` from an environment variable at container startup
2. **Build-time Configuration (Development)**: Use `--dart-define=API_BASE_URL=...` during `flutter build`
3. **Fallback**: Defaults to `http://localhost:3000/api/v1` for local development

## Configuration Methods

### Method 1: Environment Variable (Recommended for Production)

Set `API_BASE_URL` in your `docker-compose.prod.yml` or `.env` file:

```yaml
# docker-compose.prod.yml
services:
  frontend:
    environment:
      API_BASE_URL: http://backend:3000/api/v1  # Internal Docker network
      # OR
      API_BASE_URL: https://api.yourdomain.com/api/v1  # External backend
```

Or in `.env`:
```bash
API_BASE_URL=http://backend:3000/api/v1
```

The entrypoint script (`docker-entrypoint.sh`) will generate a `config.js` file that the Flutter app reads at runtime.

### Method 2: Build-time Configuration

For development or when you want the URL baked into the build:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://api.yourdomain.com/api/v1
```

### Method 3: .env File (Development Only)

Create a `.env` file in `apps/frontend/`:

```bash
API_BASE_URL=http://localhost:3000/api/v1
```

## Production Deployment Examples

### Same Server (Backend + Frontend)

```yaml
# docker-compose.prod.yml
services:
  frontend:
    environment:
      API_BASE_URL: http://backend:3000/api/v1
```

### External Backend

```yaml
# docker-compose.prod.yml
services:
  frontend:
    environment:
      API_BASE_URL: https://api.yourdomain.com/api/v1
```

### With Reverse Proxy (Nginx)

If you're using a reverse proxy where both frontend and backend are served from the same domain:

```yaml
# docker-compose.prod.yml
services:
  frontend:
    environment:
      API_BASE_URL: https://yourdomain.com/api/v1
```

## Verification

After deployment, check the browser console. You should see:
- `✅ Generated config.js with API_BASE_URL=...` in container logs
- The app should connect to the configured API URL

## Troubleshooting

### App still uses localhost

1. Check container logs: `docker logs facility-erp-frontend-prod`
2. Verify `API_BASE_URL` is set in environment
3. Check browser console for errors loading `config.js`
4. Verify nginx is not caching `config.js` (should have `no-cache` headers)

### CORS Errors

If you see CORS errors, ensure:
1. Backend `CORS_ORIGIN` includes your frontend URL
2. API URL is correct (no trailing slash issues)

### Config.js Not Found

This is normal in development. The app will use the default config from `index.html`.

