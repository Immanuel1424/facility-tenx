# Test Push Notification Guide

This guide shows you how to send a test push notification to verify your web push notification setup.

## Prerequisites

1. **Backend is running** on `http://localhost:3000`
2. **Frontend is running** in a web browser (Chrome recommended)
3. **You are logged in** to the application (to get JWT token)
4. **FCM token is registered** (should happen automatically on app load)

## Method 1: Using the Test Script (Easiest)

```bash
# 1. Login first to get JWT token
export JWT_TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -H 'x-company-id: eb75a65b-055f-4408-a58c-71d233443c17' \
  -d '{"email":"your-email@example.com","password":"your-password"}' \
  | jq -r '.accessToken')

# 2. Run the test script
cd apps/backend
./scripts/test-push-notification.sh

# Or with custom message:
TITLE="New Ticket Created" BODY="Ticket #123 has been assigned to you" ./scripts/test-push-notification.sh
```

## Method 2: Using curl Directly

```bash
# 1. Get JWT token (replace with your credentials)
JWT_TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -H 'x-company-id: eb75a65b-055f-4408-a58c-71d233443c17' \
  -d '{"email":"your-email@example.com","password":"your-password"}' \
  | jq -r '.accessToken')

# 2. Send test notification
curl -X POST http://localhost:3000/api/v1/notifications/test/push \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H 'x-company-id: eb75a65b-055f-4408-a58c-71d233443c17' \
  -d '{
    "title": "Test Notification",
    "body": "This is a test push notification",
    "ticketId": "optional-ticket-id"
  }'
```

## Method 3: Using Swagger UI

1. Open Swagger UI: `http://localhost:3000/api/docs`
2. Navigate to **notifications** section
3. Find **POST /notifications/test/push**
4. Click "Try it out"
5. Enter your request body:
   ```json
   {
     "title": "Test Notification",
     "body": "This is a test push notification",
     "ticketId": "optional-ticket-id"
   }
   ```
6. Click "Execute"
7. Check your web browser for the notification!

## Method 4: Using Postman or Insomnia

1. **Endpoint**: `POST http://localhost:3000/api/v1/notifications/test/push`
2. **Headers**:
   - `Content-Type: application/json`
   - `Authorization: Bearer YOUR_JWT_TOKEN`
   - `x-company-id: eb75a65b-055f-4408-a58c-71d233443c17`
3. **Body** (JSON):
   ```json
   {
     "title": "Test Notification",
     "body": "This is a test push notification",
     "ticketId": "optional-ticket-id"
   }
   ```

## What to Expect

1. **Backend Response**: You should get a `200 OK` response with:
   ```json
   {
     "success": true,
     "message": "Test push notification sent successfully",
     "recipientUserId": "your-user-id",
     "title": "Test Notification",
     "body": "This is a test push notification"
   }
   ```

2. **Browser Notification**: 
   - If the app is in **foreground**: Notification appears via Firebase Messaging
   - If the app is in **background**: Browser shows a system notification
   - If the app is **closed**: Browser shows a system notification

3. **Console Logs** (in browser DevTools):
   - `📬 Foreground message: Test Notification` (if app is open)
   - `[firebase-messaging-sw.js] Received background message` (if app is in background)

## Troubleshooting

### Notification not appearing?

1. **Check FCM token is registered**:
   - Open browser console
   - Look for: `📱 FCM Token (Web with VAPID): [token]`
   - Look for: `✅ FCM token registered with backend`

2. **Check notification permission**:
   - Browser should have asked for notification permission
   - Check browser settings: `chrome://settings/content/notifications`
   - Make sure your site is allowed

3. **Check service worker**:
   - Open DevTools > Application > Service Workers
   - Verify `firebase-messaging-sw.js` is registered and active

4. **Check backend logs**:
   - Look for errors in backend console
   - Verify Firebase Admin SDK is configured correctly

5. **Check FCM token in database**:
   ```sql
   SELECT * FROM user_devices WHERE platform = 'web' ORDER BY created_at DESC;
   ```

### Common Issues

- **"No active FCM tokens found"**: User hasn't registered their device token yet
- **"Firebase Admin not initialized"**: Check Firebase service account credentials in backend `.env`
- **"Permission denied"**: User needs to grant notification permission in browser

## Next Steps

Once test notifications work:
1. Integrate push notifications into your ticket workflow
2. Set up notification templates for different events
3. Configure notification preferences per user
4. Add notification sound and badge support

