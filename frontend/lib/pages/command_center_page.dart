import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../app/theme.dart';
import '../app/providers.dart';
import '../models/zone.dart';
import '../services/tracking_service.dart';

/// Page 2: Real Map View (OpenStreetMap) - EXPANDED DATASET
class CommandCenterPage extends ConsumerStatefulWidget {
  final bool triggerIntroAnimation;
  const CommandCenterPage({super.key, this.triggerIntroAnimation = false});

  @override
  ConsumerState<CommandCenterPage> createState() => _CommandCenterPageState();
}

class _CommandCenterPageState extends ConsumerState<CommandCenterPage>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late FocusNode _focusNode; // For keyboard events
  // Center of India (approximately)
  late LatLng _initialCenter;
  late double _initialZoom;
  // Final target for animation (Jaipur)
  final LatLng _jaipurCenter = const LatLng(26.9124, 75.7873);
  final double _targetZoom = 12.0; // Street level zoom
  bool _isDarkMode = false; // Add state for map style
  String _currentState = ''; // Current state/region being viewed
  bool _mapReady = false; // Track if map controller is ready
  double _currentZoom = 5.0; // Track current zoom level for clustering
  static const double _clusterZoomThreshold =
      8.0; // Show clusters below this zoom
  LatLng? _userLocation; // User's detected location
  bool _locationLoading = true; // Loading state for geolocation
  bool _isPanelExpanded = false; // Track if bottom panel is expanded

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
    _focusNode = FocusNode();

    // Initialize map state based on animation trigger
    if (widget.triggerIntroAnimation) {
      // Start at India center for Zoom transition
      _initialCenter = const LatLng(20.5937, 78.9629);
      _initialZoom = 5.0; // Zoomed out India view

      // Schedule animation after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playIntroAnimation();
      });
    } else {
      // Normal load
      _initialCenter = _jaipurCenter;
      _initialZoom = 5.0;
    }

    _initUserLocation();
  }

  /// Play the globe spinning transition
  Future<void> _playIntroAnimation() async {
    // Wait a brief moment for map to render
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 1: "Spin" - Fast pan from Atlantic to India
    if (!mounted) return;

    // Animate to India with zoom in
    _animateMapTo(_jaipurCenter, _targetZoom);
  }

  void _animateMapTo(LatLng destLocation, double destZoom) {
    // Simple custom animation implementation
    final latTween = Tween<double>(
        begin: _mapController.camera.center.latitude,
        end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.camera.center.longitude,
        end: destLocation.longitude);
    final zoomTween =
        Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

    final controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);
    final animation =
        CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);

    controller.addListener(() {
      if (!mounted) return;
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  /// Get user's current location and center map on it
  Future<void> _initUserLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationLoading = false);
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationLoading = false);
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _locationLoading = false;
      });

      // Move map to user location when ready
      if (_mapReady && _userLocation != null) {
        _mapController.move(_userLocation!, 10);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() => _locationLoading = false);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(zonesProvider);
    final userLocation = ref.watch(userLocationProvider);
    final appState = ref.watch(appStateProvider);

    // Note: Warning is now shown via custom widget in Stack, not SnackBar
    // Handle keyboard events: Space for simulation, 1/2/3 for speed
    void _handleKeyEvent(KeyEvent event) {
      if (event is! KeyDownEvent) return;

      final trackingService = ref.read(trackingServiceProvider);
      final isTracking = ref.read(userLocationProvider).isTracking;

      // Spacebar: Toggle simulation
      if (event.logicalKey == LogicalKeyboardKey.space) {
        if (isTracking) {
          trackingService.stopSimulation();
        } else {
          trackingService.startSimulation();
          // Move map to Railway Station (start point)
          _mapController.move(const LatLng(26.9208, 75.7866), 13);
        }
      }
      // Key "1": 1x speed (normal)
      else if (event.logicalKey == LogicalKeyboardKey.digit1 && isTracking) {
        trackingService.setSpeed(1);
      }
      // Key "2": 2x speed
      else if (event.logicalKey == LogicalKeyboardKey.digit2 && isTracking) {
        trackingService.setSpeed(2);
      }
      // Key "3": 3x speed
      else if (event.logicalKey == LogicalKeyboardKey.digit3 && isTracking) {
        trackingService.setSpeed(3);
      }
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        _handleKeyEvent(event);
        return KeyEventResult.handled;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // RepaintBoundary optimization
            RepaintBoundary(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: _initialZoom,
                  minZoom: 4,
                  maxZoom: 18,
                  // India bounds - prevents panning outside India
                  // maxBounds: LatLngBounds(
                  //   const LatLng(6.0, 68.0),   // Southwest
                  //   const LatLng(35.5, 97.5),  // Northeast
                  // ),
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                    enableScrollWheel: true,
                    pinchZoomThreshold: 0.3,
                  ),
                  onMapReady: () {
                    setState(() {
                      _mapReady = true;
                    });
                    // Move to user location if available
                    if (_userLocation != null) {
                      _mapController.move(_userLocation!, 10);
                    }
                  },
                  onPositionChanged: (position, hasGesture) {
                    // Detect current state based on map center
                    final center = position.center;
                    final zoom = position.zoom;
                    if (center != null && zoom != null && zoom > 7) {
                      final newState =
                          _detectState(center.latitude, center.longitude);
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
                    setState(() {
                      _currentZoom = position.zoom ?? _currentZoom;
                    });
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
                    tileProvider: CancellableNetworkTileProvider(),
                  ),
                  // Show individual zones when zoomed in, clusters when zoomed out
                  if (_currentZoom >= _clusterZoomThreshold) ...[
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
                      ],
                    ),
                  ] else ...[
                    // Show city clusters when zoomed out
                    MarkerLayer(
                      markers: MockZones.getCityClusters().map((cluster) {
                        return Marker(
                          point: LatLng(cluster.centerLat, cluster.centerLng),
                          width: 60,
                          height: 60,
                          child: GestureDetector(
                            onTap: () {
                              // Zoom into the city
                              if (_mapReady) {
                                _mapController.move(
                                  LatLng(cluster.centerLat, cluster.centerLng),
                                  10,
                                );
                              }
                            },
                            child: _buildClusterMarker(cluster),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  // User Location Marker (always visible)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                            userLocation.latitude, userLocation.longitude),
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
                          child: const Icon(Icons.navigation,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              color:
                                  _isDarkMode ? Colors.white : Colors.black87),
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
                          _buildHeaderAction(
                              Icons.my_location,
                              _mapReady
                                  ? () => _mapController.move(_initialCenter, 5)
                                  : () {}),
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
                    onTap: _mapReady
                        ? () {
                            final currentZoom = _mapController.camera.zoom;
                            if (currentZoom < 18) {
                              _mapController.move(
                                _mapController.camera.center,
                                currentZoom + 1,
                              );
                            }
                          }
                        : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isDarkMode ? Colors.black87 : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
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
                    onTap: _mapReady
                        ? () {
                            final currentZoom = _mapController.camera.zoom;
                            if (currentZoom > 4) {
                              _mapController.move(
                                _mapController.camera.center,
                                currentZoom - 1,
                              );
                            }
                          }
                        : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isDarkMode ? Colors.black87 : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12)),
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

            // Zone Warning Widget - Top Left with gradient fade and animation
            if (appState.showWarning && appState.warningMessage != null)
              Positioned(
                top: 120,
                left: 0,
                child: _AnimatedZoneWarning(
                  key: ValueKey(
                      appState.warningZoneId ?? appState.warningMessage),
                  message: appState.warningMessage!,
                  zoneType: appState.warningZoneType ?? 'caution',
                  onDismiss: () {
                    ref.read(appStateProvider.notifier).hideWarning();
                  },
                ),
              ),

            // Zones Toggle Button - Bottom Right
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() => _isPanelExpanded = !_isPanelExpanded);
                },
                backgroundColor: AppColors.brandPurple,
                child: Icon(
                  _isPanelExpanded ? Icons.close : Icons.layers_rounded,
                  color: Colors.white,
                ),
              ),
            ),

            // Animated Zones Panel - Right Side
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              right: 16,
              // If expanded, bottom is 24 (padding). If collapsed, hide below screen.
              bottom:
                  _isPanelExpanded ? 24 : -MediaQuery.of(context).size.height,
              top: _isPanelExpanded ? 24 : MediaQuery.of(context).size.height,
              child: _buildZonesOverlay(_getVisibleZones(zones)),
            ),
          ],
        ),
      ), // Close Scaffold
    ); // Close Focus
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

  /// Build cluster marker for city-level view
  Widget _buildClusterMarker(CityCluster cluster) {
    Color color;
    switch (cluster.dominantType.toLowerCase()) {
      case 'danger':
        color = AppColors.dangerZone;
        break;
      case 'caution':
        color = AppColors.cautionZone;
        break;
      case 'safe':
      default:
        color = AppColors.safeZone;
        break;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Main circle
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              cluster.cityName.length > 3
                  ? cluster.cityName.substring(0, 3).toUpperCase()
                  : cluster.cityName.toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ),
        // Zone count badge
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1),
            ),
            child: Text(
              '${cluster.zoneCount}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
        ),
      ],
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

  Widget _buildZonesOverlay(List<Zone> zones) {
    return RepaintBoundary(
        child: Container(
      width: 380, // Slightly wider for better card layout
      // Height defined by parent AnimatedPositioned
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brandSurface.withOpacity(0.95), // Themed background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12, // Reduced from 20 for performance
            offset: const Offset(-4, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Places',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22, // Larger, more prominent title
                  color: AppColors.brandPurple, // Theme Purple
                  letterSpacing: -0.5,
                ),
              ),
              // Close/Minimize button
              Material(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: () => setState(() => _isPanelExpanded = false),
                  borderRadius: BorderRadius.circular(30),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.close_rounded, color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${zones.length} locations nearby',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Scrollable Zone Content
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: zones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                // Wrap items in RepaintBoundary if list is long/complex,
                // but usually the list itself being in RepaintBoundary (via parent) is enough.
                // Keeping it simple here.
                return _buildAestheticPlaceCard(zones[index]);
              },
            ),
          ),
        ],
      ),
    ));
  }

  /// Build aesthetic place card for sidebar
  Widget _buildAestheticPlaceCard(Zone zone) {
    // Determine status color/icon
    final Color statusColor = zone.type.zoneColor;
    final IconData statusIcon = zone.type == 'danger'
        ? Icons.warning_amber_rounded
        : zone.type == 'caution'
            ? Icons.info_outline_rounded
            : Icons.check_circle_outline_rounded;

    return InkWell(
      onTap: () => _showZoneDetails(zone),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border:
              Border.all(color: AppColors.brandLightPurple.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Placeholder (Visual aesthetic)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(statusIcon, color: statusColor, size: 28),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    zone.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  // Status Badge
                  if (zone.type != 'safe') ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: statusColor.withOpacity(0.2), width: 1),
                      ),
                      child: Text(
                        zone.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated zone warning widget with fade in/out effect
class _AnimatedZoneWarning extends StatefulWidget {
  final String message;
  final String zoneType;
  final VoidCallback onDismiss;

  const _AnimatedZoneWarning({
    super.key,
    required this.message,
    required this.zoneType,
    required this.onDismiss,
  });

  @override
  State<_AnimatedZoneWarning> createState() => _AnimatedZoneWarningState();
}

class _AnimatedZoneWarningState extends State<_AnimatedZoneWarning> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Fade in immediately
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _opacity = 1.0);
    });

    // Start fade out after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _opacity = 0.0);
    });

    // Call onDismiss after fade out completes (2.5 seconds total)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get color based on zone type
    Color zoneColor;
    IconData zoneIcon;
    switch (widget.zoneType.toLowerCase()) {
      case 'danger':
        zoneColor = AppColors.dangerZone;
        zoneIcon = Icons.warning_amber_rounded;
        break;
      case 'safe':
        zoneColor = AppColors.safeZone;
        zoneIcon = Icons.check_circle_outline;
        break;
      case 'caution':
      default:
        zoneColor = AppColors.cautionZone;
        zoneIcon = Icons.info_outline;
        break;
    }

    // Get 35% of screen width for the gradient fade
    final screenWidth = MediaQuery.of(context).size.width;
    final gradientWidth = screenWidth * 0.35;

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: gradientWidth,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              zoneColor.withOpacity(0.95),
              zoneColor.withOpacity(0.8),
              zoneColor.withOpacity(0.4),
              zoneColor.withOpacity(0.0),
            ],
            stops: const [0.0, 0.5, 0.8, 1.0],
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              zoneIcon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
