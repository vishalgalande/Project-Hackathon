import 'package:equatable/equatable.dart';

/// Zone data model for SafeZone
class Zone extends Equatable {
  final String id;
  final String name;
  final String type; // 'danger', 'caution', 'safe'
  final double centerLat;
  final double centerLng;
  final double radius; // in meters
  final int crimeRate;       // 0-100
  final int lightingLevel;   // 0-100
  final int recentIncidents;
  final String description;
  final List<String> warnings;
  
  const Zone({
    required this.id,
    required this.name,
    required this.type,
    required this.centerLat,
    required this.centerLng,
    required this.radius,
    this.crimeRate = 0,
    this.lightingLevel = 100,
    this.recentIncidents = 0,
    this.description = '',
    this.warnings = const [],
  });
  
  /// Create Zone from Firestore document
  factory Zone.fromFirestore(Map<String, dynamic> data, String docId) {
    final center = data['center'] as Map<String, dynamic>? ?? {};
    return Zone(
      id: docId,
      name: data['name'] ?? 'Unknown Zone',
      type: data['type'] ?? 'safe',
      centerLat: (center['lat'] ?? 0).toDouble(),
      centerLng: (center['lng'] ?? 0).toDouble(),
      radius: (data['radius'] ?? 500).toDouble(),
      crimeRate: data['crimeRate'] ?? 0,
      lightingLevel: data['lightingLevel'] ?? 100,
      recentIncidents: data['recentIncidents'] ?? 0,
      description: data['description'] ?? '',
      warnings: List<String>.from(data['warnings'] ?? []),
    );
  }
  
  /// Get threat level as a string
  String get threatLevel {
    switch (type.toLowerCase()) {
      case 'danger':
        return 'High Risk';
      case 'caution':
        return 'Moderate Risk';
      case 'safe':
        return 'Low Risk';
      default:
        return 'Unknown';
    }
  }
  
  @override
  List<Object?> get props => [id, name, type, centerLat, centerLng, radius];
}

/// Mock zones for Delhi demo (matching the reference image)
class MockZones {
  static const List<Zone> jaipurZones = [
    // Yellow/Amber zones (Caution) - in the Central/North Delhi area
    Zone(
      id: 'delhi_caution_1',
      name: 'Chandni Chowk',
      type: 'caution',
      centerLat: 28.6562,
      centerLng: 77.2300,
      radius: 400,
      crimeRate: 45,
      lightingLevel: 60,
      recentIncidents: 5,
      description: 'Busy market area. Watch for pickpockets.',
      warnings: ['Keep valuables secure', 'Crowded during evenings'],
    ),
    Zone(
      id: 'delhi_caution_2',
      name: 'Kashmere Gate',
      type: 'caution',
      centerLat: 28.6680,
      centerLng: 77.2280,
      radius: 350,
      crimeRate: 40,
      lightingLevel: 55,
      recentIncidents: 4,
      description: 'Transit hub area with moderate foot traffic.',
      warnings: ['Be alert at night'],
    ),
    Zone(
      id: 'delhi_caution_3',
      name: 'Old Delhi Railway',
      type: 'caution',
      centerLat: 28.6617,
      centerLng: 77.2272,
      radius: 400,
      crimeRate: 50,
      lightingLevel: 50,
      recentIncidents: 6,
      description: 'Railway station area. High tourist traffic.',
      warnings: ['Watch bags', 'Use official taxis'],
    ),
    Zone(
      id: 'delhi_caution_4',
      name: 'Red Fort Area',
      type: 'caution',
      centerLat: 28.6562,
      centerLng: 77.2410,
      radius: 450,
      crimeRate: 35,
      lightingLevel: 70,
      recentIncidents: 3,
      description: 'Tourist destination with vendor activity.',
      warnings: ['Bargain for prices', 'Official guides only'],
    ),
    
    // Green zones (Safe) - in South Delhi
    Zone(
      id: 'delhi_safe_1',
      name: 'Connaught Place',
      type: 'safe',
      centerLat: 28.6315,
      centerLng: 77.2167,
      radius: 500,
      crimeRate: 12,
      lightingLevel: 95,
      recentIncidents: 1,
      description: 'Well-patrolled commercial hub with 24/7 security.',
      warnings: [],
    ),
    Zone(
      id: 'delhi_safe_2',
      name: 'Khan Market',
      type: 'safe',
      centerLat: 28.6005,
      centerLng: 77.2270,
      radius: 300,
      crimeRate: 8,
      lightingLevel: 98,
      recentIncidents: 0,
      description: 'Upscale shopping area with excellent security.',
      warnings: [],
    ),
    Zone(
      id: 'delhi_safe_3',
      name: 'Lodhi Gardens',
      type: 'safe',
      centerLat: 28.5931,
      centerLng: 77.2197,
      radius: 400,
      crimeRate: 5,
      lightingLevel: 90,
      recentIncidents: 0,
      description: 'Popular park area, safe during day hours.',
      warnings: [],
    ),
  ];
}
