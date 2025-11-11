# Docket Demo App - Setup Instructions

## Project Overview
A minimal Flutter app that allows users to create complaint tickets (dockets) by:
1. Selecting a category (Electrical, Plumbing, Cleaning, Security, Other)
2. Taking a photo with the device camera
3. Compressing and uploading to Firebase Storage
4. Writing metadata to Firestore

## Prerequisites
- Flutter SDK (3.6.0 or higher)
- Dart SDK (null-safety enabled)
- Firebase project created at https://console.firebase.google.com
- Node.js and npm (for Firebase CLI)

## Setup Steps

### 1. Install Dependencies
```bash
cd sltinternapp
flutter pub get
```

### 2. Configure Firebase

#### A. Install Firebase CLI and FlutterFire CLI
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login
```

#### B. Run FlutterFire Configuration
```bash
# In the project root directory
flutterfire configure
```

This will:
- Prompt you to select/create a Firebase project
- Generate `lib/firebase_options.dart` with your project configuration
- Configure both Android and iOS apps automatically

#### C. Enable Firebase Services
In Firebase Console (https://console.firebase.google.com):
1. **Enable Firebase Storage**:
   - Go to Storage → Get Started
   - Choose "Start in production mode" or "test mode"
   - Note: For production, configure proper security rules

2. **Enable Cloud Firestore**:
   - Go to Firestore Database → Create Database
   - Choose "Start in production mode" or "test mode"
   - Select your preferred region

3. **Security Rules** (for testing):
   
   **Storage Rules** (allow read/write for testing):
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /dockets/temp/{allPaths=**} {
         allow read, write: if true;  // Change for production
       }
     }
   }
   ```
   
   **Firestore Rules** (allow read/write for testing):
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /temp_dockets/{document=**} {
         allow read, write: if true;  // Change for production
       }
     }
   }
   ```

### 3. Platform-Specific Setup

#### Android
Permissions are already configured in `android/app/src/main/AndroidManifest.xml`:
- Camera permission
- Storage permissions (for different Android versions)
- Internet permission

No additional setup required.

#### iOS
Usage descriptions are already configured in `ios/Runner/Info.plist`:
- NSCameraUsageDescription
- NSPhotoLibraryAddUsageDescription
- NSPhotoLibraryUsageDescription

Set minimum iOS version (optional):
1. Open `ios/Podfile`
2. Uncomment and set: `platform :ios, '12.0'`

### 4. Run the App

#### Android
```bash
flutter run
```

#### iOS (requires macOS)
```bash
cd ios
pod install
cd ..
flutter run
```

## File Naming Convention
Uploaded files follow this pattern:
```
[YYYY-MM-DD]_[Category]_0.jpg
```

Examples:
- `2025-11-11_Electrical_0.jpg`
- `2025-11-11_Plumbing_0.jpg`

## Firebase Structure

### Storage Path
```
dockets/
  temp/
    2025-11-11_Electrical_0.jpg
    2025-11-11_Plumbing_0.jpg
    ...
```

### Firestore Collection: `temp_dockets`
Each document contains:
```json
{
  "filename": "2025-11-11_Electrical_0.jpg",
  "category": "Electrical",
  "storagePath": "dockets/temp/2025-11-11_Electrical_0.jpg",
  "downloadURL": "https://firebasestorage.googleapis.com/...",
  "createdAt": "2025-11-11T10:30:00Z",
  "devicePlatform": "android" // or "ios"
}
```

## Troubleshooting

### Firebase Initialization Failed
- Ensure `flutterfire configure` was run successfully
- Check that `lib/firebase_options.dart` exists and has valid credentials
- Verify internet connection

### Camera Permission Denied
- **Android**: Grant camera permission in app settings
- **iOS**: Grant camera permission when prompted

### Upload Failed
- Check Firebase Storage is enabled
- Verify Firestore is enabled
- Check internet connection
- Review Firebase Console for security rule errors

### Compression Issues
- App targets <= 300 KB compressed images
- If compression fails, original image is uploaded
- Check logs for compression details

## Testing Checklist
- [ ] Select category - Upload button disabled until photo taken
- [ ] Take photo - Shows preview
- [ ] Upload - Shows progress (0-100%)
- [ ] Success - Clears image, shows success message with filename
- [ ] Firebase Storage contains file with correct naming
- [ ] Firestore has document with all required fields
- [ ] Cancel camera - No crash, handled gracefully
- [ ] Offline - Shows friendly error message

## Production Considerations
1. **Security Rules**: Update Firebase rules for production
2. **Authentication**: Add user authentication
3. **Image Optimization**: Current target is 300 KB
4. **Error Tracking**: Integrate Crashlytics or Sentry
5. **File Management**: Implement cleanup/archival strategy
6. **UI/UX**: Add loading states, better error messages
7. **Testing**: Write unit and integration tests

## Support
For issues or questions, refer to:
- [Flutter Documentation](https://docs.flutter.dev)
- [Firebase Flutter Documentation](https://firebase.flutter.dev)
- [FlutterFire CLI](https://github.com/invertase/flutterfire_cli)
