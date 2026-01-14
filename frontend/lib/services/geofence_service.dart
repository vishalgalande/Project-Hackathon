// Geofence Service - Handles API calls and location checking
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

/// Model for a geofence zone
class GeofenceZone {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String category;

  GeofenceZone({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.category,
  });

  factory GeofenceZone.fromJson(Map<String, dynamic> json) {
    return GeofenceZone(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      radiusMeters: (json['radius_meters'] ?? 0).toDouble(),
      category: json['category'] ?? '',
    );
  }
}

/// Model for zone status when checking location
class ZoneStatus {
  final String zoneId;
  final String zoneName;
  final bool isInside;
  final double distanceMeters;
  final String description;

  ZoneStatus({
    required this.zoneId,
    required this.zoneName,
    required this.isInside,
    required this.distanceMeters,
    required this.description,
  });

  factory ZoneStatus.fromJson(Map<String, dynamic> json) {
    return ZoneStatus(
      zoneId: json['zone_id'] ?? '',
      zoneName: json['zone_name'] ?? '',
      isInside: json['is_inside'] ?? false,
      distanceMeters: (json['distance_meters'] ?? 0).toDouble(),
      description: json['description'] ?? '',
    );
  }
}

/// Service for geofencing operations
class GeofenceService {
  // IMPORTANT: Change this to your backend URL
  // For Android emulator, use 10.0.2.2 instead of localhost
  // For physical device, use your computer's IP address
  static const String baseUrl = 'http://10.0.2.2:8000';

  /// Get all geofence zones from the backend
  static Future<List<GeofenceZone>> getZones() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/geofence/zones'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final zones = data['zones'] as List;
        return zones.map((z) => GeofenceZone.fromJson(z)).toList();
      } else {
        throw Exception('Failed to load zones: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching zones: $e');
      // Return mock data for demo if backend is unavailable
      return _getMockZones();
    }
  }

  /// Check current location against all geofence zones
  static Future<Map<String, dynamic>> checkLocation(
      double latitude, double longitude) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/geofence/check'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'latitude': latitude,
              'longitude': longitude,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check location: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking location: $e');
      // Return mock response for demo
      return _getMockCheckResponse(latitude, longitude);
    }
  }

  /// Request location permission and get current position
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return null;
    }

    // Check and request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return null;
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Calculate distance between two points in meters (Haversine formula)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // ============================================================================
  // MOCK DATA (For demo when backend unavailable)
  // ============================================================================

  static List<GeofenceZone> _getMockZones() {
    return [
      GeofenceZone(
        id: 'zone_1',
        name: 'Tech Museum',
        description: 'Interactive technology exhibits and hands-on experiences.',
        latitude: 37.4220,
        longitude: -122.0840,
        radiusMeters: 200,
        category: 'museum',
      ),
      GeofenceZone(
        id: 'zone_2',
        name: 'Central Park',
        description: 'Beautiful urban park with walking trails.',
        latitude: 37.4250,
        longitude: -122.0800,
        radiusMeters: 300,
        category: 'park',
      ),
      GeofenceZone(
        id: 'zone_3',
        name: 'Historic Monument',
        description: 'A landmark commemorating the city\'s rich history.',
        latitude: 37.4190,
        longitude: -122.0870,
        radiusMeters: 150,
        category: 'monument',
      ),
    ];
  }

  static Map<String, dynamic> _getMockCheckResponse(double lat, double lon) {
    final zones = _getMockZones();
    final insideZones = <Map<String, dynamic>>[];
    final nearbyZones = <Map<String, dynamic>>[];

    for (var zone in zones) {
      final distance = calculateDistance(lat, lon, zone.latitude, zone.longitude);
      final status = {
        'zone_id': zone.id,
        'zone_name': zone.name,
        'is_inside': distance <= zone.radiusMeters,
        'distance_meters': distance,
        'description': zone.description,
      };

      if (distance <= zone.radiusMeters) {
        insideZones.add(status);
      } else if (distance <= 500) {
        nearbyZones.add(status);
      }
    }

    return {
      'current_location': {'latitude': lat, 'longitude': lon},
      'inside_zones': insideZones,
      'nearby_zones': nearbyZones,
    };
  }
}
