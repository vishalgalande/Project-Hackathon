import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/zone.dart';

/// Current user location state
class UserLocation {
  final double latitude;
  final double longitude;
  final bool isTracking;
  final Zone? currentZone;
  
  const UserLocation({
    this.latitude = 26.9124,
    this.longitude = 75.7873,
    this.isTracking = false,
    this.currentZone,
  });
  
  UserLocation copyWith({
    double? latitude,
    double? longitude,
    bool? isTracking,
    Zone? currentZone,
  }) {
    return UserLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isTracking: isTracking ?? this.isTracking,
      currentZone: currentZone,
    );
  }
}

/// User location notifier
class UserLocationNotifier extends StateNotifier<UserLocation> {
  UserLocationNotifier() : super(const UserLocation());
  
  void updateLocation(double lat, double lng) {
    state = state.copyWith(latitude: lat, longitude: lng);
  }
  
  void setTracking(bool tracking) {
    state = state.copyWith(isTracking: tracking);
  }
  
  void setCurrentZone(Zone? zone) {
    state = state.copyWith(currentZone: zone);
  }
}

/// Zones state
class ZonesNotifier extends StateNotifier<List<Zone>> {
  ZonesNotifier() : super(MockZones.jaipurZones);
  
  void loadZones(List<Zone> zones) {
    state = zones;
  }
  
  void addZone(Zone zone) {
    state = [...state, zone];
  }
  
  Zone? getZoneById(String id) {
    try {
      return state.firstWhere((z) => z.id == id);
    } catch (_) {
      return null;
    }
  }
  
  /// Check which zone contains the given point
  Zone? getZoneAtLocation(double lat, double lng) {
    // Simplified check - would use proper geo library in production
    return null;
  }
}

/// App state for global flags
class AppState {
  final bool isInitialized;
  final bool showWarning;
  final String? warningMessage;
  
  const AppState({
    this.isInitialized = false,
    this.showWarning = false,
    this.warningMessage,
  });
  
  AppState copyWith({
    bool? isInitialized,
    bool? showWarning,
    String? warningMessage,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      showWarning: showWarning ?? this.showWarning,
      warningMessage: warningMessage,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());
  
  void setInitialized(bool value) {
    state = state.copyWith(isInitialized: value);
  }
  
  void showWarning(String message) {
    state = state.copyWith(showWarning: true, warningMessage: message);
  }
  
  void hideWarning() {
    state = state.copyWith(showWarning: false, warningMessage: null);
  }
}

// ============ PROVIDERS ============

/// User location provider
final userLocationProvider = StateNotifierProvider<UserLocationNotifier, UserLocation>((ref) {
  return UserLocationNotifier();
});

/// Zones provider
final zonesProvider = StateNotifierProvider<ZonesNotifier, List<Zone>>((ref) {
  return ZonesNotifier();
});

/// App state provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

/// Selected zone provider (for Intel page)
final selectedZoneProvider = Provider.family<Zone?, String>((ref, zoneId) {
  final zones = ref.watch(zonesProvider);
  try {
    return zones.firstWhere((z) => z.id == zoneId);
  } catch (_) {
    return null;
  }
});

/// Current zone detection provider
final currentZoneProvider = Provider<Zone?>((ref) {
  return null; // Simplified - no geo detection
});

/// Is in danger zone provider
final isInDangerZoneProvider = Provider<bool>((ref) {
  final currentZone = ref.watch(currentZoneProvider);
  return currentZone?.type.toLowerCase() == 'danger';
});
