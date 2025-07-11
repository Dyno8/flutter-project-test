#!/bin/bash

# 🔐 CareNow MVP - GitHub Secrets Setup Script
# This script helps set up required GitHub secrets for CI/CD pipelines

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 CareNow MVP - GitHub Secrets Setup${NC}"
echo -e "${BLUE}====================================${NC}"

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

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) is not installed"
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    print_error "Not authenticated with GitHub CLI"
    echo "Please run: gh auth login"
    exit 1
fi

print_status "GitHub CLI is installed and authenticated"

# Get repository information
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
print_info "Setting up secrets for repository: $REPO"

echo ""
echo -e "${BLUE}📋 Required Secrets for CareNow MVP CI/CD${NC}"
echo "============================================="

# Firebase Secrets
echo ""
echo -e "${YELLOW}🔥 Firebase Configuration Secrets${NC}"
echo "These secrets are required for Firebase integration:"

FIREBASE_SECRETS=(
    "FIREBASE_TOKEN:Firebase CLI token for deployment"
    "FIREBASE_PROJECT_ID:Firebase project ID"
    "FIREBASE_WEB_API_KEY_DEV:Firebase Web API key for development"
    "FIREBASE_WEB_API_KEY_STAGING:Firebase Web API key for staging"
    "FIREBASE_WEB_API_KEY_PROD:Firebase Web API key for production"
    "FIREBASE_ANDROID_API_KEY_DEV:Firebase Android API key for development"
    "FIREBASE_ANDROID_API_KEY_STAGING:Firebase Android API key for staging"
    "FIREBASE_ANDROID_API_KEY_PROD:Firebase Android API key for production"
    "FIREBASE_IOS_API_KEY_DEV:Firebase iOS API key for development"
    "FIREBASE_IOS_API_KEY_STAGING:Firebase iOS API key for staging"
    "FIREBASE_IOS_API_KEY_PROD:Firebase iOS API key for production"
)

# Android Secrets
echo ""
echo -e "${YELLOW}🤖 Android Deployment Secrets${NC}"
echo "These secrets are required for Android app deployment:"

ANDROID_SECRETS=(
    "ANDROID_KEYSTORE_BASE64:Base64 encoded Android keystore file"
    "ANDROID_KEY_ALIAS:Android signing key alias"
    "ANDROID_KEY_PASSWORD:Android signing key password"
    "ANDROID_STORE_PASSWORD:Android keystore password"
    "GOOGLE_PLAY_SERVICE_ACCOUNT:Google Play Console service account JSON"
)

# iOS Secrets
echo ""
echo -e "${YELLOW}🍎 iOS Deployment Secrets${NC}"
echo "These secrets are required for iOS app deployment:"

IOS_SECRETS=(
    "IOS_CERTIFICATE_BASE64:Base64 encoded iOS distribution certificate"
    "IOS_CERTIFICATE_PASSWORD:iOS certificate password"
    "IOS_PROVISIONING_PROFILE_BASE64:Base64 encoded iOS provisioning profile"
    "APP_STORE_CONNECT_API_KEY:App Store Connect API key"
    "APP_STORE_CONNECT_ISSUER_ID:App Store Connect issuer ID"
    "APP_STORE_CONNECT_KEY_ID:App Store Connect key ID"
)

# Security Secrets
echo ""
echo -e "${YELLOW}🔐 Security & Encryption Secrets${NC}"
echo "These secrets are required for security features:"

SECURITY_SECRETS=(
    "ENCRYPTION_KEY_DEV:Encryption key for development environment"
    "ENCRYPTION_KEY_STAGING:Encryption key for staging environment"
    "ENCRYPTION_KEY_PROD:Encryption key for production environment"
    "JWT_SECRET:JWT signing secret"
    "API_SECRET_KEY:API secret key for backend communication"
)

# Function to set a secret
set_secret() {
    local secret_name=$1
    local secret_description=$2
    
    echo ""
    echo -e "${BLUE}Setting up: $secret_name${NC}"
    echo "Description: $secret_description"
    
    read -p "Do you want to set this secret? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -s -p "Enter the secret value: " secret_value
        echo
        
        if [ -n "$secret_value" ]; then
            if gh secret set "$secret_name" --body "$secret_value" --repo "$REPO"; then
                print_status "Secret $secret_name set successfully"
            else
                print_error "Failed to set secret $secret_name"
            fi
        else
            print_warning "Empty value provided, skipping $secret_name"
        fi
    else
        print_info "Skipped $secret_name"
    fi
}

# Function to process secret array
process_secrets() {
    local -n secrets_array=$1
    local category=$2
    
    echo ""
    echo -e "${BLUE}🔧 Setting up $category secrets...${NC}"
    
    for secret_info in "${secrets_array[@]}"; do
        IFS=':' read -r secret_name secret_description <<< "$secret_info"
        set_secret "$secret_name" "$secret_description"
    done
}

# Main setup process
echo ""
read -p "Do you want to proceed with setting up secrets? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    process_secrets FIREBASE_SECRETS "Firebase"
    process_secrets ANDROID_SECRETS "Android"
    process_secrets IOS_SECRETS "iOS"
    process_secrets SECURITY_SECRETS "Security"
    
    echo ""
    print_status "Secret setup process completed!"
    
    echo ""
    echo -e "${BLUE}📋 Next Steps:${NC}"
    echo "1. Verify all secrets are set correctly in your GitHub repository"
    echo "2. Test the CI/CD pipelines with a test commit"
    echo "3. Review the deployment workflows in .github/workflows/"
    echo "4. Configure environment protection rules if needed"
    
    echo ""
    echo -e "${YELLOW}🔍 To view current secrets:${NC}"
    echo "gh secret list --repo $REPO"
    
else
    print_info "Secret setup cancelled"
fi

echo ""
echo -e "${GREEN}🎉 Setup script completed!${NC}"
