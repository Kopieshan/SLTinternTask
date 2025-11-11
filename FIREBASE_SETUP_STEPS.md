# Firebase Setup Guide - Step by Step

## Step 1: Install Firebase CLI

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Or using curl (if you don't have npm)
curl -sL https://firebase.tools | bash
```

## Step 2: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

## Step 3: Login to Firebase

```bash
firebase login
```

This will open a browser window. Login with your Firebase account.

## Step 4: Create Firebase Project (if not done)

Go to [Firebase Console](https://console.firebase.google.com/):
1. Click "Add project" (or select existing project)
2. Enter project name: `docket-app` (or your choice)
3. **Disable Google Analytics** (optional, for faster setup)
4. Click "Create project"

## Step 5: Enable Firebase Services

In Firebase Console, enable these services:

### A. Firebase Storage
1. Click "Storage" in left sidebar
2. Click "Get started"
3. **Security Rules:** Choose "Start in test mode"
4. Click "Next"
5. Choose location (e.g., `us-central1`)
6. Click "Done"

### B. Cloud Firestore
1. Click "Firestore Database" in left sidebar
2. Click "Create database"
3. **Start in test mode** (allows read/write for 30 days)
4. Choose location (same as Storage)
5. Click "Enable"

## Step 6: Configure FlutterFire (IMPORTANT!)

Run this command in your project directory:

```bash
cd /Users/demonking/Developer/SLT-FlutterIntern-task/sltinternapp
flutterfire configure
```

**What this does:**
- Connects to your Firebase project
- Generates `lib/firebase_options.dart` with your credentials
- Creates platform-specific config files
- Registers your app with Firebase

**Follow the prompts:**
1. Select your Firebase project from the list
2. Select platforms: Choose **iOS** and **Android** (use space bar)
3. Enter iOS bundle ID: `com.example.sltinternapp`
4. Enter Android package name: `com.example.sltinternapp`
5. Wait for configuration to complete

## Step 7: Verify Configuration

Check that these files were created:
- ✅ `lib/firebase_options.dart` (auto-generated)
- ✅ `android/app/google-services.json` (auto-generated)
- ✅ `ios/Runner/GoogleService-Info.plist` (auto-generated)

**Important:** These files are in `.gitignore` and won't be committed to GitHub!

## Step 8: Update Security Rules (Important!)

### Storage Rules (for file uploads)
Go to Firebase Console → Storage → Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /dockets/temp/{allPaths=**} {
      // Allow anyone to upload to temp folder (for testing)
      allow read, write: if true;
    }
  }
}
```

### Firestore Rules (for database)
Go to Firebase Console → Firestore → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /temp_dockets/{document=**} {
      // Allow anyone to read/write temp_dockets (for testing)
      allow read, write: if true;
    }
  }
}
```

**Publish the rules** after pasting them.

## Step 9: Test the App

```bash
flutter run -d iPhone
# Or for Android:
flutter run -d android
```

## Step 10: Test Upload Flow

1. Select a category (e.g., "Electrical")
2. Click "Open Camera"
3. Take a photo
4. Wait for compression and upload
5. Check Firebase Console:
   - Storage → `dockets/temp/` folder should have your image
   - Firestore → `temp_dockets` collection should have metadata

---

## Troubleshooting

### Error: "firebase_options.dart not found"
**Solution:** Run `flutterfire configure` again

### Error: "Permission denied" on upload
**Solution:** Update Storage Rules in Firebase Console (see Step 8)

### Error: "Firebase not initialized"
**Solution:** Make sure `flutterfire configure` completed successfully

### Error: "FlutterFire command not found"
**Solution:** Run `dart pub global activate flutterfire_cli` and ensure `~/.pub-cache/bin` is in your PATH

### Add to PATH (if needed)
```bash
# For macOS/Linux
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

---

## Quick Command Summary

```bash
# 1. Install tools
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# 2. Login
firebase login

# 3. Configure (most important!)
cd /Users/demonking/Developer/SLT-FlutterIntern-task/sltinternapp
flutterfire configure

# 4. Run app
flutter run
```

---

## Security Notes

✅ **Safe:** The generated config files are automatically added to `.gitignore`
✅ **Safe:** Test mode rules are fine for development
⚠️ **Warning:** Before production, update rules to require authentication
⚠️ **Warning:** Test mode rules expire in 30 days

---

## Next Steps After Setup

1. Test photo upload
2. Verify files appear in Firebase Storage
3. Verify metadata appears in Firestore
4. Update security rules for production (add authentication)
5. Deploy app

**You're all set!** 🎉
