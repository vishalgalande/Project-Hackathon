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
      // Try two-part prefix first (e.g., jai_muj), then single-part (e.g., jai)
      final parts = zone.id.split('_');
      String prefix;
      if (parts.length >= 2 &&
          cityNames.containsKey('${parts[0]}_${parts[1]}')) {
        prefix = '${parts[0]}_${parts[1]}';
      } else {
        prefix = parts.first;
      }

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
      'jai_muj': 'Jaipur',
      'lko': 'Lucknow',
      'chd': 'Chandigarh',
      'goa': 'Goa',
      'koc': 'Kochi',
      'var': 'Varanasi',
    };
  }

  // ============ USER REPORTS (Account-Linked) ============

  CollectionReference get _userReportsRef =>
      _firestore.collection('user_reports');

  /// Get user's reports for a specific zone
  Stream<QuerySnapshot> getUserReportsForZone(String userId, String zoneId) {
    return _userReportsRef
        .where('userId', isEqualTo: userId)
        .where('zoneId', isEqualTo: zoneId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Get count of user's reports for a zone (for rate limiting)
  Future<int> getUserReportCountForZone(String userId, String zoneId) async {
    try {
      // Using get() instead of count() for better compatibility without composite index
      final snapshot = await _userReportsRef
          .where('userId', isEqualTo: userId)
          .where('zoneId', isEqualTo: zoneId)
          .get();
      print(
          'DEBUG: User $userId has ${snapshot.docs.length} reports for zone $zoneId');
      return snapshot.docs.length;
    } catch (e) {
      print('ERROR getting report count: $e');
      // If query fails (e.g., missing index), return 0 but log the error
      return 0;
    }
  }

  /// Submit a user report with rate limiting (max 3 per zone per user)
  /// Returns: null on success, error message on failure
  Future<String?> submitUserReport({
    required String userId,
    required String zoneId,
    required String cityId,
    required String reportType,
  }) async {
    // Check rate limit
    final existingCount = await getUserReportCountForZone(userId, zoneId);
    if (existingCount >= 3) {
      return 'You have already submitted 3 reports for this zone.';
    }

    // Create user report document
    await _userReportsRef.add({
      'userId': userId,
      'zoneId': zoneId,
      'cityId': cityId,
      'reportType': reportType,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Also update zone counters (existing logic)
    final zoneDoc = await _zonesRef.doc(zoneId).get();
    final zoneData = zoneDoc.data() as Map<String, dynamic>?;
    final currentCount = (zoneData?['negativeFeedbackCount'] ?? 0) as int;

    await reportZone(zoneId, cityId, currentCount + 1, reportType: reportType);

    return null; // Success
  }

  /// Get all reports by a user (for profile/history)
  Stream<QuerySnapshot> getAllUserReports(String userId) {
    return _userReportsRef
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Delete a user's report and decrement zone counters
  Future<void> deleteUserReport(
      String reportId, String zoneId, String cityId, String reportType) async {
    // Delete the report document
    await _userReportsRef.doc(reportId).delete();

    // Decrement zone counters
    final zoneDoc = await _zonesRef.doc(zoneId).get();
    final zoneData = zoneDoc.data() as Map<String, dynamic>?;
    final currentCount = (zoneData?['negativeFeedbackCount'] ?? 1) as int;

    final updates = <String, dynamic>{
      'negativeFeedbackCount': (currentCount - 1).clamp(0, 999),
    };

    // Decrement specific report type counter
    switch (reportType) {
      case 'theft':
        updates['theftReports'] = FieldValue.increment(-1);
        break;
      case 'harassment':
        updates['harassmentReports'] = FieldValue.increment(-1);
        break;
      case 'lighting':
        updates['poorLightingReports'] = FieldValue.increment(-1);
        break;
      case 'suspicious':
        updates['suspiciousReports'] = FieldValue.increment(-1);
        break;
    }

    await _zonesRef.doc(zoneId).update(updates);

    // Recalculate city aggregates
    if (cityId.isNotEmpty) {
      await _updateCityAggregates(cityId);
    }
  }
}
