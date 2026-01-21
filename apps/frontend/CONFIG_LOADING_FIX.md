# Runtime Configuration Loading Fix

## Issue Identified

The dynamic API endpoint configuration (`config.js`) was not being loaded reliably, causing the app to fall back to hardcoded values.

### Root Cause

1. **Timing Issue**: `config.js` was loaded with an `onerror` handler that silently failed
2. **Script Loading Order**: `flutter_bootstrap.js` was loaded with `async`, potentially executing before `config.js` finished loading
3. **Error Handling**: The `onerror` handler masked loading failures, making debugging difficult

## Solution Implemented

### 1. HTML Loading Order (`web/index.html`)

**Before:**
- `config.js` loaded with `onerror` handler that silently failed
- `flutter_bootstrap.js` loaded with `async` (non-blocking)

**After:**
- `config.js` loaded **synchronously** (no async/defer) - blocks until loaded
- Added verification script after `config.js` to log the final config
- `flutter_bootstrap.js` uses `defer` to ensure it executes after DOM is ready but respects script order

### 2. Dart Code Robustness (`lib/src/core/config/app_config.dart`)

**Improvements:**
- Better null checking for `window.__APP_CONFIG__`
- More defensive error handling
- Clearer logging to identify which config source is being used

## How It Works Now

1. **Container Startup**: `docker-entrypoint.sh` generates `config.js` with `API_BASE_URL` from environment variable
2. **HTML Loads**: `index.html` loads `config.js` synchronously (blocks until loaded)
3. **Config Available**: `window.__APP_CONFIG__` is set before Flutter initializes
4. **Flutter Reads**: Dart code reads from `window.__APP_CONFIG__` and uses it
5. **Fallback Chain**: If config.js fails, falls back to:
   - Build-time environment variable
   - `.env` file
   - Hardcoded value (last resort)

## Testing

To verify the fix works:

1. **Check Container Logs**:
   ```bash
   docker logs facility-erp-frontend-prod | grep config.js
   ```
   Should show: `✅ config.js created successfully`

2. **Check Browser Console**:
   - Open browser DevTools
   - Look for: `📋 Final config after loading config.js`
   - Should show the correct `API_BASE_URL`

3. **Verify API Calls**:
   - Check Network tab in DevTools
   - API calls should go to the URL from `config.js`, not localhost

## Making It Dynamic

The configuration is now fully dynamic:

1. **Set Environment Variable** in `.env`:
   ```bash
   API_BASE_URL=https://hsense-test-v1.helixsense.com/api/v1
   ```

2. **Restart Container**:
   ```bash
   docker-compose -f docker-compose.prod.yml restart frontend
   ```

3. **Verify**: Check logs and browser console to confirm new URL is used

## Why Hardcoded Worked

The hardcoded URL worked because:
- It bypassed all the runtime config loading
- It was always available regardless of `config.js` loading
- No timing or network issues

## Why Dynamic Now Works

The dynamic config now works because:
- `config.js` loads **synchronously** before Flutter starts
- Proper error handling and logging
- Clear fallback chain if config fails to load
- Verification scripts ensure config is ready

