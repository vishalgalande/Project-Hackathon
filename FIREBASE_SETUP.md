# Firebase Setup Guide

This guide explains how to set up Firebase for the Tourism App.

## 1. Create a Firebase Project

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click **"Add project"**
3. Name it `tourism-hackathon` (or similar)
4. Disable Google Analytics (optional for hackathon)
5. Click **Create**

## 2. Enable Services

### Authentication
1. In Firebase Console, go to **Build → Authentication**
2. Click **Get Started**
3. Enable **Email/Password** (and optionally Google Sign-In)

### Firestore Database
1. Go to **Build → Firestore Database**
2. Click **Create Database**
3. Choose **Start in test mode** (for hackathon)
4. Select a location (asia-south1 for India)

### Storage
1. Go to **Build → Storage**
2. Click **Get Started**
3. Choose **Start in test mode**

## 3. Get Service Account Key (for Python Backend)

1. Go to **Project Settings** (gear icon) → **Service Accounts**
2. Click **Generate New Private Key**
3. Download the JSON file
4. **IMPORTANT**: Rename it to `service_account.json`
5. Move it to `firebase/service_account.json` in your project

> ⚠️ **NEVER commit this file to Git!** It's already in `.gitignore`.

## 4. Get Web Config (for Flutter)

1. Go to **Project Settings** → **General**
2. Scroll down to **Your apps**
3. Click the **</>** icon (Web app)
4. Register your app
5. Copy the config object (you'll need this for Flutter Web)

Example config:
```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456",
  appId: "1:123456:web:abc123"
};
```

## 5. Flutter Setup

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
```

Initialize in `main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

## 6. Python Backend Setup

Install the SDK:
```bash
pip install firebase-admin
```

The `backend/services/firebase_service.py` file handles everything!

## Quick Test

Run this to verify Firebase is working:
```bash
python backend/services/firebase_service.py
```

Expected output:
```
Firebase initialized for project: your-project-id
=== Firebase Service Test ===
Firebase available: True
Database connected: True
Storage connected: True
```
