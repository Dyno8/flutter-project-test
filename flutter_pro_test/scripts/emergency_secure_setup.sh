#!/bin/bash

# Emergency Firebase Security Setup Script
# This script helps secure Firebase configuration after API key exposure

set -e

echo "🚨 EMERGENCY FIREBASE SECURITY SETUP 🚨"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: Please run this script from the Flutter project root directory${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Creating secure environment file...${NC}"

# Create .env file with placeholder values
cat > .env << EOF
# Firebase Configuration - Development Environment
# Replace these placeholder values with your actual Firebase API keys
# NEVER commit this file to version control

# Web Configuration
FIREBASE_WEB_API_KEY=your-actual-web-api-key-here
FIREBASE_WEB_APP_ID=1:133710469637:web:03e765bcb9d10180d09a6c

# Android Configuration  
FIREBASE_ANDROID_API_KEY=your-actual-android-api-key-here
FIREBASE_ANDROID_APP_ID=1:133710469637:android:5eb0a6e4f88cec8bd09a6c

# iOS Configuration
FIREBASE_IOS_API_KEY=your-actual-ios-api-key-here
FIREBASE_IOS_APP_ID=1:133710469637:ios:cecb666ccd35c6edd09a6c

# Common Configuration
FIREBASE_PROJECT_ID=carenow-app-2024
FIREBASE_MESSAGING_SENDER_ID=133710469637
FIREBASE_AUTH_DOMAIN=carenow-app-2024.firebaseapp.com
FIREBASE_STORAGE_BUCKET=carenow-app-2024.firebasestorage.app
FIREBASE_DATABASE_URL=https://carenow-app-2024-default-rtdb.firebaseio.com/

# iOS Bundle ID
FIREBASE_IOS_BUNDLE_ID=com.carenow.app

# Windows App ID
FIREBASE_WINDOWS_APP_ID=1:133710469637:web:dce0da2cf3cab9cad09a6c
EOF

echo -e "${GREEN}✅ Created .env file with placeholder values${NC}"

echo -e "${YELLOW}Step 2: Updating .gitignore to prevent future exposure...${NC}"

# Ensure .env is in .gitignore
if ! grep -q "^\.env$" .gitignore; then
    echo "" >> .gitignore
    echo "# Environment files - NEVER commit these" >> .gitignore
    echo ".env" >> .gitignore
    echo ".env.*" >> .gitignore
    echo "!.env.example" >> .gitignore
fi

echo -e "${GREEN}✅ Updated .gitignore${NC}"

echo -e "${YELLOW}Step 3: Creating environment example file...${NC}"

# Create .env.example with safe placeholder values
cat > .env.example << EOF
# Firebase Configuration - Example Template
# Copy this file to .env and replace with your actual Firebase API keys
# This file is safe to commit to version control

# Web Configuration
FIREBASE_WEB_API_KEY=your-actual-web-api-key-here
FIREBASE_WEB_APP_ID=your-web-app-id-here

# Android Configuration  
FIREBASE_ANDROID_API_KEY=your-actual-android-api-key-here
FIREBASE_ANDROID_APP_ID=your-android-app-id-here

# iOS Configuration
FIREBASE_IOS_API_KEY=your-actual-ios-api-key-here
FIREBASE_IOS_APP_ID=your-ios-app-id-here

# Common Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project.firebasestorage.app
FIREBASE_DATABASE_URL=https://your-project-default-rtdb.firebaseio.com/

# iOS Bundle ID
FIREBASE_IOS_BUNDLE_ID=com.yourcompany.yourapp

# Windows App ID
FIREBASE_WINDOWS_APP_ID=your-windows-app-id-here
EOF

echo -e "${GREEN}✅ Created .env.example template${NC}"

echo -e "${YELLOW}Step 4: Creating secure build script...${NC}"

# Create secure build script
cat > scripts/build_with_env.sh << 'EOF'
#!/bin/bash

# Secure Build Script with Environment Variables
# This script loads environment variables and builds the app securely

set -e

# Load environment variables
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✅ Loaded environment variables from .env"
else
    echo "❌ Error: .env file not found. Please create it from .env.example"
    exit 1
fi

# Validate required environment variables
required_vars=(
    "FIREBASE_WEB_API_KEY"
    "FIREBASE_ANDROID_API_KEY" 
    "FIREBASE_PROJECT_ID"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ] || [ "${!var}" = "your-actual-${var,,}-here" ]; then
        echo "❌ Error: $var is not set or contains placeholder value"
        echo "Please update your .env file with actual Firebase API keys"
        exit 1
    fi
done

echo "✅ Environment validation passed"

# Build the app
echo "🔨 Building Flutter app with secure configuration..."

case "${1:-web}" in
    "web")
        flutter build web --dart-define-from-file=.env
        ;;
    "android")
        flutter build apk --dart-define-from-file=.env
        ;;
    "ios")
        flutter build ios --dart-define-from-file=.env
        ;;
    *)
        echo "Usage: $0 [web|android|ios]"
        exit 1
        ;;
esac

echo "✅ Build completed successfully"
EOF

chmod +x scripts/build_with_env.sh

echo -e "${GREEN}✅ Created secure build script${NC}"

echo ""
echo -e "${GREEN}🎉 EMERGENCY SECURITY SETUP COMPLETE! 🎉${NC}"
echo ""
echo -e "${YELLOW}NEXT STEPS:${NC}"
echo "1. Edit the .env file and replace placeholder values with your actual Firebase API keys"
echo "2. Run the Git cleanup commands provided separately to remove exposed keys from history"
echo "3. Regenerate your Firebase API keys in the Firebase Console"
echo "4. Test the secure build process: ./scripts/build_with_env.sh web"
echo ""
echo -e "${RED}IMPORTANT: The .env file contains sensitive data and should NEVER be committed!${NC}"
