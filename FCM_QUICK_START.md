# FCM Push Notifications - Quick Start Guide

## ✅ Implementation Complete!

All code has been implemented. You just need to configure Firebase.

---

## 🚀 Quick Setup (5 Steps)

### Step 1: Create Firebase Project (5 minutes)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Name: `facility-erp` (or your choice)
4. **Skip** Google Analytics (optional)
5. Click **Create project**

### Step 2: Get Web App Config (2 minutes)

1. In Firebase Console, click **Web icon** (`</>`)
2. App nickname: `facility-erp-web`
3. Click **Register app**
4. **Copy the config** - you'll see:
   ```javascript
   const firebaseConfig = {
     apiKey: "AIza...",
     authDomain: "your-project.firebaseapp.com",
     projectId: "your-project-id",
     storageBucket: "your-project.appspot.com",
     messagingSenderId: "123456789",
     appId: "1:123456789:web:abc123"
   };
   ```

### Step 3: Get Service Account (2 minutes)

1. Firebase Console → **⚙️ Project settings** → **Service accounts**
2. Click **Generate new private key**
3. Click **Generate key**
4. JSON file downloads - **open it** and copy:
   - `project_id`
   - `private_key` (the full string)
   - `client_email`

### Step 4: Enable Cloud Messaging (1 minute)

1. Firebase Console → **Build** → **Cloud Messaging**
2. Click **Get started** (if needed)
3. Go to **Cloud Messaging API (Legacy)** tab
4. Click **Enable**

### Step 5: Configure Your App (3 minutes)

**Backend `.env`:**
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
```

**Frontend `web/index.html`:**
Replace the placeholder config with your values from Step 2.

**Run migration:**
```bash
cd apps/backend
npm run migrate
# Or manually: psql -d facility_erp -f migrations/create-user-devices-table.sql
```

**Install dependencies:**
```bash
# Backend
cd apps/backend
npm install

# Frontend
cd apps/frontend
flutter pub get
```

---

## ✅ Done!

Your push notifications are now ready! 

**Test it:**
1. Start backend: `npm run start:dev`
2. Start frontend: `flutter run -d chrome`
3. Check browser console for FCM token
4. Send a test notification from your backend

---

## 📚 Full Documentation

- **Setup Guide**: `FIREBASE_SETUP_GUIDE.md`
- **Implementation Details**: `FCM_IMPLEMENTATION_SUMMARY.md`
- **Requirements**: `FCM_IMPLEMENTATION_REQUIREMENTS.md`

---

## 🎯 What Works Now

✅ **Desktop Web** - Chrome, Firefox, Edge  
✅ **Android Mobile Web** - Chrome, Firefox  
✅ **Native Android** - With FCM setup  
✅ **Native iOS** - With APNs setup  

❌ **iOS Mobile Web** - Not supported (Safari limitation)

