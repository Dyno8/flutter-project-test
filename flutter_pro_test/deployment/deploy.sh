#!/bin/bash

# 🚀 CareNow MVP Admin Dashboard - Automated Deployment Script
# This script automates the deployment process for the admin dashboard

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="CareNow MVP Admin Dashboard"
VERSION="1.0.0"
BUILD_DIR="build"
DEPLOYMENT_LOG="deployment/deployment.log"

# Functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$DEPLOYMENT_LOG"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$DEPLOYMENT_LOG"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$DEPLOYMENT_LOG"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$DEPLOYMENT_LOG"
    exit 1
}

# Create deployment log
mkdir -p deployment
echo "=== $PROJECT_NAME Deployment Log ===" > "$DEPLOYMENT_LOG"
echo "Deployment started at: $(date)" >> "$DEPLOYMENT_LOG"

# Banner
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    🚀 CareNow MVP Deployment                 ║"
echo "║                   Admin Dashboard v$VERSION                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check deployment target
if [ -z "$1" ]; then
    echo "Usage: ./deploy.sh [web|android|ios|all]"
    echo "Example: ./deploy.sh web"
    exit 1
fi

DEPLOYMENT_TARGET="$1"

# Pre-deployment checks
log "🔍 Running pre-deployment checks..."

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    error "Flutter is not installed or not in PATH"
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
log "Flutter version: $FLUTTER_VERSION"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    error "Not in Flutter project directory. Please run from project root."
fi

# Check for environment file
if [ ! -f ".env" ]; then
    warning "No .env file found. Using default configuration."
fi

# Clean previous builds
log "🧹 Cleaning previous builds..."
flutter clean
rm -rf "$BUILD_DIR"

# Get dependencies
log "📦 Installing dependencies..."
flutter pub get

# Run tests
log "🧪 Running tests..."
if ! flutter test; then
    error "Tests failed. Deployment aborted."
fi
success "All tests passed"

# Security check
log "🔐 Running security checks..."
if grep -r "AIza[A-Za-z0-9_-]*" lib/ --exclude-dir=.git 2>/dev/null; then
    error "Potential API key leak detected in source code"
fi
success "Security check passed"

# Build based on target
case $DEPLOYMENT_TARGET in
    "web")
        log "🌐 Building for web deployment..."
        flutter build web --release --web-renderer html
        
        if [ -d "build/web" ]; then
            success "Web build completed successfully"
            
            # Optional: Deploy to Firebase Hosting
            if command -v firebase &> /dev/null; then
                log "🔥 Deploying to Firebase Hosting..."
                firebase deploy --only hosting
                success "Deployed to Firebase Hosting"
            else
                warning "Firebase CLI not found. Manual deployment required."
            fi
        else
            error "Web build failed"
        fi
        ;;
        
    "android")
        log "🤖 Building for Android deployment..."
        
        # Check for signing configuration
        if [ ! -f "android/key.properties" ]; then
            warning "No signing configuration found. Building debug version."
            flutter build apk --debug
        else
            flutter build appbundle --release
            flutter build apk --release
        fi
        
        if [ -f "build/app/outputs/flutter-apk/app-release.apk" ] || [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
            success "Android build completed successfully"
            log "APK location: build/app/outputs/flutter-apk/"
            if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
                log "App Bundle location: build/app/outputs/bundle/release/"
            fi
        else
            error "Android build failed"
        fi
        ;;
        
    "ios")
        log "🍎 Building for iOS deployment..."
        
        # Check if running on macOS
        if [[ "$OSTYPE" != "darwin"* ]]; then
            error "iOS builds require macOS"
        fi
        
        flutter build ios --release --no-codesign
        
        if [ -d "build/ios/iphoneos/Runner.app" ]; then
            success "iOS build completed successfully"
            log "iOS app location: build/ios/iphoneos/"
            warning "Manual code signing and App Store upload required"
        else
            error "iOS build failed"
        fi
        ;;
        
    "all")
        log "🌍 Building for all platforms..."
        
        # Web
        log "Building web..."
        flutter build web --release --web-renderer html
        
        # Android
        log "Building Android..."
        if [ -f "android/key.properties" ]; then
            flutter build appbundle --release
            flutter build apk --release
        else
            flutter build apk --debug
        fi
        
        # iOS (only on macOS)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            log "Building iOS..."
            flutter build ios --release --no-codesign
        else
            warning "Skipping iOS build (requires macOS)"
        fi
        
        success "Multi-platform build completed"
        ;;
        
    *)
        error "Invalid deployment target: $DEPLOYMENT_TARGET"
        ;;
