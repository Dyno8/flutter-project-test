# Firebase Security Configuration - CareNow MVP

## 🔒 Security Overview

This document outlines the secure Firebase configuration practices implemented in the CareNow MVP to prevent API key exposure and maintain production security standards.

## 🚨 Security Principles

1. **Never commit real API keys** to version control
2. **Use environment variables** for sensitive configuration
3. **Implement build-time injection** for production builds
4. **Maintain template files** with placeholder values

## 📁 File Structure

```
android/app/
├── google-services.json          # Template with placeholders (COMMITTED)
├── google-services.json.dev      # Development with real keys (IGNORED)
├── google-services.json.real     # Production with real keys (IGNORED)
└── google-services.json.backup   # Temporary backup (IGNORED)
```

## 🔧 Development Setup

### 1. Initial Setup
```bash
# Copy environment template
cp .env.example .env

# Edit .env with your Firebase configuration
nano .env

# Setup development Firebase configuration
./scripts/setup_firebase_dev.sh
```

### 2. Development Workflow
```bash
# For development (use real API keys)
cp android/app/google-services.json.dev android/app/google-services.json
flutter run

# Before committing (restore template)
cp android/app/google-services.json.template android/app/google-services.json
git add .
git commit -m "Your commit message"
```

## 🚀 Production Build

### Secure Build Process
```bash
# Use the secure build script
./scripts/build_android_secure.sh
```

This script:
1. Validates environment variables
2. Temporarily injects real API keys
3. Builds the APK
4. Restores template file
5. Cleans up temporary files

## 🔐 Environment Variables

Required in `.env` file:
```bash
FIREBASE_ANDROID_API_KEY=your-real-android-api-key
FIREBASE_ANDROID_APP_ID=your-android-app-id
FIREBASE_PROJECT_ID=carenow-app-2024
FIREBASE_MESSAGING_SENDER_ID=133710469637
FIREBASE_STORAGE_BUCKET=carenow-app-2024.firebasestorage.app
FIREBASE_DATABASE_URL=https://carenow-app-2024-default-rtdb.firebaseio.com/
```

## ⚠️ Security Checklist

Before each commit:
- [ ] `google-services.json` contains only placeholder values
- [ ] `.env` file is not committed
- [ ] No real API keys in any committed files
- [ ] Development files (`.dev`, `.real`) are gitignored

## 🔍 Security Verification

```bash
# Check for exposed API keys
grep -r "AIzaSy" . --exclude-dir=.git --exclude="*.md"

# Verify git status
git status --porcelain | grep -E "(google-services|\.env)"

# Check gitignore effectiveness
git check-ignore android/app/google-services.json.dev
```

## 🚨 Security Incident Response

If API keys are accidentally committed:
1. **Immediately rotate** the exposed API keys in Firebase Console
2. **Remove** the keys from Git history using `git filter-branch` or BFG
3. **Update** all team members with new keys
4. **Review** and strengthen security practices

## 📞 Support

For security questions or incidents, contact the development team immediately.
