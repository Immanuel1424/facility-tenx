# Firebase Push Notification Testing Guide

This guide helps you test the complete push notification flow from registration to delivery.

## Prerequisites

✅ Firebase Admin credentials configured in `apps/backend/.env`:
- `FIREBASE_PROJECT_ID=tenx-bf726`
- `FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@tenx-bf726.iam.gserviceaccount.com`
- `FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n..."`

✅ `user_devices` table created in database

✅ Frontend Firebase configuration updated

## Testing Flow

### Step 1: Check Current Token Status

Check if admin user has registered FCM tokens:

```bash
cd apps/backend
npm run check:tokens
```

**Expected Output:**
- If no tokens: Shows instructions to log in
- If tokens exist: Lists all registered devices with platform and last used time

### Step 2: Register FCM Token (Admin Login)

1. **Start the frontend app:**
   ```bash
   cd apps/frontend
   flutter run -d chrome  # For web
   # OR
   flutter run  # For mobile
   ```

2. **Log in as admin:**
   - Email: `vivek.ellappan@helixsense.com`
   - Password: `password123`

3. **Grant notification permissions:**
   - Browser will prompt for notification permissions (web)
   - Mobile will prompt for notification permissions (iOS/Android)
   - Click "Allow" or "Grant"

4. **Verify token registration:**
   ```bash
   cd apps/backend
   npm run check:tokens
   ```
   
   You should now see registered FCM tokens!

### Step 3: Send Test Notification

Send a test push notification to the admin:

```bash
cd apps/backend
npm run test:push
```

**Expected Output:**
- ✅ Firebase Admin initialized successfully
- ✅ Found admin user
- ✅ Found X active FCM token(s)
- ✅ Test notification sent successfully

### Step 4: Verify Notification Delivery

**On Web:**
- Check browser notifications (top-right corner)
- Check in-app notifications list in the app

**On Mobile:**
- Check system notification tray
- Check in-app notifications list in the app

## Troubleshooting

### Issue: "No FCM tokens found"

**Solution:**
1. Ensure admin user has logged into the app
2. Check that notification permissions were granted
3. Verify the app is running and connected
4. Check browser console for any errors

### Issue: "Firebase Admin not initialized"

**Solution:**
1. Verify `.env` file has all three Firebase variables
2. Restart the backend server after adding credentials
3. Check that private key is properly escaped with `\n` for newlines

### Issue: "Notification not received"

**Solution:**
1. Verify FCM token is registered: `npm run check:tokens`
2. Check browser/system notification settings
3. Verify Firebase project has Cloud Messaging API enabled
4. Check backend logs for any errors

### Issue: "user_devices table does not exist"

**Solution:**
```bash
cd apps/backend
psql -h localhost -U postgres -d facility_erp -f migrations/create-user-devices-table.sql
```

## Testing Different Scenarios

### Test 1: In-App Notification Only
```bash
# Send notification without push channel
# Edit test-push-notification.ts to use channels: ['in_app']
npm run test:push
```

### Test 2: Push Notification Only
```bash
# Send notification with only push channel
# Edit test-push-notification.ts to use channels: ['push']
npm run test:push
```

### Test 3: Multiple Devices
1. Log in as admin on multiple devices (web + mobile)
2. Each device will register its own FCM token
3. Send notification - it should be delivered to all devices

### Test 4: Notification from Ticket Creation
When a maintenance ticket is created/updated, notifications are automatically sent. Test by:
1. Creating a new ticket as a tenant
2. Check if admin receives notification
3. Verify notification appears in notifications list

## Monitoring

### Check Notification Delivery Status

Query the database to see notification delivery status:

```sql
SELECT 
  n.id,
  n.title,
  n.message,
  n.severity,
  n.channels,
  d.channel,
  d.status,
  d.attempt_count,
  d.last_error
FROM notifications n
LEFT JOIN notification_deliveries d ON d.notification_id = n.id
WHERE n.recipient_user_id = '44142ebb-779d-4e83-b0a2-3db691e389ff'
ORDER BY n.created_at DESC
LIMIT 10;
```

### Check Registered Devices

```sql
SELECT 
  id,
  platform,
  is_active,
  last_used_at,
  created_at,
  LEFT(fcm_token, 50) as token_preview
FROM user_devices
WHERE user_id = '44142ebb-779d-4e83-b0a2-3db691e389ff'
ORDER BY last_used_at DESC;
```

## Next Steps

Once testing is complete:

1. ✅ Verify notifications work on all platforms (web, Android, iOS)
2. ✅ Test notification delivery for different user roles
3. ✅ Test notification templates for different event types
4. ✅ Monitor notification delivery success rates
5. ✅ Set up notification preferences/permissions UI

## Quick Reference

| Command | Purpose |
|---------|---------|
| `npm run check:tokens` | Check FCM token registration status |
| `npm run test:push` | Send test push notification to admin |
| `npm run test:email` | Send test email notification |

## Admin User Credentials

- **Email:** `vivek.ellappan@helixsense.com`
- **Password:** `password123`
- **Company ID:** `eb75a65b-055f-4408-a58c-71d233443c17`
- **User ID:** `44142ebb-779d-4e83-b0a2-3db691e389ff`

