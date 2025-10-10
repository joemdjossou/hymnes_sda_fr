# 🚀 Quick Setup: Branch Protection

Follow these steps to quickly set up branch protection for your repository.

## ⚡ Quick Setup Steps

### 1. Go to GitHub Repository Settings

1. Navigate to: `https://github.com/joemdjossou/hymnes_sda_fr/settings/branches`
2. Click **"Add rule"**

### 2. Protect the `main` Branch

**Branch name pattern:** `main`

**Protection Settings:**

- ✅ **Require a pull request before merging**
  - ✅ Require approvals: **2**
  - ✅ Dismiss stale PR approvals when new commits are pushed
  - ✅ Require review from code owners
- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - Add these required status checks:
    - `test` (from CI workflow)
    - `security` (from CI workflow)
- ✅ **Require conversation resolution before merging**
- ✅ **Require linear history**
- ✅ **Restrict pushes to matching branches**
- ✅ **Allow force pushes**: **Never**
- ✅ **Allow deletions**: **Never**
- ✅ **Allow bypassing the above settings**: Only for repository administrators

### 3. Protect the `review-branch`

**Branch name pattern:** `review-branch`

**Protection Settings:**

- ✅ **Require a pull request before merging**
  - ✅ Require approvals: **1**
  - ✅ Dismiss stale PR approvals when new commits are pushed
- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - Add these required status checks:
    - `test` (from CI workflow)
- ✅ **Require conversation resolution before merging**
- ✅ **Restrict pushes to matching branches**
- ✅ **Allow force pushes**: **Never**
- ✅ **Allow deletions**: **Never**
- ✅ **Allow bypassing the above settings**: Only for repository administrators

### 4. Verify Setup

After setting up the rules:

1. **Test the protection** by trying to push directly to `main`:

   ```bash
   git checkout main
   echo "# Test" >> README.md
   git add README.md
   git commit -m "test: direct push to main"
   git push origin main
   ```

   This should fail with a protection error.

2. **Test the workflow** by creating a PR:
   - Create a feature branch
   - Make a small change
   - Create a PR targeting `main`
   - Verify that status checks run automatically

## 🔧 Files Created

The following files have been created to support branch protection:

- `.github/CODEOWNERS` - Automatic review assignments
- `.github/workflows/ci.yml` - Automated testing and security checks
- `.github/workflows/release.yml` - Release automation
- `.github/pull_request_template.md` - Consistent PR format
- `BRANCH_PROTECTION_GUIDE.md` - Comprehensive documentation

## ✅ Verification Checklist

- [ ] `main` branch protection rules configured
- [ ] `review-branch` protection rules configured
- [ ] Required status checks are set up
- [ ] CODEOWNERS file is in place
- [ ] CI workflow is working
- [ ] PR template is active
- [ ] Direct push to `main` is blocked
- [ ] PRs require approval before merging

## 🆘 Troubleshooting

### If status checks are not running:

1. Check the Actions tab in your repository
2. Ensure the workflow files are in the correct location
3. Verify the branch names match exactly

### If CODEOWNERS is not working:

1. Ensure the file is in `.github/CODEOWNERS`
2. Check that usernames are correct (case-sensitive)
3. Verify the file is committed to the default branch

### If protection rules are not working:

1. Check that you have admin permissions
2. Verify the branch name patterns match exactly
3. Ensure the rules are saved and active

## 📞 Need Help?

If you encounter any issues:

1. Check the GitHub documentation
2. Review the comprehensive guide in `BRANCH_PROTECTION_GUIDE.md`
3. Test with a small change first
4. Contact GitHub support if needed

---

**🎉 Congratulations!** Your repository is now protected with industry-standard security measures.
