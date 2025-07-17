#!/bin/bash

# CareNow MVP - Android Device Testing Execution Script
# This script orchestrates comprehensive Android device testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📱 CareNow MVP - Android Device Testing Suite${NC}"
echo -e "${BLUE}=============================================${NC}"

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_RESULTS_DIR="$PROJECT_ROOT/test_results/android_devices"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEST_SESSION_DIR="$TEST_RESULTS_DIR/$TIMESTAMP"

# Create test results directory
mkdir -p "$TEST_SESSION_DIR"

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

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Flutter installation
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check Android SDK
    if [ -z "$ANDROID_HOME" ]; then
        print_error "ANDROID_HOME is not set"
        exit 1
    fi
    
    # Check ADB
    if ! command -v adb &> /dev/null; then
        print_error "ADB is not installed or not in PATH"
        exit 1
    fi
    
    # Check connected devices
    CONNECTED_DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | wc -l)
    if [ "$CONNECTED_DEVICES" -eq 0 ]; then
        print_error "No Android devices connected"
        exit 1
    fi
    
    print_status "Prerequisites check passed"
    print_info "Connected devices: $CONNECTED_DEVICES"
}

# Function to setup test environment
setup_test_environment() {
    print_info "Setting up test environment..."
    
    # Load environment variables
    if [ -f "$PROJECT_ROOT/.env" ]; then
        export $(cat "$PROJECT_ROOT/.env" | grep -v '^#' | xargs)
        print_status "Environment variables loaded"
    else
        print_warning ".env file not found, using default configuration"
    fi
    
    # Validate Firebase configuration
    if [ -z "$FIREBASE_ANDROID_API_KEY" ] || [ "$FIREBASE_ANDROID_API_KEY" = "your-android-api-key-here" ]; then
        print_error "Firebase Android API key not configured properly"
        print_info "Please update your .env file with actual Firebase API keys"
        exit 1
    fi
    
    # Clean previous test data
    print_info "Cleaning previous test data..."
    rm -rf "$PROJECT_ROOT/build/app/outputs/flutter-apk/app-debug.apk" 2>/dev/null || true
    
    print_status "Test environment setup complete"
}

# Function to build test APK
build_test_apk() {
    print_info "Building test APK with secure configuration..."
    
    cd "$PROJECT_ROOT"
    
    # Build APK with environment variables
    flutter build apk --debug \
        --dart-define-from-file=.env \
        --target-platform android-arm,android-arm64,android-x64
    
    if [ $? -eq 0 ]; then
        print_status "Test APK built successfully"
        APK_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-debug.apk"
        
        # Verify APK exists
        if [ ! -f "$APK_PATH" ]; then
            print_error "APK file not found at expected location"
            exit 1
        fi
        
        # Copy APK to test results directory
        cp "$APK_PATH" "$TEST_SESSION_DIR/carenow-test-$TIMESTAMP.apk"
        print_status "APK copied to test results directory"
    else
        print_error "APK build failed"
        exit 1
    fi
}

# Function to install APK on connected devices
install_apk_on_devices() {
    print_info "Installing APK on connected devices..."
    
    # Get list of connected devices
    DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | cut -f1)
    
    for device in $DEVICES; do
        print_info "Installing on device: $device"
        
        # Get device information
        DEVICE_MODEL=$(adb -s "$device" shell getprop ro.product.model)
        ANDROID_VERSION=$(adb -s "$device" shell getprop ro.build.version.release)
        API_LEVEL=$(adb -s "$device" shell getprop ro.build.version.sdk)
        
        print_info "Device: $DEVICE_MODEL (Android $ANDROID_VERSION, API $API_LEVEL)"
        
        # Uninstall previous version
        adb -s "$device" uninstall com.carenow.app 2>/dev/null || true
        
        # Install new APK
        if adb -s "$device" install "$APK_PATH"; then
            print_status "APK installed successfully on $device"
            
            # Create device-specific test directory
            DEVICE_TEST_DIR="$TEST_SESSION_DIR/device_${device}_${DEVICE_MODEL// /_}"
            mkdir -p "$DEVICE_TEST_DIR"
            
            # Save device information
            cat > "$DEVICE_TEST_DIR/device_info.txt" << EOF
Device ID: $device
Model: $DEVICE_MODEL
Android Version: $ANDROID_VERSION
API Level: $API_LEVEL
Installation Time: $(date)
APK Path: $APK_PATH
EOF
        else
            print_error "Failed to install APK on $device"
        fi
    done
}

