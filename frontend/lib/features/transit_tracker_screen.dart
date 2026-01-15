import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_dialog.dart';
import '../models/transit_vehicle.dart';
import '../services/mock_transit_service.dart';

class TransitTrackerScreen extends StatefulWidget {
  const TransitTrackerScreen({super.key});

  @override
  State<TransitTrackerScreen> createState() => _TransitTrackerScreenState();
}

class _TransitTrackerScreenState extends State<TransitTrackerScreen> {
  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final MockTransitService _mockService = MockTransitService();
  List<TransitVehicle> _vehicles = [];
  StreamSubscription<List<TransitVehicle>>? _vehicleSubscription;

  // Selected Route State
  String? _selectedVehicleId;
  TransitRoute? _selectedRoute;

  // Initial position (Delhi)
  static const LatLng _initialCenter = LatLng(28.6139, 77.2090);

  StreamSubscription<QuerySnapshot>? _reportsSubscription;
  bool _isSheetExpanded = false;

  @override
  void initState() {
    super.initState();
    _mockService.startSimulation();
    _vehicleSubscription = _mockService.vehiclesStream.listen((vehicles) {
      setState(() {
        _vehicles = vehicles;
      });
    });

    _listenToReports();
    _sheetController.addListener(() {
      final expanded = _sheetController.size > 0.15;
      if (expanded != _isSheetExpanded) {
        setState(() => _isSheetExpanded = expanded);
      }
    });

    // Tap outside to clear selection
  }

