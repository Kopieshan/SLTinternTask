# 🚀 QUICK START - Run This After Cloning

## ⚡ Fast Setup (5 minutes)

### Step 1: Install Dependencies
```bash
cd sltinternapp
flutter pub get
```

### Step 2: Configure Firebase
```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Install FlutterFire CLI (if not installed)
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Firebase for this project
flutterfire configure
```

**What `flutterfire configure` does:**
- Creates/selects Firebase project
- Generates `lib/firebase_options.dart` with your credentials
- Registers Android and iOS apps
- **This replaces the placeholder firebase_options.dart file**

### Step 3: Enable Firebase Services

Go to [Firebase Console](https://console.firebase.google.com):

1. **Storage**: Navigate to Storage → Get Started → Enable
2. **Firestore**: Navigate to Firestore Database → Create Database → Enable

### Step 4: Set Security Rules (for testing)

**Storage Rules:**
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /dockets/temp/{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

**Firestore Rules:**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /temp_dockets/{document=**} {
      allow read, write: if true;
    }
  }
}
```

### Step 5: Run the App
```bash
# Android
flutter run

# iOS (macOS only)
cd ios && pod install && cd ..
flutter run
```

---

## 📱 How to Use the App

1. **Select Category** from dropdown (Electrical, Plumbing, etc.)
2. **Tap "Take Photo"** - Camera opens
3. **Capture image** - Preview appears
4. **Tap "Upload"** - Progress bar shows 0-100%
5. **Success!** - Green message appears with filename

---

## 🎯 Expected Behavior

### File Location in Firebase
```
Storage: dockets/temp/2025-11-11_Electrical_0.jpg
Firestore: temp_dockets collection (auto-created)
```

### Firestore Document Structure
```json
{
  "filename": "2025-11-11_Electrical_0.jpg",
  "category": "Electrical",
  "storagePath": "dockets/temp/2025-11-11_Electrical_0.jpg",
  "downloadURL": "https://firebasestorage.googleapis.com/...",
  "createdAt": Timestamp,
  "devicePlatform": "android" | "ios"
}
```

---

## ⚠️ Common Issues

### Issue: "Firebase initialization error"
**Fix:** Run `flutterfire configure` - this generates the correct firebase_options.dart

### Issue: Camera permission denied
**Fix Android:** Settings → Apps → Docket Demo → Permissions → Enable Camera
**Fix iOS:** Settings → Docket Demo → Enable Camera

### Issue: Upload fails with permission denied
**Fix:** Check Firebase Console → Storage/Firestore → Rules (set to test mode)

### Issue: iOS build fails
**Fix:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

---

## 📦 What's Included

✅ Complete Flutter app with camera integration  
✅ Firebase Storage upload with progress tracking  
✅ Firestore metadata storage  
✅ Image compression (target: ≤ 300 KB)  
✅ Android & iOS permissions configured  
✅ Error handling & user feedback  
✅ Clean, production-ready code  

---

## 🔗 Important Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | Main app code |
| `lib/firebase_options.dart` | Firebase config (auto-generated) |
| `android/app/src/main/AndroidManifest.xml` | Android permissions |
| `ios/Runner/Info.plist` | iOS permissions |
| `pubspec.yaml` | Dependencies |
| `PROJECT_SUMMARY.md` | Complete documentation |

---

## 🎓 Next Steps

1. ✅ Run `flutterfire configure` (most important!)
2. ✅ Enable Storage & Firestore in Firebase Console
3. ✅ Set security rules to test mode
4. ✅ Run `flutter run`
5. ✅ Test: Select category → Take photo → Upload
6. ✅ Verify: Check Firebase Console for uploaded file

---

**Questions?** Check `PROJECT_SUMMARY.md` for detailed documentation.

**Ready?** Run the commands above! 🚀
