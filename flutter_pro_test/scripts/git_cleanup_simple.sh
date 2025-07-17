#!/bin/bash

# Simple Git Cleanup Script for Exposed Firebase API Keys
# Uses git filter-branch (built into Git, no external tools needed)

set -e

echo "🧹 SIMPLE GIT CLEANUP FOR EXPOSED FIREBASE API KEYS"
echo "==================================================="

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
echo -e "${RED}⚠️  WARNING: This will rewrite Git history!${NC}"
echo -e "${RED}⚠️  Make sure you have a backup of your repository!${NC}"
echo -e "${RED}⚠️  This action cannot be undone!${NC}"
echo ""

read -p "Do you want to proceed with Git history cleanup? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Suppress git filter-branch warning
export FILTER_BRANCH_SQUELCH_WARNING=1

echo ""
echo -e "${YELLOW}Step 1: Creating backup branch...${NC}"

# Create backup branch
git branch backup-before-cleanup 2>/dev/null || echo "Backup branch already exists"
echo -e "${GREEN}✅ Backup branch created: backup-before-cleanup${NC}"

echo -e "${YELLOW}Step 2: Removing exposed API keys from Git history...${NC}"

# Define the exposed API keys
EXPOSED_WEB_KEY="AIzaSyCHjFdprKiFYY9DkKV0tkRPYyrjQfpSQu0"
EXPOSED_ANDROID_KEY="AIzaSyCznKxPBBlYcLUNVewfQuI4LZu9KSLjl1o"

# Use git filter-branch to replace the exposed keys in all commits
git filter-branch --tree-filter "
    if [ -f 'flutter_pro_test/lib/firebase_options.dart' ]; then
        sed -i.bak 's/$EXPOSED_WEB_KEY/your-web-api-key-here/g' flutter_pro_test/lib/firebase_options.dart 2>/dev/null || true
        sed -i.bak 's/$EXPOSED_ANDROID_KEY/your-android-api-key-here/g' flutter_pro_test/lib/firebase_options.dart 2>/dev/null || true
        rm -f flutter_pro_test/lib/firebase_options.dart.bak 2>/dev/null || true
    fi
    if [ -f 'lib/firebase_options.dart' ]; then
        sed -i.bak 's/$EXPOSED_WEB_KEY/your-web-api-key-here/g' lib/firebase_options.dart 2>/dev/null || true
        sed -i.bak 's/$EXPOSED_ANDROID_KEY/your-android-api-key-here/g' lib/firebase_options.dart 2>/dev/null || true
        rm -f lib/firebase_options.dart.bak 2>/dev/null || true
    fi
" --all

echo -e "${GREEN}✅ API keys replaced in Git history${NC}"

echo -e "${YELLOW}Step 3: Cleaning up Git repository...${NC}"

# Clean up the repository
git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo -e "${GREEN}✅ Git cleanup completed${NC}"

echo -e "${YELLOW}Step 4: Verifying cleanup...${NC}"

# Check if the exposed keys are still in the repository
if git log --all --oneline | xargs -I {} git show {} | grep -q "$EXPOSED_WEB_KEY\|$EXPOSED_ANDROID_KEY"; then
    echo -e "${RED}❌ Warning: Some exposed keys may still be present${NC}"
    echo "Manual verification recommended"
else
    echo -e "${GREEN}✅ No exposed keys found in recent commits${NC}"
fi

echo ""
echo -e "${GREEN}🎉 SIMPLE GIT CLEANUP COMPLETE! 🎉${NC}"
echo ""
echo -e "${YELLOW}NEXT STEPS:${NC}"
echo "1. Verify the current firebase_options.dart file has placeholder values:"
echo -e "   ${BLUE}cat lib/firebase_options.dart | grep -A5 -B5 'apiKey'${NC}"
echo ""
echo "2. Force push to update the remote repository:"
echo -e "   ${BLUE}git push --force-with-lease origin main${NC}"
echo ""
echo "3. If you need to restore, use the backup branch:"
echo -e "   ${BLUE}git checkout backup-before-cleanup${NC}"
echo ""
echo -e "${RED}⚠️  IMPORTANT: Regenerate Firebase API keys in Firebase Console!${NC}"
echo -e "${RED}⚠️  Update your .env file with new API keys!${NC}"
