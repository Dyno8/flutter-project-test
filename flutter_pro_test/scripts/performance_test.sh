#!/bin/bash

# 🚀 CareNow MVP - Performance Testing Script
# This script runs comprehensive performance tests for production readiness

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
REPORTS_DIR="$PROJECT_ROOT/performance_reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo -e "${BLUE}🚀 Starting CareNow MVP Performance Testing${NC}"
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
    
    # Check if we're in a Flutter project
    if [ ! -f "$PROJECT_ROOT/pubspec.yaml" ]; then
        print_error "Not in a Flutter project directory"
        exit 1
    fi
    
    # Create reports directory
    mkdir -p "$REPORTS_DIR"
    
    print_status "Prerequisites check completed"
}

# Function to run Flutter analyze
run_flutter_analyze() {
    echo -e "${BLUE}🔍 Running Flutter analyze...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Run analyze and capture output
    ANALYZE_OUTPUT="$REPORTS_DIR/flutter_analyze_$TIMESTAMP.txt"
    
    if flutter analyze --no-fatal-infos > "$ANALYZE_OUTPUT" 2>&1; then
        print_status "Flutter analyze completed successfully"
    else
        print_warning "Flutter analyze found issues. Check report: $ANALYZE_OUTPUT"
    fi
    
    # Count issues
    ISSUE_COUNT=$(grep -c "info\|warning\|error" "$ANALYZE_OUTPUT" || echo "0")
    echo -e "${BLUE}Total issues found: $ISSUE_COUNT${NC}"
}

# Function to run unit tests with coverage
run_unit_tests() {
    echo -e "${BLUE}🧪 Running unit tests with coverage...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Run tests with coverage
    TEST_OUTPUT="$REPORTS_DIR/test_results_$TIMESTAMP.txt"
    COVERAGE_OUTPUT="$REPORTS_DIR/coverage_$TIMESTAMP"
    
    if flutter test --coverage --reporter=expanded > "$TEST_OUTPUT" 2>&1; then
        print_status "Unit tests completed successfully"
        
        # Generate coverage report
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o "$COVERAGE_OUTPUT"
            print_status "Coverage report generated: $COVERAGE_OUTPUT/index.html"
        else
            print_warning "genhtml not found. Install lcov for HTML coverage reports."
        fi
    else
        print_error "Unit tests failed. Check report: $TEST_OUTPUT"
        return 1
    fi
    
    # Extract test statistics
    TOTAL_TESTS=$(grep -o "All tests passed!" "$TEST_OUTPUT" | wc -l || echo "0")
    echo -e "${BLUE}Total tests passed: $TOTAL_TESTS${NC}"
}

# Function to measure build performance
measure_build_performance() {
    echo -e "${BLUE}⏱️  Measuring build performance...${NC}"
    
    cd "$PROJECT_ROOT"
    
    BUILD_REPORT="$REPORTS_DIR/build_performance_$TIMESTAMP.txt"
    
    echo "Build Performance Report - $(date)" > "$BUILD_REPORT"
    echo "========================================" >> "$BUILD_REPORT"
    
    # Clean before measuring
    flutter clean
    flutter pub get
    
    # Measure debug build time
    echo -e "${BLUE}📱 Measuring debug build time...${NC}"
    DEBUG_START=$(date +%s)
    flutter build apk --debug >> "$BUILD_REPORT" 2>&1
    DEBUG_END=$(date +%s)
    DEBUG_TIME=$((DEBUG_END - DEBUG_START))
    
    echo "Debug build time: ${DEBUG_TIME}s" >> "$BUILD_REPORT"
    print_status "Debug build completed in ${DEBUG_TIME}s"
    
    # Measure release build time
    echo -e "${BLUE}📱 Measuring release build time...${NC}"
    RELEASE_START=$(date +%s)
    flutter build apk --release >> "$BUILD_REPORT" 2>&1
    RELEASE_END=$(date +%s)
    RELEASE_TIME=$((RELEASE_END - RELEASE_START))
    
    echo "Release build time: ${RELEASE_TIME}s" >> "$BUILD_REPORT"
    print_status "Release build completed in ${RELEASE_TIME}s"
    
    # Measure web build time
    echo -e "${BLUE}🌐 Measuring web build time...${NC}"
    WEB_START=$(date +%s)
    flutter build web --release >> "$BUILD_REPORT" 2>&1
    WEB_END=$(date +%s)
    WEB_TIME=$((WEB_END - WEB_START))
    
    echo "Web build time: ${WEB_TIME}s" >> "$BUILD_REPORT"
    print_status "Web build completed in ${WEB_TIME}s"
    
    # Calculate build sizes
    measure_build_sizes >> "$BUILD_REPORT"
}

