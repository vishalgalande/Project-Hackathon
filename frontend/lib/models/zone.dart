import 'package:equatable/equatable.dart';

/// Zone data model for SafeZone
class Zone extends Equatable {
  final String id;
  final String name;
  final String _baseType; // The initial base type
  final double centerLat;
  final double centerLng;
  final double radius;
  final int crimeRate;
  final int lightingLevel;
  final int recentIncidents;
  final String description;
  final List<String> warnings;
  final int negativeFeedbackCount; // New field for user reports

  const Zone({
    required this.id,
    required this.name,
    required String type,
    required this.centerLat,
    required this.centerLng,
    required this.radius,
    this.crimeRate = 0,
    this.lightingLevel = 100,
    this.recentIncidents = 0,
    this.description = '',
    this.warnings = const [],
    this.negativeFeedbackCount = 0,
  }) : _baseType = type;

  /// Dynamic type based on feedback
  /// If negative reports > 10, strictly enforce DANGER type
  String get type {
    if (negativeFeedbackCount > 10) return 'danger';
    return _baseType;
  }

  String get threatLevel {
    if (negativeFeedbackCount > 10) return 'User Reported Risk';
    
    switch (_baseType.toLowerCase()) {
      case 'danger': return 'High Risk';
      case 'caution': return 'Moderate Risk';
      case 'safe': return 'Low Risk';
      default: return 'Unknown';
    }
  }
  
  // Create a copy with updated feedback
  Zone copyWithFeedback(int newCount) {
    return Zone(
      id: id,
      name: name,
      type: _baseType,
      centerLat: centerLat,
      centerLng: centerLng,
      radius: radius,
      crimeRate: crimeRate,
      lightingLevel: lightingLevel,
      recentIncidents: recentIncidents,
      description: description,
      warnings: warnings,
      negativeFeedbackCount: newCount,
    );
  }

  @override
  List<Object?> get props => [id, name, _baseType, centerLat, centerLng, radius, negativeFeedbackCount];
}