esac

# Post-deployment tasks
log "📊 Generating deployment report..."

# Create deployment report
REPORT_FILE="deployment/deployment_report_$(date +%Y%m%d_%H%M%S).md"
cat > "$REPORT_FILE" << EOF
# Deployment Report - $PROJECT_NAME

**Date**: $(date)
**Version**: $VERSION
**Target**: $DEPLOYMENT_TARGET
**Deployed By**: $(whoami)

## Build Information
- Flutter Version: $FLUTTER_VERSION
- Build Type: Release
- Target Platform: $DEPLOYMENT_TARGET

## Files Generated
EOF

# List generated files
if [ "$DEPLOYMENT_TARGET" = "web" ] || [ "$DEPLOYMENT_TARGET" = "all" ]; then
    if [ -d "build/web" ]; then
        echo "- Web build: build/web/" >> "$REPORT_FILE"
        echo "- Size: $(du -sh build/web | cut -f1)" >> "$REPORT_FILE"
    fi
fi

if [ "$DEPLOYMENT_TARGET" = "android" ] || [ "$DEPLOYMENT_TARGET" = "all" ]; then
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        echo "- Android APK: build/app/outputs/flutter-apk/app-release.apk" >> "$REPORT_FILE"
        echo "- APK Size: $(du -sh build/app/outputs/flutter-apk/app-release.apk | cut -f1)" >> "$REPORT_FILE"
    fi
    if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
        echo "- Android Bundle: build/app/outputs/bundle/release/app-release.aab" >> "$REPORT_FILE"
        echo "- Bundle Size: $(du -sh build/app/outputs/bundle/release/app-release.aab | cut -f1)" >> "$REPORT_FILE"
    fi
fi

if [ "$DEPLOYMENT_TARGET" = "ios" ] || [ "$DEPLOYMENT_TARGET" = "all" ]; then
    if [ -d "build/ios/iphoneos/Runner.app" ]; then
        echo "- iOS App: build/ios/iphoneos/Runner.app" >> "$REPORT_FILE"
        echo "- App Size: $(du -sh build/ios/iphoneos/Runner.app | cut -f1)" >> "$REPORT_FILE"
    fi
fi

cat >> "$REPORT_FILE" << EOF

## Next Steps
1. Test the deployed application
2. Monitor system performance
3. Collect user feedback
4. Plan next iteration

## Support
- Technical issues: [Your Email]
- User support: [Support Email]
EOF

success "Deployment report generated: $REPORT_FILE"

# Final success message
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    🎉 Deployment Complete!                   ║"
echo "║                                                              ║"
echo "║  Your CareNow MVP Admin Dashboard has been successfully      ║"
echo "║  built and is ready for deployment to $DEPLOYMENT_TARGET environment.     ║"
echo "║                                                              ║"
echo "║  Check the deployment report for detailed information.       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

log "🎯 Deployment completed successfully for target: $DEPLOYMENT_TARGET"
echo "Deployment completed at: $(date)" >> "$DEPLOYMENT_LOG"

# Open deployment report
if command -v open &> /dev/null; then
    open "$REPORT_FILE"
elif command -v xdg-open &> /dev/null; then
    xdg-open "$REPORT_FILE"
fi
