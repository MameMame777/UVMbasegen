#!/bin/bash
# Pre-commit security check hook
# Place this file in .git/hooks/pre-commit and make it executable

echo "Running security pre-commit checks..."

# Check for potential personal information in staged files
SECURITY_VIOLATIONS=$(git diff --cached --name-only | xargs grep -l "Users\\\\\\|PC-\\|C:\\\\\\|AppData\\|Nautilus" 2>/dev/null || true)

if [ ! -z "$SECURITY_VIOLATIONS" ]; then
    echo "🚨 SECURITY WARNING: Potential personal information detected!"
    echo "Files with potential security issues:"
    echo "$SECURITY_VIOLATIONS"
    echo ""
    echo "Please review these files and remove any:"
    echo "- Personal usernames (e.g., 'Nautilus')"
    echo "- Computer names (e.g., 'PC-HOME')"
    echo "- Personal file paths (e.g., 'C:\\Users\\username\\')"
    echo "- System-specific information"
    echo ""
    echo "Use environment variables instead:"
    echo "- %USERPROFILE% instead of C:\\Users\\username"
    echo "- %COMPUTERNAME% instead of specific computer names"
    echo "- Generic paths like ./workspace instead of full paths"
    echo ""
    echo "Run 'git diff --cached' to review your changes."
    echo "To bypass this check (NOT RECOMMENDED), use: git commit --no-verify"
    exit 1
fi

# Check for environment files
ENV_FILES=$(git diff --cached --name-only | grep -E "\\.env$|dsim\\.env" || true)

if [ ! -z "$ENV_FILES" ]; then
    echo "🚨 SECURITY WARNING: Environment files detected!"
    echo "Files:"
    echo "$ENV_FILES"
    echo ""
    echo "Environment files often contain sensitive information and should not be committed."
    echo "Add these files to .gitignore instead."
    exit 1
fi

# Check for license files
LICENSE_FILES=$(git diff --cached --name-only | grep -i "license.*\\.json\\|.*key.*\\|.*secret.*" || true)

if [ ! -z "$LICENSE_FILES" ]; then
    echo "🚨 SECURITY WARNING: License or key files detected!"
    echo "Files:"
    echo "$LICENSE_FILES"
    echo ""
    echo "License files and keys should not be committed to the repository."
    echo "Add these files to .gitignore instead."
    exit 1
fi

echo "✅ Security pre-commit checks passed."
exit 0
