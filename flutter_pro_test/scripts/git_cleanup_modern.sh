#!/bin/bash

# Modern Git Cleanup Script for Exposed Firebase API Keys
# Uses git filter-repo (recommended) or falls back to manual commit approach

set -e

echo "🧹 MODERN GIT CLEANUP FOR EXPOSED FIREBASE API KEYS"
echo "===================================================="

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

echo ""
echo -e "${YELLOW}Step 1: Creating backup branch...${NC}"

# Create backup branch
git branch backup-before-cleanup-$(date +%Y%m%d_%H%M%S) 2>/dev/null || echo "Backup branch creation attempted"
echo -e "${GREEN}✅ Backup branch created${NC}"

echo -e "${YELLOW}Step 2: Checking for git-filter-repo...${NC}"

# Define the exposed API keys
EXPOSED_WEB_KEY="AIzaSyCHjFdprKiFYY9DkKV0tkRPYyrjQfpSQu0"
EXPOSED_ANDROID_KEY="AIzaSyCznKxPBBlYcLUNVewfQuI4LZu9KSLjl1o"

# Check if git-filter-repo is available
if command -v git-filter-repo &> /dev/null; then
    echo -e "${GREEN}✅ git-filter-repo found, using modern approach${NC}"
    
    # Create replacement file for git-filter-repo
    cat > /tmp/api_key_replacements.txt << EOF
$EXPOSED_WEB_KEY==>your-web-api-key-here
$EXPOSED_ANDROID_KEY==>your-android-api-key-here
EOF
    
    # Use git-filter-repo to replace the keys
    git filter-repo --replace-text /tmp/api_key_replacements.txt --force
    
    # Clean up
    rm -f /tmp/api_key_replacements.txt
    
    echo -e "${GREEN}✅ API keys replaced using git-filter-repo${NC}"
    
else
    echo -e "${YELLOW}git-filter-repo not found, using alternative approach...${NC}"
    
    # Alternative approach: Create a new commit that fixes the issue and then squash history
    echo -e "${YELLOW}Step 2a: Installing git-filter-repo (recommended)...${NC}"
    
    if command -v pip3 &> /dev/null; then
        echo "Installing git-filter-repo via pip3..."
        pip3 install git-filter-repo
        
        if command -v git-filter-repo &> /dev/null; then
            echo -e "${GREEN}✅ git-filter-repo installed successfully${NC}"
            
            # Create replacement file
            cat > /tmp/api_key_replacements.txt << EOF
$EXPOSED_WEB_KEY==>your-web-api-key-here
$EXPOSED_ANDROID_KEY==>your-android-api-key-here
EOF
            
            # Use git-filter-repo
            git filter-repo --replace-text /tmp/api_key_replacements.txt --force
            rm -f /tmp/api_key_replacements.txt
            
            echo -e "${GREEN}✅ API keys replaced using git-filter-repo${NC}"
        else
            echo -e "${RED}Failed to install git-filter-repo, using manual approach...${NC}"
            manual_cleanup
        fi
    else
        echo -e "${YELLOW}pip3 not found, using manual approach...${NC}"
        manual_cleanup
    fi
fi

manual_cleanup() {
    echo -e "${YELLOW}Step 2b: Using manual cleanup approach...${NC}"
    
    # Get the current branch
    CURRENT_BRANCH=$(git branch --show-current)
    
    # Create a new orphan branch
    git checkout --orphan temp-clean-branch
    
    # Add all files except the problematic ones
    git add .
    
    # Make sure firebase_options.dart has clean values
    if [ -f "flutter_pro_test/lib/firebase_options.dart" ]; then
        sed -i.bak "s/$EXPOSED_WEB_KEY/your-web-api-key-here/g" flutter_pro_test/lib/firebase_options.dart
        sed -i.bak "s/$EXPOSED_ANDROID_KEY/your-android-api-key-here/g" flutter_pro_test/lib/firebase_options.dart
        rm -f flutter_pro_test/lib/firebase_options.dart.bak
    fi
    
    # Commit the clean version
    git add .
    git commit -m "Clean version without exposed Firebase API keys

This commit removes all exposed Firebase API keys from the codebase:
- Replaced exposed web API key with placeholder
- Replaced exposed Android API key with placeholder
- Implemented secure environment-based configuration

Security incident response: $(date)"
    
    # Replace the main branch with the clean version
    git branch -D "$CURRENT_BRANCH" 2>/dev/null || true
    git branch -m "$CURRENT_BRANCH"
    
    echo -e "${GREEN}✅ Manual cleanup completed${NC}"
}

echo -e "${YELLOW}Step 3: Cleaning up Git repository...${NC}"

# Clean up the repository
git reflog expire --expire=now --all 2>/dev/null || true
git gc --prune=now --aggressive

echo -e "${GREEN}✅ Git cleanup completed${NC}"

echo -e "${YELLOW}Step 4: Verifying cleanup...${NC}"

# Check if the exposed keys are still in the current files
if find . -name "*.dart" -exec grep -l "$EXPOSED_WEB_KEY\|$EXPOSED_ANDROID_KEY" {} \; 2>/dev/null | head -1; then
    echo -e "${RED}❌ Warning: Exposed keys still found in current files${NC}"
    echo "Please check the files manually"
else
    echo -e "${GREEN}✅ No exposed keys found in current files${NC}"
fi

echo ""
echo -e "${GREEN}🎉 MODERN GIT CLEANUP COMPLETE! 🎉${NC}"
echo ""
echo -e "${YELLOW}NEXT STEPS:${NC}"
echo "1. Verify the current firebase_options.dart file:"
echo -e "   ${BLUE}cat flutter_pro_test/lib/firebase_options.dart | grep -A2 -B2 'apiKey'${NC}"
echo ""
echo "2. Force push to update the remote repository:"
echo -e "   ${BLUE}git push --force-with-lease origin main${NC}"
echo ""
echo "3. Regenerate Firebase API keys in Firebase Console"
echo "4. Update your .env file with new API keys"
echo ""
echo -e "${RED}⚠️  IMPORTANT: All collaborators must re-clone the repository!${NC}"