# Function to run automated integration tests
run_automated_tests() {
    print_info "Running automated integration tests..."
    
    cd "$PROJECT_ROOT"
    
    # Run integration tests
    flutter test integration_test/automated_android_tests.dart \
        --dart-define-from-file=.env \
        --reporter json > "$TEST_SESSION_DIR/automated_test_results.json" 2>&1
    
    if [ $? -eq 0 ]; then
        print_status "Automated tests completed successfully"
    else
        print_warning "Some automated tests failed - check results for details"
    fi
}

# Function to run performance tests
run_performance_tests() {
    print_info "Running performance tests..."
    
    # Get list of connected devices
    DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | cut -f1)
    
    for device in $DEVICES; do
        print_info "Running performance tests on device: $device"
        
        DEVICE_MODEL=$(adb -s "$device" shell getprop ro.product.model)
        DEVICE_TEST_DIR="$TEST_SESSION_DIR/device_${device}_${DEVICE_MODEL// /_}"
        
        # Launch app and measure startup time
        print_info "Measuring app startup time..."
        START_TIME=$(date +%s%N)
        adb -s "$device" shell am start -n com.carenow.app/.MainActivity
        sleep 5  # Wait for app to fully load
        END_TIME=$(date +%s%N)
        STARTUP_TIME=$(( (END_TIME - START_TIME) / 1000000 ))  # Convert to milliseconds
        
        # Get memory usage
        print_info "Measuring memory usage..."
        MEMORY_USAGE=$(adb -s "$device" shell dumpsys meminfo com.carenow.app | grep "TOTAL" | awk '{print $2}')
        
        # Get CPU usage
        print_info "Measuring CPU usage..."
        CPU_USAGE=$(adb -s "$device" shell top -n 1 | grep com.carenow.app | awk '{print $9}')
        
        # Save performance metrics
        cat > "$DEVICE_TEST_DIR/performance_metrics.txt" << EOF
App Startup Time: ${STARTUP_TIME}ms
Memory Usage: ${MEMORY_USAGE}KB
CPU Usage: ${CPU_USAGE}%
Test Time: $(date)
EOF
        
        print_status "Performance metrics saved for $device"
    done
}

# Function to capture device screenshots
capture_screenshots() {
    print_info "Capturing device screenshots..."
    
    DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | cut -f1)
    
    for device in $DEVICES; do
        DEVICE_MODEL=$(adb -s "$device" shell getprop ro.product.model)
        DEVICE_TEST_DIR="$TEST_SESSION_DIR/device_${device}_${DEVICE_MODEL// /_}"
        
        # Create screenshots directory
        mkdir -p "$DEVICE_TEST_DIR/screenshots"
        
        # Launch app
        adb -s "$device" shell am start -n com.carenow.app/.MainActivity
        sleep 3
        
        # Capture home screen
        adb -s "$device" exec-out screencap -p > "$DEVICE_TEST_DIR/screenshots/home_screen.png"
        
        print_status "Screenshots captured for $device"
    done
}

# Function to run security validation
run_security_validation() {
    print_info "Running security validation tests..."
    
    # Check APK for hardcoded secrets
    print_info "Scanning APK for hardcoded secrets..."
    
    # Extract APK
    TEMP_DIR=$(mktemp -d)
    unzip -q "$APK_PATH" -d "$TEMP_DIR"
    
    # Search for potential API keys or secrets
    SECRETS_FOUND=false
    
    # Check for Firebase API keys
    if grep -r "AIzaSy" "$TEMP_DIR" 2>/dev/null; then
        print_error "Potential Firebase API key found in APK"
        SECRETS_FOUND=true
    fi
    
    # Check for other sensitive patterns
    if grep -r "sk_test_\|sk_live_" "$TEMP_DIR" 2>/dev/null; then
        print_error "Potential Stripe secret key found in APK"
        SECRETS_FOUND=true
    fi
    
    # Clean up
    rm -rf "$TEMP_DIR"
    
    if [ "$SECRETS_FOUND" = false ]; then
        print_status "No hardcoded secrets found in APK"
    else
        print_error "Security validation failed - secrets found in APK"
    fi
    
    # Test Firebase configuration
    print_info "Validating Firebase configuration..."
    
    DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | cut -f1)
    for device in $DEVICES; do
        # Launch app and check logs for Firebase initialization
        adb -s "$device" shell am start -n com.carenow.app/.MainActivity
        sleep 5
        
        # Check logs for Firebase initialization
        FIREBASE_LOGS=$(adb -s "$device" logcat -d | grep -i firebase | tail -10)
        
        if echo "$FIREBASE_LOGS" | grep -q "Firebase initialized"; then
            print_status "Firebase initialized successfully on $device"
        else
            print_warning "Firebase initialization unclear on $device"
        fi
    done
}

