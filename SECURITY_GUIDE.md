# Security Guide for Git Upload

## ✅ Safe to Commit
The following files are already protected and safe to upload:

- ✅ All source code (`lib/`)
- ✅ Documentation files
- ✅ Platform configurations (AndroidManifest.xml, Info.plist)
- ✅ `.env.example` (template with placeholder values)
- ✅ `lib/firebase_options.dart` (currently has MY_* placeholders)

## ❌ NEVER Commit These Files
These are in `.gitignore` and contain sensitive credentials:

- ❌ `.env` (your actual Firebase credentials)
- ❌ `lib/firebase_options.dart` (after running flutterfire configure)
- ❌ `android/app/google-services.json`
- ❌ `ios/Runner/GoogleService-Info.plist`
- ❌ `macos/Runner/GoogleService-Info.plist`

## How to Use .env File

### Step 1: Fill in Your Credentials
Open `.env` file and add your Firebase credentials:
```
ANDROID_API_KEY=AIzaSyC...your_actual_key
ANDROID_APP_ID=1:123456789:android:abc123...
# etc.
```

### Step 2: Verify .env is Ignored
```bash
git status
# You should NOT see .env listed
```

### Step 3: Share Template with Team
The `.env.example` file can be committed safely. Team members copy it:
```bash
cp .env.example .env
# Then fill in their own credentials
```

## Before First Git Push

### 1. Verify Firebase Files are Ignored
```bash
cd /Users/demonking/Developer/SLT-FlutterIntern-task/sltinternapp
git status
```

You should NOT see:
- `.env`
- `lib/firebase_options.dart` (if it has real credentials)
- Any `google-services.json` or `GoogleService-Info.plist`

### 2. Check What Will Be Committed
```bash
git add .
git status
```

Review the list carefully. If you see any sensitive files, stop and add them to `.gitignore`.

### 3. Safe First Commit
```bash
git commit -m "Initial commit: Docket app with environment template"
```

## If You Accidentally Committed Secrets

### ⚠️ Emergency Fix
If you already committed sensitive files:

```bash
# Remove from Git but keep locally
git rm --cached .env
git rm --cached lib/firebase_options.dart

# Commit the removal
git commit -m "Remove sensitive files from version control"

# Force push to overwrite history (if already pushed to GitHub)
git push --force
```

### ⚠️ Rotate All Credentials
If secrets were pushed to GitHub:
1. Go to Firebase Console
2. Regenerate all API keys
3. Update your local `.env` file
4. Delete and recreate the GitHub repository

## Recommended Workflow

### For Local Development
1. Keep actual credentials in `.env`
2. Run `flutterfire configure` to generate `firebase_options.dart`
3. Both files are automatically ignored by Git

### For Team Sharing
1. Share `.env.example` template
2. Each team member creates their own `.env`
3. Each team member runs `flutterfire configure` for their own Firebase project

### For Production
1. Use CI/CD secrets (GitHub Actions, GitLab CI, etc.)
2. Inject credentials at build time
3. Never hardcode in source code

## Current Status

✅ `.gitignore` is configured  
✅ `.env.example` template created  
✅ `.env` file created (empty, ready for your credentials)  
✅ `lib/firebase_options.dart` has placeholders only  

**You are safe to proceed with Git initialization and GitHub upload!**
