# API Documentation for Flutter Frontend

This document describes all available backend API endpoints.

## Base URL
When running locally: `http://localhost:5000`
When deployed on Vercel: `https://your-app.vercel.app/api`

---

## Zones API (Geo-Fencing)

### GET `/zones`
Returns all map chunks with their current zone colors.

**Response:**
```json
{
  "success": true,
  "count": 6,
  "zones": [
    {
      "id": "chunk_001",
      "name": "Beach Area",
      "bounds": {
        "lat_min": 12.91,
        "lat_max": 12.92,
        "lng_min": 77.58,
        "lng_max": 77.59
      },
      "score": 6,
      "zone_color": "green",
      "vote_count": 6
    }
  ]
}
```

### GET `/zones/{chunk_id}`
Returns details for a single chunk.

**Parameters:**
- `chunk_id` (string): The ID of the chunk (e.g., `chunk_001`)

**Response:**
```json
{
  "success": true,
  "zone": {
    "id": "chunk_001",
    "name": "Beach Area",
    "bounds": { ... },
    "score": 6,
    "zone_color": "green",
    "vote_count": 6
  }
}
```

### POST `/zones/{chunk_id}/vote`
Submit a safety vote for a zone.

**Parameters:**
- `chunk_id` (string): The ID of the chunk

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
  "message": "Vote recorded for Beach Area",
  "new_score": 7,
  "new_zone_color": "green"
}
```

### GET `/zones/location?lat=X&lng=Y`
Find which zone contains a specific coordinate.

**Query Parameters:**
- `lat` (float): Latitude
- `lng` (float): Longitude

**Response:**
```json
{
  "success": true,
  "zone": { ... }
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

## Flutter Integration Example

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Zone>> fetchZones() async {
  final response = await http.get(Uri.parse('$baseUrl/zones'));
  final data = jsonDecode(response.body);
  return (data['zones'] as List).map((z) => Zone.fromJson(z)).toList();
}

Future<void> submitVote(String chunkId, int vote) async {
  await http.post(
    Uri.parse('$baseUrl/zones/$chunkId/vote'),
    body: jsonEncode({'vote': vote}),
    headers: {'Content-Type': 'application/json'},
  );
}
```
