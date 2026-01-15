import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/zone.dart';

/// Service for Firebase Firestore operations on zones and cities
class ZoneService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _zonesRef => _firestore.collection('zones');
  CollectionReference get _citiesRef => _firestore.collection('cities');

  // Singleton pattern
  static final ZoneService _instance = ZoneService._internal();
  factory ZoneService() => _instance;
  ZoneService._internal();

  /// Stream of all zones
  Stream<List<Zone>> getZonesStream() {
    return _zonesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Zone.fromFirebase(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Get zones for a specific city
  Stream<List<Zone>> getZonesByCity(String cityId) {
    return _zonesRef
        .where('cityId', isEqualTo: cityId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Zone.fromFirebase(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Stream of all cities
  Stream<List<CityCluster>> getCitiesStream() {
    return _citiesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CityCluster.fromFirebase(
            doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Add a new zone
  Future<void> addZone(Zone zone) async {
    await _zonesRef.doc(zone.id).set(zone.toMap());
    await _updateCityAggregates(zone.cityId);
  }

  /// Update zone rating/feedback
  Future<void> updateZoneFeedback(
      String zoneId, int negativeFeedbackCount) async {
    await _zonesRef.doc(zoneId).update({
      'negativeFeedbackCount': negativeFeedbackCount,
    });
  }

  /// Report a zone - updates feedback count and recalculates city aggregates
  /// reportType: 'theft', 'harassment', 'lighting', or 'suspicious'
  Future<void> reportZone(String zoneId, String cityId, int newFeedbackCount,
      {String reportType = ''}) async {
    // Update zone feedback count
    final updates = <String, dynamic>{
      'negativeFeedbackCount': newFeedbackCount,
    };

    // Increment specific report type counter
    switch (reportType) {
      case 'theft':
        updates['theftReports'] = FieldValue.increment(1);
        break;
      case 'harassment':
        updates['harassmentReports'] = FieldValue.increment(1);
        break;
      case 'lighting':
        updates['poorLightingReports'] = FieldValue.increment(1);
        break;
      case 'suspicious':
        updates['suspiciousReports'] = FieldValue.increment(1);
        break;
    }

    // If feedback exceeds threshold, mark zone as danger
    if (newFeedbackCount > 10) {
      updates['type'] = 'danger';
    }

    await _zonesRef.doc(zoneId).update(updates);

    // Recalculate city aggregates
    if (cityId.isNotEmpty) {
      await _updateCityAggregates(cityId);
    }
  }

  /// Add a new city
  Future<void> addCity(CityCluster city) async {
    await _citiesRef.doc(city.cityId).set(city.toMap());
  }

  /// Update city aggregates based on its zones
  Future<void> _updateCityAggregates(String cityId) async {
    if (cityId.isEmpty) return;

    // Get all zones for this city
    final zonesSnapshot =
        await _zonesRef.where('cityId', isEqualTo: cityId).get();

    if (zonesSnapshot.docs.isEmpty) return;

    // Calculate aggregates
    int totalCrimeRate = 0;
    int totalLightingLevel = 0;
    int dangerCount = 0;
    int cautionCount = 0;
    int safeCount = 0;

    for (final doc in zonesSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalCrimeRate += (data['crimeRate'] ?? 0) as int;
      totalLightingLevel += (data['lightingLevel'] ?? 80) as int;

      final type = data['type'] ?? 'safe';
      if (type == 'danger')
        dangerCount++;
      else if (type == 'caution')
        cautionCount++;
      else
        safeCount++;
    }

    final count = zonesSnapshot.docs.length;
    final avgCrimeRate = totalCrimeRate ~/ count;
    final avgLightingLevel = totalLightingLevel ~/ count;

    String dominantType = 'safe';
    if (dangerCount > 0) {
      dominantType = 'danger';
    } else if (cautionCount > safeCount) {
      dominantType = 'caution';
    }

    // Update city document
    await _citiesRef.doc(cityId).update({
      'avgCrimeRate': avgCrimeRate,
      'avgLightingLevel': avgLightingLevel,
      'dominantType': dominantType,
      'zoneCount': count,
    });
  }

  /// Seed database with mock data (one-time use)
  Future<void> seedDatabase() async {
    // Get city mappings
    final cityNames = _getCityNames();
    final Map<String, List<Zone>> cityGroups = {};

    // Group zones by city
    for (final zone in MockZones.allIndiaZones) {
      final prefix = zone.id.split('_').first;
      final cityName = cityNames[prefix] ?? prefix.toUpperCase();
      final cityId =
          cityName.toLowerCase().replaceAll(' ', '_').replaceAll('&', 'and');

      // Create zone with cityId
      final zoneWithCity = Zone(
        id: zone.id,
        cityId: cityId,
        name: zone.name,
        type: zone.type,
        centerLat: zone.centerLat,
        centerLng: zone.centerLng,
        radius: zone.radius,
        crimeRate: zone.crimeRate,
        lightingLevel: zone.lightingLevel,
        recentIncidents: zone.recentIncidents,
        description: zone.description,
        warnings: zone.warnings,
        negativeFeedbackCount: zone.negativeFeedbackCount,
      );

      cityGroups.putIfAbsent(cityId, () => []).add(zoneWithCity);

      // Add zone to Firestore
      await _zonesRef.doc(zone.id).set(zoneWithCity.toMap());
    }

    // Create city documents with aggregates
    for (final entry in cityGroups.entries) {
      final cityId = entry.key;
      final zones = entry.value;
      final cityName = cityNames[zones.first.id.split('_').first] ?? cityId;

      final cluster = CityCluster.fromZones(cityId, cityName, zones);
      await _citiesRef.doc(cityId).set(cluster.toMap());
    }
  }

  Map<String, String> _getCityNames() {
    return {
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
    };
  }
}
