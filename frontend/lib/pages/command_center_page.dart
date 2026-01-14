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
  final LatLng _initialCenter = const LatLng(28.6300, 77.2200);
  final double _initialZoom = 13.0;
  bool _isDarkMode = false; // Add state for map style

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(zonesProvider);
    
    final zonePolygons = zones.map((zone) {
      return Polygon(
        points: _createSquareZone(LatLng(zone.centerLat, zone.centerLng), zone.radius * 2.0),
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
      extendBodyBehindAppBar: true, 
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              minZoom: 11,
              maxZoom: 18,
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(28.45, 76.9),
                  const LatLng(28.80, 77.5),
                ),
              ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isDarkMode ? Colors.black87.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 8)
                          ]
                        ),
                        child: Icon(Icons.arrow_back, color: _isDarkMode ? Colors.white : Colors.black87),
                      ),
                    ),
                    
                    // Boxed Title
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isDarkMode ? Colors.black87.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 8)
                        ]
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, color: AppColors.safeZone, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'SafeZone', 
                            style: GoogleFonts.orbitron(
                              color: _isDarkMode ? Colors.white : Colors.black87, 
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
                        _buildHeaderAction(Icons.my_location, () => _mapController.move(_initialCenter, 14)),
                        const SizedBox(width: 12),
                        _buildHeaderAction(
                          _isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round, 
                          () {
                            setState(() {
                              _isDarkMode = !_isDarkMode;
                            });
                          }
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8)
          ]
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
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
            color: Colors.black26, 
            blurRadius: 4, 
            offset: const Offset(0, 2)
          )
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
  
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  Widget _buildBottomPanel(List<Zone> zones) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.15, // Start Visible (Peek)
      minChildSize: 0.05,     // BUT allow hiding it (Option available)
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.05, 0.15, 0.9], // Hidden, Peek, Full
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.transparent, // User requested removing white background
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
                    _sheetController.animateTo(0.15, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); // Unhide
                  } else if (_sheetController.size > 0.5) {
                    _sheetController.animateTo(0.15, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); // Minimize
                  } else {
                    _sheetController.animateTo(0.9, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); // Maximize
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black, // User requested background black ONLY on arrows
                    borderRadius: BorderRadius.circular(30), // Pill shape
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Wrap content height/width
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Up Arrow
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white), // White Icon
                        onPressed: () {
                          if (_sheetController.size < 0.1) {
                            _sheetController.animateTo(0.15, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                          } else {
                            _sheetController.animateTo(0.9, duration: const Duration(milliseconds: 500), curve: Curves.elasticOut);
                          }
                        },
                        tooltip: 'Expand',
                      ),
                      const SizedBox(width: 16), // Tighter Space
                      // Down Arrow
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white), // White Icon
                        onPressed: () {
                             if (_sheetController.size > 0.5) {
                               _sheetController.animateTo(0.15, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                             } else {
                               _sheetController.animateTo(0.05, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                             }
                        },
                        tooltip: 'Minimize',
                      ),
                    ],
                  ),
                ),
              ),
              
              ...zones.map((zone) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), // Semi-transparent for legibility
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: ListTile(
                  onTap: () => _showZoneDetails(zone),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: zone.type.zoneColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      zone.type == 'danger' ? Icons.warning_amber_rounded :
                      zone.type == 'caution' ? Icons.priority_high_rounded :
                      Icons.verified_user_rounded,
                      color: zone.type.zoneColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    zone.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(zone.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
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
  
  Widget _buildZoneCard(Zone zone) {
    final color = zone.type.zoneColor;
    
    return GestureDetector(
      onTap: () => _showZoneDetails(zone),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        zone.type == 'danger' ? Icons.warning_amber_rounded :
                        zone.type == 'caution' ? Icons.priority_high_rounded :
                        Icons.verified_user_rounded,
                        size: 14,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        zone.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    zone.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'View Details ->',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
