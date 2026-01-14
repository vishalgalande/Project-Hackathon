# Deploying to Vercel

Since our project has both a **Flutter Frontend** and a **Python Backend**, we need to configure Vercel carefully.

## 1. Connect to Vercel
1.  Go to [Vercel.com](https://vercel.com) and sign up/login.
2.  Click **"Add New..."** -> **"Project"**.
3.  Import your `Project-Hackathon` repository.

## 2. Configure Project Settings (Crucial!)
Before clicking "Deploy", you must configure the Build settings so Vercel can run Flutter.

### Frontend Settings (Root Directory)
Vercel might ask for the "Root Directory".
-   Select `frontend` as the root directory? **NO**, keep the root as `.` (the main folder), but we need to override the **Build Command**.

**ACTUALLY**: Vercel does not have Flutter installed by default.
**The Easiest Hackathon Solution**:
1.  **Build Locally**: Run `flutter build web` on your laptop.
2.  This creates a `build/web` folder in `frontend/`.
3.  **Un-ignore it**: Open `.gitignore` and remove `build/` from the Flutter section (or force add it).
4.  **Push** the `build/web` folder to GitHub.
5.  **In Vercel**:
    -   **Output Directory**: Set this to `frontend/build/web`.
    -   **Framework Preset**: Select "Other".

*Note: The "Proper" way is to use a custom install script on Vercel to install Flutter every time, but that takes 5+ minutes per build. For a hackathon, committing the build folder is faster.*

### Backend Settings
The `vercel.json` file I created handles the backend.
-   It tells Vercel that `backend/main.py` is a serverless function.
-   Any request to `https://your-app.vercel.app/api/...` will go to Python.

## 3. Python Requirements
Make sure your `backend/requirements.txt` lists your framework (likely `Flask` or `FastAPI`).
Example content for `requirements.txt`:
```
Flask
```

## 4. Deploy
Click **Deploy**.
-   Updates to the `main` branch will auto-deploy.
