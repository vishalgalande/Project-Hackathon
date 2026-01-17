@echo off
echo ==========================================
echo      Strawhats Deployment Script
echo ==========================================

REM --- Configuration ---
set WEB_PROJECT=team-strawhats
REM set APPS_PROJECT=heacathon-f52de

echo.
echo [1/3] Building Website (Next.js)...
cd team-strawhats-web
call npm install
if %errorlevel% neq 0 (
    echo Error installing website dependencies.
    pause
    exit /b %errorlevel%
)
call npm run build
if %errorlevel% neq 0 (
    echo Error building website.
    pause
    exit /b %errorlevel%
)
cd ..

echo.
echo [3/3] Deploying...

echo.
echo --> Switching to WEBSITE project (%WEB_PROJECT%)...
call firebase use %WEB_PROJECT%
echo --> Deploying Website...
call firebase deploy --only hosting:team-strawhats

echo.
echo ==========================================
echo      Deployment Complete!
echo ==========================================
pause
