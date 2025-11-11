# GitHub Repository Setup Guide

## Quick Steps to Create & Upload Your Project

### 1. Initialize Git Repository (if not already done)
```bash
cd /Users/demonking/Developer/SLT-FlutterIntern-task/sltinternapp
git init
```

### 2. Create .gitignore (Already exists, but verify it includes)
Flutter projects should ignore:
- `build/`
- `.dart_tool/`
- `.flutter-plugins`
- `.flutter-plugins-dependencies`
- `.packages`
- `pubspec.lock` (optional)
- `ios/Pods/`
- `macos/Pods/`
- `*.iml`
- `.idea/`

### 3. Stage All Files
```bash
git add .
```

### 4. Create Initial Commit
```bash
git commit -m "Initial commit: Docket app with camera, compression, and Firebase integration"
```

### 5. Create GitHub Repository (Two Options)

#### Option A: Using GitHub Website
1. Go to [github.com](https://github.com)
2. Click the "+" icon in top-right corner → "New repository"
3. Repository name: `docket-flutter-app` (or your preferred name)
4. Description: "Flutter mobile app for documenting maintenance issues with camera, image compression, and Firebase Storage/Firestore integration"
5. Choose **Public** or **Private**
6. **DO NOT** check "Initialize with README" (you already have one)
7. Click "Create repository"
8. Copy the repository URL (e.g., `https://github.com/YOUR_USERNAME/docket-flutter-app.git`)

#### Option B: Using GitHub CLI (if installed)
```bash
# Install GitHub CLI first if you don't have it: brew install gh
gh auth login
gh repo create docket-flutter-app --public --source=. --remote=origin --push
```

### 6. Link Local Repository to GitHub (Option A only)
```bash
git remote add origin https://github.com/YOUR_USERNAME/docket-flutter-app.git
```

### 7. Push Code to GitHub
```bash
git branch -M main
git push -u origin main
```

---

## Verify Upload
After pushing, go to your GitHub repository URL and you should see:
- ✅ All project files
- ✅ README.md displayed on homepage
- ✅ 10 documentation files
- ✅ Complete source code

---

## Important: Protect Your Firebase Credentials!

### CRITICAL SECURITY STEP:
Before making the repository **public**, ensure `lib/firebase_options.dart` is in `.gitignore` or:

1. **Option 1 (Recommended):** Add to `.gitignore`:
```bash
echo "lib/firebase_options.dart" >> .gitignore
git rm --cached lib/firebase_options.dart
git commit -m "Remove Firebase credentials from version control"
git push
```

2. **Option 2:** Use environment variables (advanced)
   - Store credentials in GitHub Secrets
   - Load them at build time

### What's Safe to Push?
✅ All code with `MY_*` placeholders  
✅ Documentation files  
✅ Platform configurations (AndroidManifest.xml, Info.plist)  
❌ Actual Firebase API keys/credentials  
❌ `google-services.json` (Android)  
❌ `GoogleService-Info.plist` (iOS)  

---

## Typical .gitignore for Flutter + Firebase
```gitignore
# Flutter/Dart
build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/

# iOS
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# macOS
macos/Pods/
macos/Flutter/ephemeral/

# Firebase (CRITICAL!)
lib/firebase_options.dart
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

# IDEs
.idea/
*.iml
*.iws
.vscode/
*.swp
.DS_Store
```

---

## After Upload: Share Your Project

### For Your Portfolio:
1. Add a nice README with:
   - Screenshot of the app
   - Feature list
   - Technologies used
   - Setup instructions

2. Add topics/tags on GitHub:
   - `flutter`
   - `dart`
   - `firebase`
   - `mobile-app`
   - `image-compression`
   - `camera`

### For Interviews:
Share the repository URL:
```
https://github.com/YOUR_USERNAME/docket-flutter-app
```

Then mention:
- "I built this Flutter app with camera integration, two-stage image compression targeting 300KB, and Firebase Storage/Firestore backend"
- "The UI follows Material Design 3 guidelines with card-based layouts"
- "I implemented proper error handling and user feedback with progress indicators"
- "The project includes comprehensive documentation for setup and testing"

---

## Common Issues & Fixes

### Issue: "Permission denied (publickey)"
**Fix:** Set up SSH key or use HTTPS with personal access token
```bash
# Use HTTPS instead
git remote set-url origin https://github.com/YOUR_USERNAME/docket-flutter-app.git
```

### Issue: "Repository not found"
**Fix:** Verify repository name and your GitHub username

### Issue: "Large files rejected"
**Fix:** Flutter projects are usually <10MB without build artifacts. If larger:
```bash
# Check .gitignore includes build/ and Pods/
git rm -r --cached build ios/Pods macos/Pods
git commit -m "Remove large build artifacts"
```

---

## Next Steps After GitHub Upload

1. ✅ Verify all files uploaded correctly
2. ✅ Test cloning on a different machine
3. ✅ Add a LICENSE file (MIT is common for portfolios)
4. ✅ Add screenshots to README
5. ✅ Enable GitHub Actions for CI/CD (optional, advanced)

**Your project is now version-controlled and shareable!** 🎉
