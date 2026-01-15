import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../app/providers.dart';
import '../models/zone.dart';

/// Service to handle real-time tracking and simulation
class TrackingService {
  final Ref ref;
  Timer? _simulationTimer;
  int _pathIndex = 0;

  // Mock path ensuring we cross some zones
  // Starts near Albert Hall (Jaipur), goes through Walled City, then to Amber Fort
  final List<LatLng> _mockPath = [
    const LatLng(26.9114, 75.8190), // Start: Albert Hall
    const LatLng(26.9150, 75.8150),
    const LatLng(26.9200, 75.8200),
    const LatLng(26.9250, 75.8250), // Hawa Mahal area
    const LatLng(26.9300, 75.8280),
    const LatLng(26.9400, 75.8350),
    const LatLng(26.9500, 75.8450), // Jal Mahal area
    const LatLng(26.9600, 75.8500),
    const LatLng(26.9750, 75.8550),
    const LatLng(26.9855, 75.8507), // End: Amber Fort
  ];

  TrackingService(this.ref);

  void startSimulation() {
    stopSimulation(); // clear existing
    _pathIndex = 0;
    
    // Initial update
    _updateLocation(_mockPath[0]);
    ref.read(userLocationProvider.notifier).setTracking(true);

    // Simulate movement every 2 seconds
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_pathIndex >= _mockPath.length - 1) {
        _pathIndex = 0; // Loop the path
      } else {
        _pathIndex++;
      }
      
      final newLoc = _mockPath[_pathIndex];
      _updateLocation(newLoc);
    });
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    ref.read(userLocationProvider.notifier).setTracking(false);
  }

  void _updateLocation(LatLng pos) {
    // 1. Update position in provider
    ref.read(userLocationProvider.notifier).updateLocation(
      pos.latitude, 
      pos.longitude
    );

    // 2. Check for zone breaches
    _checkZones(pos);
  }

  void _checkZones(LatLng pos) {
    final zones = ref.read(zonesProvider);
    Zone? activeZone;

    for (final zone in zones) {
      // Simple distance check (approximate for circular zones)
      final distance = const Distance().as(
        LengthUnit.Meter, 
        pos, 
        LatLng(zone.centerLat, zone.centerLng)
      );

      if (distance <= zone.radius) {
        activeZone = zone;
        break; // Assume in only one zone at a time for now
      }
    }

    final prevZone = ref.read(userLocationProvider).currentZone;
    
    if (activeZone != prevZone) {
      // Zone Changed!
      ref.read(userLocationProvider.notifier).setCurrentZone(activeZone);

      if (activeZone != null) {
        // Entered a zone
        ref.read(appStateProvider.notifier).showWarning(
          "Entered ${activeZone.name} (${activeZone.type.toUpperCase()})"
        );
      } else {
        // Exited a zone
        ref.read(appStateProvider.notifier).hideWarning();
      }
    }
  }
}

final trackingServiceProvider = Provider<TrackingService>((ref) {
  return TrackingService(ref);
});
