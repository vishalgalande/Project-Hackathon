import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../app/providers.dart';
import '../models/zone.dart';

/// Page 2: Real Map View (OpenStreetMap)
/// Professional standard map styling with crisp zone overlays
class CommandCenterPage extends ConsumerStatefulWidget {
  const CommandCenterPage({super.key});
  
  @override
  ConsumerState<CommandCenterPage> createState() => _CommandCenterPageState();
}

class _CommandCenterPageState extends ConsumerState<CommandCenterPage> {
  final MapController _mapController = MapController();
  
  // Delhi coordinates (Central)
  final LatLng _initialCenter = const LatLng(28.6448, 77.2167);
  final double _initialZoom = 12.0;

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(zonesProvider);
    
    // Create Polygon overlays for zones
    // Converting circular radius to simple square/rectangle for the "grid" look requested
    final zonePolygons = zones.map((zone) {
      return Polygon(
        points: _createSquareZone(LatLng(zone.centerLat, zone.centerLng), zone.radius * 2.5),
        color: zone.type.zoneColor.withOpacity(0.15),
        borderColor: zone.type.zoneColor,
        borderStrokeWidth: 2,
        isFilled: true,
        label: zone.name,
        labelStyle: TextStyle(
          color: Colors.black.withOpacity(0.7),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('SafeZone Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // Center on initial location for demo
              _mapController.move(_initialCenter, 13);
            },
          ),
          IconButton(
            icon: const Icon(Icons.layers_outlined),
            onPressed: () {
              // Toggle layers (could switch map styles)
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // REAL OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              // Restrict to Delhi area for demo
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(28.4, 76.8),
                  const LatLng(28.9, 77.5),
                ),
              ),
              onTap: (_, __) => _hideZoneDetails(),
            ),
            children: [
              // OpenStreetMap Standard Tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.safezone',
                subdomains: const ['a', 'b', 'c'],
              ),
              
              // Zone Overlays (as squares matching reference image)
              PolygonLayer(
                polygons: zonePolygons,
              ),
              
              // Marker Layer for Zone Centers
              MarkerLayer(
                markers: zones.map((zone) {
                  return Marker(
                    point: LatLng(zone.centerLat, zone.centerLng),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showZoneDetails(zone),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: zone.type.zoneColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          zone.type.toLowerCase() == 'danger'
                              ? Icons.warning
                              : zone.type.toLowerCase() == 'caution'
                                  ? Icons.priority_high
                                  : Icons.check,
                          color: zone.type.zoneColor,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          
          // Attribution (Required for OSM)
          const Positioned(
            bottom: 4,
            right: 4,
            child: Text(
              '© OpenStreetMap contributors',
              style: TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ),
          
          // Bottom info panel
          _buildBottomPanel(zones),
        ],
      ),
    );
  }

  // Helper to create a square polygon around a center point
  List<LatLng> _createSquareZone(LatLng center, double sizeMeters) {
    // Approx conversation: 1 degree lat ~= 111km
    final offset = sizeMeters / 111000; 
    
    return [
      LatLng(center.latitude + offset, center.longitude - offset), // Top-left
      LatLng(center.latitude + offset, center.longitude + offset), // Top-right
      LatLng(center.latitude - offset, center.longitude + offset), // Bottom-right
      LatLng(center.latitude - offset, center.longitude - offset), // Bottom-left
    ];
  }
  
  void _showZoneDetails(Zone zone) {
    context.push('/intel/${zone.id}');
  }
  
  void _hideZoneDetails() {
    // Logic to hide details if showing inline overlay
  }
  
  Widget _buildBottomPanel(List<Zone> zones) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Nearby Zones',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Zone list
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: zones.length,
                itemBuilder: (context, index) {
                  final zone = zones[index];
                  return _buildZoneCard(zone);
                },
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildZoneCard(Zone zone) {
    final zoneColor = zone.type.zoneColor;
    
    return GestureDetector(
      onTap: () => _showZoneDetails(zone),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored header
              Container(
                height: 6,
                width: double.infinity,
                color: zoneColor,
              ),
              
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          zone.type.toLowerCase() == 'danger' ? Icons.warning_amber : Icons.verified_user_outlined,
                          size: 16,
                          color: zoneColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            zone.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: zoneColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      zone.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      zone.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.arrow_forward, size: 12, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
