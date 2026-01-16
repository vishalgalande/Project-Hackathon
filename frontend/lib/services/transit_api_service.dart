import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/transit_vehicle.dart';

class TransitApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  /// Fetch all active routes from the backend
  Future<List<TransitRoute>> fetchAllRoutes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/routes'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List routesJson = data['data'];
          return routesJson.map((json) => _parseRoute(json)).toList();
        }
      }
      print('Failed to load routes: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching routes: $e');
      return [];
    }
  }

  /// Fetch list of regions (countries/cities) for search suggestions
  Future<List<String>> fetchCities() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/regions'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List regions = data['data'];
          final List<String> cities = [];

          for (var region in regions) {
            final List cityList = region['cities'] ?? [];
            cities.addAll(cityList.map((e) => e.toString()));
          }
          return cities;
        }
      }
      return [];
    } catch (e) {
      print('Error fetching regions: $e');
      return [];
    }
  }

  TransitRoute _parseRoute(Map<String, dynamic> json) {
    // Parse stops
    List<TransitStop> stops = [];
    if (json['stops'] != null) {
      stops = (json['stops'] as List).map((s) {
        return TransitStop(
            name: s['name'],
            position: LatLng(s['lat'], s['lng']),
            arrivalTimeOffset: 0 // Mock/calculable
            );
      }).toList();
    }

    // Parse path
    List<LatLng> polyline = [];
    if (json['path'] != null) {
      polyline = (json['path'] as List)
          .map((p) => LatLng(p['lat'], p['lng']))
          .toList();
    }

    // Parse color
    Color? color = json['type'] == 'Metro'
        ? const Color(0xFF9C27B0)
        : const Color(0xFF4CAF50);
    // basic color mapping based on type or name if color not in JSON
    // (backend mock generator doesn't send hex colors explicitly usually, but let's check)

    // Parse type
    TransitType type = TransitType.bus;
    if (json['type'] != null) {
      final t = json['type'].toString().toLowerCase();
      if (t.contains('metro'))
        type = TransitType.metro;
      else if (t.contains('train') || t.contains('rail'))
        type = TransitType.train;
      else if (t.contains('tram')) type = TransitType.tram;
    }

    return TransitRoute(
        id: json['id'],
        polyline: polyline,
        stops: stops,
        color: color,
        city: json['city'],
        country: json['country_code'],
        type: type);
  }
}
