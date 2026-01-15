import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/theme.dart';
import '../app/providers.dart';
import '../models/zone.dart';
import '../services/tracking_service.dart';

/// Page 2: Real Map View (OpenStreetMap) - EXPANDED DATASET
class CommandCenterPage extends ConsumerStatefulWidget {
  const CommandCenterPage({super.key});

  @override
  ConsumerState<CommandCenterPage> createState() => _CommandCenterPageState();
}

class _CommandCenterPageState extends ConsumerState<CommandCenterPage> {
  final MapController _mapController = MapController();
  late DraggableScrollableController _sheetController;
  // Center of India (approximately)
  final LatLng _initialCenter = const LatLng(20.5937, 78.9629);
  final double _initialZoom = 5.0; // Zoom out to see all India
  bool _isDarkMode = false; // Add state for map style
  String _currentState = ''; // Current state/region being viewed

  /// Detect the state/region based on map center coordinates
  String _detectState(double lat, double lng) {
    // State boundaries defined by approximate lat/lng ranges
    // Format: [minLat, maxLat, minLng, maxLng, stateName]
    // IMPORTANT: Cities (smaller regions) MUST come BEFORE states
    final stateRegions = [
      // === CITIES FIRST (most specific) ===
      [28.4, 28.9, 76.8, 77.5, 'Delhi NCR'],
      [18.85, 19.35, 72.75, 73.05, 'Mumbai'],
      [12.85, 13.15, 77.45, 77.75, 'Bangalore'],
      [12.95, 13.25, 80.15, 80.35, 'Chennai'],
      [22.45, 22.7, 88.25, 88.5, 'Kolkata'],
      [17.3, 17.55, 78.35, 78.6, 'Hyderabad'],
      [23.0, 23.15, 72.5, 72.7, 'Ahmedabad'],
      [18.45, 18.65, 73.75, 74.0, 'Pune'],
      [26.8, 27.0, 75.7, 75.95, 'Jaipur'],
      [30.65, 30.85, 76.7, 76.9, 'Chandigarh'],
      [26.0, 26.2, 91.65, 91.85, 'Guwahati'],
      [25.55, 25.7, 91.85, 92.0, 'Shillong'],
      [21.1, 21.3, 79.0, 79.2, 'Nagpur'],
      [25.55, 25.7, 84.95, 85.1, 'Patna'],
      [23.3, 23.5, 85.25, 85.45, 'Ranchi'],
      [20.25, 20.35, 85.8, 85.95, 'Bhubaneswar'],
      [21.15, 21.3, 81.55, 81.7, 'Raipur'],
      [22.65, 22.85, 88.35, 88.5, 'Howrah'],
      [15.3, 15.55, 73.75, 74.05, 'Goa'],
      [30.3, 30.4, 78.0, 78.15, 'Dehradun'],
      [24.55, 24.7, 73.65, 73.85, 'Udaipur'],
      [30.0, 30.15, 78.25, 78.35, 'Rishikesh'],
      [31.05, 31.15, 77.1, 77.2, 'Shimla'],
      [32.25, 32.35, 76.3, 76.4, 'Manali'],
      [12.25, 12.35, 76.6, 76.7, 'Mysore'],
      [9.9, 10.0, 78.1, 78.2, 'Madurai'],
      [27.15, 27.25, 78.0, 78.1, 'Agra'],
      [26.25, 26.35, 73.0, 73.1, 'Jodhpur'],
      [22.25, 22.4, 70.75, 70.9, 'Rajkot'],
      [22.25, 22.4, 73.15, 73.3, 'Vadodara'],
      [32.7, 32.85, 74.8, 75.0, 'Jammu'],
      [34.05, 34.15, 74.75, 74.85, 'Srinagar'],
      
      // === STATES (larger regions) ===
      // North India
      [28.0, 30.5, 74.5, 77.5, 'Punjab & Haryana'],
      [29.5, 31.5, 77.5, 81.0, 'Uttarakhand'],
      [25.5, 30.5, 79.5, 84.5, 'Uttar Pradesh'],
      [30.0, 35.5, 73.5, 80.5, 'Jammu & Kashmir'],
      // Rajasthan
      [23.0, 30.0, 69.5, 78.5, 'Rajasthan'],
      // West India
      [15.5, 22.0, 72.5, 80.5, 'Maharashtra'],
      [20.0, 24.5, 68.0, 74.5, 'Gujarat'],
      // South India
      [11.0, 18.5, 74.0, 78.5, 'Karnataka'],
      [8.0, 13.5, 77.0, 80.5, 'Tamil Nadu'],
      [8.0, 12.8, 74.5, 77.5, 'Kerala'],
      [13.5, 19.5, 77.5, 84.5, 'Telangana & Andhra Pradesh'],
      // East India
      [21.5, 27.5, 85.5, 89.0, 'West Bengal'],
      [19.5, 22.5, 82.0, 87.5, 'Odisha'],
      [24.0, 27.5, 83.5, 88.5, 'Bihar'],
      [21.5, 25.5, 83.5, 88.0, 'Jharkhand'],
      [18.0, 24.5, 80.0, 84.5, 'Chhattisgarh'],
      [19.5, 25.5, 74.0, 82.5, 'Madhya Pradesh'],
      // Northeast India
      [24.0, 28.5, 89.5, 97.5, 'Northeast India'],
      [25.5, 28.0, 89.5, 96.5, 'Assam'],
      [25.0, 26.5, 91.0, 92.5, 'Meghalaya'],
    ];

    // Check each region - cities come first so they match before states
    for (final region in stateRegions) {
      final minLat = region[0] as double;
      final maxLat = region[1] as double;
      final minLng = region[2] as double;
      final maxLng = region[3] as double;
      final stateName = region[4] as String;
      
      if (lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng) {
        return stateName;
      }
    }
    return 'India';
  }

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(zonesProvider);
    final userLocation = ref.watch(userLocationProvider);
    final appState = ref.watch(appStateProvider);

