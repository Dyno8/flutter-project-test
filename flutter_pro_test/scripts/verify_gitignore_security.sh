#!/bin/bash

# Verify .gitignore Security Patterns
# This script tests that sensitive files are properly excluded from Git

set -e

echo "🔍 VERIFYING .GITIGNORE SECURITY PATTERNS"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Navigate to Git repository root
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a Git repository!${NC}"
    exit 1
fi

GIT_ROOT=$(git rev-parse --show-toplevel)
cd "$GIT_ROOT"
echo -e "${GREEN}✅ Working from Git repository root: $GIT_ROOT${NC}"

echo ""
echo -e "${YELLOW}Step 1: Testing environment file patterns...${NC}"

# Create test files to verify .gitignore patterns
test_files=(
    ".env"
    ".env.local" 
    ".env.production"
    ".env.staging"
    ".env.development"
    ".env.tmp"
    ".env.build"
    "firebase_env_test"
    "api_keys_test.txt"
)

ignored_count=0
for file in "${test_files[@]}"; do
    # Create temporary test file
    echo "test-content" > "$file"
    
    # Check if Git ignores it
    if git check-ignore "$file" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $file - properly ignored${NC}"
        ((ignored_count++))
    else
        echo -e "${RED}❌ $file - NOT ignored (SECURITY RISK!)${NC}"
    fi
    
    # Clean up test file
    rm -f "$file"
done

echo ""
echo -e "${YELLOW}Step 2: Testing backup file patterns...${NC}"

backup_files=(
    "firebase_options.dart.backup"
    "firebase_options.dart.bak"
    "firebase_options.dart.orig"
    "test.backup"
    "config.bak"
    "script.orig"
)

for file in "${backup_files[@]}"; do
    echo "test-content" > "$file"
    
    if git check-ignore "$file" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $file - properly ignored${NC}"
        ((ignored_count++))
    else
        echo -e "${RED}❌ $file - NOT ignored${NC}"
    fi
    
    rm -f "$file"
done

echo ""
echo -e "${YELLOW}Step 3: Testing security cleanup temporary files...${NC}"

temp_files=(
    "exposed_keys.txt"
    "api_key_replacements.txt"
    "flutter_pro_test/scripts/test.tmp"
    "flutter_pro_test/scripts/output_test"
    "flutter_pro_test/scripts/debug_test"
    "emergency_test.log"
    "cleanup_test.log"
)

for file in "${temp_files[@]}"; do
    # Create directory if needed
    mkdir -p "$(dirname "$file")"
    echo "test-content" > "$file"
    
    if git check-ignore "$file" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $file - properly ignored${NC}"
        ((ignored_count++))
    else
        echo -e "${RED}❌ $file - NOT ignored${NC}"
    fi
    
    rm -f "$file"
done

echo ""
echo -e "${YELLOW}Step 4: Testing sensitive name patterns...${NC}"

sensitive_files=(
    "test_secret_file.txt"
    "my_key_file.txt"
    "api_keys_real.txt"
    "firebase_secret.json"
)

for file in "${sensitive_files[@]}"; do
    echo "test-content" > "$file"
    
    if git check-ignore "$file" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $file - properly ignored${NC}"
        ((ignored_count++))
    else
        echo -e "${RED}❌ $file - NOT ignored${NC}"
    fi
    
    rm -f "$file"
done

echo ""
echo -e "${YELLOW}Step 5: Testing that safe files are NOT ignored...${NC}"

safe_files=(
    "flutter_pro_test/scripts/git_cleanup_immediate.sh"
    "flutter_pro_test/scripts/emergency_secure_setup.sh"
    "flutter_pro_test/.env.example"
    "README.md"
    "flutter_pro_test/lib/firebase_options.dart"
)

safe_count=0
for file in "${safe_files[@]}"; do
    if [ -f "$file" ]; then
        if git check-ignore "$file" > /dev/null 2>&1; then
            echo -e "${RED}❌ $file - incorrectly ignored (should be tracked)${NC}"
        else
            echo -e "${GREEN}✅ $file - correctly tracked${NC}"
            ((safe_count++))
        fi
    else
        echo -e "${YELLOW}⚠️  $file - file doesn't exist${NC}"
    fi
done

echo ""
echo -e "${YELLOW}Step 6: Checking for any committed sensitive files...${NC}"

# Check if any sensitive patterns are already in the repository
sensitive_patterns=(
    "AIzaSy"  # Google API key prefix
    "firebase.*api.*key"
    "\.env$"
)

found_sensitive=false
for pattern in "${sensitive_patterns[@]}"; do
    matching_files=$(git ls-files | grep -i "$pattern" || true)
    if [ -n "$matching_files" ]; then
        echo -e "${RED}❌ Found files matching sensitive pattern: $pattern${NC}"
        echo "$matching_files"
        found_sensitive=true
    fi
done

# Check for files with "secret" or "_key_" but exclude safe CI/CD setup files
secret_files=$(git ls-files | grep -i "secret\|_key_" | grep -v "setup-secrets.sh\|github.*secrets\|ci.*secrets" || true)
if [ -n "$secret_files" ]; then
    echo -e "${RED}❌ Found files with potentially sensitive names:${NC}"
    echo "$secret_files"
    found_sensitive=true
fi

if [ "$found_sensitive" = false ]; then
    echo -e "${GREEN}✅ No sensitive files found in Git repository${NC}"
fi

echo ""
echo -e "${BLUE}📊 VERIFICATION SUMMARY${NC}"
echo "======================="
echo -e "Sensitive files properly ignored: ${GREEN}$ignored_count${NC}"
echo -e "Safe files correctly tracked: ${GREEN}$safe_count${NC}"

if [ "$found_sensitive" = false ] && [ "$ignored_count" -gt 15 ]; then
    echo ""
    echo -e "${GREEN}🎉 SECURITY VERIFICATION PASSED! 🎉${NC}"
    echo -e "${GREEN}Your .gitignore file is properly configured to prevent sensitive data exposure.${NC}"
else
    echo ""
    echo -e "${RED}⚠️  SECURITY VERIFICATION FAILED!${NC}"
    echo -e "${RED}Please review and fix the .gitignore patterns.${NC}"
fi

echo ""
echo -e "${YELLOW}💡 RECOMMENDATIONS:${NC}"
echo "1. Run this verification script regularly"
echo "2. Always use 'git add -p' instead of 'git add .' for interactive staging"
echo "3. Set up pre-commit hooks to scan for secrets"
echo "4. Regularly audit committed files for sensitive data"
