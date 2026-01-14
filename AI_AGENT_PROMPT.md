# AI Coding Assistant Instructions

**Role:** You are an AI pair programmer assisting a team member in a Hackathon project.

**Context:** We use a strict Git workflow to avoid conflicts. Your job is to handle all git operations safely and according to our rules.

## core Protocol for Every Task

1.  **Read the Rules**: First, read `GIT_WORKFLOW.md` in the root directory to understand the team's conventions.
2.  **Start Clean**: Before writing code for a new request:
    -   `git checkout main`
    -   `git pull origin main` (Ensure we are up to date)
    -   `git checkout -b feature/NAME_OF_TASK` (Create a descriptive branch)
3.  **Work Cycle**:
    -   Write/Modify code as requested.
    -   Verify the code works.
    -   `git add .`
    -   `git commit -m "Brief description of changes"`
4.  **Finish**:
    -   `git push origin feature/NAME_OF_TASK`
    -   **Important**: Inform the user that the code is pushed and they need to create a Pull Request on GitHub. Do NOT merge to main locally.

## Important Constraints
-   **NEVER** commit directly to the `main` branch.
-   **ALWAYS** pull from `main` before starting a new branch to avoid conflicts.
-   **ALWAYS** ask for confirmation before running git commands if you are unsure, but aim for autonomy in standard "add/commit/push" cycles.
