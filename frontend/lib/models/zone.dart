import 'package:equatable/equatable.dart';

/// Zone data model for SafeZone
class Zone extends Equatable {
  final String id;
  final String cityId; // Link to parent city
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
  final int negativeFeedbackCount; // Total user reports

  // Categorized report counts
  final int theftReports;
  final int harassmentReports;
  final int poorLightingReports;
  final int suspiciousReports;

  const Zone({
    required this.id,
    this.cityId = '',
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
    this.theftReports = 0,
    this.harassmentReports = 0,
    this.poorLightingReports = 0,
    this.suspiciousReports = 0,
  }) : _baseType = type;

  /// Create Zone from Firebase document
  factory Zone.fromFirebase(String id, Map<String, dynamic> data) {
    return Zone(
      id: id,
      cityId: data['cityId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? 'safe',
      centerLat: (data['centerLat'] ?? 0).toDouble(),
      centerLng: (data['centerLng'] ?? 0).toDouble(),
      radius: (data['radius'] ?? 500).toDouble(),
      crimeRate: data['crimeRate'] ?? 0,
      lightingLevel: data['lightingLevel'] ?? 100,
      recentIncidents: data['recentIncidents'] ?? 0,
      description: data['description'] ?? '',
      warnings: List<String>.from(data['warnings'] ?? []),
      negativeFeedbackCount: data['negativeFeedbackCount'] ?? 0,
      theftReports: data['theftReports'] ?? 0,
      harassmentReports: data['harassmentReports'] ?? 0,
      poorLightingReports: data['poorLightingReports'] ?? 0,
      suspiciousReports: data['suspiciousReports'] ?? 0,
    );
  }

  /// Convert Zone to Firebase map
  Map<String, dynamic> toMap() {
    return {
      'cityId': cityId,
      'name': name,
      'type': _baseType,
      'centerLat': centerLat,
      'centerLng': centerLng,
      'radius': radius,
      'crimeRate': crimeRate,
      'lightingLevel': lightingLevel,
      'recentIncidents': recentIncidents,
      'description': description,
      'warnings': warnings,
      'negativeFeedbackCount': negativeFeedbackCount,
      'theftReports': theftReports,
      'harassmentReports': harassmentReports,
      'poorLightingReports': poorLightingReports,
      'suspiciousReports': suspiciousReports,
    };
  }

  /// Get live warnings based on actual report counts
  List<String> get liveWarnings {
    final List<String> result = [];
    if (theftReports >= 3)
      result.add('⚠️ Theft/Pickpocketing reported ($theftReports reports)');
    if (harassmentReports >= 3)
      result.add('⚠️ Harassment reported ($harassmentReports reports)');
    if (poorLightingReports >= 3)
      result.add('💡 Poor lighting reported ($poorLightingReports reports)');
    if (suspiciousReports >= 3)
      result
          .add('👁️ Suspicious activity reported ($suspiciousReports reports)');
    return result;
  }

  /// Dynamic type based on feedback
  /// If negative reports > 10, strictly enforce DANGER type
  String get type {
    if (negativeFeedbackCount > 10) return 'danger';
    return _baseType;
  }

  String get threatLevel {
    if (negativeFeedbackCount > 10) return 'User Reported Risk';

    switch (_baseType.toLowerCase()) {
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

  /// Pulse animation speed based on zone type
  /// Danger zones pulse faster to draw attention
  Duration get pulseSpeed {
    switch (type.toLowerCase()) {
      case 'danger':
        return const Duration(milliseconds: 800);
      case 'caution':
        return const Duration(milliseconds: 1200);
      case 'safe':
        return const Duration(milliseconds: 1500);
      default:
        return const Duration(milliseconds: 1000);
    }
  }

  // Create a copy with updated feedback
  Zone copyWithFeedback(int newCount) {
    return Zone(
      id: id,
      cityId: cityId,
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
  List<Object?> get props => [
        id,
        cityId,
        name,
        _baseType,
        centerLat,
        centerLng,
        radius,
        negativeFeedbackCount
      ];
}

/// City cluster for aggregated zone display when zoomed out
class CityCluster {
  final String cityId;
  final String cityName;
  final double centerLat;
  final double centerLng;
  final int zoneCount;
  final int avgCrimeRate;
  final int avgLightingLevel;
  final String dominantType; // 'safe', 'caution', or 'danger'

  const CityCluster({
    required this.cityId,
    required this.cityName,
    required this.centerLat,
    required this.centerLng,
    required this.zoneCount,
    required this.avgCrimeRate,
    this.avgLightingLevel = 80,
    required this.dominantType,
  });

  /// Create CityCluster from Firebase document
  factory CityCluster.fromFirebase(String id, Map<String, dynamic> data) {
    return CityCluster(
      cityId: id,
      cityName: data['name'] ?? '',
      centerLat: (data['centerLat'] ?? 0).toDouble(),
      centerLng: (data['centerLng'] ?? 0).toDouble(),
      zoneCount: data['zoneCount'] ?? 0,
      avgCrimeRate: data['avgCrimeRate'] ?? 0,
      avgLightingLevel: data['avgLightingLevel'] ?? 80,
      dominantType: data['dominantType'] ?? 'safe',
    );
  }

  /// Convert CityCluster to Firebase map
  Map<String, dynamic> toMap() {
    return {
      'name': cityName,
      'centerLat': centerLat,
      'centerLng': centerLng,
      'zoneCount': zoneCount,
      'avgCrimeRate': avgCrimeRate,
      'avgLightingLevel': avgLightingLevel,
      'dominantType': dominantType,
    };
  }

  /// Create a cluster from a list of zones
  factory CityCluster.fromZones(
      String cityId, String cityName, List<Zone> zones) {
    if (zones.isEmpty) {
      return CityCluster(
        cityId: cityId,
        cityName: cityName,
        centerLat: 0,
        centerLng: 0,
        zoneCount: 0,
        avgCrimeRate: 0,
        avgLightingLevel: 80,
        dominantType: 'safe',
      );
    }

    // Calculate center
    final avgLat =
        zones.map((z) => z.centerLat).reduce((a, b) => a + b) / zones.length;
    final avgLng =
        zones.map((z) => z.centerLng).reduce((a, b) => a + b) / zones.length;

    // Calculate averages
    final avgCrime =
        zones.map((z) => z.crimeRate).reduce((a, b) => a + b) ~/ zones.length;
    final avgLighting =
        zones.map((z) => z.lightingLevel).reduce((a, b) => a + b) ~/
            zones.length;

    // Count zone types
    int dangerCount = zones.where((z) => z.type == 'danger').length;
    int cautionCount = zones.where((z) => z.type == 'caution').length;
    int safeCount = zones.where((z) => z.type == 'safe').length;

    // Determine dominant type
    String dominant = 'safe';
    if (dangerCount > 0) {
      dominant = 'danger'; // Any danger zone makes it dangerous
    } else if (cautionCount > safeCount) {
      dominant = 'caution';
    }

    return CityCluster(
      cityId: cityId,
      cityName: cityName,
      centerLat: avgLat,
      centerLng: avgLng,
      zoneCount: zones.length,
      avgCrimeRate: avgCrime,
      avgLightingLevel: avgLighting,
      dominantType: dominant,
    );
  }
}

/// Expanded Mock zones for All India
class MockZones {
  static const List<Zone> allIndiaZones = [
    // ============================================
    // DELHI NCR
    // ============================================
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
      name: 'MG Road Gurgaon',
      type: 'caution',
      centerLat: 28.4800,
      centerLng: 77.0800,
      radius: 400,
      crimeRate: 25,
      lightingLevel: 80,
      recentIncidents: 3,
      description: 'Major mall mile. Heavy traffic and crowding.',
      warnings: ['Traffic congestion'],
      negativeFeedbackCount: 8,
    ),
    // --- NCR: NOIDA ---
    Zone(
      id: 'ncr_noida_1',
      name: 'Sector 18 Noida',
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
    // --- DELHI ---
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
      negativeFeedbackCount: 9,
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
      negativeFeedbackCount: 15,
    ),

    // ============================================
    // MUMBAI
    // ============================================
    Zone(
      id: 'mum_1',
      name: 'Bandra West',
      type: 'safe',
      centerLat: 19.0596,
      centerLng: 72.8295,
      radius: 500,
      crimeRate: 12,
      lightingLevel: 90,
      recentIncidents: 2,
      description: 'Upscale neighborhood with cafes and boutiques.',
      warnings: [],
    ),
    Zone(
      id: 'mum_2',
      name: 'Colaba',
      type: 'safe',
      centerLat: 18.9067,
      centerLng: 72.8147,
      radius: 400,
      crimeRate: 8,
      lightingLevel: 95,
      recentIncidents: 1,
      description: 'Tourist area near Gateway of India.',
      warnings: [],
    ),
    Zone(
      id: 'mum_3',
      name: 'Dharavi',
      type: 'danger',
      centerLat: 19.0430,
      centerLng: 72.8567,
      radius: 600,
      crimeRate: 70,
      lightingLevel: 35,
      recentIncidents: 15,
      description: 'Dense slum area. Use caution.',
      warnings: ['Local guide recommended', 'Avoid after dark'],
      negativeFeedbackCount: 25,
    ),
    Zone(
      id: 'mum_4',
      name: 'Andheri East',
      type: 'caution',
      centerLat: 19.1136,
      centerLng: 72.8697,
      radius: 500,
      crimeRate: 35,
      lightingLevel: 70,
      recentIncidents: 5,
      description: 'Commercial hub. Crowded during rush hours.',
      warnings: ['Heavy traffic'],
    ),
    Zone(
      id: 'mum_5',
      name: 'Marine Drive',
      type: 'safe',
      centerLat: 18.9442,
      centerLng: 72.8234,
      radius: 400,
      crimeRate: 5,
      lightingLevel: 98,
      recentIncidents: 0,
      description: 'Iconic seafront promenade.',
      warnings: [],
    ),
    Zone(
      id: 'mum_6',
      name: 'Dadar',
      type: 'caution',
      centerLat: 19.0178,
      centerLng: 72.8478,
      radius: 400,
      crimeRate: 40,
      lightingLevel: 65,
      recentIncidents: 6,
      description: 'Busy transit hub. Flower and vegetable markets.',
      warnings: ['Pickpockets', 'Crowded'],
    ),

    // ============================================
    // BANGALORE
    // ============================================
    Zone(
      id: 'blr_1',
      name: 'Koramangala',
      type: 'safe',
      centerLat: 12.9352,
      centerLng: 77.6245,
      radius: 500,
      crimeRate: 10,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Startup hub with restaurants and pubs.',
      warnings: [],
    ),
    Zone(
      id: 'blr_2',
      name: 'Whitefield',
      type: 'safe',
      centerLat: 12.9698,
      centerLng: 77.7500,
      radius: 600,
      crimeRate: 8,
      lightingLevel: 92,
      recentIncidents: 1,
      description: 'IT corridor with tech parks.',
      warnings: [],
    ),
    Zone(
      id: 'blr_3',
      name: 'MG Road Bangalore',
      type: 'safe',
      centerLat: 12.9758,
      centerLng: 77.6045,
      radius: 400,
      crimeRate: 15,
      lightingLevel: 95,
      recentIncidents: 2,
      description: 'Prime shopping and entertainment district.',
      warnings: [],
    ),
    Zone(
      id: 'blr_4',
      name: 'Majestic',
      type: 'caution',
      centerLat: 12.9766,
      centerLng: 77.5713,
      radius: 400,
      crimeRate: 45,
      lightingLevel: 60,
      recentIncidents: 7,
      description: 'Main bus station. Very crowded.',
      warnings: ['Pickpockets active', 'Avoid late night'],
      negativeFeedbackCount: 8,
    ),
    Zone(
      id: 'blr_5',
      name: 'Electronic City',
      type: 'safe',
      centerLat: 12.8456,
      centerLng: 77.6603,
      radius: 700,
      crimeRate: 7,
      lightingLevel: 88,
      recentIncidents: 1,
      description: 'Major IT hub with Infosys and Wipro.',
      warnings: [],
    ),

    // ============================================
    // CHENNAI
    // ============================================
    Zone(
      id: 'che_1',
      name: 'T. Nagar',
      type: 'caution',
      centerLat: 13.0418,
      centerLng: 80.2341,
      radius: 400,
      crimeRate: 30,
      lightingLevel: 75,
      recentIncidents: 4,
      description: 'Largest commercial area. Very crowded.',
      warnings: ['Watch belongings'],
    ),
    Zone(
      id: 'che_2',
      name: 'Marina Beach',
      type: 'safe',
      centerLat: 13.0500,
      centerLng: 80.2824,
      radius: 500,
      crimeRate: 12,
      lightingLevel: 80,
      recentIncidents: 2,
      description: 'Famous beach promenade.',
      warnings: [],
    ),
    Zone(
      id: 'che_3',
      name: 'Anna Nagar',
      type: 'safe',
      centerLat: 13.0850,
      centerLng: 80.2101,
      radius: 500,
      crimeRate: 8,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Planned residential area.',
      warnings: [],
    ),
    Zone(
      id: 'che_4',
      name: 'Royapuram',
      type: 'danger',
      centerLat: 13.1145,
      centerLng: 80.2960,
      radius: 400,
      crimeRate: 60,
      lightingLevel: 45,
      recentIncidents: 10,
      description: 'Fishing harbor area. Exercise caution.',
      warnings: ['Avoid after dark', 'Local gangs reported'],
      negativeFeedbackCount: 18,
    ),

    // ============================================
    // KOLKATA
    // ============================================
    Zone(
      id: 'kol_1',
      name: 'Park Street',
      type: 'safe',
      centerLat: 22.5529,
      centerLng: 88.3531,
      radius: 400,
      crimeRate: 10,
      lightingLevel: 92,
      recentIncidents: 1,
      description: 'Famous for restaurants and nightlife.',
      warnings: [],
    ),
    Zone(
      id: 'kol_2',
      name: 'Salt Lake City',
      type: 'safe',
      centerLat: 22.5804,
      centerLng: 88.4167,
      radius: 600,
      crimeRate: 5,
      lightingLevel: 95,
      recentIncidents: 0,
      description: 'Planned township with IT hub.',
      warnings: [],
    ),
    Zone(
      id: 'kol_3',
      name: 'Howrah Station',
      type: 'caution',
      centerLat: 22.5839,
      centerLng: 88.3428,
      radius: 350,
      crimeRate: 50,
      lightingLevel: 60,
      recentIncidents: 8,
      description: 'Busiest railway station. Very crowded.',
      warnings: ['Pickpockets', 'Watch luggage'],
      negativeFeedbackCount: 10,
    ),
    Zone(
      id: 'kol_4',
      name: 'Sealdah',
      type: 'caution',
      centerLat: 22.5654,
      centerLng: 88.3699,
      radius: 300,
      crimeRate: 45,
      lightingLevel: 55,
      recentIncidents: 6,
      description: 'Major railway terminus.',
      warnings: ['Crowded platforms'],
    ),

    // ============================================
    // HYDERABAD
    // ============================================
    Zone(
      id: 'hyd_1',
      name: 'HITEC City',
      type: 'safe',
      centerLat: 17.4435,
      centerLng: 78.3772,
      radius: 700,
      crimeRate: 5,
      lightingLevel: 96,
      recentIncidents: 0,
      description: 'IT hub with Microsoft, Google campuses.',
      warnings: [],
    ),
    Zone(
      id: 'hyd_2',
      name: 'Banjara Hills',
      type: 'safe',
      centerLat: 17.4156,
      centerLng: 78.4347,
      radius: 500,
      crimeRate: 8,
      lightingLevel: 92,
      recentIncidents: 1,
      description: 'Upscale residential and commercial area.',
      warnings: [],
    ),
    Zone(
      id: 'hyd_3',
      name: 'Charminar',
      type: 'caution',
      centerLat: 17.3616,
      centerLng: 78.4747,
      radius: 400,
      crimeRate: 40,
      lightingLevel: 65,
      recentIncidents: 5,
      description: 'Historic monument. Crowded bazaars.',
      warnings: ['Watch valuables', 'Narrow lanes'],
    ),
    Zone(
      id: 'hyd_4',
      name: 'Secunderabad',
      type: 'caution',
      centerLat: 17.4399,
      centerLng: 78.4983,
      radius: 500,
      crimeRate: 30,
      lightingLevel: 75,
      recentIncidents: 4,
      description: 'Twin city hub. Railway junction.',
      warnings: ['Crowded station area'],
    ),

    // ============================================
    // PUNE
    // ============================================
    Zone(
      id: 'pne_1',
      name: 'Koregaon Park',
      type: 'safe',
      centerLat: 18.5362,
      centerLng: 73.8939,
      radius: 400,
      crimeRate: 10,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Upscale area with cafes and nightlife.',
      warnings: [],
    ),
    Zone(
      id: 'pne_2',
      name: 'Hinjewadi',
      type: 'safe',
      centerLat: 18.5912,
      centerLng: 73.7390,
      radius: 600,
      crimeRate: 6,
      lightingLevel: 92,
      recentIncidents: 1,
      description: 'IT Park. Major tech companies.',
      warnings: [],
    ),
    Zone(
      id: 'pne_3',
      name: 'Pune Station',
      type: 'caution',
      centerLat: 18.5285,
      centerLng: 73.8743,
      radius: 350,
      crimeRate: 35,
      lightingLevel: 70,
      recentIncidents: 4,
      description: 'Main railway station. Very busy.',
      warnings: ['Watch belongings'],
    ),

    // ============================================
    // AHMEDABAD
    // ============================================
    Zone(
      id: 'ahm_1',
      name: 'SG Highway',
      type: 'safe',
      centerLat: 23.0469,
      centerLng: 72.5299,
      radius: 600,
      crimeRate: 8,
      lightingLevel: 92,
      recentIncidents: 1,
      description: 'Modern commercial corridor.',
      warnings: [],
    ),
    Zone(
      id: 'ahm_2',
      name: 'Sabarmati Ashram',
      type: 'safe',
      centerLat: 23.0607,
      centerLng: 72.5806,
      radius: 300,
      crimeRate: 3,
      lightingLevel: 95,
      recentIncidents: 0,
      description: 'Historic Gandhi Ashram. Tourist area.',
      warnings: [],
    ),
    Zone(
      id: 'ahm_3',
      name: 'Manek Chowk',
      type: 'caution',
      centerLat: 23.0252,
      centerLng: 72.5871,
      radius: 300,
      crimeRate: 35,
      lightingLevel: 70,
      recentIncidents: 4,
      description: 'Famous food market. Crowded at night.',
      warnings: ['Crowded', 'Watch valuables'],
    ),

    // ============================================
    // JAIPUR
    // ============================================
    Zone(
      id: 'jai_1',
      name: 'Hawa Mahal',
      type: 'caution',
      centerLat: 26.9239,
      centerLng: 75.8267,
      radius: 300,
      crimeRate: 30,
      lightingLevel: 75,
      recentIncidents: 3,
      description: 'Tourist landmark. Busy market area.',
      warnings: ['Touts active', 'Bargain hard'],
    ),
    Zone(
      id: 'jai_2',
      name: 'Malviya Nagar Jaipur',
      type: 'safe',
      centerLat: 26.8549,
      centerLng: 75.8054,
      radius: 500,
      crimeRate: 12,
      lightingLevel: 88,
      recentIncidents: 1,
      description: 'Modern residential and commercial area.',
      warnings: [],
    ),
    Zone(
      id: 'jai_3',
      name: 'Johari Bazaar',
      type: 'caution',
      centerLat: 26.9186,
      centerLng: 75.8268,
      radius: 300,
      crimeRate: 40,
      lightingLevel: 65,
      recentIncidents: 5,
      description: 'Famous jewelry market. Very crowded.',
      warnings: ['Watch valuables', 'Bargain required'],
    ),

    // ============================================
    // LUCKNOW
    // ============================================
    Zone(
      id: 'lko_1',
      name: 'Hazratganj',
      type: 'safe',
      centerLat: 26.8500,
      centerLng: 80.9500,
      radius: 400,
      crimeRate: 15,
      lightingLevel: 88,
      recentIncidents: 2,
      description: 'Prime shopping and cultural district.',
      warnings: [],
    ),
    Zone(
      id: 'lko_2',
      name: 'Aminabad',
      type: 'caution',
      centerLat: 26.8560,
      centerLng: 80.9150,
      radius: 350,
      crimeRate: 40,
      lightingLevel: 60,
      recentIncidents: 5,
      description: 'Old market. Narrow congested lanes.',
      warnings: ['Crowded', 'Watch belongings'],
    ),

    // ============================================
    // CHANDIGARH
    // ============================================
    Zone(
      id: 'chd_1',
      name: 'Sector 17',
      type: 'safe',
      centerLat: 30.7415,
      centerLng: 76.7784,
      radius: 400,
      crimeRate: 5,
      lightingLevel: 95,
      recentIncidents: 0,
      description: 'Main shopping and entertainment hub.',
      warnings: [],
    ),
    Zone(
      id: 'chd_2',
      name: 'IT Park Chandigarh',
      type: 'safe',
      centerLat: 30.7046,
      centerLng: 76.8010,
      radius: 500,
      crimeRate: 3,
      lightingLevel: 98,
      recentIncidents: 0,
      description: 'Tech hub with startups and corporates.',
      warnings: [],
    ),

    // ============================================
    // GOA
    // ============================================
    Zone(
      id: 'goa_1',
      name: 'Baga Beach',
      type: 'caution',
      centerLat: 15.5553,
      centerLng: 73.7514,
      radius: 400,
      crimeRate: 30,
      lightingLevel: 70,
      recentIncidents: 4,
      description: 'Popular tourist beach. Nightlife hub.',
      warnings: ['Drink responsibly', 'Watch belongings'],
    ),
    Zone(
      id: 'goa_2',
      name: 'Panaji',
      type: 'safe',
      centerLat: 15.4989,
      centerLng: 73.8278,
      radius: 400,
      crimeRate: 12,
      lightingLevel: 85,
      recentIncidents: 1,
      description: 'State capital. Clean and well-maintained.',
      warnings: [],
    ),
    Zone(
      id: 'goa_3',
      name: 'Calangute',
      type: 'caution',
      centerLat: 15.5439,
      centerLng: 73.7553,
      radius: 400,
      crimeRate: 35,
      lightingLevel: 65,
      recentIncidents: 5,
      description: 'Crowded tourist beach. Peak season chaos.',
      warnings: ['Touts active', 'Overpriced vendors'],
    ),

    // ============================================
    // KOCHI
    // ============================================
    Zone(
      id: 'koc_1',
      name: 'Fort Kochi',
      type: 'safe',
      centerLat: 9.9658,
      centerLng: 76.2421,
      radius: 400,
      crimeRate: 8,
      lightingLevel: 85,
      recentIncidents: 1,
      description: 'Heritage area with colonial architecture.',
      warnings: [],
    ),
    Zone(
      id: 'koc_2',
      name: 'MG Road Kochi',
      type: 'safe',
      centerLat: 9.9837,
      centerLng: 76.2823,
      radius: 400,
      crimeRate: 10,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Main commercial street.',
      warnings: [],
    ),

    // ============================================
    // VARANASI
    // ============================================
    Zone(
      id: 'var_1',
      name: 'Dashashwamedh Ghat',
      type: 'caution',
      centerLat: 25.3109,
      centerLng: 83.0107,
      radius: 300,
      crimeRate: 35,
      lightingLevel: 65,
      recentIncidents: 4,
      description: 'Main ghat. Famous for Ganga Aarti.',
      warnings: ['Touts aggressive', 'Watch belongings'],
    ),
    Zone(
      id: 'var_2',
      name: 'Vishwanath Temple',
      type: 'caution',
      centerLat: 25.3109,
      centerLng: 83.0107,
      radius: 250,
      crimeRate: 30,
      lightingLevel: 70,
      recentIncidents: 3,
      description: 'Sacred temple. Very crowded.',
      warnings: ['Long queues', 'Beware of fake guides'],
    ),

    // ============================================
    // AMRITSAR
    // ============================================
    Zone(
      id: 'asr_1',
      name: 'Golden Temple',
      type: 'safe',
      centerLat: 31.6200,
      centerLng: 74.8765,
      radius: 400,
      crimeRate: 5,
      lightingLevel: 95,
      recentIncidents: 0,
      description: 'Holiest Sikh shrine. Well-secured.',
      warnings: [],
    ),
    Zone(
      id: 'asr_2',
      name: 'Hall Bazaar',
      type: 'caution',
      centerLat: 31.6340,
      centerLng: 74.8734,
      radius: 300,
      crimeRate: 35,
      lightingLevel: 70,
      recentIncidents: 4,
      description: 'Main market near railway station.',
      warnings: ['Crowded', 'Bargain required'],
    ),

    // ============================================
    // INDORE
    // ============================================
    Zone(
      id: 'ind_1',
      name: 'Vijay Nagar',
      type: 'safe',
      centerLat: 22.7533,
      centerLng: 75.8937,
      radius: 500,
      crimeRate: 8,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Modern commercial and residential area.',
      warnings: [],
    ),
    Zone(
      id: 'ind_2',
      name: 'Sarafa Bazaar',
      type: 'caution',
      centerLat: 22.7196,
      centerLng: 75.8577,
      radius: 300,
      crimeRate: 25,
      lightingLevel: 75,
      recentIncidents: 3,
      description: 'Famous night food market.',
      warnings: ['Crowded at night'],
    ),

    // ============================================
    // BHOPAL
    // ============================================
    Zone(
      id: 'bpl_1',
      name: 'New Market Bhopal',
      type: 'caution',
      centerLat: 23.2332,
      centerLng: 77.4029,
      radius: 350,
      crimeRate: 30,
      lightingLevel: 72,
      recentIncidents: 3,
      description: 'Main shopping area. Gets crowded.',
      warnings: ['Watch valuables'],
    ),
    Zone(
      id: 'bpl_2',
      name: 'DB Mall Area',
      type: 'safe',
      centerLat: 23.2271,
      centerLng: 77.4365,
      radius: 400,
      crimeRate: 10,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Modern commercial hub.',
      warnings: [],
    ),

    // ============================================
    // SURAT
    // ============================================
    Zone(
      id: 'sur_1',
      name: 'Ring Road Surat',
      type: 'safe',
      centerLat: 21.1702,
      centerLng: 72.8311,
      radius: 600,
      crimeRate: 10,
      lightingLevel: 88,
      recentIncidents: 1,
      description: 'Modern commercial belt with malls.',
      warnings: [],
    ),
    Zone(
      id: 'sur_2',
      name: 'Diamond Bourse',
      type: 'safe',
      centerLat: 21.1462,
      centerLng: 72.7812,
      radius: 400,
      crimeRate: 3,
      lightingLevel: 98,
      recentIncidents: 0,
      description: 'World\'s largest diamond trading hub.',
      warnings: [],
    ),

    // ============================================
    // VISAKHAPATNAM
    // ============================================
    Zone(
      id: 'viz_1',
      name: 'RK Beach',
      type: 'safe',
      centerLat: 17.7167,
      centerLng: 83.3167,
      radius: 400,
      crimeRate: 12,
      lightingLevel: 85,
      recentIncidents: 1,
      description: 'Popular beach with promenade.',
      warnings: [],
    ),
    Zone(
      id: 'viz_2',
      name: 'Dwaraka Nagar',
      type: 'safe',
      centerLat: 17.7248,
      centerLng: 83.3116,
      radius: 400,
      crimeRate: 8,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Main shopping area.',
      warnings: [],
    ),

    // ============================================
    // COIMBATORE
    // ============================================
    Zone(
      id: 'cbe_1',
      name: 'RS Puram',
      type: 'safe',
      centerLat: 11.0100,
      centerLng: 76.9548,
      radius: 400,
      crimeRate: 10,
      lightingLevel: 88,
      recentIncidents: 1,
      description: 'Upscale residential and commercial area.',
      warnings: [],
    ),
    Zone(
      id: 'cbe_2',
      name: 'Gandhipuram',
      type: 'caution',
      centerLat: 11.0183,
      centerLng: 76.9725,
      radius: 400,
      crimeRate: 30,
      lightingLevel: 72,
      recentIncidents: 4,
      description: 'Central bus stand area. Very busy.',
      warnings: ['Crowded', 'Watch belongings'],
    ),

    // ============================================
    // THIRUVANANTHAPURAM
    // ============================================
    Zone(
      id: 'tvm_1',
      name: 'Technopark',
      type: 'safe',
      centerLat: 8.5569,
      centerLng: 76.8810,
      radius: 600,
      crimeRate: 5,
      lightingLevel: 95,
      recentIncidents: 0,
      description: 'Major IT hub with tech companies.',
      warnings: [],
    ),
    Zone(
      id: 'tvm_2',
      name: 'Kovalam Beach',
      type: 'caution',
      centerLat: 8.4004,
      centerLng: 76.9787,
      radius: 400,
      crimeRate: 25,
      lightingLevel: 70,
      recentIncidents: 3,
      description: 'Tourist beach. Some touts active.',
      warnings: ['Bargain with vendors'],
    ),

    // ============================================
    // NAGPUR
    // ============================================
    Zone(
      id: 'nag_1',
      name: 'Sitabuldi',
      type: 'caution',
      centerLat: 21.1458,
      centerLng: 79.0882,
      radius: 400,
      crimeRate: 30,
      lightingLevel: 72,
      recentIncidents: 4,
      description: 'Central commercial hub. Very crowded.',
      warnings: ['Watch belongings'],
    ),
    Zone(
      id: 'nag_2',
      name: 'Dharampeth',
      type: 'safe',
      centerLat: 21.1388,
      centerLng: 79.0657,
      radius: 400,
      crimeRate: 10,
      lightingLevel: 88,
      recentIncidents: 1,
      description: 'Upscale residential area.',
      warnings: [],
    ),

    // ============================================
    // PATNA
    // ============================================
    Zone(
      id: 'pat_1',
      name: 'Gandhi Maidan',
      type: 'caution',
      centerLat: 25.6093,
      centerLng: 85.1376,
      radius: 400,
      crimeRate: 35,
      lightingLevel: 65,
      recentIncidents: 5,
      description: 'Historic ground. Crowded during events.',
      warnings: ['Pickpockets active'],
    ),
    Zone(
      id: 'pat_2',
      name: 'Boring Road',
      type: 'safe',
      centerLat: 25.6145,
      centerLng: 85.1053,
      radius: 500,
      crimeRate: 15,
      lightingLevel: 85,
      recentIncidents: 2,
      description: 'Modern commercial and food hub.',
      warnings: [],
    ),
    Zone(
      id: 'pat_3',
      name: 'Patna Junction',
      type: 'danger',
      centerLat: 25.6084,
      centerLng: 85.1406,
      radius: 350,
      crimeRate: 55,
      lightingLevel: 50,
      recentIncidents: 10,
      description: 'Major railway station. Very chaotic.',
      warnings: ['High theft', 'Watch luggage'],
      negativeFeedbackCount: 14,
    ),

    // ============================================
    // RANCHI
    // ============================================
    Zone(
      id: 'ran_1',
      name: 'Main Road Ranchi',
      type: 'caution',
      centerLat: 23.3441,
      centerLng: 85.3096,
      radius: 400,
      crimeRate: 30,
      lightingLevel: 70,
      recentIncidents: 4,
      description: 'Central shopping area.',
      warnings: ['Crowded'],
    ),
    Zone(
      id: 'ran_2',
      name: 'Kanke',
      type: 'safe',
      centerLat: 23.3859,
      centerLng: 85.3158,
      radius: 500,
      crimeRate: 8,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Residential area near dam.',
      warnings: [],
    ),

    // ============================================
    // GUWAHATI
    // ============================================
    Zone(
      id: 'guw_1',
      name: 'Fancy Bazar',
      type: 'caution',
      centerLat: 26.1861,
      centerLng: 91.7496,
      radius: 400,
      crimeRate: 35,
      lightingLevel: 65,
      recentIncidents: 5,
      description: 'Main commercial area. Very congested.',
      warnings: ['Watch belongings', 'Traffic chaos'],
    ),
    Zone(
      id: 'guw_2',
      name: 'Paltan Bazar',
      type: 'caution',
      centerLat: 26.1831,
      centerLng: 91.7530,
      radius: 350,
      crimeRate: 40,
      lightingLevel: 60,
      recentIncidents: 6,
      description: 'Railway station area. Busy.',
      warnings: ['Pickpockets'],
    ),
    Zone(
      id: 'guw_3',
      name: 'GS Road',
      type: 'safe',
      centerLat: 26.1562,
      centerLng: 91.7742,
      radius: 500,
      crimeRate: 12,
      lightingLevel: 88,
      recentIncidents: 1,
      description: 'Modern commercial corridor.',
      warnings: [],
    ),
    Zone(
      id: 'guw_4',
      name: 'Kamakhya Temple',
      type: 'caution',
      centerLat: 26.1665,
      centerLng: 91.7053,
      radius: 300,
      crimeRate: 25,
      lightingLevel: 75,
      recentIncidents: 3,
      description: 'Famous temple. Crowded during festivals.',
      warnings: ['Long queues', 'Beware of touts'],
    ),

    // ============================================
    // SHILLONG
    // ============================================
    Zone(
      id: 'shi_1',
      name: 'Police Bazar',
      type: 'safe',
      centerLat: 25.5788,
      centerLng: 91.8933,
      radius: 350,
      crimeRate: 15,
      lightingLevel: 80,
      recentIncidents: 2,
      description: 'Main shopping hub of Shillong.',
      warnings: [],
    ),
    Zone(
      id: 'shi_2',
      name: 'Laitumkhrah',
      type: 'safe',
      centerLat: 25.5723,
      centerLng: 91.8994,
      radius: 400,
      crimeRate: 10,
      lightingLevel: 85,
      recentIncidents: 1,
      description: 'Commercial and food area.',
      warnings: [],
    ),

    // ============================================
    // AGRA
    // ============================================
    Zone(
      id: 'agr_1',
      name: 'Taj Mahal Area',
      type: 'caution',
      centerLat: 27.1751,
      centerLng: 78.0421,
      radius: 500,
      crimeRate: 30,
      lightingLevel: 75,
      recentIncidents: 4,
      description: 'World famous monument. Heavy tourist area.',
      warnings: ['Touts aggressive', 'Overpriced vendors'],
    ),
    Zone(
      id: 'agr_2',
      name: 'Sadar Bazaar Agra',
      type: 'caution',
      centerLat: 27.1835,
      centerLng: 78.0175,
      radius: 400,
      crimeRate: 40,
      lightingLevel: 65,
      recentIncidents: 5,
      description: 'Main market. Very congested.',
      warnings: ['Watch valuables'],
    ),
    Zone(
      id: 'agr_3',
      name: 'Agra Cantt',
      type: 'safe',
      centerLat: 27.1590,
      centerLng: 78.0050,
      radius: 500,
      crimeRate: 10,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Military area. Well-secured.',
      warnings: [],
    ),

    // ============================================
    // UDAIPUR
    // ============================================
    Zone(
      id: 'udp_1',
      name: 'City Palace',
      type: 'safe',
      centerLat: 24.5764,
      centerLng: 73.6834,
      radius: 400,
      crimeRate: 8,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Royal palace. Tourist hub.',
      warnings: [],
    ),
    Zone(
      id: 'udp_2',
      name: 'Lake Pichola',
      type: 'safe',
      centerLat: 24.5695,
      centerLng: 73.6778,
      radius: 400,
      crimeRate: 5,
      lightingLevel: 88,
      recentIncidents: 0,
      description: 'Scenic lake. Romantic destination.',
      warnings: [],
    ),
    Zone(
      id: 'udp_3',
      name: 'Hathi Pol',
      type: 'caution',
      centerLat: 24.5817,
      centerLng: 73.6883,
      radius: 300,
      crimeRate: 30,
      lightingLevel: 70,
      recentIncidents: 3,
      description: 'Old city market. Narrow lanes.',
      warnings: ['Crowded', 'Bargain required'],
    ),

    // ============================================
    // RISHIKESH
    // ============================================
    Zone(
      id: 'rsk_1',
      name: 'Laxman Jhula',
      type: 'safe',
      centerLat: 30.1245,
      centerLng: 78.3163,
      radius: 400,
      crimeRate: 10,
      lightingLevel: 80,
      recentIncidents: 1,
      description: 'Iconic bridge. Yoga capital.',
      warnings: [],
    ),
    Zone(
      id: 'rsk_2',
      name: 'Ram Jhula',
      type: 'safe',
      centerLat: 30.1134,
      centerLng: 78.3145,
      radius: 350,
      crimeRate: 8,
      lightingLevel: 82,
      recentIncidents: 1,
      description: 'Spiritual hub with ashrams.',
      warnings: [],
    ),
    Zone(
      id: 'rsk_3',
      name: 'Triveni Ghat',
      type: 'safe',
      centerLat: 30.1048,
      centerLng: 78.3047,
      radius: 300,
      crimeRate: 5,
      lightingLevel: 85,
      recentIncidents: 0,
      description: 'Holy ghat for evening aarti.',
      warnings: [],
    ),

    // ============================================
    // DEHRADUN
    // ============================================
    Zone(
      id: 'ddn_1',
      name: 'Rajpur Road',
      type: 'safe',
      centerLat: 30.3300,
      centerLng: 78.0429,
      radius: 500,
      crimeRate: 12,
      lightingLevel: 88,
      recentIncidents: 1,
      description: 'Main commercial strip.',
      warnings: [],
    ),
    Zone(
      id: 'ddn_2',
      name: 'Clock Tower',
      type: 'caution',
      centerLat: 30.3255,
      centerLng: 78.0381,
      radius: 350,
      crimeRate: 30,
      lightingLevel: 70,
      recentIncidents: 4,
      description: 'Old city center. Congested.',
      warnings: ['Traffic congestion'],
    ),

    // ============================================
    // SHIMLA
    // ============================================
    Zone(
      id: 'sim_1',
      name: 'The Mall',
      type: 'safe',
      centerLat: 31.1048,
      centerLng: 77.1734,
      radius: 400,
      crimeRate: 8,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Main promenade. No vehicles.',
      warnings: [],
    ),
    Zone(
      id: 'sim_2',
      name: 'Lakkar Bazaar',
      type: 'safe',
      centerLat: 31.1062,
      centerLng: 77.1700,
      radius: 300,
      crimeRate: 12,
      lightingLevel: 82,
      recentIncidents: 1,
      description: 'Famous for wooden handicrafts.',
      warnings: [],
    ),
    Zone(
      id: 'sim_3',
      name: 'Shimla Railway Station',
      type: 'caution',
      centerLat: 31.1031,
      centerLng: 77.1490,
      radius: 300,
      crimeRate: 25,
      lightingLevel: 75,
      recentIncidents: 3,
      description: 'Heritage railway. Crowded.',
      warnings: ['Watch belongings'],
    ),

    // ============================================
    // MYSORE
    // ============================================
    Zone(
      id: 'mys_1',
      name: 'Mysore Palace',
      type: 'safe',
      centerLat: 12.3052,
      centerLng: 76.6552,
      radius: 400,
      crimeRate: 8,
      lightingLevel: 92,
      recentIncidents: 1,
      description: 'Magnificent royal palace.',
      warnings: [],
    ),
    Zone(
      id: 'mys_2',
      name: 'Devaraja Market',
      type: 'caution',
      centerLat: 12.3108,
      centerLng: 76.6532,
      radius: 300,
      crimeRate: 30,
      lightingLevel: 70,
      recentIncidents: 3,
      description: 'Historic market. Crowded.',
      warnings: ['Watch valuables'],
    ),
    Zone(
      id: 'mys_3',
      name: 'Chamundi Hill',
      type: 'safe',
      centerLat: 12.2724,
      centerLng: 76.6701,
      radius: 500,
      crimeRate: 5,
      lightingLevel: 80,
      recentIncidents: 0,
      description: 'Temple hill with views.',
      warnings: [],
    ),

    // ============================================
    // MADURAI
    // ============================================
    Zone(
      id: 'mad_1',
      name: 'Meenakshi Temple',
      type: 'caution',
      centerLat: 9.9195,
      centerLng: 78.1193,
      radius: 400,
      crimeRate: 35,
      lightingLevel: 70,
      recentIncidents: 4,
      description: 'Iconic temple. Very crowded.',
      warnings: ['Long queues', 'Watch belongings'],
    ),
    Zone(
      id: 'mad_2',
      name: 'Anna Nagar Madurai',
      type: 'safe',
      centerLat: 9.9395,
      centerLng: 78.1287,
      radius: 400,
      crimeRate: 10,
      lightingLevel: 88,
      recentIncidents: 1,
      description: 'Modern residential area.',
      warnings: [],
    ),

    // ============================================
    // TRICHY
    // ============================================
    Zone(
      id: 'try_1',
      name: 'Rockfort Temple',
      type: 'caution',
      centerLat: 10.8097,
      centerLng: 78.6871,
      radius: 350,
      crimeRate: 28,
      lightingLevel: 72,
      recentIncidents: 3,
      description: 'Historic rock temple.',
      warnings: ['Steep climb'],
    ),
    Zone(
      id: 'try_2',
      name: 'Cantonment Trichy',
      type: 'safe',
      centerLat: 10.7978,
      centerLng: 78.6961,
      radius: 400,
      crimeRate: 8,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Well-planned area.',
      warnings: [],
    ),

    // ============================================
    // MANGALORE
    // ============================================
    Zone(
      id: 'mng_1',
      name: 'Hampankatta',
      type: 'caution',
      centerLat: 12.8714,
      centerLng: 74.8426,
      radius: 400,
      crimeRate: 30,
      lightingLevel: 72,
      recentIncidents: 4,
      description: 'Central commercial hub.',
      warnings: ['Crowded'],
    ),
    Zone(
      id: 'mng_2',
      name: 'Panambur Beach',
      type: 'safe',
      centerLat: 12.9336,
      centerLng: 74.7990,
      radius: 400,
      crimeRate: 10,
      lightingLevel: 80,
      recentIncidents: 1,
      description: 'Popular beach destination.',
      warnings: [],
    ),

    // ============================================
    // VADODARA
    // ============================================
    Zone(
      id: 'vad_1',
      name: 'Alkapuri',
      type: 'safe',
      centerLat: 22.3089,
      centerLng: 73.1740,
      radius: 500,
      crimeRate: 10,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Upscale commercial area.',
      warnings: [],
    ),
    Zone(
      id: 'vad_2',
      name: 'Mandvi',
      type: 'caution',
      centerLat: 22.2996,
      centerLng: 73.2013,
      radius: 350,
      crimeRate: 35,
      lightingLevel: 65,
      recentIncidents: 4,
      description: 'Old city market. Congested.',
      warnings: ['Watch belongings'],
    ),

    // ============================================
    // RAJKOT
    // ============================================
    Zone(
      id: 'raj_1',
      name: 'Race Course',
      type: 'safe',
      centerLat: 22.2969,
      centerLng: 70.7828,
      radius: 500,
      crimeRate: 8,
      lightingLevel: 92,
      recentIncidents: 1,
      description: 'Modern shopping and food hub.',
      warnings: [],
    ),
    Zone(
      id: 'raj_2',
      name: 'Dhebar Road',
      type: 'caution',
      centerLat: 22.2991,
      centerLng: 70.8003,
      radius: 400,
      crimeRate: 28,
      lightingLevel: 75,
      recentIncidents: 3,
      description: 'Busy commercial street.',
      warnings: ['Traffic congestion'],
    ),

    // ============================================
    // JODHPUR
    // ============================================
    Zone(
      id: 'jod_1',
      name: 'Mehrangarh Fort',
      type: 'safe',
      centerLat: 26.2979,
      centerLng: 73.0183,
      radius: 500,
      crimeRate: 8,
      lightingLevel: 88,
      recentIncidents: 1,
      description: 'Magnificent fort. Well-maintained.',
      warnings: [],
    ),
    Zone(
      id: 'jod_2',
      name: 'Clock Tower Market',
      type: 'caution',
      centerLat: 26.2913,
      centerLng: 73.0244,
      radius: 350,
      crimeRate: 35,
      lightingLevel: 68,
      recentIncidents: 4,
      description: 'Famous spice market.',
      warnings: ['Watch valuables', 'Bargain hard'],
    ),

    // ============================================
    // RAIPUR
    // ============================================
    Zone(
      id: 'rai_1',
      name: 'Pandri',
      type: 'caution',
      centerLat: 21.2385,
      centerLng: 81.6328,
      radius: 400,
      crimeRate: 30,
      lightingLevel: 70,
      recentIncidents: 4,
      description: 'Main market area.',
      warnings: ['Crowded'],
    ),
    Zone(
      id: 'rai_2',
      name: 'Shankar Nagar',
      type: 'safe',
      centerLat: 21.2454,
      centerLng: 81.6149,
      radius: 500,
      crimeRate: 10,
      lightingLevel: 88,
      recentIncidents: 1,
      description: 'Modern residential area.',
      warnings: [],
    ),

    // ============================================
    // BHUBANESWAR
    // ============================================
    Zone(
      id: 'bhu_1',
      name: 'Unit 1 Market',
      type: 'caution',
      centerLat: 20.2723,
      centerLng: 85.8359,
      radius: 400,
      crimeRate: 28,
      lightingLevel: 72,
      recentIncidents: 3,
      description: 'Popular shopping area.',
      warnings: ['Crowded evenings'],
    ),
    Zone(
      id: 'bhu_2',
      name: 'Lingaraj Temple',
      type: 'safe',
      centerLat: 20.2384,
      centerLng: 85.8342,
      radius: 350,
      crimeRate: 10,
      lightingLevel: 85,
      recentIncidents: 1,
      description: 'Ancient temple. Sacred area.',
      warnings: [],
    ),
    Zone(
      id: 'bhu_3',
      name: 'Infocity',
      type: 'safe',
      centerLat: 20.3051,
      centerLng: 85.8161,
      radius: 600,
      crimeRate: 5,
      lightingLevel: 95,
      recentIncidents: 0,
      description: 'IT park with tech companies.',
      warnings: [],
    ),

    // ============================================
    // PURI
    // ============================================
    Zone(
      id: 'pur_1',
      name: 'Jagannath Temple',
      type: 'caution',
      centerLat: 19.8048,
      centerLng: 85.8181,
      radius: 400,
      crimeRate: 30,
      lightingLevel: 70,
      recentIncidents: 4,
      description: 'Sacred shrine. Massive crowds.',
      warnings: ['Long queues', 'Pandas active'],
    ),
    Zone(
      id: 'pur_2',
      name: 'Puri Beach',
      type: 'caution',
      centerLat: 19.7943,
      centerLng: 85.8249,
      radius: 500,
      crimeRate: 25,
      lightingLevel: 65,
      recentIncidents: 3,
      description: 'Popular beach. Careful swimming.',
      warnings: ['Strong currents', 'Watch belongings'],
    ),

    // ============================================
    // JAMMU
    // ============================================
    Zone(
      id: 'jam_1',
      name: 'Raghunath Bazaar',
      type: 'caution',
      centerLat: 32.7327,
      centerLng: 74.8635,
      radius: 350,
      crimeRate: 28,
      lightingLevel: 72,
      recentIncidents: 3,
      description: 'Main market near temple.',
      warnings: ['Crowded'],
    ),
    Zone(
      id: 'jam_2',
      name: 'Jammu Tawi',
      type: 'caution',
      centerLat: 32.7181,
      centerLng: 74.8608,
      radius: 400,
      crimeRate: 35,
      lightingLevel: 68,
      recentIncidents: 5,
      description: 'Railway station area.',
      warnings: ['Watch luggage'],
    ),

    // ============================================
    // SRINAGAR
    // ============================================
    Zone(
      id: 'sri_1',
      name: 'Dal Lake',
      type: 'safe',
      centerLat: 34.1172,
      centerLng: 74.8503,
      radius: 600,
      crimeRate: 10,
      lightingLevel: 80,
      recentIncidents: 1,
      description: 'Iconic lake with houseboats.',
      warnings: [],
    ),
    Zone(
      id: 'sri_2',
      name: 'Lal Chowk',
      type: 'caution',
      centerLat: 34.0747,
      centerLng: 74.7978,
      radius: 400,
      crimeRate: 40,
      lightingLevel: 65,
      recentIncidents: 6,
      description: 'City center. Security sensitive.',
      warnings: ['Check advisories'],
    ),

    // ============================================
    // MANALI
    // ============================================
    Zone(
      id: 'man_1',
      name: 'Mall Road Manali',
      type: 'safe',
      centerLat: 32.2396,
      centerLng: 77.1887,
      radius: 350,
      crimeRate: 12,
      lightingLevel: 82,
      recentIncidents: 1,
      description: 'Main tourist street.',
      warnings: [],
    ),
    Zone(
      id: 'man_2',
      name: 'Old Manali',
      type: 'safe',
      centerLat: 32.2556,
      centerLng: 77.1876,
      radius: 400,
      crimeRate: 8,
      lightingLevel: 75,
      recentIncidents: 1,
      description: 'Hippie village with cafes.',
      warnings: [],
    ),
    Zone(
      id: 'man_3',
      name: 'Solang Valley',
      type: 'safe',
      centerLat: 32.3150,
      centerLng: 77.1557,
      radius: 500,
      crimeRate: 5,
      lightingLevel: 70,
      recentIncidents: 0,
      description: 'Adventure sports hub.',
      warnings: [],
    ),

    // ============================================
    // MORE DELHI NCR ZONES
    // ============================================
    Zone(
      id: 'd_south_5',
      name: 'Saket',
      type: 'safe',
      centerLat: 28.5244,
      centerLng: 77.2179,
      radius: 500,
      crimeRate: 12,
      lightingLevel: 92,
      recentIncidents: 1,
      description: 'Upscale area with malls.',
      warnings: [],
    ),
    Zone(
      id: 'd_south_6',
      name: 'Greater Kailash',
      type: 'safe',
      centerLat: 28.5456,
      centerLng: 77.2397,
      radius: 500,
      crimeRate: 10,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Affluent residential area.',
      warnings: [],
    ),
    Zone(
      id: 'd_south_7',
      name: 'Defence Colony',
      type: 'safe',
      centerLat: 28.5701,
      centerLng: 77.2333,
      radius: 400,
      crimeRate: 8,
      lightingLevel: 94,
      recentIncidents: 0,
      description: 'Premium residential colony.',
      warnings: [],
    ),
    Zone(
      id: 'd_east_3',
      name: 'Preet Vihar',
      type: 'safe',
      centerLat: 28.6382,
      centerLng: 77.2938,
      radius: 400,
      crimeRate: 15,
      lightingLevel: 85,
      recentIncidents: 2,
      description: 'Residential and commercial hub.',
      warnings: [],
    ),
    Zone(
      id: 'd_east_4',
      name: 'Akshardham',
      type: 'safe',
      centerLat: 28.6127,
      centerLng: 77.2773,
      radius: 500,
      crimeRate: 5,
      lightingLevel: 98,
      recentIncidents: 0,
      description: 'Famous temple complex. High security.',
      warnings: [],
    ),

    // ============================================
    // MORE MUMBAI ZONES
    // ============================================
    Zone(
      id: 'mum_7',
      name: 'Powai',
      type: 'safe',
      centerLat: 19.1176,
      centerLng: 72.9060,
      radius: 500,
      crimeRate: 8,
      lightingLevel: 92,
      recentIncidents: 1,
      description: 'IT hub with lake. IIT area.',
      warnings: [],
    ),
    Zone(
      id: 'mum_8',
      name: 'Juhu Beach',
      type: 'caution',
      centerLat: 19.0948,
      centerLng: 72.8258,
      radius: 500,
      crimeRate: 25,
      lightingLevel: 70,
      recentIncidents: 3,
      description: 'Famous beach. Crowded evenings.',
      warnings: ['Avoid late night'],
    ),
    Zone(
      id: 'mum_9',
      name: 'Worli',
      type: 'safe',
      centerLat: 19.0178,
      centerLng: 72.8183,
      radius: 400,
      crimeRate: 10,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Upscale area with sea link.',
      warnings: [],
    ),
    Zone(
      id: 'mum_10',
      name: 'Lower Parel',
      type: 'safe',
      centerLat: 18.9987,
      centerLng: 72.8297,
      radius: 400,
      crimeRate: 12,
      lightingLevel: 92,
      recentIncidents: 1,
      description: 'Corporate hub with malls.',
      warnings: [],
    ),
    Zone(
      id: 'mum_11',
      name: 'CST Station',
      type: 'caution',
      centerLat: 18.9398,
      centerLng: 72.8355,
      radius: 350,
      crimeRate: 40,
      lightingLevel: 70,
      recentIncidents: 6,
      description: 'Heritage railway station. Very busy.',
      warnings: ['Watch belongings', 'Crowded'],
    ),

    // ============================================
    // MORE BANGALORE ZONES
    // ============================================
    Zone(
      id: 'blr_6',
      name: 'Indiranagar',
      type: 'safe',
      centerLat: 12.9784,
      centerLng: 77.6408,
      radius: 500,
      crimeRate: 12,
      lightingLevel: 88,
      recentIncidents: 1,
      description: 'Trendy area with pubs and restaurants.',
      warnings: [],
    ),
    Zone(
      id: 'blr_7',
      name: 'HSR Layout',
      type: 'safe',
      centerLat: 12.9121,
      centerLng: 77.6446,
      radius: 500,
      crimeRate: 10,
      lightingLevel: 90,
      recentIncidents: 1,
      description: 'Startup hub with cafes.',
      warnings: [],
    ),
    Zone(
      id: 'blr_8',
      name: 'Jayanagar',
      type: 'safe',
      centerLat: 12.9250,
      centerLng: 77.5938,
      radius: 500,
      crimeRate: 8,
      lightingLevel: 92,
      recentIncidents: 1,
      description: 'Well-planned residential area.',
      warnings: [],
    ),
    Zone(
      id: 'blr_9',
      name: 'Malleshwaram',
      type: 'safe',
      centerLat: 13.0067,
      centerLng: 77.5713,
      radius: 400,
      crimeRate: 10,
      lightingLevel: 88,
      recentIncidents: 1,
      description: 'Traditional area with markets.',
      warnings: [],
    ),
  ];

  // Legacy accessor for backward compatibility
  static const List<Zone> jaipurZones = allIndiaZones;

  /// Get city clusters from all zones
  static List<CityCluster> getCityClusters() {
    // Group zones by city prefix (e.g., 'mum_', 'blr_', 'del_')
    final Map<String, List<Zone>> cityGroups = {};
    final Map<String, String> cityNames = {
      'd': 'Delhi NCR',
      'ncr': 'Delhi NCR',
      'mum': 'Mumbai',
      'blr': 'Bangalore',
      'che': 'Chennai',
      'kol': 'Kolkata',
      'hyd': 'Hyderabad',
      'pne': 'Pune',
      'ahm': 'Ahmedabad',
      'jai': 'Jaipur',
      'lko': 'Lucknow',
      'chd': 'Chandigarh',
      'goa': 'Goa',
      'koc': 'Kochi',
      'var': 'Varanasi',
      'agr': 'Agra',
      'deh': 'Dehradun',
      'mys': 'Mysore',
      'guw': 'Guwahati',
      'pat': 'Patna',
      'ran': 'Ranchi',
      'bhu': 'Bhubaneswar',
      'rai': 'Raipur',
      'nag': 'Nagpur',
      'uda': 'Udaipur',
      'jod': 'Jodhpur',
      'vad': 'Vadodara',
      'raj': 'Rajkot',
      'sri': 'Srinagar',
      'sim': 'Shimla',
      'man': 'Manali',
      'shi': 'Shillong',
    };

    for (final zone in allIndiaZones) {
      // Extract city prefix from zone ID
      final prefix = zone.id.split('_').first;
      final cityName = cityNames[prefix] ?? prefix.toUpperCase();

      cityGroups.putIfAbsent(cityName, () => []).add(zone);
    }

    // Create clusters from groups
    return cityGroups.entries.map((entry) {
      return CityCluster.fromZones(
        entry.key.toLowerCase().replaceAll(' ', '_'),
        entry.key,
        entry.value,
      );
    }).toList();
  }
}
