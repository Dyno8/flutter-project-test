#!/bin/bash

# 🔐 Firebase Security Setup Script
# This script helps set up secure Firebase configuration for CareNow MVP

set -e

echo "🔐 Firebase Security Setup for CareNow MVP"
echo "=========================================="

# Check if .env.example exists
if [ ! -f ".env.example" ]; then
    echo "❌ Error: .env.example not found!"
    echo "Please run this script from the project root directory."
    exit 1
fi

# Step 1: Copy environment template
echo "📋 Step 1: Setting up environment variables..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "✅ Created .env from template"
else
    echo "⚠️  .env already exists, skipping copy"
fi

# Step 2: Check iOS configuration
echo "📱 Step 2: Checking iOS configuration..."
if [ -f "ios/Runner/GoogleService-Info.plist.real" ]; then
    if [ ! -f "ios/Runner/GoogleService-Info.plist" ] || [ "ios/Runner/GoogleService-Info.plist.real" -nt "ios/Runner/GoogleService-Info.plist" ]; then
        cp ios/Runner/GoogleService-Info.plist.real ios/Runner/GoogleService-Info.plist
        echo "✅ Updated iOS GoogleService-Info.plist from real configuration"
    else
        echo "✅ iOS configuration is up to date"
    fi
else
    echo "⚠️  Real iOS configuration not found (ios/Runner/GoogleService-Info.plist.real)"
    echo "   You'll need to download it from Firebase Console"
fi

# Step 3: Verify .gitignore
echo "🔒 Step 3: Verifying security settings..."
if grep -q "^\.env$" .gitignore; then
    echo "✅ .env is properly gitignored"
else
    echo "❌ Warning: .env is not gitignored!"
    echo "   Please add '.env' to your .gitignore file"
fi

# Step 4: Security check
echo "🔍 Step 4: Running security check..."
echo "Checking for exposed API keys..."

# Check for potential API key leaks (excluding safe files)
if grep -r "AIza[A-Za-z0-9_-]*" . \
    --exclude-dir=.git \
    --exclude="*.real" \
    --exclude=".env" \
    --exclude="setup_firebase_security.sh" \
    --exclude="SECURITY_SETUP.md" \
    --include="*.dart" \
    --include="*.plist" \
    --include="*.json" 2>/dev/null | grep -v "your-.*-api-key-here" | grep -v "String.fromEnvironment"; then
    echo "❌ WARNING: Potential API key exposure detected!"
    echo "   Please review the files above and ensure no real API keys are committed."
else
    echo "✅ No exposed API keys detected"
fi

# Step 5: Instructions
echo ""
echo "🎯 Next Steps:"
echo "=============="
echo "1. Edit .env file with your actual Firebase configuration values"
echo "2. Get Firebase config from: https://console.firebase.google.com/"
echo "3. Never commit the .env file to version control"
echo "4. For iOS: Download GoogleService-Info.plist from Firebase Console if needed"
echo ""
echo "📖 For detailed instructions, see: SECURITY_SETUP.md"
echo ""

# Step 6: Verify environment setup
echo "🧪 Step 6: Testing environment setup..."
if [ -f ".env" ]; then
    # Check if .env has been customized (not just the template)
    if grep -q "your-.*-here" .env; then
        echo "⚠️  .env file still contains template values"
        echo "   Please update .env with your actual Firebase configuration"
    else
        echo "✅ .env file appears to be configured"
    fi
fi

echo ""
echo "🔐 Security setup complete!"
echo "Remember: Always keep your API keys secure and never commit them to version control."
