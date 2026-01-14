# API Documentation for Flutter Frontend

This document describes all available backend API endpoints.

## Base URL
- **Local**: `http://localhost:5000`
- **Vercel**: `https://your-app.vercel.app/api`

---

## Authentication

All voting endpoints require authentication. Include the Firebase ID token in the header:

```
Authorization: Bearer <firebase_id_token>
```

### Getting the Token (Flutter)

```dart
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getAuthToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return await user.getIdToken();
  }
  return null;
}

// Usage in API calls
Future<void> makeAuthenticatedRequest() async {
  final token = await getAuthToken();
  final response = await http.post(
    Uri.parse('$baseUrl/zones/delhi_001/vote'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'vote': 1}),
  );
}
```

---

## Zones API

### GET `/zones`
Returns all map chunks with their current zone colors.

**Authentication**: Not required

**Response:**
```json
{
  "success": true,
  "count": 9,
  "source": "firestore",
  "zones": [
    {
      "id": "delhi_001",
      "name": "Connaught Place",
      "bounds": {
        "lat_min": 28.628,
        "lat_max": 28.638,
        "lng_min": 77.215,
        "lng_max": 77.225
      },
      "score": 8,
      "zone_color": "green"
    }
  ]
}
```

### GET `/zones/{zone_id}`
Returns details for a single zone.

**Authentication**: Not required

### POST `/zones/{zone_id}/vote`
Submit a safety vote for a zone.

**Authentication**: ✅ Required

**Headers:**
```
Authorization: Bearer <firebase_id_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "vote": 1
}
```
- `vote`: `1` for SAFE, `-1` for DANGER

**Response:**
```json
{
  "success": true,
  "message": "Vote recorded for Connaught Place",
  "new_score": 9,
  "new_zone_color": "green"
}
```

**Error Response (401):**
```json
{
  "success": false,
  "error": "Authentication required",
  "code": "UNAUTHORIZED"
}
```

---

## Zone Color Logic

| Score Range | Color | Meaning |
|-------------|-------|---------|
| score >= 5  | 🟢 green | Safe zone |
| -5 < score < 5 | 🟡 yellow | Caution zone |
| score <= -5 | 🔴 red | Danger zone |

---

## Flutter Complete Example

### 1. Setup Firebase Auth

```dart
// pubspec.yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  http: ^1.1.0
```

### 2. Auth Service

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Sign in with email/password
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }
  
  // Sign up
  Future<User?> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }
  
  // Sign out
  Future<void> signOut() => _auth.signOut();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Get ID token for API calls
  Future<String?> getIdToken() async {
    return await currentUser?.getIdToken();
  }
}
```

### 3. Zone API Service

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ZoneService {
  final String baseUrl;
  final AuthService authService;
  
  ZoneService({required this.baseUrl, required this.authService});
  
  // Fetch all zones (no auth required)
  Future<List<Zone>> fetchZones() async {
    final response = await http.get(Uri.parse('$baseUrl/zones'));
    final data = jsonDecode(response.body);
    return (data['zones'] as List)
        .map((z) => Zone.fromJson(z))
        .toList();
  }
  
  // Submit vote (auth required)
  Future<VoteResult> submitVote(String zoneId, int vote) async {
    final token = await authService.getIdToken();
    if (token == null) throw Exception('Not logged in');
    
    final response = await http.post(
      Uri.parse('$baseUrl/zones/$zoneId/vote'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'vote': vote}),
    );
    
    if (response.statusCode == 401) {
      throw Exception('Please log in to vote');
    }
    
    return VoteResult.fromJson(jsonDecode(response.body));
  }
}
```

### 4. Zone Model

```dart
class Zone {
  final String id;
  final String name;
  final Map<String, double> bounds;
  final int score;
  final String zoneColor;
  
  Zone({
    required this.id,
    required this.name,
    required this.bounds,
    required this.score,
    required this.zoneColor,
  });
  
  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'],
      name: json['name'],
      bounds: Map<String, double>.from(json['bounds']),
      score: json['score'],
      zoneColor: json['zone_color'],
    );
  }
  
  Color get color {
    switch (zoneColor) {
      case 'green': return Colors.green;
      case 'red': return Colors.red;
      default: return Colors.yellow;
    }
  }
}
```
