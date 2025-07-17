#!/bin/bash

# CareNow MVP - Development Firebase Setup Script
# This script sets up Firebase configuration for development

set -e  # Exit on any error

echo "🔧 CareNow MVP - Development Firebase Setup"
echo "=========================================="

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
if [ -z "$FIREBASE_ANDROID_API_KEY" ]; then
    echo "❌ Error: FIREBASE_ANDROID_API_KEY is not set in .env file"
    exit 1
fi

# Create development google-services.json with real API key
echo "🔑 Creating development google-services.json..."
cp android/app/google-services.json android/app/google-services.json.template
sed "s/YOUR_ANDROID_API_KEY_HERE/$FIREBASE_ANDROID_API_KEY/g" android/app/google-services.json.template > android/app/google-services.json.dev

echo "✅ Development Firebase configuration created!"
echo ""
echo "📁 Files created:"
echo "  - android/app/google-services.json.dev (with real API key)"
echo "  - android/app/google-services.json.template (backup)"
echo ""
echo "🚀 To use for development:"
echo "  cp android/app/google-services.json.dev android/app/google-services.json"
echo ""
echo "⚠️  Remember to restore template before committing:"
echo "  cp android/app/google-services.json.template android/app/google-services.json"
