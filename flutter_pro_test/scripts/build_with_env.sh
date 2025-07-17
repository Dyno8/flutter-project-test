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
