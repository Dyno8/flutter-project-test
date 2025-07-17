#!/bin/bash

# CareNow MVP - Secure Android Build Script
# This script builds the Android app with environment variables loaded securely

set -e  # Exit on any error

echo "🚀 CareNow MVP - Secure Android Build"
echo "======================================"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found!"
    echo "Please copy .env.example to .env and configure your Firebase keys"
    echo "Command: cp .env.example .env"
    exit 1
fi

# Load environment variables
echo "📋 Loading environment variables..."
export $(cat .env | grep -v '^#' | xargs)

# Validate required environment variables
required_vars=(
    "FIREBASE_ANDROID_API_KEY"
    "FIREBASE_ANDROID_APP_ID"
    "FIREBASE_PROJECT_ID"
    "FIREBASE_MESSAGING_SENDER_ID"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: Required environment variable $var is not set"
        exit 1
    fi
done

echo "✅ Environment variables validated"

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Inject API key into google-services.json temporarily
echo "🔑 Injecting API key into google-services.json..."
cp android/app/google-services.json android/app/google-services.json.backup
sed -i.tmp "s/YOUR_ANDROID_API_KEY_HERE/$FIREBASE_ANDROID_API_KEY/g" android/app/google-services.json

# Build Android APK with environment variables
echo "🔨 Building Android APK..."
flutter build apk --debug \
    --dart-define=FIREBASE_ANDROID_API_KEY="$FIREBASE_ANDROID_API_KEY" \
    --dart-define=FIREBASE_ANDROID_APP_ID="$FIREBASE_ANDROID_APP_ID" \
    --dart-define=FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
    --dart-define=FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID" \
    --dart-define=FIREBASE_STORAGE_BUCKET="$FIREBASE_STORAGE_BUCKET" \
    --dart-define=FIREBASE_DATABASE_URL="$FIREBASE_DATABASE_URL"

# Restore original google-services.json
echo "🔄 Restoring original google-services.json..."
mv android/app/google-services.json.backup android/app/google-services.json
rm -f android/app/google-services.json.tmp

echo "✅ Android APK built successfully!"
echo "📱 APK location: build/app/outputs/flutter-apk/app-debug.apk"
echo ""
echo "🔧 To install on device:"
echo "flutter install --debug -d <device-id>"
