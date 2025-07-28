# Security Guidelines for UVM Project

**Date**: July 28, 2025  
**Purpose**: Security best practices for FPGA verification environment

## Overview

This document outlines security practices to prevent accidental exposure of sensitive information in the UVM verification environment.

## Files to Never Commit

### 1. Simulator Environment Files
```
# Never commit these files:
dsim.env           # Contains complete system environment
*.env              # Any environment files
dsim.log           # May contain personal paths
tr_db.log          # Transaction database logs
metrics.db         # Metrics database
```

### 2. License and Authentication Files
```
# Security-sensitive files:
*license*.json     # Software licenses
*key*              # Any key files
*secret*           # Secret configurations
*password*         # Password files
*.p12              # Certificate files
*.pem              # Certificate files
```

### 3. Personal Information Patterns
```
# Avoid committing content with:
- User names (e.g., "Nautilus", "john.doe")
- Computer names (e.g., "PC-HOME", "WORKSTATION-01") 
- Full file paths (e.g., "C:\\Users\\username\\")
- IP addresses and network configurations
- Serial numbers or hardware identifiers
```

## Secure Practices

### 1. Environment Variable Usage
Use environment variables instead of hardcoded paths:

```batch
REM GOOD - Uses environment variables
set "DSIM_LICENSE=%USERPROFILE%\\AppData\\Local\\metrics-ca\\dsim-license.json"
call "%DSIM_HOME%\\shell_activate.bat"

REM BAD - Hardcoded personal paths
set "DSIM_LICENSE=C:\\Users\\Nautilus\\AppData\\Local\\metrics-ca\\dsim-license.json"
call "C:\\Users\\Nautilus\\AppData\\Local\\metrics-ca\\dsim\\20240422.0.0\\shell_activate.bat"
```

### 2. Template Configuration
Use template files for configuration:

```yaml
# config_template.yaml
project:
  name: "UVM_PROJECT_NAME"
  user: "${USER}"
  workspace: "${WORKSPACE_PATH}"
  
simulator:
  home: "${DSIM_HOME}"
  license: "${DSIM_LICENSE}"
```

### 3. Gitignore Configuration
Maintain comprehensive .gitignore:

```gitignore
# Security-sensitive files
**/dsim.env
**/*.env
**/dsim.log
**/*license*.json
**/*key*
**/*secret*
**/*password*

# Build artifacts with potential personal info
**/work/
**/build/
**/waves/
```

## Repository Cleanup

### If Sensitive Files Were Already Committed

1. **Remove from current state:**
   ```bash
   git rm --cached sensitive_file.env
   git commit -m "Remove security-sensitive file"
   ```

2. **Add to .gitignore:**
   ```bash
   echo "sensitive_file.env" >> .gitignore
   git add .gitignore
   git commit -m "Update gitignore for security"
   ```

3. **For complete history removal (use with caution):**
   ```bash
   # Install git-filter-repo first
   git filter-repo --path sensitive_file.env --invert-paths
   ```

## Development Workflow

### 1. Pre-commit Checks
Create a pre-commit hook to scan for sensitive information:

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check for potential personal information
if git diff --cached --name-only | xargs grep -l "Users\\\\\\|PC-\\|C:\\\\\\|AppData" 2>/dev/null; then
    echo "WARNING: Potential personal information detected!"
    echo "Files contain personal paths or computer names."
    echo "Please review before committing."
    exit 1
fi
```

### 2. Regular Security Audits
Run periodic checks for sensitive information:

```bash
# Search for potential personal info in repository
grep -r "Users\\\\" . --exclude-dir=.git
grep -r "PC-" . --exclude-dir=.git
grep -r "AppData" . --exclude-dir=.git
```

### 3. Template-based Development
Use template substitution for environment-specific configurations:

```python
# generate_secure_config.py
import os
import template

template_vars = {
    'USER': os.environ.get('USERNAME', 'user'),
    'WORKSPACE_PATH': os.environ.get('WORKSPACE_PATH', './workspace'),
    'DSIM_HOME': os.environ.get('DSIM_HOME', '/opt/dsim')
}

# Generate configuration from template
config = template.substitute(config_template, template_vars)
```

## Team Guidelines

### 1. Code Review Checklist
- [ ] No hardcoded personal paths
- [ ] No user names or computer names
- [ ] Environment variables used appropriately
- [ ] No license files or keys included
- [ ] Simulator logs not committed

### 2. Documentation Standards
- Use generic examples in documentation
- Replace personal information with placeholders
- Example: Use `${USER}` instead of actual usernames

### 3. Training and Awareness
- Regular security awareness sessions
- Document security incidents and lessons learned
- Maintain updated security guidelines

## Emergency Procedures

### If Sensitive Information is Accidentally Pushed

1. **Immediate Actions:**
   ```bash
   # Remove from current branch
   git rm sensitive_file
   git commit -m "Emergency: Remove sensitive file"
   git push --force
   ```

2. **Notify Team:**
   - Inform all team members immediately
   - Request they update their local repositories
   - Document the incident for future prevention

3. **Repository Cleanup:**
   - Consider using git-filter-repo for complete removal
   - Update security practices based on incident

## Compliance and Auditing

### 1. Regular Security Reviews
- Monthly repository scans for sensitive information
- Quarterly security guideline updates
- Annual security training for team members

### 2. Automated Monitoring
- Implement automated scans in CI/CD pipeline
- Set up alerts for potential security violations
- Regular backup and recovery testing

---

## Quick Reference

### Safe Practices ✅
- Use environment variables: `%USERPROFILE%`, `%DSIM_HOME%`
- Generic paths: `./workspace`, `../tools`
- Template configurations with substitution
- Comprehensive .gitignore files

### Avoid ❌
- Hardcoded personal paths: `C:\Users\Nautilus\`
- Computer names: `PC-HOME`
- License files in repository
- Simulator environment dumps

### Emergency Commands
```bash
# Remove sensitive file from Git
git rm --cached sensitive_file.env
git commit -m "Remove sensitive file"

# Check repository for personal info
grep -r "Users\\\\" . --exclude-dir=.git

# Update .gitignore
echo "*.env" >> .gitignore
```

Remember: **Security is everyone's responsibility**. When in doubt, ask for a security review before committing.
