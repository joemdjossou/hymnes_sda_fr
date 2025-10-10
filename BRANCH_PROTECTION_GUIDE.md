# 🛡️ Branch Protection Guide

This guide will help you protect your most important branches in your GitHub repository to ensure code quality, prevent accidental deletions, and maintain a stable codebase.

## 🎯 Critical Branches to Protect

Based on your repository structure, here are the branches that should be protected:

### 1. **main** (Primary Branch)

- **Priority**: 🔴 **CRITICAL**
- **Purpose**: Production-ready code
- **Protection Level**: Maximum

### 2. **review-branch** (Review Branch)

- **Priority**: 🟡 **HIGH**
- **Purpose**: Code review and testing before merging to main
- **Protection Level**: High

## 🛡️ Branch Protection Rules Setup

### Step 1: Access Branch Protection Settings

1. Go to your GitHub repository: `https://github.com/yourusername/hymnes_sda_fr`
2. Click on **Settings** tab
3. In the left sidebar, click **Branches**
4. Click **Add rule** or **Add branch protection rule**

### Step 2: Configure Protection Rules

#### For the `main` branch:

**Basic Settings:**

- ✅ **Require a pull request before merging**

  - ✅ Require approvals: **2** (recommended for critical branches)
  - ✅ Dismiss stale PR approvals when new commits are pushed
  - ✅ Require review from code owners (if you have CODEOWNERS file)

- ✅ **Require status checks to pass before merging**

  - ✅ Require branches to be up to date before merging
  - Add status checks:
    - `flutter test` (unit tests)
    - `flutter analyze` (static analysis)
    - `flutter build` (build verification)
    - Any CI/CD checks you have

- ✅ **Require conversation resolution before merging**

- ✅ **Require linear history** (prevents merge commits)

- ✅ **Require deployments to succeed before merging** (if you have deployment workflows)

**Advanced Settings:**

- ✅ **Restrict pushes that create files**
- ✅ **Restrict pushes that create files larger than 100MB**
- ✅ **Restrict pushes that create files with certain extensions** (e.g., `.exe`, `.dll`)

**Administrative Settings:**

- ✅ **Restrict pushes to matching branches**
- ✅ **Allow force pushes**: **Never** (for main branch)
- ✅ **Allow deletions**: **Never** (for main branch)
- ✅ **Allow bypassing the above settings**: Only for repository administrators

#### For the `review-branch`:

**Basic Settings:**

- ✅ **Require a pull request before merging**

  - ✅ Require approvals: **1** (less strict than main)
  - ✅ Dismiss stale PR approvals when new commits are pushed

- ✅ **Require status checks to pass before merging**

  - ✅ Require branches to be up to date before merging
  - Add status checks:
    - `flutter test` (unit tests)
    - `flutter analyze` (static analysis)

- ✅ **Require conversation resolution before merging**

**Administrative Settings:**

- ✅ **Restrict pushes to matching branches**
- ✅ **Allow force pushes**: **Never**
- ✅ **Allow deletions**: **Never**
- ✅ **Allow bypassing the above settings**: Only for repository administrators

## 🔧 Additional Security Measures

### 1. Create a CODEOWNERS File

Create a `.github/CODEOWNERS` file to automatically request reviews from specific people:

```gitignore
# Global owners
* @yourusername

# Core functionality
lib/core/ @yourusername @senior-developer
lib/features/ @yourusername @senior-developer

# Tests
test/ @yourusername @qa-team

# Configuration files
pubspec.yaml @yourusername
android/ @yourusername @android-developer
ios/ @yourusername @ios-developer
```

### 2. Set Up Required Status Checks

Create GitHub Actions workflows for automated checks:

#### `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main, review-branch]
  pull_request:
    branches: [main, review-branch]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.2.3"
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --debug
```

#### `.github/workflows/security.yml`

```yaml
name: Security Scan

on:
  push:
    branches: [main, review-branch]
  pull_request:
    branches: [main, review-branch]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run security scan
        run: |
          flutter pub get
          flutter pub audit
```

### 3. Branch Naming Conventions

Enforce consistent branch naming:

- **Feature branches**: `feature/description` (e.g., `feature/user-authentication`)
- **Bug fixes**: `fix/description` (e.g., `fix/audio-playback-issue`)
- **Hotfixes**: `hotfix/description` (e.g., `hotfix/critical-security-fix`)
- **Release branches**: `release/version` (e.g., `release/v1.2.0`)

## 📋 Workflow for Protected Branches

### For Contributors:

1. **Create a feature branch** from `main`:

   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** and commit:

   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

3. **Push to your branch**:

   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create a Pull Request**:

   - Target: `review-branch` (for initial review)
   - Or target: `main` (for direct production changes)
   - Fill out the PR template
   - Request reviews from appropriate reviewers

5. **Address feedback** and update your branch:
   ```bash
   git add .
   git commit -m "fix: address review feedback"
   git push origin feature/your-feature-name
   ```

### For Maintainers:

1. **Review Pull Requests** thoroughly
2. **Approve** when code meets standards
3. **Merge** using "Squash and merge" for clean history
4. **Delete** feature branches after merging

## 🚨 Emergency Procedures

### If you need to bypass protection rules:

1. **Temporary bypass** (for emergencies only):

   - Go to repository settings
   - Temporarily disable protection rules
   - Make necessary changes
   - Re-enable protection rules immediately

2. **Force push to main** (emergency only):
   - Only repository administrators can do this
   - Document the reason for the emergency
   - Notify team members immediately

## 📊 Monitoring and Maintenance

### Regular Checks:

1. **Review protection rules** monthly
2. **Update CODEOWNERS** as team changes
3. **Monitor failed status checks** and fix issues
4. **Review branch activity** for any suspicious patterns

### Metrics to Track:

- Number of PRs requiring multiple reviews
- Average time from PR creation to merge
- Number of failed status checks
- Branch deletion attempts (should be zero for protected branches)

## 🔍 Troubleshooting

### Common Issues:

1. **"Required status checks are pending"**

   - Check GitHub Actions tab for failed workflows
   - Fix any failing tests or linting issues
   - Re-run failed workflows

2. **"Changes requested"**

   - Address all review comments
   - Push new commits to the branch
   - Re-request review if needed

3. **"Branch is not up to date"**
   - Merge or rebase the latest changes from target branch
   - Resolve any merge conflicts
   - Push updated branch

## 📚 Additional Resources

- [GitHub Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
- [GitHub CODEOWNERS Documentation](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Remember**: Branch protection is a security measure, not a hindrance. It ensures code quality and prevents accidents that could break your production application.
