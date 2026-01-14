// Geofencing Screen - Main UI for location tracking and zone detection
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/geofence_service.dart';

class GeofencingScreen extends StatefulWidget {
  const GeofencingScreen({super.key});

  @override
  State<GeofencingScreen> createState() => _GeofencingScreenState();
}

class _GeofencingScreenState extends State<GeofencingScreen> {
  // State variables
  List<GeofenceZone> _zones = [];
  List<ZoneStatus> _insideZones = [];
  List<ZoneStatus> _nearbyZones = [];
  double? _currentLat;
  double? _currentLng;
  bool _isLoading = true;
  bool _isTracking = false;
  String _statusMessage = 'Initializing...';
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  /// Load all geofence zones from backend
  Future<void> _loadZones() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading zones...';
    });

    try {
      final zones = await GeofenceService.getZones();
      setState(() {
        _zones = zones;
        _isLoading = false;
        _statusMessage = 'Loaded ${zones.length} zones. Tap "Start Tracking" to begin.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error loading zones: $e';
      });
    }
  }

  /// Start continuous location tracking
  Future<void> _startTracking() async {
    setState(() {
      _statusMessage = 'Getting location...';
    });

    final position = await GeofenceService.getCurrentLocation();
    if (position == null) {
      setState(() {
        _statusMessage = 'Could not get location. Please enable location services.';
      });
      return;
    }

    setState(() {
      _isTracking = true;
      _currentLat = position.latitude;
      _currentLng = position.longitude;
    });

    // Check location immediately
    await _checkCurrentLocation();

    // Set up periodic checking every 5 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _updateLocation();
    });
  }

  /// Stop location tracking
  void _stopTracking() {
    _locationTimer?.cancel();
    setState(() {
      _isTracking = false;
      _statusMessage = 'Tracking stopped.';
    });
  }

  /// Update current location
  Future<void> _updateLocation() async {
    final position = await GeofenceService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
      });
      await _checkCurrentLocation();
    }
  }

  /// Check current location against geofence zones
  Future<void> _checkCurrentLocation() async {
    if (_currentLat == null || _currentLng == null) return;

    try {
      final result = await GeofenceService.checkLocation(_currentLat!, _currentLng!);

      final insideZones = (result['inside_zones'] as List)
          .map((z) => ZoneStatus.fromJson(z))
          .toList();
      final nearbyZones = (result['nearby_zones'] as List)
          .map((z) => ZoneStatus.fromJson(z))
          .toList();

      setState(() {
        _insideZones = insideZones;
        _nearbyZones = nearbyZones;

        if (insideZones.isNotEmpty) {
          _statusMessage = '🎯 You are inside ${insideZones.length} zone(s)!';
        } else if (nearbyZones.isNotEmpty) {
          _statusMessage = '📍 ${nearbyZones.length} zone(s) nearby';
        } else {
          _statusMessage = '🔍 No zones detected nearby';
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofencing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadZones,
            tooltip: 'Reload zones',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadZones,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status Card
                    _buildStatusCard(),
                    const SizedBox(height: 16),

                    // Current Location Card
                    if (_currentLat != null && _currentLng != null)
                      _buildLocationCard(),

                    // Inside Zones Section
                    if (_insideZones.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSectionTitle('🎯 You are inside:', Colors.green),
                      ..._insideZones.map((z) => _buildZoneStatusCard(z, true)),
                    ],

                    // Nearby Zones Section
                    if (_nearbyZones.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSectionTitle('📍 Nearby zones:', Colors.orange),
                      ..._nearbyZones.map((z) => _buildZoneStatusCard(z, false)),
                    ],

                    // All Zones Section
                    const SizedBox(height: 24),
                    _buildSectionTitle('📋 All Tourist Zones', Colors.blue),
                    ..._zones.map(_buildZoneCard),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isTracking ? _stopTracking : _startTracking,
        icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
        label: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
        backgroundColor: _isTracking ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      color: _insideZones.isNotEmpty
          ? Colors.green.shade50
          : _nearbyZones.isNotEmpty
              ? Colors.orange.shade50
              : Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _isTracking ? Icons.my_location : Icons.location_off,
              size: 48,
              color: _isTracking ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (_isTracking) ...[
              const SizedBox(height: 8),
              const Text(
                'Location updates every 5 seconds',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.blue),
        title: const Text('Current Location'),
        subtitle: Text(
          'Lat: ${_currentLat!.toStringAsFixed(6)}\nLng: ${_currentLng!.toStringAsFixed(6)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _updateLocation,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildZoneStatusCard(ZoneStatus status, bool isInside) {
    return Card(
      color: isInside ? Colors.green.shade100 : Colors.orange.shade100,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isInside ? Icons.check_circle : Icons.near_me,
          color: isInside ? Colors.green : Colors.orange,
          size: 32,
        ),
        title: Text(
          status.zoneName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status.description),
            const SizedBox(height: 4),
            Text(
              isInside
                  ? '✓ You are inside this zone!'
                  : 'Distance: ${status.distanceMeters.toStringAsFixed(0)}m',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isInside ? Colors.green.shade700 : Colors.orange.shade700,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildZoneCard(GeofenceZone zone) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _getCategoryIcon(zone.category),
        title: Text(zone.name),
        subtitle: Text(
          '${zone.description}\nRadius: ${zone.radiusMeters.toStringAsFixed(0)}m',
        ),
        isThreeLine: true,
        trailing: Text(
          zone.category.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData iconData;
    Color color;

    switch (category.toLowerCase()) {
      case 'museum':
        iconData = Icons.museum;
        color = Colors.purple;
        break;
      case 'park':
        iconData = Icons.park;
        color = Colors.green;
        break;
      case 'monument':
        iconData = Icons.account_balance;
        color = Colors.brown;
        break;
      case 'landmark':
        iconData = Icons.place;
        color = Colors.blue;
        break;
      default:
        iconData = Icons.location_on;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color),
    );
  }
}