# Function to measure build sizes
measure_build_sizes() {
    echo -e "${BLUE}📏 Measuring build sizes...${NC}"
    
    echo ""
    echo "Build Sizes:"
    echo "============"
    
    # Android APK size
    if [ -f "$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk" ]; then
        APK_SIZE=$(du -h "$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
        echo "Android APK (release): $APK_SIZE"
        print_status "Android APK size: $APK_SIZE"
    fi
    
    # Web build size
    if [ -d "$PROJECT_ROOT/build/web" ]; then
        WEB_SIZE=$(du -sh "$PROJECT_ROOT/build/web" | cut -f1)
        echo "Web build: $WEB_SIZE"
        print_status "Web build size: $WEB_SIZE"
    fi
    
    # Analyze largest files
    echo ""
    echo "Largest files in web build:"
    if [ -d "$PROJECT_ROOT/build/web" ]; then
        find "$PROJECT_ROOT/build/web" -type f -exec du -h {} + | sort -rh | head -10
    fi
}

# Function to run memory profiling
run_memory_profiling() {
    echo -e "${BLUE}💾 Running memory profiling...${NC}"
    
    MEMORY_REPORT="$REPORTS_DIR/memory_profile_$TIMESTAMP.txt"
    
    echo "Memory Profiling Report - $(date)" > "$MEMORY_REPORT"
    echo "=================================" >> "$MEMORY_REPORT"
    
    # This would typically require running the app and using Flutter DevTools
    # For now, we'll create a placeholder report
    echo "Memory profiling requires running the app with Flutter DevTools" >> "$MEMORY_REPORT"
    echo "Run: flutter run --profile and use DevTools for detailed memory analysis" >> "$MEMORY_REPORT"
    
    print_status "Memory profiling report created: $MEMORY_REPORT"
}

# Function to analyze dependencies
analyze_dependencies() {
    echo -e "${BLUE}📦 Analyzing dependencies...${NC}"
    
    cd "$PROJECT_ROOT"
    
    DEPS_REPORT="$REPORTS_DIR/dependencies_$TIMESTAMP.txt"
    
    echo "Dependencies Analysis - $(date)" > "$DEPS_REPORT"
    echo "===============================" >> "$DEPS_REPORT"
    
    # List all dependencies
    echo "Direct dependencies:" >> "$DEPS_REPORT"
    flutter pub deps --no-dev >> "$DEPS_REPORT" 2>&1
    
    echo "" >> "$DEPS_REPORT"
    echo "Outdated packages:" >> "$DEPS_REPORT"
    flutter pub outdated >> "$DEPS_REPORT" 2>&1 || true
    
    print_status "Dependencies analysis completed: $DEPS_REPORT"
}

# Function to run security audit
run_security_audit() {
    echo -e "${BLUE}🔒 Running security audit...${NC}"
    
    SECURITY_REPORT="$REPORTS_DIR/security_audit_$TIMESTAMP.txt"
    
    echo "Security Audit Report - $(date)" > "$SECURITY_REPORT"
    echo "==============================" >> "$SECURITY_REPORT"
    
    # Check for common security issues
    echo "Checking for hardcoded secrets..." >> "$SECURITY_REPORT"
    
    # Search for potential API keys or secrets
    if grep -r "api_key\|secret\|password\|token" "$PROJECT_ROOT/lib" --include="*.dart" >> "$SECURITY_REPORT" 2>&1; then
        print_warning "Potential secrets found in code. Review security report."
    else
        echo "No obvious secrets found in source code." >> "$SECURITY_REPORT"
    fi
    
    # Check permissions
    echo "" >> "$SECURITY_REPORT"
    echo "Android permissions:" >> "$SECURITY_REPORT"
    if [ -f "$PROJECT_ROOT/android/app/src/main/AndroidManifest.xml" ]; then
        grep "uses-permission" "$PROJECT_ROOT/android/app/src/main/AndroidManifest.xml" >> "$SECURITY_REPORT" || true
    fi
    
    print_status "Security audit completed: $SECURITY_REPORT"
}

# Function to generate performance summary
generate_performance_summary() {
    echo -e "${BLUE}📊 Generating performance summary...${NC}"
    
    SUMMARY_REPORT="$REPORTS_DIR/performance_summary_$TIMESTAMP.md"
    
    cat > "$SUMMARY_REPORT" << EOF
# CareNow MVP - Performance Test Summary

**Test Date:** $(date)
**Flutter Version:** $(flutter --version | head -n 1)
**Environment:** $(uname -s) $(uname -r)

## Test Results

### Code Quality
- Flutter Analyze: $([ -f "$REPORTS_DIR/flutter_analyze_$TIMESTAMP.txt" ] && echo "✅ Completed" || echo "❌ Failed")
- Unit Tests: $([ -f "$REPORTS_DIR/test_results_$TIMESTAMP.txt" ] && echo "✅ Completed" || echo "❌ Failed")
- Test Coverage: $([ -d "$REPORTS_DIR/coverage_$TIMESTAMP" ] && echo "✅ Generated" || echo "⚠️ Not available")

### Build Performance
- Debug Build: $([ -f "$REPORTS_DIR/build_performance_$TIMESTAMP.txt" ] && grep "Debug build time:" "$REPORTS_DIR/build_performance_$TIMESTAMP.txt" | cut -d: -f2 || echo "Not measured")
- Release Build: $([ -f "$REPORTS_DIR/build_performance_$TIMESTAMP.txt" ] && grep "Release build time:" "$REPORTS_DIR/build_performance_$TIMESTAMP.txt" | cut -d: -f2 || echo "Not measured")
- Web Build: $([ -f "$REPORTS_DIR/build_performance_$TIMESTAMP.txt" ] && grep "Web build time:" "$REPORTS_DIR/build_performance_$TIMESTAMP.txt" | cut -d: -f2 || echo "Not measured")

### Security
- Security Audit: $([ -f "$REPORTS_DIR/security_audit_$TIMESTAMP.txt" ] && echo "✅ Completed" || echo "❌ Failed")

### Dependencies
- Dependency Analysis: $([ -f "$REPORTS_DIR/dependencies_$TIMESTAMP.txt" ] && echo "✅ Completed" || echo "❌ Failed")

## Recommendations

1. **Performance Optimization**
   - Monitor build times and optimize if > 2 minutes
   - Keep APK size under 50MB for better user experience
   - Implement lazy loading for large assets

2. **Security**
   - Review any flagged potential secrets
   - Ensure proper permission usage
   - Implement certificate pinning for production

3. **Code Quality**
   - Address any critical analyzer issues
   - Maintain test coverage above 80%
   - Regular dependency updates

## Next Steps

1. Review individual reports for detailed findings
2. Address any critical issues before production deployment
3. Set up continuous performance monitoring
4. Implement automated performance regression testing

---
Generated by CareNow MVP Performance Testing Script
EOF

    print_status "Performance summary generated: $SUMMARY_REPORT"
}

# Main execution
main() {
    echo -e "${BLUE}🏗️  CareNow MVP Performance Testing Pipeline${NC}"
    echo -e "${BLUE}=============================================${NC}"
    
    check_prerequisites
    run_flutter_analyze
    run_unit_tests
    measure_build_performance
    run_memory_profiling
    analyze_dependencies
    run_security_audit
    generate_performance_summary
    
    echo -e "${GREEN}🎉 Performance testing completed successfully!${NC}"
    echo -e "${GREEN}Reports available in: $REPORTS_DIR${NC}"
    echo -e "${YELLOW}📋 Review summary: $REPORTS_DIR/performance_summary_$TIMESTAMP.md${NC}"
}

# Run main function
main "$@"
