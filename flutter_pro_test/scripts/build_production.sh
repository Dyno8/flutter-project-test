#!/bin/bash

# 🚀 CareNow MVP - Production Build Script
# This script builds the app for production deployment across all platforms

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
RELEASE_DIR="$PROJECT_ROOT/release"

echo -e "${BLUE}🚀 Starting CareNow MVP Production Build${NC}"
echo -e "${BLUE}Project Root: $PROJECT_ROOT${NC}"

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check Flutter version
    FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
    print_status "Flutter version: $FLUTTER_VERSION"
    
    # Check if we're in a Flutter project
    if [ ! -f "$PROJECT_ROOT/pubspec.yaml" ]; then
        print_error "Not in a Flutter project directory"
        exit 1
    fi
    
    # Check environment file
    if [ ! -f "$PROJECT_ROOT/.env.production" ]; then
        print_warning "Production environment file not found. Using defaults."
    fi
    
    print_status "Prerequisites check completed"
}

# Function to clean previous builds
clean_builds() {
    echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Clean Flutter
    flutter clean
    
    # Remove build directories
    rm -rf "$BUILD_DIR"
    rm -rf "$RELEASE_DIR"
    
    # Create release directory
    mkdir -p "$RELEASE_DIR"
    
    print_status "Build cleanup completed"
}

# Function to install dependencies
install_dependencies() {
    echo -e "${BLUE}📦 Installing dependencies...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Get Flutter dependencies
    flutter pub get
    
    # Run code generation if needed
    if [ -f "$PROJECT_ROOT/build.yaml" ]; then
        flutter packages pub run build_runner build --delete-conflicting-outputs
    fi
    
    print_status "Dependencies installed"
}

# Function to run tests
run_tests() {
    echo -e "${BLUE}🧪 Running tests...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Run unit tests
    flutter test --coverage
    
    # Check test results
    if [ $? -ne 0 ]; then
        print_error "Tests failed. Aborting build."
        exit 1
    fi
    
    print_status "All tests passed"
}

# Function to analyze code
analyze_code() {
    echo -e "${BLUE}🔍 Analyzing code...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Run Flutter analyze
    flutter analyze --no-fatal-infos
    
    if [ $? -ne 0 ]; then
        print_warning "Code analysis found issues. Review before deploying."
    else
        print_status "Code analysis passed"
    fi
}

# Function to build web version
build_web() {
    echo -e "${BLUE}🌐 Building web version...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Build web with production settings
    flutter build web \
        --release \
        --web-renderer html \
        --dart-define=FLUTTER_ENV=production \
        --dart-define-from-file=.env.production \
        --tree-shake-icons \
        --source-maps
    
    # Copy to release directory
    cp -r "$BUILD_DIR/web" "$RELEASE_DIR/web"
    
    print_status "Web build completed"
}

# Function to build Android APK
build_android_apk() {
    echo -e "${BLUE}🤖 Building Android APK...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Build APK with production settings
    flutter build apk \
        --release \
        --dart-define=FLUTTER_ENV=production \
        --dart-define-from-file=.env.production \
        --tree-shake-icons \
        --obfuscate \
        --split-debug-info="$RELEASE_DIR/android-debug-info"
    
    # Copy to release directory
    cp "$BUILD_DIR/app/outputs/flutter-apk/app-release.apk" "$RELEASE_DIR/carenow-production.apk"
    
    print_status "Android APK build completed"
}

# Function to build Android App Bundle
build_android_bundle() {
    echo -e "${BLUE}🤖 Building Android App Bundle...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Build App Bundle with production settings
    flutter build appbundle \
        --release \
        --dart-define=FLUTTER_ENV=production \
        --dart-define-from-file=.env.production \
        --tree-shake-icons \
        --obfuscate \
        --split-debug-info="$RELEASE_DIR/android-debug-info"
    
    # Copy to release directory
    cp "$BUILD_DIR/app/outputs/bundle/release/app-release.aab" "$RELEASE_DIR/carenow-production.aab"
    
    print_status "Android App Bundle build completed"
}

# Function to build iOS (if on macOS)
build_ios() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${BLUE}🍎 Building iOS version...${NC}"
        
        cd "$PROJECT_ROOT"
        
        # Build iOS with production settings
        flutter build ios \
            --release \
            --dart-define=FLUTTER_ENV=production \
            --dart-define-from-file=.env.production \
            --tree-shake-icons \
            --obfuscate \
            --split-debug-info="$RELEASE_DIR/ios-debug-info"
        
        print_status "iOS build completed (requires Xcode for final archive)"
    else
        print_warning "iOS build skipped (not on macOS)"
    fi
}

# Function to generate build report
generate_build_report() {
    echo -e "${BLUE}📊 Generating build report...${NC}"
    
    REPORT_FILE="$RELEASE_DIR/build_report.md"
    
    cat > "$REPORT_FILE" << EOF
# CareNow MVP - Production Build Report

**Build Date:** $(date)
**Flutter Version:** $(flutter --version | head -n 1)
**Environment:** Production

## Build Artifacts

### Web
- Location: \`release/web/\`
- Renderer: HTML
- Source Maps: Enabled

### Android
- APK: \`release/carenow-production.apk\`
- App Bundle: \`release/carenow-production.aab\`
- Obfuscation: Enabled
- Debug Info: \`release/android-debug-info/\`

### iOS
- Build: Completed (requires Xcode archive)
- Debug Info: \`release/ios-debug-info/\`

## Security Features
- Code obfuscation enabled
- Tree shaking enabled
- Debug info separated
- Environment variables secured

## Next Steps
1. Test builds on target devices
2. Upload to app stores
3. Deploy web version to hosting
4. Monitor deployment metrics

---
Generated by CareNow MVP Build Script
EOF

    print_status "Build report generated: $REPORT_FILE"
}

# Main execution
main() {
    echo -e "${BLUE}🏗️  CareNow MVP Production Build Pipeline${NC}"
    echo -e "${BLUE}=========================================${NC}"
    
    check_prerequisites
    clean_builds
    install_dependencies
    run_tests
    analyze_code
    
    echo -e "${BLUE}🚀 Starting platform builds...${NC}"
    
    build_web
    build_android_apk
    build_android_bundle
    build_ios
    
    generate_build_report
    
    echo -e "${GREEN}🎉 Production build completed successfully!${NC}"
    echo -e "${GREEN}Build artifacts available in: $RELEASE_DIR${NC}"
    echo -e "${YELLOW}📋 Review build report: $RELEASE_DIR/build_report.md${NC}"
}

# Run main function
main "$@"
