import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_dialog.dart';
import '../models/transit_vehicle.dart';
import '../services/mock_transit_service.dart';
import '../services/transit_api_service.dart';

class TransitTrackerScreen extends StatefulWidget {
  const TransitTrackerScreen({super.key});

  @override
  State<TransitTrackerScreen> createState() => _TransitTrackerScreenState();
}

class _TransitTrackerScreenState extends State<TransitTrackerScreen> {
  final MapController _mapController = MapController();

  final MockTransitService _mockService = MockTransitService();
  final TransitApiService _apiService = TransitApiService();

  List<TransitVehicle> _vehicles = [];
  StreamSubscription<List<TransitVehicle>>? _vehicleSubscription;

  // Selected Route State
  String? _selectedVehicleId;
  TransitRoute? _selectedRoute;

  // Initial position (Delhi)
  static const LatLng _initialCenter = LatLng(28.6139, 77.2090);

  StreamSubscription<QuerySnapshot>? _reportsSubscription;
  bool _isSheetExpanded = false;

  // Search State
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  List<String> _suggestedCities = [];
  bool _isLoadingData = true;
  double _currentZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _loadData(); // Fetch API data

    // Start simulation (will use API routes once loaded, or default)
    _mockService.startSimulation();
    _vehicleSubscription = _mockService.vehiclesStream.listen((vehicles) {
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
        });
      }
    });

    _listenToReports();
  }

  Future<void> _loadData() async {
    // 1. Fetch Cities for suggestions
    final cities = await _apiService.fetchCities();

    // 2. Fetch Routes to populate map
    final routes = await _apiService.fetchAllRoutes();

    if (mounted) {
      setState(() {
        _suggestedCities = cities;
        _isLoadingData = false;
      });
      // Feed routes into mock service
      _mockService.inputRoutes(routes);
    }
  }

  // Filter Logic: Matches Route Name OR City
  List<TransitVehicle> get _filteredVehicles {
    if (_searchQuery.isEmpty) return _vehicles;

    final query = _searchQuery.toLowerCase().trim();

    // 1. Handle "Source to Destination" search
    if (query.contains(' to ')) {
      final parts = query.split(' to ');
      if (parts.length >= 2) {
        final start = parts[0].trim();
        final end = parts[1].trim();
        if (start.isNotEmpty && end.isNotEmpty) {
          return _vehicles.where((v) {
            // Check if vehicle route matches both points
            final routeLower = v.routeName.toLowerCase();
            return routeLower.contains(start) && routeLower.contains(end);
          }).toList();
        }
      }
    }

    // 2. Standard Search
    return _vehicles.where((v) {
      final matchRoute = v.routeName.toLowerCase().contains(query) ||
          v.agency.toLowerCase().contains(query) ||
          v.name.toLowerCase().contains(query);

      final matchCity = v.city != null && v.city!.toLowerCase().contains(query);

      return matchRoute || matchCity;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _reportsSubscription?.cancel();
    _vehicleSubscription?.cancel();
    _mockService.stopSimulation();
    _mapController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Report submitted: ${result['type']}"),
            backgroundColor: Colors.green),
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
            onTap: () {
              _deselect();
              FocusScope.of(context).unfocus();
            },
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: 12,
                  onPositionChanged: (pos, hasGesture) {
                    if (pos.zoom != null && pos.zoom != _currentZoom) {
                      setState(() => _currentZoom = pos.zoom!);
                    }
                  },
                  interactionOptions:
                      const InteractionOptions(flags: InteractiveFlag.all)),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                  subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                ),
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
                if (_selectedRoute != null && _selectedVehicleId != null)
                  MarkerLayer(
                    markers: _getNextStops(
                            _vehicles
                                .firstWhere((v) => v.id == _selectedVehicleId),
                            _selectedRoute!)
                        .map((stop) => Marker(
                              point: stop.position,
                              width: 20,
                              height: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.black, width: 4)),
                              ),
                            ))
                        .toList(),
                  ),
                MarkerLayer(
                  // Hide ALL markers when zoomed out (< 10), unless searching or vehicle selected
                  markers: (_currentZoom < 10.0 &&
                          _searchQuery.isEmpty &&
                          _selectedVehicleId == null)
                      ? []
                      : _filteredVehicles.map((v) => _buildMarker(v)).toList(),
                ),
              ],
            ),
          ),

          // Premium Search Bar - Glassmorphism Style
          Positioned(
            top: 20,
            left: 20,
            width: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF9C27B0).withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  final query = textEditingValue.text.toLowerCase();

                  // Check if user is explicitly searching for long-distance routes
                  final isLongDistanceSearch = query.contains('train') ||
                      query.contains('rail') ||
                      query.contains('express') ||
                      query.contains('rajdhani') ||
                      query.contains('shatabdi') ||
                      query.contains('duronto') ||
                      query.contains(' to '); // "Mumbai to Delhi" pattern

                  // Get matching cities
                  final matchingCities = _suggestedCities
                      .where((city) => city.toLowerCase().contains(query))
                      .toList();

                  // Get matching routes - filter by transit type
                  final matchingRoutes = _vehicles
                      .where((v) {
                        final nameMatches =
                            v.routeName.toLowerCase().contains(query);
                        // If searching long-distance, include trains
                        // Otherwise, only show local transit (bus, metro, tram)
                        if (isLongDistanceSearch) {
                          return nameMatches;
                        } else {
                          return nameMatches && v.type != TransitType.train;
                        }
                      })
                      .map((v) => v.routeName)
                      .toSet()
                      .toList();

                  // Combine and limit to 6 suggestions
                  final suggestions = <String>{
                    ...matchingCities.take(2),
                    ...matchingRoutes.take(5),
                  }.take(6).toList();

                  return suggestions;
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        constraints: const BoxConstraints(maxHeight: 280),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.grey[850]!,
                              Colors.grey[900]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF9C27B0).withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              final isCity = _suggestedCities.contains(option);
                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    border: index < options.length - 1
                                        ? Border(
                                            bottom: BorderSide(
                                              color: Colors.grey[800]!,
                                              width: 0.5,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isCity
                                              ? const Color(0xFF9C27B0)
                                                  .withOpacity(0.2)
                                              : Colors.cyanAccent
                                                  .withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isCity
                                              ? Icons.location_city
                                              : Icons.route,
                                          color: isCity
                                              ? const Color(0xFF9C27B0)
                                              : Colors.cyanAccent,
                                          size: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onSelected: (String selection) {
                  setState(() {
                    _searchQuery = selection;
                  });
                  if (_filteredVehicles.isNotEmpty) {
                    _mapController.move(_filteredVehicles.first.position, 12);
                  }
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onEditingComplete) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    onSubmitted: (val) {
                      setState(() => _searchQuery = val);
                      if (_filteredVehicles.isNotEmpty) {
                        _mapController.move(
                            _filteredVehicles.first.position, 12);
                      }
                    },
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: _isLoadingData
                          ? "Loading..."
                          : "Search city or route...",
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                controller.clear();
                                setState(() => _searchQuery = "");
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 14,
                                ),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      isDense: true,
                    ),
                  );
                },
              ),
            ),
          ),

          // Report Button - Only visible when menu is CLOSED
          if (_selectedVehicleId != null && !_isSheetExpanded)
            Positioned(
              bottom: 170,
              right: 20,
              child: FloatingActionButton(
                heroTag: "report_btn",
                backgroundColor: Colors.redAccent,
                child: const Icon(Icons.report_problem, color: Colors.white),
                onPressed: _onReportPressed,
              ),
            ),

          // Round FAB Button with Spin Animation
          Positioned(
            bottom: 100,
            right: 20,
            child: AnimatedRotation(
              turns: _isSheetExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton(
                heroTag: "transit_btn",
                backgroundColor: const Color(0xFF9C27B0), // Purple
                child: Icon(
                  _isSheetExpanded ? Icons.close : Icons.directions_transit,
                  color: Colors.white,
                ),
                onPressed: () =>
                    setState(() => _isSheetExpanded = !_isSheetExpanded),
              ),
            ),
          ),

          // Bottom Slide-Up Panel (35% height)
          Builder(
            builder: (context) {
              final distance = const Distance();
              final sourceList = _filteredVehicles;
              List<TransitVehicle> nearbyVehicles;

              if (_selectedVehicleId != null) {
                final selectedVehicle =
                    _vehicles.firstWhere((v) => v.id == _selectedVehicleId);
                nearbyVehicles = sourceList
                    .where((v) =>
                        v.id != selectedVehicle.id &&
                        distance.as(LengthUnit.Kilometer, v.position,
                                selectedVehicle.position) <
                            25)
                    .toList();
              } else if (_searchQuery.isNotEmpty) {
                nearbyVehicles = sourceList;
              } else {
                nearbyVehicles = sourceList
                    .where((v) =>
                        distance.as(LengthUnit.Kilometer, v.position,
                            _mapController.camera.center) <
                        50)
                    .toList();
              }

              final panelWidth = MediaQuery.of(context).size.width * 0.25;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top:
                    _isSheetExpanded ? 100 : MediaQuery.of(context).size.height,
                bottom: 0,
                right: 0,
                width: panelWidth,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isSheetExpanded ? 1.0 : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey[900]!,
                          Colors.black,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header with Report Button
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedVehicleId != null
                                    ? "Current Transit"
                                    : "Nearby Transit",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  if (_selectedVehicleId != null)
                                    GestureDetector(
                                      onTap: _onReportPressed,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.report_problem,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => _isSheetExpanded = false),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${nearbyVehicles.length} locations nearby",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Content
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            children: [
                              // Route Details Card (Black Theme)
                              if (_selectedRoute != null &&
                                  _selectedVehicleId != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.cyanAccent
                                                  .withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.alt_route,
                                              color: Colors.cyanAccent,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _vehicles
                                                  .firstWhere((v) =>
                                                      v.id ==
                                                      _selectedVehicleId)
                                                  .routeName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ..._getNextStops(
                                        _vehicles.firstWhere(
                                            (v) => v.id == _selectedVehicleId),
                                        _selectedRoute!,
                                      ).take(4).map((s) {
                                        final arrivalTime = DateTime.now().add(
                                            Duration(
                                                minutes: s.arrivalTimeOffset));
                                        final timeStr = s.arrivalTimeOffset == 0
                                            ? "Now"
                                            : "${arrivalTime.hour}:${arrivalTime.minute.toString().padLeft(2, '0')}";
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(
                                                  color: Colors.cyanAccent,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  s.name,
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color:
                                                      s.arrivalTimeOffset == 0
                                                          ? Colors.green
                                                          : Colors.grey[800],
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  timeStr,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                // Add "Nearby Transit" label after route card
                                const Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: Text(
                                    "Nearby Transit",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                              // Transit List Items (Purple Cards)
                              ...nearbyVehicles.take(6).map((v) {
                                IconData icon;
                                Color iconBgColor;
                                switch (v.type) {
                                  case TransitType.bus:
                                    icon = Icons.directions_bus;
                                    iconBgColor = const Color(0xFFE8F5E9);
                                    break;
                                  case TransitType.metro:
                                    icon = Icons.subway;
                                    iconBgColor = const Color(0xFFE3F2FD);
                                    break;
                                  case TransitType.train:
                                    icon = Icons.train;
                                    iconBgColor = const Color(0xFFFFF3E0);
                                    break;
                                  case TransitType.tram:
                                    icon = Icons.tram;
                                    iconBgColor = const Color(0xFFF3E5F5);
                                    break;
                                }
                                return GestureDetector(
                                  onTap: () => _selectVehicle(v),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: v.id == _selectedVehicleId
                                          ? Border.all(
                                              color: const Color(0xFF9C27B0),
                                              width: 2)
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: iconBgColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(icon,
                                              size: 20,
                                              color: const Color(0xFF6A1B9A)),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                v.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                v.routeName,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Status Badge
                                        if (v.status == VehicleStatus.delayed)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFE0B2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              "CAUTION",
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFE65100),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helpers
  Marker _buildMarker(TransitVehicle v) {
    final isSelected = v.id == _selectedVehicleId;
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
                color: v.status == VehicleStatus.delayed
                    ? Colors.red
                    : Colors.green, // Bus is Green
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4)
                ]),
            child: Center(
                child: Icon(Icons.directions_bus,
                    color: Colors.white, size: size * 0.6)));
      case TransitType.metro:
        // Metro: Diamond shape
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: 0.785398, // 45 degrees
              child: Container(
                width: size * 0.7,
                height: size * 0.7,
                decoration: BoxDecoration(
                  color: v.color ?? Colors.purple, // Default Metro Purple
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4)
                  ],
                ),
              ),
            ),
            Icon(Icons.subway, color: Colors.white, size: size * 0.5),
          ],
        );
      case TransitType.train:
        // Train: Rectangular (Landscape)
        return Container(
            width: size * 1.2, // Wider
            height: size * 0.8,
            decoration: BoxDecoration(
                color: v.color ?? Colors.indigo, // Train Indigo
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4)
                ]),
            child: Center(
                child:
                    Icon(Icons.train, color: Colors.white, size: size * 0.6)));
      case TransitType.tram:
        return Container(
            decoration: BoxDecoration(
                color: Colors.teal, // Tram Teal
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white, width: 2, style: BorderStyle.solid),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4)
                ]),
            child: Center(
                child:
                    Icon(Icons.tram, color: Colors.white, size: size * 0.6)));
    }
  }

  Widget _buildTransitListItem(TransitVehicle v) {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
        border: isSelected
            ? Border.all(color: Colors.blueAccent, width: 2)
            : Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _selectVehicle(v);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${v.agency} ${v.name}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(v.routeName,
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                // Status
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: v.status == VehicleStatus.onTime
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: v.status == VehicleStatus.onTime
                            ? Colors.green
                            : Colors.red),
                  ),
                  child: Text(
                    v.status.name == 'onTime' ? 'On Time' : 'Delayed',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: v.status == VehicleStatus.onTime
                            ? Colors.green[700]
                            : Colors.red[700]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TransitStop> _getNextStops(TransitVehicle v, TransitRoute route) {
    if (route.stops.isEmpty) return [];
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
    if (v.pathDirection == 1) {
      if (nearestIndex + 1 < route.stops.length)
        nextStops.add(route.stops[nearestIndex + 1]);
      if (nearestIndex + 2 < route.stops.length)
        nextStops.add(route.stops[nearestIndex + 2]);
    } else {
      if (nearestIndex - 1 >= 0) nextStops.add(route.stops[nearestIndex - 1]);
      if (nearestIndex - 2 >= 0) nextStops.add(route.stops[nearestIndex - 2]);
    }
    return nextStops;
  }
}
