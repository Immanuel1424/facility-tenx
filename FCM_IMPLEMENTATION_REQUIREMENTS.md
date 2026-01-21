# FCM Implementation Requirements Checklist

## Information Needed from You

### 1. Firebase Project Setup ✅/❌

**Do you already have a Firebase project?**
- [ ] Yes, I have a Firebase project
- [ ] No, I need to create one

**If you have one, please provide:**
- [ ] Firebase Project ID: `_________________`
- [ ] Firebase Project Name: `_________________`

**If you need to create one:**
- I'll guide you through the setup process

---

### 2. Firebase Configuration Files

**For Web:**
- [ ] Firebase Web App Config (I'll need these values):
  - `apiKey`: `_________________`
  - `authDomain`: `_________________`
  - `projectId`: `_________________`
  - `storageBucket`: `_________________`
  - `messagingSenderId`: `_________________`
  - `appId`: `_________________`

**For Backend (Firebase Admin):**
- [ ] Service Account JSON file (or I'll help you create one)
  - Path: `_________________`
  - OR provide these values:
    - `projectId`: `_________________`
    - `privateKey`: `_________________`
    - `clientEmail`: `_________________`

---

### 3. Platform Targets

**Which platforms do you want to support?**

- [ ] Web (Desktop browsers)
- [ ] Web (Android mobile browsers)
- [ ] Native Android App
- [ ] Native iOS App

**Note:** iOS Mobile Web (Safari) doesn't support web push - only native iOS app.

---

### 4. Database Schema Decision

**I need to create a table to store FCM tokens. Options:**

**Option A: Separate `user_devices` table (Recommended)**
```sql
CREATE TABLE user_devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL,
  user_id uuid NOT NULL,
  fcm_token text NOT NULL,
  platform varchar(20) NOT NULL, -- 'web', 'android', 'ios'
  device_info jsonb, -- Optional: browser, OS, etc.
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, fcm_token)
);
```

**Option B: Add to existing `users` table**
- Add `fcm_tokens` JSONB column
- Less flexible for multiple devices per user

**Which do you prefer?**
- [ ] Option A (Separate table - Recommended)
- [ ] Option B (Add to users table)

---

### 5. Environment Variables

**Backend `.env` additions needed:**
```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email@project-id.iam.gserviceaccount.com
```

**Frontend configuration:**
- [ ] Add Firebase config to `web/index.html` (for web)
- [ ] Add `google-services.json` (for Android native)
- [ ] Add `GoogleService-Info.plist` (for iOS native)

---

### 6. Implementation Preferences

**Notification Behavior:**
- [ ] Show notifications when app is in foreground?
- [ ] Show notifications when app is in background?
- [ ] Show notifications when app is closed?
- [ ] Deep linking: Navigate to specific pages when notification is tapped?

**Notification Types:**
- [ ] Maintenance ticket updates
- [ ] New ticket assignments
- [ ] Status changes
- [ ] Comments/replies
- [ ] System announcements
- [ ] Other: `_________________`

---

### 7. Testing Requirements

**Do you have:**
- [ ] Chrome browser (for desktop web testing)
- [ ] Android device/emulator (for mobile web testing)
- [ ] Android device (for native app testing)
- [ ] iOS device (for native app testing)

---

### 8. Current Setup Questions

**Backend:**
- [ ] What's your backend URL? (for API endpoints)
- [ ] Do you have authentication middleware set up? (for device registration endpoint)

**Frontend:**
- [ ] What's your frontend URL? (for Firebase domain whitelist)
- [ ] Is your app already using HTTPS? (required for web push)

---

## What I'll Implement

Once you provide the above information, I'll implement:

### Frontend (Flutter)
1. ✅ Add Firebase dependencies to `pubspec.yaml`
2. ✅ Create `PushNotificationService` class
3. ✅ Initialize Firebase in `main.dart`
4. ✅ Request notification permissions
5. ✅ Register FCM tokens with backend
6. ✅ Handle foreground notifications
7. ✅ Handle background notifications
8. ✅ Handle notification taps (deep linking)
9. ✅ Update `web/index.html` with Firebase config
10. ✅ Create device registration API client

### Backend (NestJS)
1. ✅ Install `firebase-admin` package
2. ✅ Create `user_devices` table migration
3. ✅ Create `UserDevice` entity
4. ✅ Implement `PushChannel` with FCM
5. ✅ Create device registration endpoint
6. ✅ Create device unregistration endpoint
6. ✅ Update notification service to use FCM
7. ✅ Add environment variables to `.env.example`

### Database
1. ✅ Create migration for `user_devices` table
2. ✅ Add indexes for performance
3. ✅ Add foreign key constraints

---

## Quick Start (If You Have Firebase Ready)

If you already have Firebase set up, just provide:

1. **Firebase Project ID**: `_________________`
2. **Service Account JSON** (or the 3 values: projectId, privateKey, clientEmail)
3. **Web App Config** (the 6 values from Firebase Console)
4. **Preferred database approach**: [ ] Separate table [ ] Add to users

And I'll implement everything!

---

## Next Steps

1. **Fill out this checklist** (or tell me what you have/don't have)
2. **I'll implement the solution** based on your answers
3. **You test** and provide feedback
4. **We iterate** until it's perfect

---

## Questions?

If you're unsure about any of these, just let me know and I'll:
- Help you create a Firebase project
- Guide you through getting the configuration values
- Recommend the best approach for your use case

