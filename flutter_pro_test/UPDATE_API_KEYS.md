# 🔑 API Key Update Instructions

## 🚨 URGENT: Update Required

The old API keys were exposed in Git history and need to be replaced with new ones.

---

## 📋 Steps to Update API Keys

### 1. Generate New Firebase API Keys

#### Option A: Google Cloud Console (Recommended)
1. Go to: https://console.cloud.google.com/
2. Select project: `carenow-app-2024`
3. Navigate to: **APIs & Services** → **Credentials**
4. For each API key:
   - Click on the key name
   - Click **"Regenerate Key"** or delete and create new
   - Copy the new key immediately
   - Set proper restrictions (HTTP referrers, package names, API restrictions)

#### Option B: Firebase Console
1. Go to: https://console.firebase.google.com/
2. Select project: `carenow-app-2024`
3. Go to: **Project Settings** → **General**
4. Download new configuration files for each platform

### 2. Update Local Configuration

#### Update .env file:
```bash
# Edit .env with new API keys
FIREBASE_WEB_API_KEY=NEW_WEB_API_KEY_HERE
FIREBASE_ANDROID_API_KEY=NEW_ANDROID_API_KEY_HERE
FIREBASE_IOS_API_KEY=NEW_IOS_API_KEY_HERE
```

#### Update .real files:
```bash
# Update the backup files with new keys
# ios/Runner/GoogleService-Info.plist.real
# android/app/google-services.json.real
# macos/Runner/GoogleService-Info.plist.real
```

#### Copy to active files:
```bash
# Run the security setup script
./setup_firebase_security.sh
```

### 3. Test the New Configuration

```bash
# Test that the app still works with new keys
flutter run
```

### 4. Verify Security

```bash
# Make sure no real keys are in committed files
grep -r "AIzaSy" . --exclude="*.real" --exclude=".env"
# Should only show placeholder values
```

---

## 🔒 API Key Security Best Practices

### Set Proper Restrictions:

#### Web API Key:
- **Application restrictions**: HTTP referrers
- **Allowed referrers**: 
  - `localhost:*/*`
  - `your-domain.com/*`
  - `*.your-domain.com/*`

#### Android API Key:
- **Application restrictions**: Android apps
- **Package name**: `com.example.flutter_pro_test`
- **SHA-1 certificate fingerprint**: Your app's fingerprint

#### iOS API Key:
- **Application restrictions**: iOS apps
- **Bundle ID**: `com.example.flutterProTest`

### API Restrictions:
Limit each key to only the APIs it needs:
- Firebase Authentication API
- Cloud Firestore API
- Firebase Storage API
- Firebase Cloud Messaging API

---

## 🧹 Optional: Clean Git History

If you want to remove the exposed keys from Git history entirely:

### ⚠️ WARNING: This rewrites Git history and affects all collaborators

```bash
# Install git-filter-repo (if not installed)
pip install git-filter-repo

# Remove sensitive data from history
git filter-repo --invert-paths --path-regex 'firebase_options\.dart|GoogleService-Info\.plist|google-services\.json'

# Force push (⚠️ DANGEROUS - coordinate with team)
git push --force-with-lease origin main
```

### Alternative: Use GitHub's built-in tool
1. Go to your GitHub repository
2. Settings → Security → Secret scanning alerts
3. Follow GitHub's guidance for removing sensitive data

---

## ✅ Verification Checklist

- [ ] New API keys generated in Firebase/Google Cloud Console
- [ ] Old API keys deleted/disabled
- [ ] Local `.env` file updated with new keys
- [ ] All `.real` files updated with new keys
- [ ] App tested and working with new configuration
- [ ] No real API keys in committed files (security check passed)
- [ ] API key restrictions properly configured
- [ ] Team notified of the update (if applicable)

---

## 📞 Need Help?

If you encounter issues:
1. Check Firebase Console for any error messages
2. Verify API key restrictions aren't too restrictive
3. Ensure all platforms have the correct configuration
4. Test with a simple Firebase operation first

Remember: **Security first!** It's better to be overly cautious with API keys.
