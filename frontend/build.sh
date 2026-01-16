#!/bin/bash

echo "---------------------------------------------------"
echo "🚀 Setting up Flutter Environment on Vercel..."
echo "---------------------------------------------------"

# Clone Flutter (Stable Channel)
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Add Flutter to Path
export PATH="$PATH:`pwd`/flutter/bin"

# Basic Config
echo "🔧 Configuring Flutter..."
flutter config --no-analytics
flutter doctor -v

# Build
echo "---------------------------------------------------"
echo "🏗️ Building Flutter Web App (Wasm/CanvasKit)..."
echo "---------------------------------------------------"
flutter build web --wasm --release

echo "✅ Build Complete!"