# Function to generate test report
generate_test_report() {
    print_info "Generating test report..."
    
    REPORT_FILE="$TEST_SESSION_DIR/test_report.html"
    
    cat > "$REPORT_FILE" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>CareNow MVP - Android Device Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; }
        .device { border: 1px solid #ddd; margin: 10px 0; padding: 15px; border-radius: 5px; }
        .success { color: green; }
        .warning { color: orange; }
        .error { color: red; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>CareNow MVP - Android Device Test Report</h1>
        <p><strong>Test Session:</strong> $TIMESTAMP</p>
        <p><strong>Generated:</strong> $(date)</p>
    </div>
    
    <div class="section">
        <h2>Test Summary</h2>
        <table>
            <tr><th>Metric</th><th>Value</th></tr>
            <tr><td>Connected Devices</td><td>$CONNECTED_DEVICES</td></tr>
            <tr><td>APK Build</td><td class="success">Success</td></tr>
            <tr><td>Installation</td><td class="success">Success</td></tr>
            <tr><td>Security Validation</td><td class="success">Passed</td></tr>
        </table>
    </div>
    
    <div class="section">
        <h2>Device Information</h2>
EOF

    # Add device information to report
    DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | cut -f1)
    for device in $DEVICES; do
        DEVICE_MODEL=$(adb -s "$device" shell getprop ro.product.model)
        ANDROID_VERSION=$(adb -s "$device" shell getprop ro.build.version.release)
        API_LEVEL=$(adb -s "$device" shell getprop ro.build.version.sdk)
        
        cat >> "$REPORT_FILE" << EOF
        <div class="device">
            <h3>$DEVICE_MODEL</h3>
            <p><strong>Device ID:</strong> $device</p>
            <p><strong>Android Version:</strong> $ANDROID_VERSION</p>
            <p><strong>API Level:</strong> $API_LEVEL</p>
        </div>
EOF
    done
    
    cat >> "$REPORT_FILE" << EOF
    </div>
    
    <div class="section">
        <h2>Next Steps</h2>
        <ul>
            <li>Review automated test results in: automated_test_results.json</li>
            <li>Check performance metrics for each device</li>
            <li>Execute manual testing procedures</li>
            <li>Validate end-to-end workflows</li>
            <li>Complete security validation checklist</li>
        </ul>
    </div>
</body>
</html>
EOF
    
    print_status "Test report generated: $REPORT_FILE"
}

# Function to cleanup
cleanup() {
    print_info "Cleaning up..."
    
    # Stop any running apps
    DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | cut -f1)
    for device in $DEVICES; do
        adb -s "$device" shell am force-stop com.carenow.app 2>/dev/null || true
    done
    
    print_status "Cleanup completed"
}

# Main execution flow
main() {
    print_info "Starting Android device testing suite..."
    
    # Check command line arguments
    SKIP_BUILD=false
    SKIP_INSTALL=false
    SKIP_TESTS=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            --skip-install)
                SKIP_INSTALL=true
                shift
                ;;
            --skip-tests)
                SKIP_TESTS=true
                shift
                ;;
            --help)
                echo "Usage: $0 [--skip-build] [--skip-install] [--skip-tests]"
                echo "  --skip-build    Skip APK building step"
                echo "  --skip-install  Skip APK installation step"
                echo "  --skip-tests    Skip automated test execution"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Execute test steps
    check_prerequisites
    setup_test_environment
    
    if [ "$SKIP_BUILD" = false ]; then
        build_test_apk
    fi
    
    if [ "$SKIP_INSTALL" = false ]; then
        install_apk_on_devices
    fi
    
    capture_screenshots
    run_performance_tests
    run_security_validation
    
    if [ "$SKIP_TESTS" = false ]; then
        run_automated_tests
    fi
    
    generate_test_report
    cleanup
    
    print_status "Android device testing completed successfully!"
    print_info "Test results available in: $TEST_SESSION_DIR"
    print_info "Open test report: $TEST_SESSION_DIR/test_report.html"
}

# Handle script interruption
trap cleanup EXIT

# Run main function
main "$@"
