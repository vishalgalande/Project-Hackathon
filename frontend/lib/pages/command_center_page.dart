import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/theme.dart';
import '../app/providers.dart';
import '../models/zone.dart';

/// Page 2: Real Map View (OpenStreetMap) - EXPANDED DATASET
class CommandCenterPage extends ConsumerStatefulWidget {
  const CommandCenterPage({super.key});

  @override
  ConsumerState<CommandCenterPage> createState() => _CommandCenterPageState();
}

class _CommandCenterPageState extends ConsumerState<CommandCenterPage> {
  final MapController _mapController = MapController();
  // Center of India (approximately)
  final LatLng _initialCenter = const LatLng(20.5937, 78.9629);
  final double _initialZoom = 5.0; // Zoom out to see all India
  bool _isDarkMode = true; // Always use dark mode to match landing page

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(zonesProvider);

    final zonePolygons = zones.map((zone) {
      return Polygon(
        points: _createSquareZone(
            LatLng(zone.centerLat, zone.centerLng), zone.radius * 2.0),
        // Adjust opacity based on mode
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

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              minZoom: 4, // Allow zoom out to see all India
              maxZoom: 18,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all, // Enable all gestures including pinch zoom
              ),
              onTap: (_, __) => {},
            ),
            children: [
              TileLayer(
                // Always use dark map to match landing page theme
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.example.safezone',
                subdomains: const ['a', 'b', 'c'],
              ),
              PolygonLayer(polygons: zonePolygons),
              MarkerLayer(
                markers: zones.map((zone) {
                  return Marker(
                    point: LatLng(zone.centerLat, zone.centerLng),
                    width: 36,
                    height: 36,
                    child: GestureDetector(
                      onTap: () => _showZoneDetails(zone),
                      child: _buildMarkerIcon(zone.type),
                    ),
                  );
                }).toList(),
              ),
            ],
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
                            color: AppColors.bgCard,
                            border: Border.all(color: AppColors.border),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)
                            ]),
                        child: const Icon(Icons.arrow_back,
                            color: AppColors.textPrimary),
                      ),
                    ),

                    // Boxed Title
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)
                          ]),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined,
                              color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'SafeZone',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
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
                      color: AppColors.bgCard,
                      border: Border.all(color: AppColors.border),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.textPrimary,
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
                      color: AppColors.bgCard,
                      border: Border.all(color: AppColors.border),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sheet
          _buildBottomPanel(zones),
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
            color: AppColors.bgCard,
            border: Border.all(color: AppColors.border),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
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

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

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
                      color: AppColors.bgCard,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(30), // Pill shape
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.3),
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
                              color: AppColors.textPrimary),
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
                              color: AppColors.textPrimary),
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
                        color: AppColors.bgCard,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
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
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      zone.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
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
                                              style: GoogleFonts.inter(
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
                                  size: 20, color: AppColors.textSecondary),
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
