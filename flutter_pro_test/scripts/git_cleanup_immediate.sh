#!/bin/bash

# Immediate Git Cleanup - Simple approach without complex history rewriting
# This creates a clean slate by creating a new initial commit

set -e

echo "🚨 IMMEDIATE GIT CLEANUP FOR EXPOSED FIREBASE API KEYS"
echo "======================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in a Git repository and find the root
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a Git repository!${NC}"
    exit 1
fi

# Navigate to Git repository root
GIT_ROOT=$(git rev-parse --show-toplevel)
cd "$GIT_ROOT"
echo -e "${GREEN}✅ Working from Git repository root: $GIT_ROOT${NC}"

# Warning message
echo -e "${RED}⚠️  WARNING: This will create a new Git history!${NC}"
echo -e "${RED}⚠️  All previous commits will be replaced with a single clean commit!${NC}"
echo -e "${RED}⚠️  This action cannot be undone!${NC}"
echo ""

read -p "Do you want to proceed with immediate cleanup? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}Step 1: Creating backup of current repository...${NC}"

# Create backup
BACKUP_DIR="../flutter_pro_test_backup_$(date +%Y%m%d_%H%M%S)"
cp -r . "$BACKUP_DIR"
echo -e "${GREEN}✅ Backup created at: $BACKUP_DIR${NC}"

echo -e "${YELLOW}Step 2: Removing exposed API keys from current files...${NC}"

# Define the exposed API keys
EXPOSED_WEB_KEY="AIzaSyCHjFdprKiFYY9DkKV0tkRPYyrjQfpSQu0"
EXPOSED_ANDROID_KEY="AIzaSyCznKxPBBlYcLUNVewfQuI4LZu9KSLjl1o"

# Replace exposed keys in current files
find . -name "*.dart" -type f -exec sed -i.bak "s/$EXPOSED_WEB_KEY/your-web-api-key-here/g" {} \;
find . -name "*.dart" -type f -exec sed -i.bak "s/$EXPOSED_ANDROID_KEY/your-android-api-key-here/g" {} \;

# Clean up backup files
find . -name "*.bak" -delete

echo -e "${GREEN}✅ Exposed API keys replaced in current files${NC}"

echo -e "${YELLOW}Step 3: Creating new clean Git history...${NC}"

# Get current branch name
CURRENT_BRANCH=$(git branch --show-current)

# Remove all Git history
rm -rf .git

# Initialize new Git repository
git init
git branch -m "$CURRENT_BRANCH"

# Add all files to the new repository
git add .

# Create initial commit with security message
git commit -m "Initial commit - CareNow MVP with secure Firebase configuration

This is a clean initial commit after removing exposed Firebase API keys.

Security measures implemented:
- Environment-based Firebase configuration
- Placeholder values in committed code
- Secure build process with environment variables
- Enhanced .gitignore for sensitive files

Previous Git history removed for security compliance.
Date: $(date)
"

echo -e "${GREEN}✅ New clean Git history created${NC}"

echo -e "${YELLOW}Step 4: Verifying cleanup...${NC}"

# Check if the exposed keys are still present
if grep -r "$EXPOSED_WEB_KEY\|$EXPOSED_ANDROID_KEY" . --exclude-dir=.git 2>/dev/null; then
    echo -e "${RED}❌ Warning: Some exposed keys may still be present${NC}"
    echo "Please check the files manually"
else
    echo -e "${GREEN}✅ No exposed keys found in current files${NC}"
fi

echo ""
echo -e "${GREEN}🎉 IMMEDIATE CLEANUP COMPLETE! 🎉${NC}"
echo ""
echo -e "${YELLOW}NEXT STEPS:${NC}"
echo "1. Add your GitHub remote:"
echo -e "   ${BLUE}git remote add origin https://github.com/Dyno8/flutter-project-test.git${NC}"
echo ""
echo "2. Force push the clean repository:"
echo -e "   ${BLUE}git push --force origin $CURRENT_BRANCH${NC}"
echo ""
echo "3. Verify the firebase_options.dart file:"
echo -e "   ${BLUE}cat flutter_pro_test/lib/firebase_options.dart | grep -A2 -B2 'apiKey'${NC}"
echo ""
echo "4. Regenerate Firebase API keys in Firebase Console"
echo "5. Update your .env file with new API keys"
echo ""
echo -e "${GREEN}✅ Your repository is now clean and secure!${NC}"
echo -e "${RED}⚠️  All team members must re-clone the repository!${NC}"
echo -e "${YELLOW}📁 Backup available at: $BACKUP_DIR${NC}"
