@echo off
echo ==========================================
echo 🏗️  BUILDING SAFE TRAVEL INDIA (RELEASE)
echo ==========================================
call flutter build web --release --no-tree-shake-icons
if %errorlevel% neq 0 (
    echo ❌ Build failed! Aborting deployment.
    pause
    exit /b %errorlevel%
)

echo.
echo ==========================================
echo 🚀 DEPLOYING TO FIREBASE HOSTING
echo ==========================================
call npx firebase-tools deploy --only hosting

echo.
echo ✅ SUCCESS! Your changes are now live.
pause
