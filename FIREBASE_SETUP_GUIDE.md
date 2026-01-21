# Firebase Setup Guide

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `facility-erp` (or your preferred name)
4. Click **Continue**
5. **Disable Google Analytics** (optional, you can enable later)
6. Click **Create project**
7. Wait for project creation (30-60 seconds)
8. Click **Continue**

## Step 2: Add Web App

1. In Firebase Console, click the **Web icon** (`</>`)
2. Register app nickname: `facility-erp-web`
3. **Check** "Also set up Firebase Hosting" (optional)
4. Click **Register app**
5. **Copy the Firebase configuration** - you'll see something like:

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

**Save these values - I'll need them!**

## Step 3: Enable Cloud Messaging

1. In Firebase Console, go to **Build** → **Cloud Messaging**
2. Click **Get started** (if prompted)
3. Go to **Cloud Messaging API (Legacy)** tab
4. Click **Enable** (if not already enabled)

## Step 4: Generate VAPID Key (for Web Push)

1. In Cloud Messaging, scroll to **Web configuration**
2. Click **Generate key pair** under "Web Push certificates"
3. **Copy the key pair** - you'll need this for backend

**Save this key - I'll need it!**

## Step 5: Create Service Account (for Backend)

1. In Firebase Console, click the **gear icon** ⚙️ → **Project settings**
2. Go to **Service accounts** tab
3. Click **Generate new private key**
4. Click **Generate key** in the dialog
5. A JSON file will download - **save this securely**

**This file contains:**
- `project_id`
- `private_key`
- `client_email`

**I'll need these values for backend configuration!**

## Step 6: Add Authorized Domains (for Web)

1. In Firebase Console, go to **Authentication** → **Settings** → **Authorized domains**
2. Add your domains:
   - `localhost` (for development)
   - `yourdomain.com` (for production)
   - `yourdomain.com:8080` (if using custom port)

## What to Share with Me

After completing the above, please provide:

1. **Firebase Project ID**: `_________________`
2. **Web App Config** (from Step 2):
   - apiKey: `_________________`
   - authDomain: `_________________`
   - projectId: `_________________`
   - storageBucket: `_________________`
   - messagingSenderId: `_________________`
   - appId: `_________________`
3. **VAPID Key** (from Step 4): `_________________`
4. **Service Account** (from Step 5):
   - project_id: `_________________`
   - private_key: `_________________` (the full key string)
   - client_email: `_________________`

---

## Alternative: I Can Start Implementation

If you want, I can:
1. Start implementing the code structure
2. Add placeholder values
3. You fill in the Firebase values later

**Would you like me to start implementing now, or wait for Firebase setup?**