  @override
  void dispose() {
    _reportsSubscription?.cancel();
    _vehicleSubscription?.cancel();
    _mockService.stopSimulation();
    _mapController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _listenToReports() {
    // Listen to reports created in the last 15 minutes
    final cutoff = DateTime.now().subtract(const Duration(minutes: 15));

    _reportsSubscription = FirebaseFirestore.instance
        .collection('reports')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(cutoff))
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          final vehicleId = data['vehicle_id'];

          if (vehicleId != null) {
            // In a real app we would filter this from the stream or backend
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      '⚠️ Alert: Vehicle $vehicleId reported. Re-routing...')),
            );
          }
        }
      }
    });
  }

  void _onReportPressed() async {
    final result = await showDialog(
      context: context,
      builder: (context) => ReportDialog(initialVehicleId: _selectedVehicleId),
    );

    if (result != null) {
      // Optimistic UI update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Report submitted: ${result['type']}"),
          backgroundColor: Colors.green,
        ),
      );

      try {
        await FirebaseFirestore.instance.collection('reports').add({
          'vehicle_id': result['vehicle_id'] ?? 'unknown',
          'report_type': result['type'],
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Error submitting report: $e");
      }
    }
  }

  void _toggleSheet() {
    if (_sheetController.size < 0.2) {
      _sheetController.animateTo(0.5,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _sheetController.animateTo(0.08,
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  void _selectVehicle(TransitVehicle v) {
    setState(() {
      _selectedVehicleId = v.id;
      _selectedRoute = _mockService.getRoute(v.routeId);
    });

    _mapController.move(v.position, 15);
  }

  void _deselect() {
    if (_selectedVehicleId != null) {
      setState(() {
        _selectedVehicleId = null;
        _selectedRoute = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: _deselect, // Tap map to clear
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: 12,
                  interactionOptions:
                      InteractionOptions(flags: InteractiveFlag.all)),
              children: [
                TileLayer(
                  // Google Hybrid (Satellite + Roads)
                  urlTemplate:
                      'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                  subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                ),

                // Route Polyline
                if (_selectedRoute != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _selectedRoute!.polyline,
                        color: _selectedRoute!.color ?? Colors.blueAccent,
                        strokeWidth: 5.0,
                      ),
                    ],
                  ),

                // Route Stops (Next 2 Only)
                if (_selectedRoute != null && _selectedVehicleId != null)
                  MarkerLayer(
                    markers: _getNextStops(
                            _vehicles
                                .firstWhere((v) => v.id == _selectedVehicleId),
                            _selectedRoute!)
                        .map((stop) => Marker(
                              point: stop.position,
                              width: 20, // Slightly larger for visibility
                              height: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.black, // High contrast
                                        width: 4)),
                              ),
                            ))
                        .toList(),
                  ),

                // Vehicle Markers
                MarkerLayer(
                  markers: _vehicles.map((v) => _buildMarker(v)).toList(),
                ),
              ],
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.go('/'),
            ),
          ),

          // Report Button
          Positioned(
            top: 40,
            right: 20,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              icon: const Icon(Icons.report_problem, color: Colors.white),
              label:
                  const Text("Report", style: TextStyle(color: Colors.white)),
              onPressed: _onReportPressed,
            ),
          ),

          // Bottom Sheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.08, // Start minimized
            minChildSize: 0.08,
            maxChildSize: 0.8,
            snap: true,
            snapSizes: const [0.08, 0.5, 0.8],
            builder: (context, scrollController) {
              // Filter vehicles based on context
              List<TransitVehicle> nearbyVehicles;
              final distance = const Distance();

              if (_selectedVehicleId != null) {
                // If a vehicle is selected, show only vehicles in the same region (within 25km)
                // This ensures if you look at Kolkata, you only see Kolkata vehicles
                final selectedVehicle =
                    _vehicles.firstWhere((v) => v.id == _selectedVehicleId);
                nearbyVehicles = _vehicles
                    .where((v) =>
                        v.id != selectedVehicle.id &&
                        distance.as(LengthUnit.Kilometer, v.position,
                                selectedVehicle.position) <
                            25)
                    .toList();
              } else {
                // Default: Show vehicles near the map center
                nearbyVehicles = _vehicles
                    .where((v) =>
                        distance.as(LengthUnit.Kilometer, v.position,
                            _mapController.camera.center) <
                        50)
                    .toList();
              }

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    // Handle / Arrow Toggle
                    GestureDetector(
                      onTap: _toggleSheet,
                      child: Container(
                        color: Colors.transparent, // Hit area
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            // Single Black Arrow
                            Icon(
                              _isSheetExpanded
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              color: Colors.black, // Clear visibility
                              size: 32,
                            ),
                            // Hide text when minimized to keep it clean
                            if (_isSheetExpanded)
                              Text(
                                "Show Nearby Transit",
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    if (_selectedRoute != null &&
                        _selectedVehicleId != null) ...[
                      // Active Route Details (Next Stops) - DARK THEME
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.grey[900], // Dark Background
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                            border: Border.all(color: Colors.grey[800]!)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.alt_route, color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                const Text("Upcoming Stops",
                                    style: TextStyle(
                                        color: Colors.white, // White text
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Next Stops Only
                            ..._getNextStops(
                                    _vehicles.firstWhere(
                                        (v) => v.id == _selectedVehicleId),
                                    _selectedRoute!)
                                .map((s) {
                              final arrivalTime = DateTime.now()
                                  .add(Duration(minutes: s.arrivalTimeOffset));
                              final timeString =
                                  "${arrivalTime.hour}:${arrivalTime.minute.toString().padLeft(2, '0')}";

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    // Timeline dot
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                          color: Colors.cyanAccent, // High vis
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Text(s.name,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14))),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: s.arrivalTimeOffset == 0
                                                ? Colors.green
                                                : Colors.grey[800],
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Text(
                                            s.arrivalTimeOffset == 0
                                                ? "Now"
                                                : timeString,
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)))
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Text(
                      "Nearby Transit",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 16),

                    if (nearbyVehicles.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("No vehicles nearby...",
                            style: TextStyle(color: Colors.grey)),
                      ),

                    ...nearbyVehicles.map((v) => _buildTransitListItem(v)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(TransitVehicle v) {
    final isSelected = v.id == _selectedVehicleId;
    // Scale up if selected
    final size = isSelected ? 55.0 : 40.0;

    return Marker(
      key: Key(v.id),
      width: size,
      height: size,
      point: v.position,
      child: GestureDetector(
        onTap: () => _selectVehicle(v),
        child: _getMarkerIcon(v, size),
      ),
    );
  }

  Widget _getMarkerIcon(TransitVehicle v, double size) {
    switch (v.type) {
      case TransitType.bus:
        return Container(
          decoration: BoxDecoration(
            color:
                v.status == VehicleStatus.delayed ? Colors.red : Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Center(
            child: Icon(Icons.directions_bus,
                color: Colors.white, size: size * 0.6),
          ),
        );

      case TransitType.metro:
        // Diamond shape
        return Transform.rotate(
          angle: 0.785398, // 45 degrees
          child: Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              color: v.color ?? Colors.blue,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4)
              ],
            ),
            child: Transform.rotate(
              angle: -0.785398, // Counter rotate icon
              child: Icon(Icons.subway, color: Colors.white, size: size * 0.5),
            ),
          ),
        );

      case TransitType.train:
        // Rectangular
        return Container(
          width: size,
          height: size * 0.6,
          decoration: BoxDecoration(
            color: v.color ?? Colors.blue[800],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Center(
              child: Icon(Icons.train, color: Colors.white, size: size * 0.5)),
        );

      case TransitType.tram:
        return Container(
          decoration: BoxDecoration(
            color: Colors.purple,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Icon(Icons.tram, color: Colors.white, size: size * 0.6),
          ),
        );
    }
  }

  Widget _buildTransitListItem(TransitVehicle v) {
    if (!_isSheetExpanded &&
        _sheetController.isAttached &&
        _sheetController.size < 0.15) {
      return const SizedBox.shrink();
    }

    IconData icon;
    Color color;
    switch (v.type) {
      case TransitType.bus:
        icon = Icons.directions_bus;
        color = Colors.green;
        break;
      case TransitType.metro:
        icon = Icons.subway;
        color = v.color ?? Colors.blue;
        break;
      case TransitType.train:
        icon = Icons.train;
        color = Colors.blue[900]!;
        break;
      case TransitType.tram:
        icon = Icons.tram;
        color = Colors.purple;
        break;
    }

    if (v.status == VehicleStatus.delayed) color = Colors.red;

    final isSelected = v.id == _selectedVehicleId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isSelected
          ? Colors.blue.withOpacity(0.05)
          : Colors.grey[50], // Highlight if selected
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected ? BorderSide(color: Colors.blue) : BorderSide.none),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text('${v.agency} ${v.name}',
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black)),
        subtitle:
            Text(v.routeName, style: const TextStyle(color: Colors.black54)),
        trailing: Text(v.status.name,
            style: TextStyle(
                color: v.status == VehicleStatus.onTime
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold)),
        onTap: () {
          _selectVehicle(v);
          // Open sheet slightly if minimized to show details
          if (_sheetController.size < 0.2) {
            _sheetController.animateTo(0.5,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
          }
        },
      ),
    );
  }

  List<TransitStop> _getNextStops(TransitVehicle v, TransitRoute route) {
    if (route.stops.isEmpty) return [];

    // Simple proximity logic: Find closest stop
    int nearestIndex = -1;
    double minDistance = double.infinity;
    final distance = const Distance();

    for (int i = 0; i < route.stops.length; i++) {
      final d =
          distance.as(LengthUnit.Meter, v.position, route.stops[i].position);
      if (d < minDistance) {
        minDistance = d;
        nearestIndex = i;
      }
    }

    if (nearestIndex == -1) return [];

    List<TransitStop> nextStops = [];

    // Direct logic based on pathDirection
    if (v.pathDirection == 1) {
      // Forward: Next stops are nearest + 1, nearest + 2
      // If we are essentially AT the nearest stop (very close), we should show it?
      // Or if we passed it? For simplicity, let's assume nearest is "current/just reached"
      // So next is nearest + 1.
      if (nearestIndex + 1 < route.stops.length)
        nextStops.add(route.stops[nearestIndex + 1]);
      if (nearestIndex + 2 < route.stops.length)
        nextStops.add(route.stops[nearestIndex + 2]);
    } else {
      // Backward: Next stops are nearest - 1, nearest - 2
      if (nearestIndex - 1 >= 0) nextStops.add(route.stops[nearestIndex - 1]);
      if (nearestIndex - 2 >= 0) nextStops.add(route.stops[nearestIndex - 2]);
    }

    return nextStops;
  }
}
