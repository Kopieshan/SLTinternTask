# ✅ DEVELOPER CHECKLIST

Use this checklist to set up and test the Docket Demo app.

---

## 📋 SETUP CHECKLIST

### Initial Setup
- [ ] Clone/download project
- [ ] Navigate to `sltinternapp` directory
- [ ] Run `flutter pub get`
- [ ] Verify no dependency errors

### Firebase Configuration
- [ ] Install Firebase CLI: `npm install -g firebase-tools`
- [ ] Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
- [ ] Login to Firebase: `firebase login`
- [ ] Run `flutterfire configure` in project root
- [ ] Select/create Firebase project
- [ ] Verify `lib/firebase_options.dart` was generated (replaces placeholder)

### Firebase Console Setup
- [ ] Open Firebase Console (console.firebase.google.com)
- [ ] Navigate to your project
- [ ] Enable Firebase Storage:
  - [ ] Go to Storage → Get Started
  - [ ] Choose "Start in test mode"
  - [ ] Click "Done"
- [ ] Enable Cloud Firestore:
  - [ ] Go to Firestore Database → Create Database
  - [ ] Choose "Start in test mode"
  - [ ] Select region
  - [ ] Click "Enable"

### Security Rules (Test Mode)
- [ ] Set Storage rules to allow read/write (see QUICKSTART.md)
- [ ] Set Firestore rules to allow read/write (see QUICKSTART.md)
- [ ] Save rules in Firebase Console

### Platform Setup - Android
- [ ] Verify `android/app/src/main/AndroidManifest.xml` has camera permissions ✅ (already done)
- [ ] Check `android/app/build.gradle.kts` for minSdk compatibility ✅ (already done)

### Platform Setup - iOS
- [ ] Verify `ios/Runner/Info.plist` has usage descriptions ✅ (already done)
- [ ] Run `cd ios && pod install && cd ..`
- [ ] Check for CocoaPods errors (fix if needed)

---

## 🧪 TESTING CHECKLIST

### First Run
- [ ] Run `flutter run` successfully
- [ ] App launches without crashes
- [ ] No Firebase initialization errors
- [ ] UI loads correctly

### Feature Testing

#### Category Selection
- [ ] Dropdown shows all 5 categories:
  - [ ] Electrical
  - [ ] Plumbing
  - [ ] Cleaning
  - [ ] Security
  - [ ] Other
- [ ] Can select a category
- [ ] Selected value appears in dropdown

#### Camera Integration
- [ ] Tap "Take Photo" button
- [ ] Camera permission requested (first time)
- [ ] Grant camera permission
- [ ] Native camera opens
- [ ] Take a photo
- [ ] Photo preview appears in app
- [ ] Preview image displays correctly

#### Upload Functionality
- [ ] Upload button disabled when:
  - [ ] No category selected
  - [ ] No photo taken
- [ ] Upload button enabled when:
  - [ ] Category selected AND photo taken
- [ ] Tap "Upload" button
- [ ] Progress indicator appears
- [ ] Progress shows 0-100%
- [ ] Upload completes successfully
- [ ] Success message displays with filename format: `YYYY-MM-DD_Category_0.jpg`
- [ ] Image preview clears after successful upload

#### Error Handling
- [ ] Cancel camera (press back) - app doesn't crash
- [ ] Turn off internet, try upload - shows error message
- [ ] Error messages are user-friendly

### Firebase Verification

#### Storage Check
- [ ] Open Firebase Console → Storage
- [ ] Navigate to `dockets/temp/` folder
- [ ] Verify uploaded file exists
- [ ] Check filename format: `YYYY-MM-DD_Category_0.jpg`
- [ ] Download file and verify it's the photo you took
- [ ] Check file size (should be ≤ 300 KB if possible)

#### Firestore Check
- [ ] Open Firebase Console → Firestore Database
- [ ] Find `temp_dockets` collection
- [ ] Click on the most recent document
- [ ] Verify all fields exist:
  - [ ] `filename` (string, matches uploaded file)
  - [ ] `category` (string, one of 5 options)
  - [ ] `storagePath` (string, `dockets/temp/[filename]`)
  - [ ] `downloadURL` (string, Firebase Storage URL)
  - [ ] `createdAt` (timestamp, recent time)
  - [ ] `devicePlatform` (string, "android" or "ios")

### Multiple Upload Test
- [ ] Select different category
- [ ] Take new photo
- [ ] Upload successfully
- [ ] Verify new file in Storage
- [ ] Verify new document in Firestore
- [ ] Check that previous uploads still exist

### Platform-Specific Testing

#### Android Testing
- [ ] Test on Android emulator/device
- [ ] Camera permission prompt works
- [ ] Photo capture works
- [ ] Upload works
- [ ] `devicePlatform` field shows "android" in Firestore

#### iOS Testing (if macOS available)
- [ ] Test on iOS simulator/device
- [ ] Camera permission prompt works
- [ ] Photo capture works
- [ ] Upload works
- [ ] `devicePlatform` field shows "ios" in Firestore

---

## 🔍 VALIDATION CHECKLIST

### Code Quality
- [ ] No compile errors
- [ ] No runtime errors
- [ ] No null safety warnings
- [ ] Code follows Dart best practices

### File Naming
- [ ] Format: `YYYY-MM-DD_Category_0.jpg`
- [ ] Date is current device date
- [ ] Category matches selection (Electrical, Plumbing, etc.)
- [ ] Always ends with `_0.jpg`

### Image Compression
- [ ] Check file size in Firebase Storage
- [ ] Target: ≤ 300 KB
- [ ] Verify compression logs in console (debug mode)
- [ ] Image quality acceptable after compression

### User Experience
- [ ] UI is clean and intuitive
- [ ] Buttons have clear labels
- [ ] Progress indicator is visible during upload
- [ ] Success message is clear
- [ ] Error messages are helpful
- [ ] No confusing states

---

## 🚨 TROUBLESHOOTING COMPLETED

If you encountered and fixed any issues, check them off:

- [ ] Fixed Firebase initialization errors
- [ ] Resolved camera permission issues
- [ ] Fixed upload errors
- [ ] Resolved iOS build issues
- [ ] Fixed Android build issues
- [ ] Resolved security rules issues
- [ ] Fixed dependency conflicts

---

## 📊 FINAL ACCEPTANCE TEST

This is the complete test from the requirements:

- [ ] Select category defaults to none; Upload disabled until both category and photo are ready
- [ ] Taking a photo shows its preview
- [ ] Upload shows progress and ends with success message
- [ ] Firebase Storage contains file: `dockets/temp/[YYYY-MM-DD]_[Category]_0.jpg`
- [ ] Firestore `temp_dockets` has a document with all required fields
- [ ] App handles canceling camera gracefully (no crash)
- [ ] App shows friendly errors when offline or Firebase not set

---

## ✅ SIGN-OFF

### Developer
- [ ] All setup steps completed
- [ ] All tests passed
- [ ] Firebase properly configured
- [ ] App runs on target platform(s)
- [ ] Code reviewed and documented
- [ ] Ready for demo/submission

### Date Completed: ______________

### Platform(s) Tested:
- [ ] Android
- [ ] iOS

### Notes:
_____________________________________
_____________________________________
_____________________________________

---

## 📚 REFERENCE

- **Full Documentation**: See `PROJECT_SUMMARY.md`
- **Quick Setup**: See `QUICKSTART.md`
- **Detailed Setup**: See `README_SETUP.md`
- **Code Location**: `lib/main.dart`
- **Firebase Config**: `lib/firebase_options.dart` (auto-generated)

---

**All checkboxes completed?** 🎉 You're ready to ship!
