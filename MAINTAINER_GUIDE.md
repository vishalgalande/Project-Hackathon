# Maintainer Guide: Managing the Repository

As the moderator, your main job is to review work and integrate it into the `main` branch safely. You will do most of this on the GitHub website.

## 1. The Golden Rule
**Never push directly to `main` yourself.**
Even you should use branches (`feature/my-task`) and Pull Requests. This keeps the history clean and ensures `main` is always working code.

## 2. Reviewing & Merging (The Happy Path)
When a friend finishes a task, they will open a **Pull Request (PR)**.

1.  **Go to the "Pull requests" tab** on your GitHub repo.
2.  Click on the open request (e.g., "Added Navbar").
3.  **Check the Files**: Click only the "Files changed" tab.
    *   Look through the code. Is it clean? distinct?
    *   *Optional*: You can click on a line of code to add a comment/question.
4.  **Approve/Merge**:
    *   If it looks good, go back to the "Conversation" tab.
    *   Click the big green **"Merge pull request"** button.
    *   Click "Confirm merge".
5.  **Cleanup**: Click "Delete branch" (this deletes the `feature/navbar` branch from GitHub, keeping things tidy).

## 3. Handling Merge Conflicts (The "Merge" button is grey)
Sometimes two people change the same line of code. GitHub will say "This branch has conflicts that must be resolved".

### Option A: Resolve on GitHub (Easiest)
1.  Click the **"Resolve conflicts"** button on the PR page.
2.  You will see a text editor showing the conflicting lines.
    *   `<<<<<<<` is their code.
    *   `>>>>>>>` is the current code in `main`.
3.  Delete the marker lines (`<<<<`, `====`, `>>>>`) and edit the code to look exactly how it should end up.
4.  Click **"Mark as resolved"**.
5.  Click **"Commit merge"**.
6.  Now you can click the green **"Merge pull request"** button.

### Option B: Resolve Locally (For complex conflicts)
If the web editor is too hard, you can do it on your PC:

1.  **Get their code**:
    ```bash
    git fetch origin
    git checkout feature/their-branch-name
    ```
2.  **Merge main into it**:
    ```bash
    git pull origin main
    # Git will scream about CONFLICTS
    ```
3.  **Fix it**: Open VS Code. It will highlight conflicts nicely. Fix them and save files.
4.  **Finish**:
    ```bash
    git add .
    git commit -m "Fixed merge conflicts"
    git push origin feature/their-branch-name
    ```
5.  Go back to GitHub, and the button will be green now.

## 4. Keeping Everyone In Sync
After you merge a PR, tell the team in your group chat:
> "Merged the Navbar! Everyone run `git checkout main` and `git pull`."