    // Listen for zone warnings
    ref.listen(appStateProvider, (previous, next) {
      if (next.showWarning && next.warningMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(next.warningMessage!),
              ],
            ),
            backgroundColor: AppColors.dangerZone,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final trackingService = ref.read(trackingServiceProvider);
          if (userLocation.isTracking) {
            trackingService.stopSimulation();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Simulation Stopped')),
            );
          } else {
            trackingService.startSimulation();
            // Move map to start of Jaipur simulation
            _mapController.move(const LatLng(26.9114, 75.8190), 14);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Simulation Started: Jaipur Route')),
            );
          }
        },
        backgroundColor: userLocation.isTracking ? Colors.red : AppColors.primary,
        icon: Icon(userLocation.isTracking ? Icons.stop : Icons.play_arrow),
        label: Text(userLocation.isTracking ? 'Stop Tracking' : 'Start Simulation'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              minZoom: 4,
              maxZoom: 18,
              // India bounds - prevents panning outside India
              maxBounds: LatLngBounds(
                const LatLng(6.0, 68.0),   // Southwest
                const LatLng(35.5, 97.5),  // Northeast
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
                enableScrollWheel: true,
                pinchZoomThreshold: 0.3,
              ),
              onPositionChanged: (position, hasGesture) {
                // Detect current state based on map center
                final center = position.center;
                final zoom = position.zoom;
                if (center != null && zoom != null && zoom > 7) {
                  final newState = _detectState(center.latitude, center.longitude);
                  if (newState != _currentState) {
                    setState(() {
                      _currentState = newState;
                    });
                  }
                } else {
                  if (_currentState != '') {
                    setState(() {
                      _currentState = '';
                    });
                  }
                }
                // Trigger rebuild for zone filtering
                setState(() {});
              },
              onTap: (_, __) => {},
            ),
            children: [
              TileLayer(
                // Switch between Standard and Dark Matter
                urlTemplate: _isDarkMode
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.safezone',
                subdomains: const ['a', 'b', 'c'],
              ),
              PolygonLayer(polygons: _getVisiblePolygons(zones)),
              MarkerLayer(
                markers: [
                  ..._getVisibleZones(zones).map((zone) {
                    return Marker(
                      point: LatLng(zone.centerLat, zone.centerLng),
                      width: 36,
                      height: 36,
                      child: GestureDetector(
                        onTap: () => _showZoneDetails(zone),
                        child: _buildMarkerIcon(zone.type),
                      ),
                    );
                  }),
                  // User Location Marker
                  Marker(
                    point: LatLng(userLocation.latitude, userLocation.longitude),
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.navigation, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // State Indicator Badge (shows when zoomed in)
          if (_currentState.isNotEmpty)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isDarkMode
                          ? [Colors.indigo.shade900, Colors.purple.shade900]
                          : [Colors.indigo.shade600, Colors.purple.shade600],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentState,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ... Header Positioned ...
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: _isDarkMode
                                ? Colors.black87.withOpacity(0.9)
                                : Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 8)
                            ]),
                        child: Icon(Icons.arrow_back,
                            color: _isDarkMode ? Colors.white : Colors.black87),
                      ),
                    ),

                    // Boxed Title
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: _isDarkMode
                              ? Colors.black87.withOpacity(0.9)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 8)
                          ]),
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined,
                              color: AppColors.safeZone, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'SafeZone',
                            style: GoogleFonts.orbitron(
                              color:
                                  _isDarkMode ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Actions
                    Row(
                      children: [
                        _buildHeaderAction(Icons.my_location,
                            () => _mapController.move(_initialCenter, 5)),
                        const SizedBox(width: 12),
                        _buildHeaderAction(
                            _isDarkMode
                                ? Icons.wb_sunny_rounded
                                : Icons.nightlight_round, () {
                          setState(() {
                            _isDarkMode = !_isDarkMode;
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Zoom Controls
          Positioned(
            right: 16,
            bottom: 200,
            child: Column(
              children: [
                // Zoom In Button
                GestureDetector(
                  onTap: () {
                    final currentZoom = _mapController.camera.zoom;
                    if (currentZoom < 18) {
                      _mapController.move(
                        _mapController.camera.center,
                        currentZoom + 1,
                      );
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.black87 : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      color: _isDarkMode ? Colors.white : Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
                Container(
                  width: 44,
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                // Zoom Out Button
                GestureDetector(
                  onTap: () {
                    final currentZoom = _mapController.camera.zoom;
                    if (currentZoom > 4) {
                      _mapController.move(
                        _mapController.camera.center,
                        currentZoom - 1,
                      );
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.black87 : Colors.white,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.remove,
                      color: _isDarkMode ? Colors.white : Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sheet
          _buildBottomPanel(_getVisibleZones(zones)),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  /// Filter zones to only show those within the visible map bounds
  List<Zone> _getVisibleZones(List<Zone> allZones) {
    try {
      final bounds = _mapController.camera.visibleBounds;
      return allZones.where((zone) {
        return bounds.contains(LatLng(zone.centerLat, zone.centerLng));
      }).toList();
    } catch (e) {
      // MapController not ready yet, show all zones
      return allZones;
    }
  }

  /// Get polygons for visible zones only
  List<Polygon> _getVisiblePolygons(List<Zone> allZones) {
    final visibleZones = _getVisibleZones(allZones);
    return visibleZones.map((zone) {
      return Polygon(
        points: _createSquareZone(
            LatLng(zone.centerLat, zone.centerLng), zone.radius * 2.0),
        color: zone.type.zoneColor.withOpacity(_isDarkMode ? 0.2 : 0.1),
        borderColor: zone.type.zoneColor,
        borderStrokeWidth: 2,
        isFilled: true,
        label: zone.name,
        labelStyle: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          backgroundColor: Colors.white.withOpacity(0.7),
        ),
      );
    }).toList();
  }


  Widget _buildMarkerIcon(String type) {
    Color color;
    IconData icon;

    switch (type.toLowerCase()) {
      case 'danger':
        color = AppColors.dangerZone;
        icon = Icons.warning_amber_rounded;
        break;
      case 'caution':
        color = AppColors.cautionZone;
        icon = Icons.priority_high_rounded;
        break;
      case 'safe':
      default:
        color = AppColors.safeZone;
        icon = Icons.check_rounded;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  List<LatLng> _createSquareZone(LatLng center, double sizeMeters) {
    final offset = sizeMeters / 111000;
    return [
      LatLng(center.latitude + offset, center.longitude - offset),
      LatLng(center.latitude + offset, center.longitude + offset),
      LatLng(center.latitude - offset, center.longitude + offset),
      LatLng(center.latitude - offset, center.longitude - offset),
    ];
  }

  void _showZoneDetails(Zone zone) {
    context.push('/intel/${zone.id}');
  }

  Widget _buildBottomPanel(List<Zone> zones) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.15, // Start Visible (Peek)
      minChildSize: 0.05, // BUT allow hiding it (Option available)
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.05, 0.15, 0.9], // Hidden, Peek, Full
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color:
                Colors.transparent, // User requested removing white background
            // No shadow, no border radius needed if transparent
          ),
          child: Scrollbar(
            thumbVisibility: true,
            controller: scrollController,
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                // Handle & Controls
                GestureDetector(
                  onTap: () {
                    // Smart Toggle
                    if (_sheetController.size < 0.1) {
                      _sheetController.animateTo(0.15,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut); // Unhide
                    } else if (_sheetController.size > 0.5) {
                      _sheetController.animateTo(0.15,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut); // Minimize
                    } else {
                      _sheetController.animateTo(0.9,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut); // Maximize
                    }
                  },
                  child: Container(
                    color: Colors.transparent, // Hit test target
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),

                // Expanded Content: Arrows Only
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors
                          .black, // User requested background black ONLY on arrows
                      borderRadius: BorderRadius.circular(30), // Pill shape
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // Wrap content height/width
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Up Arrow
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_up_rounded,
                              color: Colors.white), // White Icon
                          onPressed: () {
                            if (_sheetController.size < 0.1) {
                              _sheetController.animateTo(0.15,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut);
                            } else {
                              _sheetController.animateTo(0.9,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.elasticOut);
                            }
                          },
                          tooltip: 'Expand',
                        ),
                        const SizedBox(width: 16), // Tighter Space
                        // Down Arrow
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.white), // White Icon
                          onPressed: () {
                            if (_sheetController.size > 0.5) {
                              _sheetController.animateTo(0.15,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut);
                            } else {
                              _sheetController.animateTo(0.05,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut);
                            }
                          },
                          tooltip: 'Minimize',
                        ),
                      ],
                    ),
                  ),
                ),

                ...zones.map((zone) => Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                            0.9), // Semi-transparent for legibility
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => _showZoneDetails(zone),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Leading icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: zone.type.zoneColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  zone.type == 'danger'
                                      ? Icons.warning_amber_rounded
                                      : zone.type == 'caution'
                                          ? Icons.priority_high_rounded
                                          : Icons.verified_user_rounded,
                                  color: zone.type.zoneColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      zone.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      zone.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    // Warning tags
                                    if (zone.warnings.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: zone.warnings.map((warning) =>
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: zone.type.zoneColor.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: zone.type.zoneColor.withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              warning,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: zone.type.zoneColor,
                                              ),
                                            ),
                                          ),
                                        ).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Trailing icon
                              const Icon(Icons.chevron_right,
                                  size: 20, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    )),

                const SizedBox(height: 40), // Bottom padding
              ],
            ),
          ),
        );
      },
    );
  }
}
