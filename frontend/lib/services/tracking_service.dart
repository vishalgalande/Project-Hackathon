import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../app/providers.dart';
import '../models/zone.dart';

/// Service to handle real-time tracking with smooth route simulation
/// Route: Jaipur Railway Station → Jaipur Airport (following actual road path)
class TrackingService {
  final Ref ref;
  Timer? _simulationTimer;
  int _pathIndex = 0;

  // For smooth interpolation
  double _interpolationProgress = 0.0;
  int _stepsPerSegment = 20; // Subdivide each segment into micro-steps
  int _updateIntervalMs = 100; // Update interval for smooth animation
  int _speedMultiplier = 1; // Current speed (1x, 2x, 3x)

  // Route: Jaipur Railway Station → Jaipur Airport (following depicted path)
  final List<LatLng> _routeRailwayToAirport = [
    // Start: Railway Station area
    const LatLng(26.9200, 75.7870), // Jaipur Railway Station
    const LatLng(26.9195, 75.7890), // Station Road
    const LatLng(26.9190, 75.7920),
    const LatLng(26.9185, 75.7960), // Towards walled city

    // East through walled city (horizontal movement in image)
    const LatLng(26.9180, 75.8000),
    const LatLng(26.9178, 75.8040), // Chandpole area
    const LatLng(26.9175, 75.8080),
    const LatLng(26.9173, 75.8120), // Pink City
    const LatLng(26.9170, 75.8160),
    const LatLng(26.9168, 75.8200), // Near Hawa Mahal
    const LatLng(26.9165, 75.8230), // Johari Bazaar turn

    // Turn south (going down in image)
    const LatLng(26.9140, 75.8220),
    const LatLng(26.9100, 75.8210), // MI Road area
    const LatLng(26.9050, 75.8200),
    const LatLng(26.9000, 75.8190), // GPO

    // Continue south through main road
    const LatLng(26.8950, 75.8180), // Ajmeri Gate
    const LatLng(26.8900, 75.8170),
    const LatLng(26.8850, 75.8165), // Bapu Nagar starts
    const LatLng(26.8800, 75.8160), // User location in image
    const LatLng(26.8750, 75.8155),
    const LatLng(26.8700, 75.8150), // Tonk Phatak
    const LatLng(26.8650, 75.8145),
    const LatLng(26.8600, 75.8140),

    // Continue towards Jagatpura
    const LatLng(26.8550, 75.8135),
    const LatLng(26.8500, 75.8130), // SMS Hospital area (green zone in image)
    const LatLng(26.8450, 75.8125),
    const LatLng(26.8400, 75.8120),
    const LatLng(26.8350, 75.8118), // Jagatpura approach
    const LatLng(26.8300, 75.8115),

    // Final approach to Airport
    const LatLng(26.8280, 75.8118), // Jagatpura (green zone)
    const LatLng(26.8260, 75.8120),
    const LatLng(26.8242, 75.8122), // Jaipur Airport
  ];

  TrackingService(this.ref);

  /// Get route name
  String get currentRouteName => 'Railway Station → Airport';

  /// Get starting point for map centering
  LatLng get startingPoint => _routeRailwayToAirport.first;

  /// Get current speed multiplier
  int get speedMultiplier => _speedMultiplier;

  /// Set speed multiplier (1x, 2x, 3x)
  void setSpeed(int multiplier) {
    if (multiplier < 1 || multiplier > 3) return;
    _speedMultiplier = multiplier;

    // If simulation is running, restart with new speed
    if (_simulationTimer != null) {
      _restartWithNewSpeed();
    }
  }

  void _restartWithNewSpeed() {
    _simulationTimer?.cancel();

    // Faster speed = smaller interval
    final adjustedInterval = _updateIntervalMs ~/ _speedMultiplier;

    _simulationTimer = Timer.periodic(
      Duration(milliseconds: adjustedInterval),
      (timer) {
        _simulationStep();
      },
    );
  }

  /// Interpolate between two points for smooth movement
  LatLng _interpolate(LatLng from, LatLng to, double t) {
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * t,
      from.longitude + (to.longitude - from.longitude) * t,
    );
  }

  /// Start smooth simulation (triggered by spacebar)
  void startSimulation() {
    stopSimulation(); // clear existing
    _pathIndex = 0;
    _interpolationProgress = 0.0;

    // Initial update
    _updateLocation(_routeRailwayToAirport[0]);
    ref.read(userLocationProvider.notifier).setTracking(true);

    // Smooth movement timer - adjusts based on speed multiplier
    final adjustedInterval = _updateIntervalMs ~/ _speedMultiplier;

    _simulationTimer = Timer.periodic(
      Duration(milliseconds: adjustedInterval),
      (timer) {
        _simulationStep();
      },
    );
  }

  void _simulationStep() {
    _interpolationProgress += 1.0 / _stepsPerSegment;

    if (_interpolationProgress >= 1.0) {
      // Move to next segment
      _interpolationProgress = 0.0;
      _pathIndex++;

      if (_pathIndex >= _routeRailwayToAirport.length - 1) {
        _pathIndex = 0; // Loop the path
      }
    }

    // Calculate interpolated position
    final from = _routeRailwayToAirport[_pathIndex];
    final to = _routeRailwayToAirport[
        math.min(_pathIndex + 1, _routeRailwayToAirport.length - 1)];
    final smoothPos = _interpolate(from, to, _interpolationProgress);

    _updateLocation(smoothPos);
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _pathIndex = 0;
    _interpolationProgress = 0.0;
    _speedMultiplier = 1; // Reset speed
    ref.read(userLocationProvider.notifier).setTracking(false);
  }

  void _updateLocation(LatLng pos) {
    // 1. Update position in provider
    ref
        .read(userLocationProvider.notifier)
        .updateLocation(pos.latitude, pos.longitude);

    // 2. Check for zone breaches
    _checkZones(pos);
  }

  void _checkZones(LatLng pos) {
    final zones = ref.read(zonesProvider);
    Zone? activeZone;

    for (final zone in zones) {
      // Simple distance check (approximate for circular zones)
      final distance = const Distance()
          .as(LengthUnit.Meter, pos, LatLng(zone.centerLat, zone.centerLng));

      if (distance <= zone.radius) {
        activeZone = zone;
        break; // Assume in only one zone at a time for now
      }
    }

    final prevZone = ref.read(userLocationProvider).currentZone;

    // Compare by zone ID to ensure proper change detection
    final prevZoneId = prevZone?.id;
    final activeZoneId = activeZone?.id;

    if (activeZoneId != prevZoneId) {
      // Zone Changed!
      ref.read(userLocationProvider.notifier).setCurrentZone(activeZone);

      if (activeZone != null) {
        // Entered a zone - pass zone type and ID for coloring and unique key
        ref.read(appStateProvider.notifier).showWarning(
              "Entered ${activeZone.name} (${activeZone.type.toUpperCase()})",
              zoneType: activeZone.type,
              zoneId: activeZone.id,
            );
      } else {
        // Exited all zones
        ref.read(appStateProvider.notifier).hideWarning();
      }
    }
  }
}

final trackingServiceProvider = Provider<TrackingService>((ref) {
  return TrackingService(ref);
});
