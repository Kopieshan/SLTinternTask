# 🎫 Docket Demo App

A production-ready Flutter application for creating complaint tickets (dockets) with native camera integration, image compression, and Firebase backend.

[![Flutter](https://img.shields.io/badge/Flutter-3.6%2B-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📱 Features

- **5 Predefined Categories**: Electrical, Plumbing, Cleaning, Security, Other
- **Native Camera Integration**: Take photos directly from the app
- **Automatic Image Compression**: Target ≤ 300 KB file size
- **Firebase Storage Upload**: Real-time progress tracking (0-100%)
- **Firestore Metadata**: Automatic document creation with timestamps
- **Platform Detection**: Tracks Android or iOS device
- **Error Handling**: Graceful handling of permissions, network issues, and cancellations

## 🎯 File Naming Convention

Uploaded files follow this pattern:
```
[YYYY-MM-DD]_[Category]_0.jpg
```

Examples:
- `2025-11-11_Electrical_0.jpg`
- `2025-11-11_Plumbing_0.jpg`
- `2025-11-11_Cleaning_0.jpg`

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.6.0 or higher
- Dart 3.0+ (null safety)
- Firebase account
- Node.js (for Firebase CLI)

### Installation

1. **Clone and navigate to project**:
   ```bash
   cd sltinternapp
   flutter pub get
   ```

2. **Configure Firebase**:
   ```bash
   # Install Firebase tools
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   
   # Login and configure
   firebase login
   flutterfire configure
   ```

3. **Enable Firebase services** in [Firebase Console](https://console.firebase.google.com):
   - Enable Firebase Storage
   - Enable Cloud Firestore
   - Set security rules to test mode (see [QUICKSTART.md](QUICKSTART.md))

4. **Run the app**:
   ```bash
   flutter run
   ```

For iOS (requires macOS):
```bash
cd ios && pod install && cd ..
flutter run
```

## 📖 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute setup guide (START HERE!)
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Complete feature documentation
- **[CHECKLIST.md](CHECKLIST.md)** - Testing and validation checklist
- **[README_SETUP.md](README_SETUP.md)** - Detailed setup instructions
- **[BUILD_SUMMARY.txt](BUILD_SUMMARY.txt)** - Visual build summary

## 🗄️ Firebase Structure

### Storage Path
```
dockets/
  └── temp/
      ├── 2025-11-11_Electrical_0.jpg
      ├── 2025-11-11_Plumbing_0.jpg
      └── ...
```

### Firestore Collection: `temp_dockets`
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

## 🎨 Screenshots

### Main Interface
```
┌─────────────────────────────────┐
│     🎫 Docket Demo              │
├─────────────────────────────────┤
│ Select Category                 │
│ ┌─────────────────────────────┐ │
│ │ Choose a category       ▼   │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  📷 Take Photo              │ │
│ └─────────────────────────────┘ │
│                                 │
│ [Image Preview]                 │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  ☁️ Upload                  │ │
│ └─────────────────────────────┘ │
│ [████████░░] 80%               │
└─────────────────────────────────┘
```

## 🧪 Testing

### Quick Test Flow
1. Select a category from dropdown
2. Tap "Take Photo" → Camera opens
3. Capture image → Preview appears
4. Tap "Upload" → Progress bar shows 0-100%
5. Success message displays with filename

### Verify in Firebase Console
- **Storage**: Check `dockets/temp/[filename]` exists
- **Firestore**: Check `temp_dockets` collection has new document

See [CHECKLIST.md](CHECKLIST.md) for complete testing checklist.

## 🔧 Troubleshooting

| Problem | Solution |
|---------|----------|
| Firebase initialization error | Run `flutterfire configure` |
| Camera permission denied | Grant permission in device settings |
| Upload fails | Enable Storage & Firestore in Firebase Console |
| iOS build fails | `cd ios && rm -rf Pods && pod install && cd ..` |

## 📦 Dependencies

- `firebase_core: ^3.8.1` - Firebase initialization
- `firebase_storage: ^12.3.8` - File storage
- `cloud_firestore: ^5.5.1` - Database
- `image_picker: ^1.1.2` - Camera access
- `flutter_image_compress: ^2.3.0` - Image compression
- `path: ^1.9.0` - Path manipulation
- `path_provider: ^2.1.5` - Directory access

## ⚠️ Security Notes

**Current Configuration**: Test mode (development only)

For production:
1. Implement Firebase Authentication
2. Update Storage rules to require authentication
3. Update Firestore rules to require authentication
4. Add file validation and rate limiting
5. Implement malware scanning

See [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) for production security recommendations.

## 🛠️ Built With

- **Flutter** 3.6+ - UI framework
- **Dart** 3.0+ - Programming language
- **Firebase** - Backend services
- **Material Design** - UI components

## 📋 Project Structure

```
sltinternapp/
├── lib/
│   ├── main.dart              # Main app implementation
│   └── firebase_options.dart  # Firebase config (auto-generated)
├── android/                   # Android configuration
├── ios/                       # iOS configuration
├── test/                      # Unit tests
└── Documentation files        # Setup guides and checklists
```

## 🎯 Requirements Checklist

- ✅ 5 predefined categories
- ✅ Native camera integration (Android & iOS)
- ✅ Image compression (≤ 300 KB target)
- ✅ Firebase Storage upload with progress
- ✅ Firestore metadata storage
- ✅ File naming: `[YYYY-MM-DD]_[Category]_0.jpg`
- ✅ Permission handling
- ✅ Error handling
- ✅ Success notifications
- ✅ Clean, production-ready code

## 👨‍💻 Development

### Code Quality
```bash
flutter analyze          # Static analysis
flutter test             # Run tests
flutter format lib/      # Format code
```

### Building
```bash
# Android
flutter build apk

# iOS (requires macOS)
flutter build ios
```

## 🚀 Next Steps

Future enhancements:
- [ ] User authentication
- [ ] View upload history
- [ ] Edit/delete dockets
- [ ] GPS location tracking
- [ ] Multiple photo support
- [ ] Offline mode with queue
- [ ] Push notifications
- [ ] Dark mode theme
- [ ] Unit and integration tests

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

## 💬 Support

For issues or questions:
1. Check the documentation files
2. Review [QUICKSTART.md](QUICKSTART.md) and [CHECKLIST.md](CHECKLIST.md)
3. Check [Flutter Documentation](https://docs.flutter.dev)
4. Check [Firebase Documentation](https://firebase.flutter.dev)

## ✨ Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend services
- Community plugin developers

---

**Ready to get started?** Follow [QUICKSTART.md](QUICKSTART.md) for a 5-minute setup! 🚀

