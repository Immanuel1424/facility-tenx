# FCM Token Registration Fix - 401 Error During Initial Load

## 🔍 Root Cause

The app was trying to register the FCM (Firebase Cloud Messaging) token with the backend **before authentication**, causing a 401 error during initial app load.

### Problem Flow:
1. App starts → `main.dart` calls `PushNotificationService().initialize()`
2. FCM token is obtained successfully
3. **Immediately tries to register token** with backend via `POST /notifications/devices/register`
4. Backend requires authentication → Returns **401 Unauthorized**
5. Error is caught and logged, but creates noise in logs

### Impact:
- ❌ 401 errors in console during app initialization
- ❌ Confusing error messages for developers
- ❌ Unnecessary API calls before authentication
- ✅ **Does NOT block app loading** (error is caught)

## ✅ Solution

Deferred FCM token registration until **after successful authentication**.

### Changes Made:

#### 1. **PushNotificationService** (`push_notification_service.dart`)
- **Removed** immediate token registration during initialization
- **Added** `registerTokenAfterAuth()` method to register token after login
- **Added** `markAsUnauthenticated()` method to track auth state
- **Added** `_isAuthenticated` flag to track authentication status
- **Updated** token refresh handler to only register if authenticated

#### 2. **AppRouter** (`app_router.dart`)
- **Added** FCM token registration listener in `_AuthNotifier`
- **Automatically registers** token when user becomes authenticated
- **Marks as unauthenticated** when user logs out

### Code Flow (After Fix):

1. App starts → `PushNotificationService().initialize()` runs
2. FCM token is obtained and **stored** (not registered yet)
3. User logs in → `AuthBloc` emits `AuthAuthenticated` state
4. `_AuthNotifier` listener detects authentication
5. **Calls** `PushNotificationService().registerTokenAfterAuth()`
6. Token is registered with backend **after authentication** ✅

## 📝 Key Changes

### Before:
```dart
// In PushNotificationService.initialize()
if (_fcmToken != null) {
  await _sendTokenToBackend(_fcmToken!); // ❌ Called before auth
}
```

### After:
```dart
// In PushNotificationService.initialize()
if (_fcmToken != null) {
  debugPrint('📱 FCM token obtained, will register after authentication');
  // ✅ Token stored, registration deferred
}

// In _AuthNotifier (app_router.dart)
authenticated: (_) {
  PushNotificationService().registerTokenAfterAuth(); // ✅ Called after auth
}
```

## 🧪 Testing

### Test Scenarios:
1. ✅ **Initial Load**: No 401 errors in console
2. ✅ **After Login**: FCM token registers successfully
3. ✅ **Token Refresh**: Only registers if authenticated
4. ✅ **Logout**: Marks service as unauthenticated

### Expected Behavior:
- **Before Login**: FCM token obtained, no registration attempt
- **After Login**: FCM token registered with backend (200 OK)
- **On Logout**: Service marked as unauthenticated
- **Token Refresh**: Only registers if user is authenticated

## 🎯 Benefits

1. ✅ **No more 401 errors** during initial load
2. ✅ **Cleaner logs** - no authentication errors before login
3. ✅ **Better UX** - token registration happens at the right time
4. ✅ **Proper error handling** - distinguishes between expected and unexpected failures

## 📋 Files Modified

1. `apps/frontend/lib/src/core/notifications/push_notification_service.dart`
   - Added authentication state tracking
   - Deferred token registration
   - Added `registerTokenAfterAuth()` method

2. `apps/frontend/lib/src/core/router/app_router.dart`
   - Added FCM token registration listener
   - Automatically registers token on authentication

## 🔄 Migration Notes

- **No breaking changes** - existing functionality preserved
- **Backward compatible** - works with existing authentication flow
- **No database changes** required
- **No API changes** required