/// Expanded Mock zones including NCR (Gurgaon, Noida)
class MockZones {
  static const List<Zone> jaipurZones = [
    // --- NCR: GURGAON ---
    Zone(
      id: 'ncr_ggn_1',
      name: 'Cyber City',
      type: 'safe',
      centerLat: 28.4950,
      centerLng: 77.0890,
      radius: 600,
      crimeRate: 5,
      lightingLevel: 95,
      recentIncidents: 1,
      description: 'Corporate hub. Very safe with private security.',
      warnings: [],
      negativeFeedbackCount: 2,
    ),
    Zone(
      id: 'ncr_ggn_2',
      name: 'MG Road',
      type: 'caution',
      centerLat: 28.4800,
      centerLng: 77.0800,
      radius: 400,
      crimeRate: 25,
      lightingLevel: 80,
      recentIncidents: 3,
      description: 'Major mall mile. Heavy traffic and crowding.',
       warnings: ['Traffic congestion'],
       negativeFeedbackCount: 8, // Close to danger threshold
    ),
    Zone(
      id: 'ncr_ggn_3',
      name: 'Sector 29',
      type: 'caution',
      centerLat: 28.4690,
      centerLng: 77.0650,
      radius: 350,
      crimeRate: 30,
      lightingLevel: 70,
      recentIncidents: 5,
      description: 'Nightlife district. Rowdy on weekends.',
      warnings: ['Drink responsibly'],
      negativeFeedbackCount: 5,
    ),

    // --- NCR: NOIDA ---
    Zone(
      id: 'ncr_noida_1',
      name: 'Sector 18',
      type: 'caution',
      centerLat: 28.5700,
      centerLng: 77.3200,
      radius: 450,
      crimeRate: 35,
      lightingLevel: 75,
      recentIncidents: 4,
      description: 'Major shopping district (Atta Market).',
      warnings: ['Pickpockets active'],
      negativeFeedbackCount: 6,
    ),
    Zone(
      id: 'ncr_noida_2',
      name: 'Botanical Garden',
      type: 'safe',
      centerLat: 28.5650,
      centerLng: 77.3350,
      radius: 400,
      crimeRate: 8,
      lightingLevel: 85,
      recentIncidents: 1,
       description: 'Metro hub and park area.',
       warnings: [],
    ),

    // --- NORTH DELHI (Red/Amber) ---
    Zone(
      id: 'd_north_1',
      name: 'Chandni Chowk',
      type: 'caution',
      centerLat: 28.6562,
      centerLng: 77.2300,
      radius: 350,
      crimeRate: 45,
      lightingLevel: 60,
      recentIncidents: 5,
      description: 'Congested market. User reports indicate high theft.',
      warnings: ['Crowded', 'Watch valuables'],
      negativeFeedbackCount: 9, // One more report makes it danger
    ),
    Zone(
      id: 'd_north_2',
      name: 'Kashmere Gate',
      type: 'caution',
      centerLat: 28.6680,
      centerLng: 77.2280,
      radius: 300,
      crimeRate: 40,
      lightingLevel: 55,
      recentIncidents: 4,
      description: 'Transit hub area.',
       warnings: [],
    ),
     Zone(
      id: 'd_north_3',
      name: 'Sadar Bazar',
      type: 'danger',
      centerLat: 28.6550,
      centerLng: 77.2150,
      radius: 300,
      crimeRate: 65,
      lightingLevel: 40,
      recentIncidents: 12,
      description: 'Wholesale market.',
      warnings: ['Avoid peak hours'],
      negativeFeedbackCount: 15, // Already high feedback
    ),
    Zone(
      id: 'd_north_4',
      name: 'Red Fort',
      type: 'caution',
      centerLat: 28.6560,
      centerLng: 77.2410,
      radius: 400,
      crimeRate: 35,
      lightingLevel: 70,
      recentIncidents: 3,
      description: 'Tourist hotspot.',
      warnings: ['Ignore unauthorized guides'],
    ),
    Zone(
      id: 'd_north_5',
      name: 'GB Road',
      type: 'danger',
      centerLat: 28.6460,
      centerLng: 77.2240,
      radius: 200,
      crimeRate: 85,
      lightingLevel: 20,
      recentIncidents: 18,
      description: 'Restricted area.',
      warnings: ['Do not enter', 'High risk area'],
      negativeFeedbackCount: 50,
    ),
    Zone(
      id: 'd_north_6',
      name: 'Paharganj',
      type: 'caution',
      centerLat: 28.6410,
      centerLng: 77.2120,
      radius: 300,
      crimeRate: 50,
      lightingLevel: 50,
      recentIncidents: 7,
      description: 'Backpacker area.',
      warnings: ['Check hotel reviews', 'Avoid dark alleys'],
    ),
    Zone(
      id: 'd_north_7',
      name: 'Jama Masjid',
      type: 'caution',
      centerLat: 28.6507,
      centerLng: 77.2334,
      radius: 250,
      crimeRate: 30,
      lightingLevel: 55,
      recentIncidents: 2,
      description: 'Historic area.',
      warnings: [],
    ),

    // --- CENTRAL DELHI (Green/Safe) ---
    Zone(
      id: 'd_central_1',
      name: 'Connaught Place',
      type: 'safe',
      centerLat: 28.6315,
      centerLng: 77.2167,
      radius: 500,
      crimeRate: 10,
      lightingLevel: 95,
      recentIncidents: 1,
      description: 'Central business district.',
      warnings: [],
    ),
    Zone(
      id: 'd_central_2',
      name: 'India Gate',
      type: 'safe',
      centerLat: 28.6129,
      centerLng: 77.2295,
      radius: 600,
      crimeRate: 5,
      lightingLevel: 90,
      recentIncidents: 0,
      description: 'National monument area.',
      warnings: [],
    ),
    Zone(
      id: 'd_central_3',
      name: 'Parliament Street',
      type: 'safe',
      centerLat: 28.6200,
      centerLng: 77.2100,
      radius: 400,
      crimeRate: 2,
      lightingLevel: 98,
      recentIncidents: 0,
      description: 'High security government zone.',
      warnings: [],
    ),
    Zone(
      id: 'd_central_4',
      name: 'Bengali Market',
      type: 'safe',
      centerLat: 28.6290,
      centerLng: 77.2330,
      radius: 200,
      crimeRate: 8,
      lightingLevel: 92,
      recentIncidents: 0,
      description: 'Popular food area.',
      warnings: [],
    ),

    // --- SOUTH DELHI (Green/Safe) ---
    Zone(
      id: 'd_south_1',
      name: 'Khan Market',
      type: 'safe',
      centerLat: 28.6005,
      centerLng: 77.2270,
      radius: 250,
      crimeRate: 5,
      lightingLevel: 99,
      recentIncidents: 0,
      description: 'Upscale retail.',
      warnings: [],
    ),
    Zone(
      id: 'd_south_2',
      name: 'Lodhi Gardens',
      type: 'safe',
      centerLat: 28.5930,
      centerLng: 77.2200,
      radius: 500,
      crimeRate: 4,
      lightingLevel: 85,
      recentIncidents: 0,
       description: 'Public park.',
      warnings: [],
    ),
     Zone(
      id: 'd_south_3',
      name: 'Chanakyapuri',
      type: 'safe',
      centerLat: 28.5900,
      centerLng: 77.1900,
      radius: 800,
      crimeRate: 1,
      lightingLevel: 100,
      recentIncidents: 0,
       description: 'Diplomatic enclave.',
      warnings: [],
    ),
     Zone(
      id: 'd_south_4',
      name: 'Hauz Khas Village',
      type: 'caution',
      centerLat: 28.5539,
      centerLng: 77.1942,
      radius: 300,
      crimeRate: 25,
      lightingLevel: 70,
      recentIncidents: 3,
       description: 'Nightlife hub.',
      warnings: ['Drink responsibly'],
    ),
    
    // --- EAST DELHI (DANGER/CAUTION) ---
     Zone(
      id: 'd_east_1',
      name: 'Seelampur',
      type: 'danger',
      centerLat: 28.6670,
      centerLng: 77.2700,
      radius: 400,
      crimeRate: 70,
      lightingLevel: 40,
      recentIncidents: 15,
       description: 'Dense area.',
      warnings: ['Local guide required'],
    ),
    Zone(
      id: 'd_east_2',
      name: 'Laxmi Nagar',
      type: 'caution',
      centerLat: 28.6320,
      centerLng: 77.2750,
      radius: 400,
      crimeRate: 35,
      lightingLevel: 65,
      recentIncidents: 4,
       description: 'Student hub.',
      warnings: [],
    ),
    // --- WEST DELHI (Filling empty areas) ---
    Zone(
      id: 'd_west_1',
      name: 'Punjabi Bagh',
      type: 'safe',
      centerLat: 28.6650,
      centerLng: 77.1300,
      radius: 450,
      crimeRate: 15,
      lightingLevel: 90,
      recentIncidents: 2,
      description: 'Affluent residential area with good security.',
      warnings: [],
      negativeFeedbackCount: 1,
    ),
    Zone(
      id: 'd_west_2',
      name: 'Janakpuri',
      type: 'safe',
      centerLat: 28.6200,
      centerLng: 77.0900,
      radius: 500,
      crimeRate: 20,
      lightingLevel: 85,
      recentIncidents: 3,
      description: 'Major residential hub with District Centre.',
      warnings: [],
    ),
    Zone(
      id: 'd_west_3',
      name: 'Dwarka',
      type: 'safe',
      centerLat: 28.5900,
      centerLng: 77.0500,
      radius: 700,
      crimeRate: 10,
      lightingLevel: 88,
      recentIncidents: 1,
      description: 'Planned sub-city with wide roads and societies.',
      warnings: [],
    ),
    Zone(
      id: 'd_west_4',
      name: 'Rohini',
      type: 'caution',
      centerLat: 28.7100,
      centerLng: 77.1100,
      radius: 600,
      crimeRate: 40,
      lightingLevel: 70,
      recentIncidents: 6,
      description: 'Large residential zone. Some areas poorly lit.',
      warnings: ['Avoid parks at night'],
    ),
    Zone(
      id: 'd_west_5',
      name: 'Rajouri Garden',
      type: 'safe',
      centerLat: 28.6430,
      centerLng: 77.1200,
      radius: 350,
      crimeRate: 18,
      lightingLevel: 95,
      recentIncidents: 2,
      description: 'Shopping and dining hub. Crowded but safe.',
      warnings: [],
    ),
    Zone(
      id: 'd_west_6',
      name: 'Tilak Nagar',
      type: 'caution',
      centerLat: 28.6360,
      centerLng: 77.0960,
      radius: 300,
      crimeRate: 35,
      lightingLevel: 65,
      recentIncidents: 4,
      description: 'Dense market area.',
      warnings: ['High traffic'],
    ),
    Zone(
      id: 'd_west_7',
      name: 'Paschim Vihar',
      type: 'safe',
      centerLat: 28.6700,
      centerLng: 77.1000,
      radius: 400,
      crimeRate: 12,
      lightingLevel: 92,
      recentIncidents: 1,
      description: 'Upmarket residential colony.',
      warnings: [],
    ),
    Zone(
      id: 'd_west_8',
      name: 'Pitampura',
      type: 'safe',
      centerLat: 28.6990,
      centerLng: 77.1380,
      radius: 450,
      crimeRate: 14,
      lightingLevel: 90,
      recentIncidents: 0,
      description: 'Commercial and residential hub (NSP).',
      warnings: [],
    ),
  ];
}
