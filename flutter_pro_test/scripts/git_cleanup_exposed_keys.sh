#!/bin/bash

# Git Cleanup Script for Exposed Firebase API Keys
# This script removes sensitive API keys from Git history

set -e

echo "🧹 GIT CLEANUP FOR EXPOSED FIREBASE API KEYS"
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Warning message
echo -e "${RED}⚠️  WARNING: This will rewrite Git history!${NC}"
echo -e "${RED}⚠️  Make sure all team members are aware before proceeding!${NC}"
echo -e "${RED}⚠️  This action cannot be undone!${NC}"
echo ""

read -p "Do you want to proceed with Git history cleanup? (yes/no): " confirm
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

echo -e "${YELLOW}Step 2: Installing BFG Repo-Cleaner (if not installed)...${NC}"

# Check if BFG is installed
if ! command -v bfg &> /dev/null; then
    echo "BFG Repo-Cleaner not found. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install bfg
    else
        echo -e "${RED}Error: Homebrew not found. Please install BFG manually:${NC}"
        echo "1. Download from: https://rtyley.github.io/bfg-repo-cleaner/"
        echo "2. Or install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
fi

echo -e "${GREEN}✅ BFG Repo-Cleaner is available${NC}"

echo -e "${YELLOW}Step 3: Creating list of exposed API keys to remove...${NC}"

# Create a file with the exposed API keys
cat > exposed_keys.txt << 'EOF'
AIzaSyCHjFdprKiFYY9DkKV0tkRPYyrjQfpSQu0
AIzaSyCznKxPBBlYcLUNVewfQuI4LZu9KSLjl1o
EOF

echo -e "${GREEN}✅ Created list of exposed API keys${NC}"

echo -e "${YELLOW}Step 4: Running BFG to remove exposed keys from Git history...${NC}"

# Use BFG to remove the exposed API keys from all commits
bfg --replace-text exposed_keys.txt --no-blob-protection .

echo -e "${GREEN}✅ BFG cleanup completed${NC}"

echo -e "${YELLOW}Step 5: Cleaning up Git repository...${NC}"

# Clean up the repository
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo -e "${GREEN}✅ Git cleanup completed${NC}"

echo -e "${YELLOW}Step 6: Verifying cleanup...${NC}"

# Check if the exposed keys are still in the repository
if git log --all --full-history -- "*firebase_options.dart" | grep -q "AIzaSyCHjFdprKiFYY9DkKV0tkRPYyrjQfpSQu0\|AIzaSyCznKxPBBlYcLUNVewfQuI4LZu9KSLjl1o"; then
    echo -e "${RED}❌ Warning: Some exposed keys may still be present in Git history${NC}"
    echo "You may need to run additional cleanup or contact GitHub support"
else
    echo -e "${GREEN}✅ No exposed keys found in Git history${NC}"
fi

echo -e "${YELLOW}Step 7: Cleaning up temporary files...${NC}"

# Remove temporary files
rm -f exposed_keys.txt
rm -rf .bfg-report

echo -e "${GREEN}✅ Temporary files cleaned up${NC}"

echo ""
echo -e "${GREEN}🎉 GIT CLEANUP COMPLETE! 🎉${NC}"
echo ""
echo -e "${YELLOW}NEXT STEPS:${NC}"
echo "1. Force push to update the remote repository:"
echo -e "   ${BLUE}git push --force-with-lease origin main${NC}"
echo ""
echo "2. Notify all team members to re-clone the repository:"
echo -e "   ${BLUE}git clone https://github.com/Dyno8/flutter-project-test.git${NC}"
echo ""
echo "3. Regenerate Firebase API keys in Firebase Console"
echo "4. Update your .env file with the new API keys"
echo ""
echo -e "${RED}⚠️  IMPORTANT: All collaborators must re-clone the repository!${NC}"
echo -e "${RED}⚠️  Old clones will have the exposed keys in their local history!${NC}"
