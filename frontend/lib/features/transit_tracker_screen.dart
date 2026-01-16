import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_dialog.dart';
import '../models/transit_vehicle.dart';
import '../services/mock_transit_service.dart';
import '../services/transit_api_service.dart';
import 'animations.dart';
import 'dart:ui' as dart_ui;
import 'package:google_fonts/google_fonts.dart';

class TransitTrackerScreen extends StatefulWidget {
  const TransitTrackerScreen({super.key});

  @override
  State<TransitTrackerScreen> createState() => _TransitTrackerScreenState();
}

class _TransitTrackerScreenState extends State<TransitTrackerScreen>
    with SingleTickerProviderStateMixin {
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

  double _currentZoom = 12.0;

  // From-To Route Search State
  String _fromPlace = "";
  String _toPlace = "";
  TransitType? _selectedTransitType;
  bool _isSearchExpanded = false;
  bool _showLoadingOverlay = true; // Show loading overlay on entry

  List<String> _suggestedCities = const [
    "New Delhi",
    "Mumbai",
    "Kolkata",
    "Chennai",
    "Bangalore",
    "Hyderabad",
    "Pune",
    "Ahmedabad",
    "Jaipur",
    "Lucknow"
  ];

  @override
  void initState() {
    super.initState();
    // Use this as TickerProvider. Since we are in State class, we need SingleTickerProviderStateMixin
    // However, expanding class text is hard via replace, so we'll use a local controller approach or TickerProvider
    // Simpler: Just implement manual interpolation in a timer or use a simple flutter animation controller created on fly

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

    // Hide loading overlay after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showLoadingOverlay = false);
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
      });
      // Feed routes into mock service
      _mockService.inputRoutes(routes);
    }
  }

  List<TransitVehicle> get _filteredVehicles {
    List<TransitVehicle> result = _vehicles;

    // 1. Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();

      // Handle "Source to Destination" search
      if (query.contains(' to ')) {
        final parts = query.split(' to ');
        if (parts.length >= 2) {
          final start = parts[0].trim();
          final end = parts[1].trim();
          if (start.isNotEmpty && end.isNotEmpty) {
            result = result.where((v) {
              final routeLower = v.routeName.toLowerCase();
              return routeLower.contains(start) && routeLower.contains(end);
            }).toList();
          }
        }
      } else {
        // Standard Search
        result = result.where((v) {
          final matchRoute = v.routeName.toLowerCase().contains(query) ||
              v.agency.toLowerCase().contains(query) ||
              v.name.toLowerCase().contains(query);
          final matchCity =
              v.city != null && v.city!.toLowerCase().contains(query);
          return matchRoute || matchCity;
        }).toList();
      }
    }

    // 2. Filter by Transit Type (Global Filter)
    if (_selectedTransitType != null) {
      result = result.where((v) => v.type == _selectedTransitType).toList();
    }

    // 3. Deduplicate by ID to prevent duplicate key errors in markers
    final seenIds = <String>{};
    result = result.where((v) => seenIds.add(v.id)).toList();

    return result;
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

  // Animated Map Move
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some variables
    final latTween = Tween<double>(
        begin: _mapController.camera.center.latitude,
        end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.camera.center.longitude,
        end: destLocation.longitude);
    final zoomTween =
        Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

    // Create a controller
    final controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);

    // The animation curve
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _selectVehicle(TransitVehicle v) {
    setState(() {
      _selectedVehicleId = v.id;
      _selectedRoute = _mockService.getRoute(v.routeId);
    });
    // Smooth transition instead of jump
    _animatedMapMove(v.position, 15);
  }

  void _deselect() {
    if (_selectedVehicleId != null) {
      setState(() {
        _selectedVehicleId = null;
        _selectedRoute = null;
      });
    }
  }

  // Get destinations reachable from the selected origin
  List<String> _getToSuggestions(String from) {
    if (from.isEmpty) return [];
    final destinations = <String>{};
    for (final v in _vehicles) {
      final routeName = v.routeName.toLowerCase();
      final fromLower = from.toLowerCase();
      if (routeName.contains(fromLower)) {
        // Extract destination from route name
        final parts = v.routeName.split(' - ');
        if (parts.length >= 2) {
          // If "from" matches start, add the end
          if (parts.first.toLowerCase().contains(fromLower)) {
            destinations.add(parts.last.trim());
          }
          // If "from" matches end, add the start
          if (parts.last.toLowerCase().contains(fromLower)) {
            destinations.add(parts.first.trim());
          }
        }
      }
    }
    return destinations.take(10).toList();
  }

  // Build route search field with autocomplete
  Widget _buildRouteSearchField({
    required String label,
    required String value,
    required Function(String) onChanged,
    required List<String> suggestions,
    bool enabled = true,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[900], // Same color for both From and To
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey[700]),
          Expanded(
            child: Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return suggestions.take(6);
                }
                return suggestions
                    .where((s) => s
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()))
                    .take(6);
              },
              onSelected: onChanged,
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 250,
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.grey[850]!, Colors.grey[900]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Text(
                                option,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                if (controller.text != value) {
                  controller.text = value;
                }
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: enabled,
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: enabled ? "Enter $label" : "Enter From first",
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Show all routes dialog
  void _showAllRoutesDialog(
      BuildContext context, String fromPlace, String toPlace) {
    // Get ALL vehicles (not unique), filtered by From/To if specified
    final trainVehicles = <TransitVehicle>[];
    final busVehicles = <TransitVehicle>[];
    final metroVehicles = <TransitVehicle>[];

    for (final v in _vehicles) {
      // Filter by From/To if specified
      final routeLower = v.routeName.toLowerCase();
      final fromLower = fromPlace.toLowerCase();
      final toLower = toPlace.toLowerCase();

      bool matchesFilter = true;
      if (fromPlace.isNotEmpty || toPlace.isNotEmpty) {
        // If both are specified, route must contain both
        if (fromPlace.isNotEmpty && toPlace.isNotEmpty) {
          matchesFilter =
              routeLower.contains(fromLower) && routeLower.contains(toLower);
        } else if (fromPlace.isNotEmpty) {
          // Just From specified
          matchesFilter = routeLower.contains(fromLower);
        } else if (toPlace.isNotEmpty) {
          // Just To specified
          matchesFilter = routeLower.contains(toLower);
        }
      }

      if (!matchesFilter) continue;

      if (v.type == TransitType.train) {
        trainVehicles.add(v);
      } else if (v.type == TransitType.bus) {
        busVehicles.add(v);
      } else if (v.type == TransitType.metro) {
        metroVehicles.add(v);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "All Available Routes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Routes List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Trains Section
                    if (trainVehicles.isNotEmpty) ...[
                      _buildRouteSection("🚂 Trains (${trainVehicles.length})",
                          trainVehicles, Colors.red),
                      const SizedBox(height: 16),
                    ],
                    // Buses Section
                    if (busVehicles.isNotEmpty) ...[
                      _buildRouteSection("🚌 Buses (${busVehicles.length})",
                          busVehicles, Colors.orange),
                      const SizedBox(height: 16),
                    ],
                    // Metro Section
                    if (metroVehicles.isNotEmpty) ...[
                      _buildRouteSection("🚇 Metro (${metroVehicles.length})",
                          metroVehicles, Colors.blue),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRouteSection(
      String title, List<TransitVehicle> routes, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...routes.take(10).map((v) => GestureDetector(
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _searchQuery = v.routeName;
                });
                _selectVehicle(v);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        v.type == TransitType.train
                            ? Icons.train
                            : v.type == TransitType.bus
                                ? Icons.directions_bus
                                : Icons.subway,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${v.routeName} • ${v.agency}",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[500]),
                  ],
                ),
              ),
            )),
      ],
    );
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
                  // CartoDB Voyager (clean street map, CORS-friendly)
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  retinaMode: RetinaMode.isHighDensity(context),
                  tileProvider: CancellableNetworkTileProvider(),
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
                          _selectedVehicleId == null &&
                          _selectedTransitType == null)
                      ? []
                      : _filteredVehicles.map((v) => _buildMarker(v)).toList(),
                ),
              ],
            ),
          ),

          // Top-Left Cluster: Search Panel + Filter Chips
          Positioned(
            top: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Glass Search Panel
                SlideFadeEntry(
                  delay: const Duration(milliseconds: 200),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: dart_ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutBack,
                        width: _isSearchExpanded
                            ? MediaQuery.of(context).size.width * 0.35
                            : 50,
                        // Reduced height from 360 to 280 to fit content tightly
                        height: _isSearchExpanded ? 280 : 50,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: _isSearchExpanded
                            ? _buildExpandedSearchPanel()
                            : BouncingButton(
                                onTap: () {
                                  setState(() => _isSearchExpanded = true);
                                },
                                child: const Center(
                                  child:
                                      Icon(Icons.search, color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Filter Chips (placed below search, VERTICAL alignment)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < TransitType.values.length + 1; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SlideFadeEntry(
                          delay: Duration(milliseconds: 400 + (i * 100)),
                          direction: Axis.horizontal,
                          child: _buildFilterChip(
                              i == 0 ? null : TransitType.values[i - 1]),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Top-Right: Home Button
          Positioned(
            top: 20,
            right: 20,
            child: SlideFadeEntry(
              delay: const Duration(milliseconds: 600),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: dart_ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go('/'),
                        borderRadius: BorderRadius.circular(25),
                        child: const Center(
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
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

          // LOADING OVERLAY (Hides map loading for 1.5s)
          if (_showLoadingOverlay)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showLoadingOverlay ? 1.0 : 0.0,
              child: Container(
                color: const Color(0xFF0a0a0a),
                child: Center(
                  child: _ScrollingLoadingText(),
                ),
              ),
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

  Widget _buildExpandedSearchPanel() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text("Find Routes",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() => _isSearchExpanded = false),
            )
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildRouteSearchField(
                label: "From",
                value: _fromPlace,
                onChanged: (val) {
                  setState(() {
                    _fromPlace = val;
                    // Auto-suggest logic if needed
                  });
                },
                suggestions: _suggestedCities,
              ),
              const SizedBox(height: 10),
              _buildRouteSearchField(
                label: "To",
                value: _toPlace,
                onChanged: (val) => setState(() => _toPlace = val),
                // Basic suggestions for 'To' based on 'From' or just all cities
                suggestions: _fromPlace.isNotEmpty
                    ? _getToSuggestions(_fromPlace)
                    : _suggestedCities,
                enabled: _fromPlace.isNotEmpty,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: BouncingButton(
                      onTap: () {
                        // Logic to confirm search
                        setState(() {
                          _searchQuery = "$_fromPlace to $_toPlace";
                          _isSearchExpanded = false;
                        });
                        // Move map or filter
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text("Find Route",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BouncingButton(
                      onTap: () =>
                          _showAllRoutesDialog(context, _fromPlace, _toPlace),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        alignment: Alignment.center,
                        child: const Text("Show All",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(TransitType? type) {
    final isSelected = _selectedTransitType == type;
    final color = type == null
        ? Colors.grey
        : type == TransitType.train
            ? Colors.red
            : type == TransitType.bus
                ? Colors.orange
                : Colors.blue;

    return BouncingButton(
      onTap: () {
        setState(() {
          _selectedTransitType = isSelected ? null : type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? Colors.white : Colors.white24, width: 1.5),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type != null)
              Icon(
                  type == TransitType.train
                      ? Icons.train
                      : type == TransitType.bus
                          ? Icons.directions_bus
                          : Icons.subway,
                  color: isSelected ? Colors.white : color,
                  size: 18),
            if (type != null) const SizedBox(width: 8),
            Text(
              type == null ? "All" : type.name.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrolling ASCII loading animation for entry overlay
class _ScrollingLoadingText extends StatefulWidget {
  @override
  State<_ScrollingLoadingText> createState() => _ScrollingLoadingTextState();
}

class _ScrollingLoadingTextState extends State<_ScrollingLoadingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final String _pattern = '===+=--+===+=--+===+=--+';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scrolling pattern
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = (_controller.value * _pattern.length).toInt();
            final displayText =
                _pattern.substring(offset) + _pattern.substring(0, offset);
            return Text(
              displayText,
              style: GoogleFonts.spaceMono(
                fontSize: 24,
                color: const Color(0xFF00F0FF),
                letterSpacing: 2,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'INITIALIZING TRANSIT',
          style: GoogleFonts.spaceMono(
            fontSize: 12,
            color: Colors.white24,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
