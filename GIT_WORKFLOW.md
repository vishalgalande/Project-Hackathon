# Team Git Workflow Guide

Hello team! This guide will help us collaborate smoothly during the hackathon.

## 1. Prerequisites
- **Git** installed on your computer.
- A **GitHub account**.
- Access to this repository (ask the owner to add you as a collaborator).

## 2. Initial Setup (Do this once)

### Clone the repository
Open your terminal (Command Prompt, PowerShell, or Git Bash) and run:

```bash
git clone <URL_FROM_GITHUB>
cd "Project Hackathon"
```
*(Replace `<URL_FROM_GITHUB>` with the link you get from the "Code" button on GitHub)*

## 3. Daily Workflow

### Step 1: Get latest changes
Before starting work, always pull the latest changes from the `main` branch:

```bash
git checkout main
git pull origin main
```

### Step 2: Create a new branch
**NEVER work directly on `main`.** Create a branch for your feature:

```bash
# Naming convention: feature/your-feature-name or fix/bug-fix-name
git checkout -b feature/login-page
```

### Step 3: Do your work
Make your code changes. Save your files.

### Step 4: Save your changes (Commit)

```bash
# See what changed
git status

# Add all changes
git add .

# Save with a message
git commit -m "Added login form layout"
```

### Step 5: Push to GitHub

```bash
git push origin feature/login-page
```

### Step 6: Merge your changes
1. Go to the GitHub repository page in your browser.
2. You will see a "Compare & pull request" button. Click it.
3. Review your changes and click **"Create pull request"**.
4. Let the team know! Once someone reviews it (or if we agree to merge our own), click **"Merge pull request"**.

## 4. Troubleshooting

### "Merge Conflict"
If you can't merge because of conflicts:
1. Pull the latest `main` into your branch:
   ```bash
   git checkout main
   git pull origin main
   git checkout feature/login-page
   git merge main
   ```
2. Open the files with conflicts (VS Code helps with this).
3. Fix the code to keep what we want.
4. Save, add, and commit the fix:
   ```bash
   git add .
   git commit -m "Fixed merge conflicts"
   git push origin feature/login-page
   ```

## Cheat Sheet
- `git status` : Check what branch you are on and what files changed.
- `git log` : See history of commits.
- `git branch` : Show local branches.

## 5. Releasing Versions (Milestones)
When we reach a big goal (like "MVP Complete"), we should **Tag** the version.

1.  **Create a Tag**:
    ```bash
    git tag v1.0 -m "First working release"
    ```
2.  **Push the Tag to GitHub**:
    ```bash
    git push origin v1.0
    ```
This creates a "Release" on our GitHub page that we can easily download later.
