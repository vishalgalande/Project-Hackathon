import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/transit_vehicle.dart';

class MockTransitService {
  final Random _random = Random();
  final List<TransitVehicle> _vehicles = [];
  Timer? _movementTimer;
  final StreamController<List<TransitVehicle>> _vehiclesController =
      StreamController<List<TransitVehicle>>.broadcast();

  Stream<List<TransitVehicle>> get vehiclesStream => _vehiclesController.stream;

  // Cache for Routes
  final Map<String, TransitRoute> _routes = {};

  void startSimulation({List<TransitRoute>? initialRoutes}) {
    if (initialRoutes != null && initialRoutes.isNotEmpty) {
      for (var route in initialRoutes) {
        _routes[route.id] = route;
      }
    } else {
      _initializeRoutes(); // Fallback to hardcoded if API fails
    }

    _generateInitialVehicles();

    // faster update for smooth "movement" along detailed paths
    _movementTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _updateVehiclePositions();
    });
  }

  void inputRoutes(List<TransitRoute> routes) {
    for (var route in routes) {
      _routes[route.id] = route;
    }
    // Optionally spawn vehicles for these new routes immediately
    _spawnVehiclesForNewRoutes(routes);
  }

  void _spawnVehiclesForNewRoutes(List<TransitRoute> routes) {
    for (var route in routes) {
      // Spawn 5-8 vehicles per route for more density
      for (int i = 0; i < 6; i++) {
        _spawnVehicleOnRoute(route.id, route, i);
      }
    }
  }

  void stopSimulation() {
    _movementTimer?.cancel();
    _vehiclesController.close();
  }

  TransitRoute? getRoute(String? routeId) {
    if (routeId == null) return null;
    if (_routes.containsKey(routeId)) return _routes[routeId];
    return _generateGenericRoute(routeId);
  }

  // ... (keeping route definitions) ...

  void _spawnVehicleOnRoute(String routeId, TransitRoute route, int index) {
    if (route.polyline.length < 2) return;

    // Start at a random fractional segment
    double startIndex = _random.nextDouble() * (route.polyline.length - 1);
    int direction = 1;

    TransitType type = TransitType.bus;
    String agency = "Agency";
    String name = "Vehicle";

    type = route.type;

    // Train name lists for variety
    final trainNames = [
      'Rajdhani',
      'Shatabdi',
      'Duronto',
      'Garib Rath',
      'Jan Shatabdi',
      'Superfast',
      'Mail',
      'Express',
      'Tejas',
      'Vande Bharat'
    ];
    final busNames = [
      'Volvo',
      'Sleeper',
      'AC Seater',
      'Semi-Sleeper',
      'Shivneri',
      'Deluxe',
      'Express',
      'Super Fast',
      'Ordinary'
    ];

    final metroNames = [
      'Blue Line',
      'Yellow Line',
      'Red Line',
      'Green Line',
      'Violet Line',
      'Magneta Line',
      'Pink Line',
      'Orange Line',
      'Aqua Line'
    ];

    // Generate unique names based on route and index
    if (type == TransitType.metro) {
      agency = "Metro Rail";
      name =
          "${metroNames[_random.nextInt(metroNames.length)]} Train #${index + 1}";
    } else if (type == TransitType.train) {
      agency = "Indian Railways";
      // Assign different train names based on index
      String trainName = trainNames[index % trainNames.length];
      name = "$trainName #${index + 1}";
    } else if (type == TransitType.tram) {
      agency = "CTC";
      name = "Tram ${100 + _random.nextInt(100)}";
    } else {
      // Bus Logic
      String busName = busNames[index % busNames.length];
      name = "$busName ${_random.nextInt(999)}";

      // Agency variation randomly
      int agencyIndex = _random.nextInt(6);
      if (agencyIndex == 0)
        agency = "MSRTC";
      else if (agencyIndex == 1)
        agency = "KSRTC";
      else if (agencyIndex == 2)
        agency = "DTC";
      else if (agencyIndex == 3)
        agency = "BMTC";
      else if (agencyIndex == 4)
        agency = "BEST";
      else
        agency = "State Transport";
    }

    // Specific route naming for popular routes
    if (routeId.contains("delhi_yellow")) {
      agency = "DMRC";
      name = "Yellow Line M${index + 1}";
    } else if (routeId.contains("train_mumbai_pune_deccan")) {
      agency = "Central Railway";
      name = "Deccan Express ${12123 + index}";
    } else if (routeId.contains("train_mumbai_pune_shatabdi")) {
      agency = "Central Railway";
      name = "Mumbai-Pune Shatabdi ${index + 1}";
    } else if (routeId.contains("train_delhi_mumbai")) {
      agency = "Western Railway";
      final names = ['Rajdhani Express', 'August Kranti', 'Duronto Express'];
      name = names[index % names.length];
    } else if (routeId.contains("train_delhi_kolkata")) {
      agency = "Eastern Railway";
      final names = [
        'Rajdhani Express',
        'Purushottam Express',
        'Poorva Express'
      ];
      name = names[index % names.length];
    } else if (routeId.contains("train_mumbai_bangalore")) {
      agency = "South Central Railway";
      final names = ['Udyan Express', 'Chalukya Express', 'Karnataka Express'];
      name = names[index % names.length];
    } else if (routeId.contains("train_bangalore_chennai")) {
      agency = "Southern Railway";
      final names = [
        'Shatabdi Express',
        'Brindavan Express',
        'Lalbagh Express'
      ];
      name = names[index % names.length];
    } else if (routeId.contains("train_delhi_lucknow")) {
      agency = "Northern Railway";
      final names = ['Lucknow Shatabdi', 'Lucknow Mail', 'Gomti Express'];
      name = names[index % names.length];
    } else if (routeId.contains("train_chennai_hyderabad")) {
      agency = "South Central Railway";
      final names = ['Charminar Express', 'Godavari Express'];
      name = names[index % names.length];
    } else if (routeId.contains("train_kolkata_patna")) {
      agency = "Eastern Railway";
      final names = ['Rajdhani Express', 'Vikramshila Express'];
      name = names[index % names.length];
    } else if (routeId.contains("train_ahmedabad_mumbai")) {
      agency = "Western Railway";
      final names = ['Shatabdi Express', 'Karnavati Express', 'Gujarat Mail'];
      name = names[index % names.length];
    } else if (routeId.contains("bus_mumbai_pune")) {
      agency = "MSRTC Shivneri";
      final names = ['Shivneri Volvo', 'Ashwamedh', 'Shivshahi'];
      name = names[index % names.length];
    } else if (routeId.contains("bus_delhi")) {
      agency = "Delhi Transport";
      final names = ['Volvo AC', 'Super Deluxe', 'Express'];
      name = names[index % names.length];
    } else if (routeId.contains("bus_bangalore")) {
      agency = "KSRTC";
      final names = ['Airavat Club', 'Airavat Gold', 'Rajahamsa'];
      name = names[index % names.length];
    } else if (routeId.contains("bus_chennai")) {
      agency = "SETC";
      final names = ['Ultra Deluxe', 'AC Sleeper', 'Super Deluxe'];
      name = names[index % names.length];
    } else if (routeId.contains("bus_hyderabad")) {
      agency = "TSRTC";
      final names = ['Garuda Plus', 'Indra AC', 'Super Luxury'];
      name = names[index % names.length];
    } else if (routeId.contains("bus_kolkata")) {
      agency = "NBSTC/SBSTC";
      final names = ['Rocket', 'Volvo', 'AC Deluxe'];
      name = names[index % names.length];
    }

    // Init position via interpolation
    int lowerIndex = startIndex.floor();
    int upperIndex = (lowerIndex + 1).clamp(0, route.polyline.length - 1);
    double t = startIndex - lowerIndex;

    LatLng p1 = route.polyline[lowerIndex];
    LatLng p2 = route.polyline[upperIndex];
    double lat = p1.latitude + (p2.latitude - p1.latitude) * t;
    double lng = p1.longitude + (p2.longitude - p1.longitude) * t;

    _vehicles.add(TransitVehicle(
        id: '${routeId}_${_random.nextInt(9999)}',
        name: name,
        routeName: route.stops.isNotEmpty
            ? "${route.stops.first.name} - ${route.stops.last.name}"
            : "Route",
        type: type,
        agency: agency,
        status: VehicleStatus.onTime,
        position: LatLng(lat, lng),
        heading: 0,
        routeId: routeId,
        color: route.color,
        currentPathIndex: startIndex,
        pathDirection: direction,
        city: route.city, // Pass city/country from route
        country: route.country));
  }

  double _calculateHeading(LatLng start, LatLng end) {
    double dLon = (end.longitude - start.longitude);
    double y = sin(dLon) * cos(end.latitude);
    double x = cos(start.latitude) * sin(end.latitude) -
        sin(start.latitude) * cos(end.latitude) * cos(dLon);
    double brng = atan2(y, x);
    return (brng * 180 / pi + 360) % 360;
  }

  // --- Simulation Implementation ---

  void _updateVehiclePositions() {
    for (int i = 0; i < _vehicles.length; i++) {
      var v = _vehicles[i];
      if (v.routeId == null || !_routes.containsKey(v.routeId)) continue;
      final route = _routes[v.routeId]!;
      if (route.polyline.length < 2) continue;

      // Move by fractional delta
      // 0.02 * 2 updates/sec = 0.04 segments/sec => 25 seconds per segment
      // 0.001 * 2 updates/sec = 0.002 segments/sec => 500 seconds per segment (Ultra Slow / Crawling)
      double delta = 0.001;
      double nextIndex = v.currentPathIndex + (v.pathDirection * delta);
      int newDirection = v.pathDirection;

      if (nextIndex >= route.polyline.length - 1) {
        nextIndex = route.polyline.length - 1.001;
        newDirection = -1;
      } else if (nextIndex < 0) {
        nextIndex = 0.001;
        newDirection = 1;
      }

      int lower = nextIndex.floor();
      int upper = (lower + 1).clamp(0, route.polyline.length - 1);
      double t = nextIndex - lower;

      LatLng p1 = route.polyline[lower];
      LatLng p2 = route.polyline[upper];

      double newLat = p1.latitude + (p2.latitude - p1.latitude) * t;
      double newLng = p1.longitude + (p2.longitude - p1.longitude) * t;
      LatLng nextPos = LatLng(newLat, newLng);

      // Only re-calc heading if moved significantly
      double heading = v.heading;
      if (t > 0.01 && t < 0.99) {
        // Avoid jitter near nodes
        heading = _calculateHeading(p1, p2);
        if (newDirection == -1) heading = (heading + 180) % 360;
      }

      _vehicles[i] = v.copyWith(
          position: nextPos,
          currentPathIndex: nextIndex,
          pathDirection: newDirection,
          heading: heading);
    }
    _vehiclesController.add(List.from(_vehicles));
  }

  // --- Route Data Definition ---
  // High fidelity paths for key demos
  void _initializeRoutes() {
    // 1. Delhi Metro Yellow Line (Detailed Track Geometry)
    _routes['delhi_yellow'] = TransitRoute(
        id: 'delhi_yellow',
        city: 'Delhi',
        type: TransitType.metro,
        color: Colors.yellow[700],
        polyline: [
          LatLng(28.7919, 77.1290), // Samaypur Badli
          LatLng(28.7800, 77.1280), LatLng(28.7700, 77.1270),
          LatLng(28.7600, 77.1250), // Jahangirpuri
          LatLng(28.7500, 77.1230), LatLng(28.7400, 77.1200),
          LatLng(28.7300, 77.1180), LatLng(28.7200, 77.1150), // GTB Nagar
          LatLng(28.7041, 77.1025), // Vishwavidyalaya
          LatLng(28.6980, 77.2080), // Vidhan Sabha (Curve)
          LatLng(28.6940, 77.2150), // Civil Lines
          LatLng(28.6700, 77.2250), // Kashmere Gate
          LatLng(28.6650, 77.2280), LatLng(28.6610, 77.2276),
          LatLng(28.6550, 77.2250), // Chandni Chowk
          LatLng(28.6500, 77.2200), // Chawri Bazar
          LatLng(28.6400, 77.2180), // New Delhi
          LatLng(28.6328, 77.2197), // Rajiv Chowk
          LatLng(28.6250, 77.2180), // Patel Chowk
          LatLng(28.6200, 77.2150), // Central Secretariat
          LatLng(28.6000, 77.2120), // Udyog Bhawan
          LatLng(28.5900, 77.2100), // Jor Bagh
          LatLng(28.5800, 77.2080), // INA
          LatLng(28.5679, 77.2100), // AIIMS
          LatLng(28.5600, 77.2080), // Green Park
          LatLng(28.5500, 77.2050), // Hauz Khas
          LatLng(28.5400, 77.2000), // Malviya Nagar
          LatLng(28.5300, 77.1950), // Saket
          LatLng(28.5200, 77.1900), // Qutab Minar
          LatLng(28.5000, 77.1600), // Chhatarpur
          LatLng(28.4800, 77.1000), // MG Road
          LatLng(28.4700, 77.0800), // IFFCO Chowk
          LatLng(28.4595, 77.0725), // HUDA City Centre
        ],
        stops: [
          TransitStop(
              name: "Samaypur Badli",
              position: LatLng(28.7919, 77.1290),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Rajiv Chowk",
              position: LatLng(28.6328, 77.2197),
              arrivalTimeOffset: 35),
          TransitStop(
              name: "HUDA City Centre",
              position: LatLng(28.4595, 77.0725),
              arrivalTimeOffset: 65),
        ]);

    // 2. DTC 502 (Detailed Road Path)
    _routes['dtc_502'] = const TransitRoute(
        id: 'dtc_502',
        city: 'Delhi',
        color: Colors.green,
        polyline: [
          LatLng(28.5175, 77.1856), // Mehrauli
          LatLng(28.5250, 77.1900), LatLng(28.5350, 77.1950), // Qutub
          LatLng(28.5400, 77.2000), // IIT
          LatLng(28.5500, 77.2050), LatLng(28.5679, 77.2100), // AIIMS
          LatLng(28.5800, 77.2150), LatLng(28.5900, 77.2200),
          LatLng(28.6000, 77.2300), LatLng(28.6080, 77.2380), // India Gate
          LatLng(28.6200, 77.2400), LatLng(28.6300, 77.2410),
          LatLng(28.6562, 77.2410), // Old Delhi
        ],
        stops: [
          TransitStop(
              name: "Mehrauli",
              position: LatLng(28.5175, 77.1856),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Saket",
              position: LatLng(28.5250, 77.2000),
              arrivalTimeOffset: 10),
          TransitStop(
              name: "Green Park",
              position: LatLng(28.5580, 77.2020),
              arrivalTimeOffset: 18),
          TransitStop(
              name: "AIIMS",
              position: LatLng(28.5679, 77.2100),
              arrivalTimeOffset: 25),
          TransitStop(
              name: "Safdarjung",
              position: LatLng(28.5900, 77.2100),
              arrivalTimeOffset: 35),
          TransitStop(
              name: "Udyog Bhawan",
              position: LatLng(28.6100, 77.2150),
              arrivalTimeOffset: 45),
          TransitStop(
              name: "Old Delhi",
              position: LatLng(28.6562, 77.2410),
              arrivalTimeOffset: 55),
        ]);

    // 3. Mumbai Western Line (Straight-ish Rail with curves)
    _routes['mumbai_western'] = TransitRoute(
        id: 'mumbai_western',
        city: 'Mumbai',
        type: TransitType.train,
        color: Colors.blue[900],
        polyline: [
          LatLng(18.9322, 72.8264), // Churchgate
          LatLng(18.9500, 72.8200), LatLng(18.9696, 72.8193), // Mumbai Central
          LatLng(19.0000, 72.8300), LatLng(19.0178, 72.8478), // Dadar
          LatLng(19.0400, 72.8480), LatLng(19.0607, 72.8499), // Bandra
          LatLng(19.0800, 72.8500), LatLng(19.1136, 72.8697), // Andheri
          LatLng(19.1500, 72.8600), LatLng(19.2300, 72.8550), // Borivali
          LatLng(19.3000, 72.8400), LatLng(19.4563, 72.8118), // Virar
        ],
        stops: [
          TransitStop(
              name: "Churchgate",
              position: LatLng(18.9322, 72.8264),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Marine Lines",
              position: LatLng(18.9450, 72.8230),
              arrivalTimeOffset: 3),
          TransitStop(
              name: "Grant Road",
              position: LatLng(18.9600, 72.8160),
              arrivalTimeOffset: 6),
          TransitStop(
              name: "Mumbai Central",
              position: LatLng(18.9696, 72.8193),
              arrivalTimeOffset: 10),
          TransitStop(
              name: "Lower Parel",
              position: LatLng(18.9950, 72.8300),
              arrivalTimeOffset: 15),
          TransitStop(
              name: "Dadar",
              position: LatLng(19.0178, 72.8478),
              arrivalTimeOffset: 20),
          TransitStop(
              name: "Bandra",
              position: LatLng(19.0607, 72.8499),
              arrivalTimeOffset: 30),
          TransitStop(
              name: "Andheri",
              position: LatLng(19.1136, 72.8697),
              arrivalTimeOffset: 45),
          TransitStop(
              name: "Malad",
              position: LatLng(19.1860, 72.8480),
              arrivalTimeOffset: 52),
          TransitStop(
              name: "Borivali",
              position: LatLng(19.2300, 72.8550),
              arrivalTimeOffset: 60),
          TransitStop(
              name: "Virar",
              position: LatLng(19.4563, 72.8118),
              arrivalTimeOffset: 85),
        ]);

    // 4. Delhi Blue Line (Curves)
    _routes['delhi_blue'] = const TransitRoute(
        id: 'delhi_blue',
        city: 'Delhi',
        type: TransitType.metro,
        color: Colors.blue,
        polyline: [
          LatLng(28.6280, 77.0600), // Dwarka 21
          LatLng(28.6200, 77.0900), LatLng(28.6150, 77.1500), // Janakpuri
          LatLng(28.6400, 77.1600), LatLng(28.6500, 77.1800), // Karo Bagh
          LatLng(28.6328, 77.2197), // Rajiv Chowk
          LatLng(28.6250, 77.2500), LatLng(28.6200, 77.3000), // Mayur Vihar
          LatLng(28.5800, 77.3100), LatLng(28.5700, 77.3200) // Noida
        ],
        stops: [
          TransitStop(
              name: "Dwarka Sec 21",
              position: LatLng(28.6280, 77.0600),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Janakpuri West",
              position: LatLng(28.6150, 77.1500),
              arrivalTimeOffset: 15),
          TransitStop(
              name: "Rajendra Place",
              position: LatLng(28.6420, 77.1780),
              arrivalTimeOffset: 25),
          TransitStop(
              name: "RK Ashram",
              position: LatLng(28.6380, 77.2100),
              arrivalTimeOffset: 30),
          TransitStop(
              name: "Rajiv Chowk",
              position: LatLng(28.6328, 77.2197),
              arrivalTimeOffset: 35),
          TransitStop(
              name: "Barakhamba Road",
              position: LatLng(28.6300, 77.2250),
              arrivalTimeOffset: 38),
          TransitStop(
              name: "Mandi House",
              position: LatLng(28.6260, 77.2340),
              arrivalTimeOffset: 42),
          TransitStop(
              name: "Mayur Vihar",
              position: LatLng(28.6250, 77.2500),
              arrivalTimeOffset: 50),
          TransitStop(
              name: "Noida City Center",
              position: LatLng(28.5700, 77.3200),
              arrivalTimeOffset: 65)
        ]);

    // 5. DTC Mudrika (Ring Road)
    _routes['dtc_mudrika'] = const TransitRoute(
        id: 'dtc_mudrika',
        city: 'Delhi',
        color: Colors.green,
        polyline: [
          LatLng(28.5679, 77.2100), // AIIMS
          LatLng(28.5700, 77.1800), LatLng(28.5800, 77.1600), // Moti Bagh
          LatLng(28.6000, 77.1400), LatLng(28.6300, 77.1200), // Naraina
          LatLng(28.6700, 77.1300), LatLng(28.7000, 77.1500) // Azadpur
        ],
        stops: [
          TransitStop(
              name: "AIIMS",
              position: LatLng(28.5679, 77.2100),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Azadpur",
              position: LatLng(28.7000, 77.1500),
              arrivalTimeOffset: 45)
        ]);

    // 6. Mumbai-Pune Shivneri (Expressway Curves)
    _routes['mum_pune'] =
        const TransitRoute(id: 'mum_pune', color: Colors.purple, polyline: [
      LatLng(19.0178, 72.8478), // Dadar
      LatLng(19.0400, 72.9500), LatLng(19.0300, 73.0600), // Vashi/Panvel
      LatLng(18.9000, 73.2000), LatLng(18.8000, 73.3000), // Ghats
      LatLng(18.7500, 73.4000), // Lonavala
      LatLng(18.6500, 73.6000), LatLng(18.5204, 73.8567) // Pune
    ], stops: [
      TransitStop(
          name: "Mumbai",
          position: LatLng(19.0178, 72.8478),
          arrivalTimeOffset: 0),
      TransitStop(
          name: "Pune",
          position: LatLng(18.5204, 73.8567),
          arrivalTimeOffset: 180)
    ]);

    // 7. Bengaluru Airport (Bellary Rd)
    _routes['bengaluru_airport'] = const TransitRoute(
        id: 'bengaluru_airport',
        city: 'Bengaluru',
        color: Colors.orange,
        polyline: [
          LatLng(12.9716, 77.5946), // Majestic
          LatLng(12.9900, 77.5900), LatLng(13.0100, 77.5850), // Malleshwaram
          LatLng(13.0300, 77.5900), // Hebbal
          LatLng(13.0800, 77.6000), // Yelahanka
          LatLng(13.1500, 77.6500), LatLng(13.1986, 77.7066) // Airport
        ],
        stops: [
          TransitStop(
              name: "Majestic",
              position: LatLng(12.9716, 77.5946),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Airport",
              position: LatLng(13.1986, 77.7066),
              arrivalTimeOffset: 60)
        ]);

    // 8. Bengaluru Purple (East-West)
    _routes['bengaluru_purple'] = const TransitRoute(
        id: 'bengaluru_purple',
        city: 'Bengaluru',
        color: Colors.deepPurple,
        polyline: [
          LatLng(12.9750, 77.7300), // Whitefield
          LatLng(12.9800, 77.6800), LatLng(12.9800, 77.6400), // Indiranagar
          LatLng(12.9750, 77.6100), LatLng(12.9716, 77.5946), // Majestic
          LatLng(12.9600, 77.5500), LatLng(12.9500, 77.5000) // Mysore Rd
        ],
        stops: [
          TransitStop(
              name: "Whitefield",
              position: LatLng(12.9750, 77.7300),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Indiranagar",
              position: LatLng(12.9780, 77.6400),
              arrivalTimeOffset: 15),
          TransitStop(
              name: "MG Road",
              position: LatLng(12.9750, 77.6100),
              arrivalTimeOffset: 20),
          TransitStop(
              name: "Majestic",
              position: LatLng(12.9716, 77.5946),
              arrivalTimeOffset: 30),
          TransitStop(
              name: "Vijayanagar",
              position: LatLng(12.9650, 77.5300),
              arrivalTimeOffset: 45)
        ]);

    // 9. Jaipur Pink Line
    _routes['jaipur_pink'] = const TransitRoute(
        id: 'jaipur_pink',
        city: 'Jaipur',
        type: TransitType.metro,
        color: Colors.pink,
        polyline: [
          LatLng(26.8800, 75.7500), // Mansarovar
          LatLng(26.8900, 75.7700), LatLng(26.9000, 75.7900), // Station
          LatLng(26.9150, 75.8000), LatLng(26.9200, 75.8100), // Sindhi Camp
          LatLng(26.9250, 75.8250) // Badi Chaupar
        ],
        stops: [
          TransitStop(
              name: "Mansarovar",
              position: LatLng(26.8800, 75.7500),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Railway Station",
              position: LatLng(26.9000, 75.7900),
              arrivalTimeOffset: 10),
          TransitStop(
              name: "Sindhi Camp",
              position: LatLng(26.9150, 75.8000),
              arrivalTimeOffset: 15),
          TransitStop(
              name: "Chandpole",
              position: LatLng(26.9200, 75.8150),
              arrivalTimeOffset: 20),
          TransitStop(
              name: "Badi Chaupar",
              position: LatLng(26.9250, 75.8250),
              arrivalTimeOffset: 25)
        ]);

    // 10. Ahmedabad BRTS
    _routes['ahmedabad_brts'] = const TransitRoute(
        id: 'ahmedabad_brts',
        city: 'Ahmedabad',
        color: Colors.orangeAccent,
        polyline: [
          LatLng(23.0600, 72.5800), // RTO
          LatLng(23.0500, 72.5700), LatLng(23.0400, 72.5600), // Shivranjani
          LatLng(23.0300, 72.5550), LatLng(23.0200, 72.5500), // Nehrunagar
          LatLng(23.0100, 72.5700), LatLng(23.0000, 72.5900) // Maninagar
        ],
        stops: [
          TransitStop(
              name: "RTO",
              position: LatLng(23.0600, 72.5800),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Shivranjani",
              position: LatLng(23.0400, 72.5600),
              arrivalTimeOffset: 15),
          TransitStop(
              name: "Nehrunagar",
              position: LatLng(23.0200, 72.5500),
              arrivalTimeOffset: 25),
          TransitStop(
              name: "Maninagar",
              position: LatLng(23.0000, 72.5900),
              arrivalTimeOffset: 40)
        ]);

    // 11. Chennai Blue Line
    _routes['chennai_blue'] = const TransitRoute(
        id: 'chennai_blue',
        city: 'Chennai',
        type: TransitType.metro,
        color: Colors.blue,
        polyline: [
          LatLng(12.9800, 80.1600), // Airport
          LatLng(12.9900, 80.1800), LatLng(13.0000, 80.2000), // Guindy
          LatLng(13.0200, 80.2300), LatLng(13.0400, 80.2500), // Teynampet
          LatLng(13.0600, 80.2600), LatLng(13.0800, 80.2700) // Central
        ],
        stops: [
          TransitStop(
              name: "Airport",
              position: LatLng(12.9800, 80.1600),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Guindy",
              position: LatLng(13.0080, 80.2150),
              arrivalTimeOffset: 10),
          TransitStop(
              name: "Nandanam",
              position: LatLng(13.0300, 80.2400),
              arrivalTimeOffset: 15),
          TransitStop(
              name: "Thousand Lights",
              position: LatLng(13.0550, 80.2550),
              arrivalTimeOffset: 22),
          TransitStop(
              name: "Chennai Central",
              position: LatLng(13.0800, 80.2700),
              arrivalTimeOffset: 30)
        ]);

    // 12. Hyderabad Red Line
    _routes['hyd_red'] = const TransitRoute(
        id: 'hyd_red',
        city: 'Hyderabad',
        type: TransitType.metro,
        color: Colors.red,
        polyline: [
          LatLng(17.4950, 78.3600), // Miyapur
          LatLng(17.4700, 78.3900), LatLng(17.4400, 78.4400), // Ameerpet
          LatLng(17.4200, 78.4600), LatLng(17.3900, 78.4800), // Nampally
          LatLng(17.3700, 78.5200), LatLng(17.3500, 78.5500) // LB Nagar
        ],
        stops: [
          TransitStop(
              name: "Miyapur",
              position: LatLng(17.4950, 78.3600),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Kukatpally",
              position: LatLng(17.4800, 78.3800),
              arrivalTimeOffset: 8),
          TransitStop(
              name: "Ameerpet",
              position: LatLng(17.4350, 78.4450),
              arrivalTimeOffset: 20),
          TransitStop(
              name: "Nampally",
              position: LatLng(17.3900, 78.4700),
              arrivalTimeOffset: 35),
          TransitStop(
              name: "LB Nagar",
              position: LatLng(17.3500, 78.5500),
              arrivalTimeOffset: 50)
        ]);

    // 13. Lucknow Red Line
    _routes['lucknow_red'] = const TransitRoute(
        id: 'lucknow_red',
        city: 'Lucknow',
        type: TransitType.metro,
        color: Colors.redAccent,
        polyline: [
          LatLng(26.7600, 80.8800), // Amausi
          LatLng(26.7900, 80.8850), LatLng(26.8100, 80.8900), // Charbagh
          LatLng(26.8300, 80.9200), LatLng(26.8500, 80.9400), // Hazratganj
          LatLng(26.8700, 80.9700), LatLng(26.8800, 80.9900) // Munshipulia
        ],
        stops: [
          TransitStop(
              name: "Amausi (Airport)",
              position: LatLng(26.7600, 80.8800),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Charbagh",
              position: LatLng(26.8300, 80.8900),
              arrivalTimeOffset: 15),
          TransitStop(
              name: "Hazratganj",
              position: LatLng(26.8500, 80.9400),
              arrivalTimeOffset: 25),
          TransitStop(
              name: "Indira Nagar",
              position: LatLng(26.8650, 80.9800),
              arrivalTimeOffset: 30),
          TransitStop(
              name: "Munshipulia",
              position: LatLng(26.8800, 80.9900),
              arrivalTimeOffset: 35)
        ]);

    // 14. Kolkata Metro Blue
    _routes['kolkata_blue'] = const TransitRoute(
        id: 'kolkata_blue',
        city: 'Kolkata',
        type: TransitType.metro,
        color: Colors.blue,
        polyline: [
          LatLng(22.6500, 88.3700), // Dakshineswar
          LatLng(22.6300, 88.3650), LatLng(22.6000, 88.3600), // Dum Dum
          LatLng(22.5800, 88.3550), LatLng(22.5600, 88.3500), // Esplanade
          LatLng(22.5300, 88.3450), LatLng(22.5100, 88.3400), // Kalighat
          LatLng(22.4700, 88.3900) // Kavi Subhash
        ],
        stops: [
          TransitStop(
              name: "Dakshineswar",
              position: LatLng(22.6500, 88.3700),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Dum Dum",
              position: LatLng(22.6200, 88.3650),
              arrivalTimeOffset: 12),
          TransitStop(
              name: "Shyambazar",
              position: LatLng(22.6000, 88.3650),
              arrivalTimeOffset: 18),
          TransitStop(
              name: "Esplanade",
              position: LatLng(22.5650, 88.3500),
              arrivalTimeOffset: 25),
          TransitStop(
              name: "Park Street",
              position: LatLng(22.5500, 88.3500),
              arrivalTimeOffset: 28),
          TransitStop(
              name: "Kalighat",
              position: LatLng(22.5200, 88.3450),
              arrivalTimeOffset: 35),
          TransitStop(
              name: "Kavi Subhash",
              position: LatLng(22.4700, 88.3900),
              arrivalTimeOffset: 45)
        ]);

    // --- INDIAN RAILWAYS MAJOR CORRIDORS ---

    // 15. Delhi - Howrah (via Kanpur, Prayagraj)
    _routes['rail_del_how'] = const TransitRoute(
        id: 'rail_del_how',
        type: TransitType.train,
        color: Colors.indigo, // Classic Railway Blue
        polyline: [
          LatLng(28.6562, 77.2410), // New Delhi
          LatLng(28.0000, 78.0000), // Aligarh
          LatLng(27.1767, 78.0081), // Agra (Tundla)
          LatLng(26.4499, 80.3319), // Kanpur Central
          LatLng(25.4358, 81.8463), // Prayagraj (Allahabad)
          LatLng(25.2800, 83.1000), // Mirzapur
          LatLng(25.2600, 83.1200), // Pt. Deen Dayal Upadhyaya (Mughalsarai)
          LatLng(24.7914, 85.0002), // Gaya
          LatLng(23.8143, 86.4412), // Dhanbad
          LatLng(23.6900, 86.9400), // Asansol
          LatLng(23.2324, 87.8615), // Bardhaman
          LatLng(22.5800, 88.3300), // Howrah
        ],
        stops: [
          TransitStop(
              name: "New Delhi",
              position: LatLng(28.6562, 77.2410),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Kanpur Central",
              position: LatLng(26.4499, 80.3319),
              arrivalTimeOffset: 300),
          TransitStop(
              name: "Prayagraj",
              position: LatLng(25.4358, 81.8463),
              arrivalTimeOffset: 480),
          TransitStop(
              name: "Pt. DD Upadhyaya",
              position: LatLng(25.2600, 83.1200),
              arrivalTimeOffset: 600),
          TransitStop(
              name: "Dhanbad",
              position: LatLng(23.8143, 86.4412),
              arrivalTimeOffset: 900),
          TransitStop(
              name: "Asansol",
              position: LatLng(23.6900, 86.9400),
              arrivalTimeOffset: 960),
          TransitStop(
              name: "Howrah (Kolkata)",
              position: LatLng(22.5800, 88.3300),
              arrivalTimeOffset: 1200),
        ]);

    // 16. Delhi - Mumbai (via Kota, Vadodara) - Rajdhani Route
    _routes['rail_del_mum'] = const TransitRoute(
        id: 'rail_del_mum',
        type: TransitType.train,
        color: Colors.redAccent, // Rajdhani/August Kranti Red
        polyline: [
          LatLng(28.5800, 77.2400), // Nizamuddin
          LatLng(27.4924, 77.6737), // Mathura
          LatLng(27.2000, 77.5000), // Bharatpur
          LatLng(25.1800, 75.8300), // Kota
          LatLng(23.3300, 75.0300), // Ratlam
          LatLng(22.3072, 73.1812), // Vadodara
          LatLng(21.1702, 72.8311), // Surat
          LatLng(19.9975, 72.7200), // Palghar
          LatLng(19.2300, 72.8500), // Borivali
          LatLng(18.9696, 72.8193), // Mumbai Central
        ],
        stops: [
          TransitStop(
              name: "Delhi Nizamuddin",
              position: LatLng(28.5800, 77.2400),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Kota",
              position: LatLng(25.1800, 75.8300),
              arrivalTimeOffset: 360),
          TransitStop(
              name: "Ratlam",
              position: LatLng(23.3300, 75.0300),
              arrivalTimeOffset: 540),
          TransitStop(
              name: "Vadodara",
              position: LatLng(22.3072, 73.1812),
              arrivalTimeOffset: 720),
          TransitStop(
              name: "Surat",
              position: LatLng(21.1702, 72.8311),
              arrivalTimeOffset: 840),
          TransitStop(
              name: "Mumbai Central",
              position: LatLng(18.9696, 72.8193),
              arrivalTimeOffset: 960),
        ]);

    // 17. Mumbai - Chennai (via Pune, Solapur)
    _routes['rail_mum_chn'] = const TransitRoute(
        id: 'rail_mum_chn',
        type: TransitType.train,
        color: Colors.blueGrey,
        polyline: [
          LatLng(18.9322, 72.8264), // CSMT
          LatLng(19.0178, 72.8478), // Dadar
          LatLng(18.5204, 73.8567), // Pune
          LatLng(18.0000, 75.0000), // Daund
          LatLng(17.6599, 75.9064), // Solapur
          LatLng(17.3297, 76.8343), // Kalaburagi
          LatLng(17.0600, 76.9900), // Wadi
          LatLng(15.8281, 77.5000), // Raichur
          LatLng(15.1394, 77.3500), // Guntakal
          LatLng(13.6288, 79.4192), // Renigunta
          LatLng(13.0827, 80.2707), // Chennai Central
        ],
        stops: [
          TransitStop(
              name: "Mumbai CSMT",
              position: LatLng(18.9322, 72.8264),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Dadar",
              position: LatLng(19.0178, 72.8478),
              arrivalTimeOffset: 15),
          TransitStop(
              name: "Pune",
              position: LatLng(18.5204, 73.8567),
              arrivalTimeOffset: 180),
          TransitStop(
              name: "Solapur",
              position: LatLng(17.6599, 75.9064),
              arrivalTimeOffset: 360),
          TransitStop(
              name: "Kalaburagi",
              position: LatLng(17.3297, 76.8343),
              arrivalTimeOffset: 500),
          TransitStop(
              name: "Guntakal",
              position: LatLng(15.1394, 77.3500),
              arrivalTimeOffset: 700),
          TransitStop(
              name: "Chennai Central",
              position: LatLng(13.0827, 80.2707),
              arrivalTimeOffset: 1300),
        ]);

    // 18. Howrah - Chennai (East Coast)
    _routes['rail_how_chn'] = const TransitRoute(
        id: 'rail_how_chn',
        type: TransitType.train,
        color: Colors.brown, // Coromandel Route
        polyline: [
          LatLng(22.5800, 88.3300), // Howrah
          LatLng(22.3000, 87.3000), // Kharagpur
          LatLng(20.4625, 85.8828), // Cuttack
          LatLng(20.2961, 85.8245), // Bhubaneswar
          LatLng(19.3176, 84.7900), // Berhampur
          LatLng(17.6868, 83.2185), // Visakhapatnam
          LatLng(17.0000, 82.2000), // Rajahmundry
          LatLng(16.5062, 80.6480), // Vijayawada
          LatLng(14.4426, 79.9865), // Nellore
          LatLng(13.0827, 80.2707), // Chennai Central
        ],
        stops: [
          TransitStop(
              name: "Howrah (Kolkata)",
              position: LatLng(22.5800, 88.3300),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Bhubaneswar",
              position: LatLng(20.2961, 85.8245),
              arrivalTimeOffset: 360),
          TransitStop(
              name: "Visakhapatnam",
              position: LatLng(17.6868, 83.2185),
              arrivalTimeOffset: 600),
          TransitStop(
              name: "Chennai Central",
              position: LatLng(13.0827, 80.2707),
              arrivalTimeOffset: 1400),
        ]);

    // 18b. Kolkata - Mumbai (Gitanjali Route)
    _routes['rail_how_mum'] = const TransitRoute(
        id: 'rail_how_mum',
        type: TransitType.train,
        color: Colors.teal,
        polyline: [
          LatLng(22.5800, 88.3300), // Howrah
          LatLng(22.2500, 86.6000), // Kharagpur
          LatLng(21.2000, 81.6000), // Raipur
          LatLng(21.1000, 79.0000), // Nagpur
          LatLng(20.5000, 76.0000), // Akola
          LatLng(19.3000, 73.0000), // Kalyan
          LatLng(18.9322, 72.8264), // CSMT
        ],
        stops: [
          TransitStop(
              name: "Howrah (Kolkata)",
              position: LatLng(22.5800, 88.3300),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Kharagpur",
              position: LatLng(22.2500, 86.6000),
              arrivalTimeOffset: 120),
          TransitStop(
              name: "Raipur",
              position: LatLng(21.2000, 81.6000),
              arrivalTimeOffset: 600),
          TransitStop(
              name: "Nagpur",
              position: LatLng(21.1000, 79.0000),
              arrivalTimeOffset: 900),
          TransitStop(
              name: "Mumbai CSMT",
              position: LatLng(18.9322, 72.8264),
              arrivalTimeOffset: 1600),
        ]);

    // --- NATIONAL HIGHWAYS (Long Distance Buses) ---

    // 19. NH-44 (North-South Corridor)
    _routes['nh_44'] = const TransitRoute(
        id: 'nh_44',
        type: TransitType.bus,
        color: Colors.orange,
        polyline: [
          LatLng(34.0837, 74.7973), // Srinagar
          LatLng(32.7266, 74.8570), // Jammu
          LatLng(30.9010, 75.8573), // Ludhiana
          LatLng(28.6139, 77.2090), // Delhi
          LatLng(27.1767, 78.0081), // Agra
          LatLng(21.1458, 79.0882), // Nagpur
          LatLng(17.3850, 78.4867), // Hyderabad
          LatLng(12.9716, 77.5946), // Bangalore
          LatLng(11.6643, 78.1460), // Salem
          LatLng(9.9252, 78.1198), // Madurai
          LatLng(8.0883, 77.5385), // Kanyakumari
        ],
        stops: [
          TransitStop(
              name: "Srinagar",
              position: LatLng(34.0837, 74.7973),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Delhi",
              position: LatLng(28.6139, 77.2090),
              arrivalTimeOffset: 720),
          TransitStop(
              name: "Hyderabad",
              position: LatLng(17.3850, 78.4867),
              arrivalTimeOffset: 1800),
          TransitStop(
              name: "Kanyakumari",
              position: LatLng(8.0883, 77.5385),
              arrivalTimeOffset: 2800),
        ]);

    // 20. NH-27 (East-West Corridor)
    _routes['nh_27'] = const TransitRoute(
        id: 'nh_27',
        type: TransitType.bus,
        color: Colors.orange,
        polyline: [
          LatLng(21.6417, 69.6293), // Porbandar
          LatLng(24.5854, 72.7163), // Mount Abu
          LatLng(25.1800, 75.8300), // Kota
          LatLng(25.4484, 78.5685), // Jhansi
          LatLng(26.4499, 80.3319), // Kanpur
          LatLng(26.7606, 83.3732), // Gorakhpur
          LatLng(26.7271, 88.3953), // Siliguri
          LatLng(26.1433, 91.7898), // Guwahati
          LatLng(24.8170, 92.7912), // Silchar
        ],
        stops: [
          TransitStop(
              name: "Porbandar",
              position: LatLng(21.6417, 69.6293),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Kota",
              position: LatLng(25.1800, 75.8300),
              arrivalTimeOffset: 480),
          TransitStop(
              name: "Silchar",
              position: LatLng(24.8170, 92.7912),
              arrivalTimeOffset: 2400),
        ]);

    // 21. NH-66 (West Coast)
    _routes['nh_66'] = const TransitRoute(
        id: 'nh_66',
        type: TransitType.bus,
        color: Colors.deepOrange,
        polyline: [
          LatLng(18.9894, 73.1175), // Panvel (Mumbai)
          LatLng(16.9904, 73.3120), // Ratnagiri
          LatLng(15.4909, 73.8278), // Panaji (Goa)
          LatLng(12.9141, 74.8560), // Mangalore
          LatLng(11.2588, 75.7804), // Kozhikode
          LatLng(9.9312, 76.2673), // Kochi
          LatLng(8.5241, 76.9366), // Thiruvananthapuram
        ],
        stops: [
          TransitStop(
              name: "Mumbai (Panvel)",
              position: LatLng(18.9894, 73.1175),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Goa (Panaji)",
              position: LatLng(15.4909, 73.8278),
              arrivalTimeOffset: 480),
          TransitStop(
              name: "Kochi",
              position: LatLng(9.9312, 76.2673),
              arrivalTimeOffset: 1200),
        ]);

    // --- STATE ROAD TRANSPORT (Key Routes) ---

    // 22. TNSTC: Chennai - Coimbatore
    _routes['bus_tn_cbe'] = const TransitRoute(
        id: 'bus_tn_cbe',
        color: Colors.green, // TNSTC Green
        polyline: [
          LatLng(13.0827, 80.2707),
          LatLng(12.9165, 79.1325),
          LatLng(11.6643, 78.1460),
          LatLng(11.0168, 76.9558)
        ],
        stops: [
          TransitStop(
              name: "Chennai",
              position: LatLng(13.0827, 80.2707),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Coimbatore",
              position: LatLng(11.0168, 76.9558),
              arrivalTimeOffset: 420)
        ]);

    // 23. KSRTC: Bangalore - Mysore (Airavat)
    _routes['bus_ka_mys'] = const TransitRoute(
        id: 'bus_ka_mys',
        color: Colors.white, // KSRTC White/Red
        polyline: [
          LatLng(12.9716, 77.5946),
          LatLng(12.7209, 77.2799),
          LatLng(12.5204, 76.8951),
          LatLng(12.2958, 76.6394)
        ],
        stops: [
          TransitStop(
              name: "Bangalore",
              position: LatLng(12.9716, 77.5946),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Mysore",
              position: LatLng(12.2958, 76.6394),
              arrivalTimeOffset: 120)
        ]);

    // 24. MSRTC: Pune - Nagpur
    _routes['bus_mh_nag'] = const TransitRoute(
        id: 'bus_mh_nag',
        color: Colors.red, // MSRTC Red
        polyline: [
          LatLng(18.5204, 73.8567),
          LatLng(19.8762, 75.3433),
          LatLng(20.9320, 77.7523),
          LatLng(21.1458, 79.0882)
        ],
        stops: [
          TransitStop(
              name: "Pune",
              position: LatLng(18.5204, 73.8567),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Nagpur",
              position: LatLng(21.1458, 79.0882),
              arrivalTimeOffset: 600)
        ]);

    // 25. UPSRTC: Delhi - Agra (Taj Exp Hwy)
    _routes['bus_up_agra'] = const TransitRoute(
        id: 'bus_up_agra',
        color: Colors.greenAccent,
        polyline: [
          LatLng(28.5800, 77.2400),
          LatLng(28.4500, 77.5000),
          LatLng(27.4924, 77.6737),
          LatLng(27.1767, 78.0081)
        ],
        stops: [
          TransitStop(
              name: "Delhi",
              position: LatLng(28.5800, 77.2400),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Agra",
              position: LatLng(27.1767, 78.0081),
              arrivalTimeOffset: 180)
        ]);

    // 26. RSRTC: Jaipur - Jodhpur
    _routes['bus_rj_jodh'] = const TransitRoute(
        id: 'bus_rj_jodh',
        color: Colors.blueAccent,
        polyline: [
          LatLng(26.9124, 75.7873),
          LatLng(26.6273, 74.6309),
          LatLng(26.2389, 73.0243)
        ],
        stops: [
          TransitStop(
              name: "Jaipur",
              position: LatLng(26.9124, 75.7873),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Jodhpur",
              position: LatLng(26.2389, 73.0243),
              arrivalTimeOffset: 300)
        ]);

    // 27. KSRTC (Kerala): TVM - Kozhikode
    _routes['bus_kl_calicut'] =
        const TransitRoute(id: 'bus_kl_calicut', color: Colors.teal, polyline: [
      LatLng(8.5241, 76.9366),
      LatLng(9.9312, 76.2673),
      LatLng(11.2588, 75.7804)
    ], stops: [
      TransitStop(
          name: "Trivandrum",
          position: LatLng(8.5241, 76.9366),
          arrivalTimeOffset: 0),
      TransitStop(
          name: "Kozhikode",
          position: LatLng(11.2588, 75.7804),
          arrivalTimeOffset: 480)
    ]);

    // 28. GSRTC: Ahmedabad - Rajkot
    _routes['bus_gj_rajkot'] =
        const TransitRoute(id: 'bus_gj_rajkot', color: Colors.red, polyline: [
      LatLng(23.0225, 72.5714),
      LatLng(22.6916, 71.6917),
      LatLng(22.3039, 70.8022)
    ], stops: [
      TransitStop(
          name: "Ahmedabad",
          position: LatLng(23.0225, 72.5714),
          arrivalTimeOffset: 0),
      TransitStop(
          name: "Rajkot",
          position: LatLng(22.3039, 70.8022),
          arrivalTimeOffset: 240)
    ]);

    // 29. APSRTC: Vizag - Vijayawada
    _routes['bus_ap_vizag'] =
        const TransitRoute(id: 'bus_ap_vizag', color: Colors.green, polyline: [
      LatLng(17.6868, 83.2185),
      LatLng(17.0000, 81.8000),
      LatLng(16.5062, 80.6480)
    ], stops: [
      TransitStop(
          name: "Vizag",
          position: LatLng(17.6868, 83.2185),
          arrivalTimeOffset: 0)
    ]);

    // 30. TSRTC: Hyd - Warangal
    _routes['bus_ts_wgl'] = const TransitRoute(
        id: 'bus_ts_wgl',
        color: Colors.redAccent,
        polyline: [
          LatLng(17.3850, 78.4867),
          LatLng(17.6000, 79.0000),
          LatLng(17.9689, 79.5941)
        ],
        stops: [
          TransitStop(
              name: "Hyderabad",
              position: LatLng(17.3850, 78.4867),
              arrivalTimeOffset: 0)
        ]);

    // --- NEW METRO ROUTES (User Requested) ---

    // 31. Mumbai Metro Line 1 (Versova - Ghatkopar - High Fidelity)
    _routes['mum_metro_1'] = const TransitRoute(
        id: 'mum_metro_1',
        color: Colors.blue, // Blue Line
        polyline: [
          LatLng(19.1314, 72.8151), // Versova
          LatLng(19.1290, 72.8250), // DN Nagar
          LatLng(19.1240, 72.8350), // Azad Nagar (Curve)
          LatLng(19.1190, 72.8460), // Andheri
          LatLng(19.1150, 72.8600), // WEH
          LatLng(19.1110, 72.8640), // Chakala
          LatLng(19.1105, 72.8690), // Airport Rd
          LatLng(19.1100, 72.8750), // Marol Naka
          LatLng(19.1080, 72.8850), // Saki Naka
          LatLng(19.1060, 72.8950), // Asalpha
          LatLng(19.1050, 72.9060), // Ghatkopar
        ],
        stops: [
          TransitStop(
              name: "Versova",
              position: LatLng(19.1314, 72.8151),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Andheri",
              position: LatLng(19.1190, 72.8460),
              arrivalTimeOffset: 120),
          TransitStop(
              name: "Saki Naka",
              position: LatLng(19.1080, 72.8850),
              arrivalTimeOffset: 240),
          TransitStop(
              name: "Ghatkopar",
              position: LatLng(19.1050, 72.9060),
              arrivalTimeOffset: 300),
        ]);

    // 32. Namma Metro Green Line (Bengaluru)
    _routes['bengaluru_green'] = const TransitRoute(
        id: 'bengaluru_green',
        color: Colors.green,
        polyline: [
          LatLng(13.0540, 77.5020), // Nagasandra
          LatLng(13.0090, 77.5500),
          LatLng(12.9716, 77.5946), // Majestic
          LatLng(12.9430, 77.5800), // Lalbagh
          LatLng(12.9170, 77.5730),
          LatLng(12.8600, 77.5400), // Silk Institute
        ],
        stops: [
          TransitStop(
              name: "Nagasandra",
              position: LatLng(13.0540, 77.5020),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Majestic",
              position: LatLng(12.9716, 77.5946),
              arrivalTimeOffset: 600),
          TransitStop(
              name: "Silk Institute",
              position: LatLng(12.8600, 77.5400),
              arrivalTimeOffset: 1200),
        ]);

    // 33. Hyderabad Metro Blue Line
    _routes['hyd_blue'] =
        const TransitRoute(id: 'hyd_blue', color: Colors.blue, polyline: [
      LatLng(17.3750, 78.5500), // Nagole
      LatLng(17.4300, 78.5400),
      LatLng(17.4360, 78.4980), // Secunderabad
      LatLng(17.4400, 78.4400), // Ameerpet
      LatLng(17.4450, 78.3900), // Hi-Tec City
      LatLng(17.4400, 78.3760), // Raidurg
    ], stops: [
      TransitStop(
          name: "Nagole",
          position: LatLng(17.3750, 78.5500),
          arrivalTimeOffset: 0),
      TransitStop(
          name: "Ameerpet",
          position: LatLng(17.4400, 78.4400),
          arrivalTimeOffset: 600),
      TransitStop(
          name: "Raidurg",
          position: LatLng(17.4400, 78.3760),
          arrivalTimeOffset: 1200),
    ]);

    // 34. Chennai Metro Green Line
    _routes['chennai_green'] =
        const TransitRoute(id: 'chennai_green', color: Colors.green, polyline: [
      LatLng(13.0827, 80.2707), // Central
      LatLng(13.0730, 80.2500),
      LatLng(13.0600, 80.2100), // Koyambedu
      LatLng(13.0400, 80.2000), // Ashok Nagar
      LatLng(13.0060, 80.2010), // St Thomas Mount
    ], stops: [
      TransitStop(
          name: "Central",
          position: LatLng(13.0827, 80.2707),
          arrivalTimeOffset: 0),
      TransitStop(
          name: "Koyambedu",
          position: LatLng(13.0600, 80.2100),
          arrivalTimeOffset: 300),
      TransitStop(
          name: "St Thomas Mount",
          position: LatLng(13.0060, 80.2010),
          arrivalTimeOffset: 600),
    ]);

    // 35. Kolkata Metro Green Line (Underwater)
    _routes['kolkata_green'] =
        const TransitRoute(id: 'kolkata_green', color: Colors.green, polyline: [
      LatLng(22.5830, 88.3000), // Howrah Maidan
      LatLng(22.5800, 88.3300), // Howrah Station
      LatLng(22.5700, 88.3450), // Mahakaran
      LatLng(22.5644, 88.3517), // Esplanade
      LatLng(22.5630, 88.3700), // Sealdah
      LatLng(22.5750, 88.4200), // Sector V
    ], stops: [
      TransitStop(
          name: "Howrah Maidan",
          position: LatLng(22.5830, 88.3000),
          arrivalTimeOffset: 0),
      TransitStop(
          name: "Esplanade",
          position: LatLng(22.5644, 88.3517),
          arrivalTimeOffset: 180),
      TransitStop(
          name: "Sector V",
          position: LatLng(22.5750, 88.4200),
          arrivalTimeOffset: 600),
    ]);

    // --- POPULAR INTERCITY ROUTES ---

    // Delhi - Mumbai Express Bus
    _routes['bus_delhi_mumbai'] = const TransitRoute(
        id: 'bus_delhi_mumbai',
        type: TransitType.bus,
        color: Colors.deepOrange,
        city: 'Delhi',
        polyline: [
          LatLng(28.6139, 77.2090), // Delhi
          LatLng(27.1767, 78.0081), // Agra
          LatLng(26.2183, 78.1828), // Gwalior
          LatLng(23.2599, 77.4126), // Bhopal
          LatLng(22.7196, 75.8577), // Indore
          LatLng(21.1702, 72.8311), // Surat
          LatLng(19.0760, 72.8777), // Mumbai
        ],
        stops: [
          TransitStop(
              name: "Delhi ISBT",
              position: LatLng(28.6139, 77.2090),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Agra",
              position: LatLng(27.1767, 78.0081),
              arrivalTimeOffset: 180),
          TransitStop(
              name: "Bhopal",
              position: LatLng(23.2599, 77.4126),
              arrivalTimeOffset: 480),
          TransitStop(
              name: "Indore",
              position: LatLng(22.7196, 75.8577),
              arrivalTimeOffset: 600),
          TransitStop(
              name: "Mumbai Central",
              position: LatLng(19.0760, 72.8777),
              arrivalTimeOffset: 960),
        ]);

    // Delhi - Mumbai Rajdhani Express (Train)
    _routes['train_delhi_mumbai_raj'] = TransitRoute(
        id: 'train_delhi_mumbai_raj',
        type: TransitType.train,
        color: Colors.red[700],
        city: 'Delhi',
        polyline: [
          LatLng(28.6423, 77.2196), // New Delhi Station
          LatLng(27.1767, 78.0081), // Agra Cantt
          LatLng(26.4499, 80.3319), // Kanpur
          LatLng(25.3176, 82.9739), // Varanasi
          LatLng(21.1458, 79.0882), // Nagpur
          LatLng(18.9322, 72.8264), // Mumbai CSMT
        ],
        stops: [
          TransitStop(
              name: "New Delhi",
              position: LatLng(28.6423, 77.2196),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Agra Cantt",
              position: LatLng(27.1767, 78.0081),
              arrivalTimeOffset: 120),
          TransitStop(
              name: "Nagpur",
              position: LatLng(21.1458, 79.0882),
              arrivalTimeOffset: 600),
          TransitStop(
              name: "Mumbai CSMT",
              position: LatLng(18.9322, 72.8264),
              arrivalTimeOffset: 960),
        ]);

    // Delhi - Kolkata Duronto (Train)
    _routes['train_delhi_kolkata'] = TransitRoute(
        id: 'train_delhi_kolkata',
        type: TransitType.train,
        color: Colors.blue[800],
        city: 'Delhi',
        polyline: [
          LatLng(28.6625, 77.2280), // Delhi Nizamuddin
          LatLng(26.4499, 80.3319), // Kanpur
          LatLng(25.6093, 85.1376), // Patna
          LatLng(23.7957, 86.4304), // Dhanbad
          LatLng(22.5726, 88.3639), // Kolkata Howrah
        ],
        stops: [
          TransitStop(
              name: "Delhi Nizamuddin",
              position: LatLng(28.6625, 77.2280),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Kanpur",
              position: LatLng(26.4499, 80.3319),
              arrivalTimeOffset: 300),
          TransitStop(
              name: "Patna",
              position: LatLng(25.6093, 85.1376),
              arrivalTimeOffset: 600),
          TransitStop(
              name: "Kolkata Howrah",
              position: LatLng(22.5726, 88.3639),
              arrivalTimeOffset: 1020),
        ]);

    // Delhi - Kolkata Bus
    _routes['bus_delhi_kolkata'] = const TransitRoute(
        id: 'bus_delhi_kolkata',
        type: TransitType.bus,
        color: Colors.teal,
        city: 'Delhi',
        polyline: [
          LatLng(28.6139, 77.2090), // Delhi
          LatLng(26.8467, 80.9462), // Lucknow
          LatLng(25.3176, 82.9739), // Varanasi
          LatLng(25.6093, 85.1376), // Patna
          LatLng(22.5726, 88.3639), // Kolkata
        ],
        stops: [
          TransitStop(
              name: "Delhi",
              position: LatLng(28.6139, 77.2090),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Lucknow",
              position: LatLng(26.8467, 80.9462),
              arrivalTimeOffset: 360),
          TransitStop(
              name: "Varanasi",
              position: LatLng(25.3176, 82.9739),
              arrivalTimeOffset: 600),
          TransitStop(
              name: "Kolkata",
              position: LatLng(22.5726, 88.3639),
              arrivalTimeOffset: 1080),
        ]);

    // Mumbai - Bangalore Express Bus
    _routes['bus_mumbai_bangalore'] = const TransitRoute(
        id: 'bus_mumbai_bangalore',
        type: TransitType.bus,
        color: Colors.purple,
        city: 'Mumbai',
        polyline: [
          LatLng(19.0760, 72.8777), // Mumbai
          LatLng(18.5204, 73.8567), // Pune
          LatLng(17.6868, 74.0183), // Satara
          LatLng(15.8497, 74.4977), // Belgaum
          LatLng(15.3647, 75.1240), // Hubli
          LatLng(12.9716, 77.5946), // Bangalore
        ],
        stops: [
          TransitStop(
              name: "Mumbai Dadar",
              position: LatLng(19.0760, 72.8777),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Pune",
              position: LatLng(18.5204, 73.8567),
              arrivalTimeOffset: 180),
          TransitStop(
              name: "Belgaum",
              position: LatLng(15.8497, 74.4977),
              arrivalTimeOffset: 480),
          TransitStop(
              name: "Bangalore Majestic",
              position: LatLng(12.9716, 77.5946),
              arrivalTimeOffset: 720),
        ]);

    // Mumbai - Bangalore Train (Udyan Express)
    _routes['train_mumbai_bangalore'] = TransitRoute(
        id: 'train_mumbai_bangalore',
        type: TransitType.train,
        color: Colors.indigo[600],
        city: 'Mumbai',
        polyline: [
          LatLng(18.9322, 72.8264), // Mumbai CSMT
          LatLng(18.5204, 73.8567), // Pune
          LatLng(17.6868, 74.0183), // Satara
          LatLng(15.8497, 74.4977), // Belgaum
          LatLng(12.9716, 77.5946), // Bangalore
        ],
        stops: [
          TransitStop(
              name: "Mumbai CSMT",
              position: LatLng(18.9322, 72.8264),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Pune",
              position: LatLng(18.5204, 73.8567),
              arrivalTimeOffset: 180),
          TransitStop(
              name: "Bangalore City",
              position: LatLng(12.9716, 77.5946),
              arrivalTimeOffset: 1440),
        ]);

    // Mumbai - Chennai Express
    _routes['train_mumbai_chennai'] = TransitRoute(
        id: 'train_mumbai_chennai',
        type: TransitType.train,
        color: Colors.green[700],
        city: 'Mumbai',
        polyline: [
          LatLng(18.9322, 72.8264), // Mumbai CSMT
          LatLng(17.3850, 78.4867), // Hyderabad
          LatLng(13.0827, 80.2707), // Chennai Central
        ],
        stops: [
          TransitStop(
              name: "Mumbai CSMT",
              position: LatLng(18.9322, 72.8264),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Hyderabad",
              position: LatLng(17.3850, 78.4867),
              arrivalTimeOffset: 720),
          TransitStop(
              name: "Chennai Central",
              position: LatLng(13.0827, 80.2707),
              arrivalTimeOffset: 1320),
        ]);

    // Bangalore - Chennai Bus
    _routes['bus_bangalore_chennai'] = const TransitRoute(
        id: 'bus_bangalore_chennai',
        type: TransitType.bus,
        color: Colors.amber,
        city: 'Bangalore',
        polyline: [
          LatLng(12.9716, 77.5946), // Bangalore
          LatLng(12.5266, 78.2150), // Vellore
          LatLng(13.0827, 80.2707), // Chennai
        ],
        stops: [
          TransitStop(
              name: "Bangalore Majestic",
              position: LatLng(12.9716, 77.5946),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Vellore",
              position: LatLng(12.5266, 78.2150),
              arrivalTimeOffset: 120),
          TransitStop(
              name: "Chennai CMBT",
              position: LatLng(13.0827, 80.2707),
              arrivalTimeOffset: 360),
        ]);

    // Bangalore - Chennai Train (Shatabdi)
    _routes['train_bangalore_chennai'] = TransitRoute(
        id: 'train_bangalore_chennai',
        type: TransitType.train,
        color: Colors.red[600],
        city: 'Bangalore',
        polyline: [
          LatLng(12.9716, 77.5946), // Bangalore City
          LatLng(12.9180, 77.6190), // Krishnarajapuram
          LatLng(12.7409, 77.8253), // Hosur
          LatLng(12.5266, 78.2150), // Katpadi (Vellore)
          LatLng(13.0827, 80.2707), // Chennai Central
        ],
        stops: [
          TransitStop(
              name: "Bangalore City",
              position: LatLng(12.9716, 77.5946),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Katpadi (Vellore)",
              position: LatLng(12.5266, 78.2150),
              arrivalTimeOffset: 120),
          TransitStop(
              name: "Chennai Central",
              position: LatLng(13.0827, 80.2707),
              arrivalTimeOffset: 300),
        ]);

    // Kolkata - Chennai Train
    _routes['train_kolkata_chennai'] = TransitRoute(
        id: 'train_kolkata_chennai',
        type: TransitType.train,
        color: Colors.cyan[700],
        city: 'Kolkata',
        polyline: [
          LatLng(22.5726, 88.3639), // Kolkata Howrah
          LatLng(20.2961, 85.8245), // Bhubaneswar
          LatLng(17.6868, 83.2185), // Visakhapatnam
          LatLng(13.0827, 80.2707), // Chennai Central
        ],
        stops: [
          TransitStop(
              name: "Kolkata Howrah",
              position: LatLng(22.5726, 88.3639),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Bhubaneswar",
              position: LatLng(20.2961, 85.8245),
              arrivalTimeOffset: 420),
          TransitStop(
              name: "Visakhapatnam",
              position: LatLng(17.6868, 83.2185),
              arrivalTimeOffset: 720),
          TransitStop(
              name: "Chennai Central",
              position: LatLng(13.0827, 80.2707),
              arrivalTimeOffset: 1560),
        ]);

    // Delhi - Jaipur Bus (Pink City Express)
    _routes['bus_delhi_jaipur'] = const TransitRoute(
        id: 'bus_delhi_jaipur',
        type: TransitType.bus,
        color: Colors.pink,
        city: 'Delhi',
        polyline: [
          LatLng(28.6139, 77.2090), // Delhi
          LatLng(28.4595, 77.0266), // Gurgaon
          LatLng(27.5530, 76.6346), // Alwar
          LatLng(26.9124, 75.7873), // Jaipur
        ],
        stops: [
          TransitStop(
              name: "Delhi ISBT",
              position: LatLng(28.6139, 77.2090),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Gurgaon",
              position: LatLng(28.4595, 77.0266),
              arrivalTimeOffset: 60),
          TransitStop(
              name: "Jaipur Sindhi Camp",
              position: LatLng(26.9124, 75.7873),
              arrivalTimeOffset: 300),
        ]);

    // Delhi - Jaipur Train (Double Decker)
    _routes['train_delhi_jaipur'] = TransitRoute(
        id: 'train_delhi_jaipur',
        type: TransitType.train,
        color: Colors.pink[800],
        city: 'Delhi',
        polyline: [
          LatLng(28.6401, 77.2180), // Delhi Sarai Rohilla
          LatLng(27.2046, 77.4977), // Rewari
          LatLng(26.9124, 75.7873), // Jaipur
        ],
        stops: [
          TransitStop(
              name: "Delhi Sarai Rohilla",
              position: LatLng(28.6401, 77.2180),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Rewari",
              position: LatLng(27.2046, 77.4977),
              arrivalTimeOffset: 90),
          TransitStop(
              name: "Jaipur Junction",
              position: LatLng(26.9124, 75.7873),
              arrivalTimeOffset: 270),
        ]);

    // Hyderabad - Bangalore Bus
    _routes['bus_hyderabad_bangalore'] = const TransitRoute(
        id: 'bus_hyderabad_bangalore',
        type: TransitType.bus,
        color: Colors.orange,
        city: 'Hyderabad',
        polyline: [
          LatLng(17.3850, 78.4867), // Hyderabad
          LatLng(15.9129, 78.0029), // Kurnool
          LatLng(14.6819, 77.5995), // Anantapur
          LatLng(12.9716, 77.5946), // Bangalore
        ],
        stops: [
          TransitStop(
              name: "Hyderabad MGBS",
              position: LatLng(17.3850, 78.4867),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Kurnool",
              position: LatLng(15.9129, 78.0029),
              arrivalTimeOffset: 240),
          TransitStop(
              name: "Anantapur",
              position: LatLng(14.6819, 77.5995),
              arrivalTimeOffset: 360),
          TransitStop(
              name: "Bangalore Majestic",
              position: LatLng(12.9716, 77.5946),
              arrivalTimeOffset: 600),
        ]);

    // Hyderabad - Bangalore Train
    _routes['train_hyderabad_bangalore'] = TransitRoute(
        id: 'train_hyderabad_bangalore',
        type: TransitType.train,
        color: Colors.deepPurple,
        city: 'Hyderabad',
        polyline: [
          LatLng(17.4334, 78.5013), // Secunderabad
          LatLng(15.9129, 78.0029), // Kurnool
          LatLng(14.6819, 77.5995), // Anantapur
          LatLng(13.3161, 77.1155), // Tumkur
          LatLng(12.9716, 77.5946), // Bangalore
        ],
        stops: [
          TransitStop(
              name: "Secunderabad",
              position: LatLng(17.4334, 78.5013),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Kurnool",
              position: LatLng(15.9129, 78.0029),
              arrivalTimeOffset: 240),
          TransitStop(
              name: "Bangalore City",
              position: LatLng(12.9716, 77.5946),
              arrivalTimeOffset: 720),
        ]);

    // --- MORE POPULAR INTERCITY ROUTES ---

    // Mumbai - Pune Deccan Express (Train)
    _routes['train_mumbai_pune_deccan'] = TransitRoute(
        id: 'train_mumbai_pune_deccan',
        type: TransitType.train,
        color: Colors.blue[600],
        city: 'Mumbai',
        polyline: [
          LatLng(18.9322, 72.8264), // Mumbai CSMT
          LatLng(19.0176, 72.8562), // Dadar
          LatLng(19.0330, 73.0297), // Thane
          LatLng(18.7357, 73.4064), // Lonavala
          LatLng(18.5204, 73.8567), // Pune
        ],
        stops: [
          TransitStop(
              name: "Mumbai CSMT",
              position: LatLng(18.9322, 72.8264),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Dadar",
              position: LatLng(19.0176, 72.8562),
              arrivalTimeOffset: 20),
          TransitStop(
              name: "Lonavala",
              position: LatLng(18.7357, 73.4064),
              arrivalTimeOffset: 90),
          TransitStop(
              name: "Pune Junction",
              position: LatLng(18.5204, 73.8567),
              arrivalTimeOffset: 180),
        ]);

    // Mumbai - Pune Shatabdi (Train)
    _routes['train_mumbai_pune_shatabdi'] = TransitRoute(
        id: 'train_mumbai_pune_shatabdi',
        type: TransitType.train,
        color: Colors.red[600],
        city: 'Mumbai',
        polyline: [
          LatLng(18.9322, 72.8264), // Mumbai CSMT
          LatLng(18.7357, 73.4064), // Lonavala
          LatLng(18.5204, 73.8567), // Pune
        ],
        stops: [
          TransitStop(
              name: "Mumbai CSMT",
              position: LatLng(18.9322, 72.8264),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Lonavala",
              position: LatLng(18.7357, 73.4064),
              arrivalTimeOffset: 75),
          TransitStop(
              name: "Pune Junction",
              position: LatLng(18.5204, 73.8567),
              arrivalTimeOffset: 150),
        ]);

    // Mumbai - Pune Bus (MSRTC Shivneri)
    _routes['bus_mumbai_pune'] = const TransitRoute(
        id: 'bus_mumbai_pune',
        type: TransitType.bus,
        color: Colors.green,
        city: 'Mumbai',
        polyline: [
          LatLng(19.0760, 72.8777), // Mumbai Central
          LatLng(19.0330, 73.0297), // Thane
          LatLng(18.7357, 73.4064), // Lonavala
          LatLng(18.5204, 73.8567), // Pune
        ],
        stops: [
          TransitStop(
              name: "Mumbai Central",
              position: LatLng(19.0760, 72.8777),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Thane",
              position: LatLng(19.0330, 73.0297),
              arrivalTimeOffset: 45),
          TransitStop(
              name: "Lonavala",
              position: LatLng(18.7357, 73.4064),
              arrivalTimeOffset: 120),
          TransitStop(
              name: "Pune Shivajinagar",
              position: LatLng(18.5204, 73.8567),
              arrivalTimeOffset: 210),
        ]);

    // Delhi - Lucknow Train (Shatabdi)
    _routes['train_delhi_lucknow'] = TransitRoute(
        id: 'train_delhi_lucknow',
        type: TransitType.train,
        color: Colors.indigo[600],
        city: 'Delhi',
        polyline: [
          LatLng(28.6423, 77.2196), // New Delhi
          LatLng(28.3670, 77.3070), // Ghaziabad
          LatLng(26.8467, 80.9462), // Lucknow
        ],
        stops: [
          TransitStop(
              name: "New Delhi",
              position: LatLng(28.6423, 77.2196),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Ghaziabad",
              position: LatLng(28.3670, 77.3070),
              arrivalTimeOffset: 30),
          TransitStop(
              name: "Lucknow Charbagh",
              position: LatLng(26.8467, 80.9462),
              arrivalTimeOffset: 390),
        ]);

    // Delhi - Lucknow Bus
    _routes['bus_delhi_lucknow'] = const TransitRoute(
        id: 'bus_delhi_lucknow',
        type: TransitType.bus,
        color: Colors.teal,
        city: 'Delhi',
        polyline: [
          LatLng(28.6139, 77.2090), // Delhi
          LatLng(28.3670, 77.3070), // Ghaziabad
          LatLng(27.1767, 78.0081), // Agra
          LatLng(26.8467, 80.9462), // Lucknow
        ],
        stops: [
          TransitStop(
              name: "Delhi ISBT",
              position: LatLng(28.6139, 77.2090),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Agra",
              position: LatLng(27.1767, 78.0081),
              arrivalTimeOffset: 180),
          TransitStop(
              name: "Lucknow",
              position: LatLng(26.8467, 80.9462),
              arrivalTimeOffset: 480),
        ]);

    // Chennai - Hyderabad Train
    _routes['train_chennai_hyderabad'] = TransitRoute(
        id: 'train_chennai_hyderabad',
        type: TransitType.train,
        color: Colors.purple[600],
        city: 'Chennai',
        polyline: [
          LatLng(13.0827, 80.2707), // Chennai Central
          LatLng(14.6819, 77.5995), // Anantapur
          LatLng(17.3850, 78.4867), // Hyderabad
        ],
        stops: [
          TransitStop(
              name: "Chennai Central",
              position: LatLng(13.0827, 80.2707),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Anantapur",
              position: LatLng(14.6819, 77.5995),
              arrivalTimeOffset: 360),
          TransitStop(
              name: "Hyderabad Kacheguda",
              position: LatLng(17.3850, 78.4867),
              arrivalTimeOffset: 720),
        ]);

    // Chennai - Hyderabad Bus
    _routes['bus_chennai_hyderabad'] = const TransitRoute(
        id: 'bus_chennai_hyderabad',
        type: TransitType.bus,
        color: Colors.deepOrange,
        city: 'Chennai',
        polyline: [
          LatLng(13.0827, 80.2707), // Chennai
          LatLng(15.9259, 79.9908), // Ongole
          LatLng(17.3850, 78.4867), // Hyderabad
        ],
        stops: [
          TransitStop(
              name: "Chennai CMBT",
              position: LatLng(13.0827, 80.2707),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Ongole",
              position: LatLng(15.9259, 79.9908),
              arrivalTimeOffset: 300),
          TransitStop(
              name: "Hyderabad MGBS",
              position: LatLng(17.3850, 78.4867),
              arrivalTimeOffset: 600),
        ]);

    // Kolkata - Patna Train
    _routes['train_kolkata_patna'] = TransitRoute(
        id: 'train_kolkata_patna',
        type: TransitType.train,
        color: Colors.brown[600],
        city: 'Kolkata',
        polyline: [
          LatLng(22.5726, 88.3639), // Kolkata Howrah
          LatLng(23.7957, 86.4304), // Dhanbad
          LatLng(25.6093, 85.1376), // Patna
        ],
        stops: [
          TransitStop(
              name: "Kolkata Howrah",
              position: LatLng(22.5726, 88.3639),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Dhanbad",
              position: LatLng(23.7957, 86.4304),
              arrivalTimeOffset: 180),
          TransitStop(
              name: "Patna Junction",
              position: LatLng(25.6093, 85.1376),
              arrivalTimeOffset: 420),
        ]);

    // Kolkata - Patna Bus
    _routes['bus_kolkata_patna'] = const TransitRoute(
        id: 'bus_kolkata_patna',
        type: TransitType.bus,
        color: Colors.lime,
        city: 'Kolkata',
        polyline: [
          LatLng(22.5726, 88.3639), // Kolkata
          LatLng(23.7957, 86.4304), // Dhanbad
          LatLng(25.6093, 85.1376), // Patna
        ],
        stops: [
          TransitStop(
              name: "Kolkata Esplanade",
              position: LatLng(22.5726, 88.3639),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Dhanbad",
              position: LatLng(23.7957, 86.4304),
              arrivalTimeOffset: 240),
          TransitStop(
              name: "Patna",
              position: LatLng(25.6093, 85.1376),
              arrivalTimeOffset: 540),
        ]);

    // Ahmedabad - Mumbai Train
    _routes['train_ahmedabad_mumbai'] = TransitRoute(
        id: 'train_ahmedabad_mumbai',
        type: TransitType.train,
        color: Colors.amber[700],
        city: 'Ahmedabad',
        polyline: [
          LatLng(23.0225, 72.5714), // Ahmedabad
          LatLng(21.1702, 72.8311), // Surat
          LatLng(19.0760, 72.8777), // Mumbai
        ],
        stops: [
          TransitStop(
              name: "Ahmedabad Junction",
              position: LatLng(23.0225, 72.5714),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Surat",
              position: LatLng(21.1702, 72.8311),
              arrivalTimeOffset: 180),
          TransitStop(
              name: "Mumbai Central",
              position: LatLng(19.0760, 72.8777),
              arrivalTimeOffset: 420),
        ]);

    // Ahmedabad - Mumbai Bus
    _routes['bus_ahmedabad_mumbai'] = const TransitRoute(
        id: 'bus_ahmedabad_mumbai',
        type: TransitType.bus,
        color: Colors.cyan,
        city: 'Ahmedabad',
        polyline: [
          LatLng(23.0225, 72.5714), // Ahmedabad
          LatLng(22.3072, 73.1812), // Vadodara
          LatLng(21.1702, 72.8311), // Surat
          LatLng(19.0760, 72.8777), // Mumbai
        ],
        stops: [
          TransitStop(
              name: "Ahmedabad",
              position: LatLng(23.0225, 72.5714),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Vadodara",
              position: LatLng(22.3072, 73.1812),
              arrivalTimeOffset: 120),
          TransitStop(
              name: "Surat",
              position: LatLng(21.1702, 72.8311),
              arrivalTimeOffset: 240),
          TransitStop(
              name: "Mumbai",
              position: LatLng(19.0760, 72.8777),
              arrivalTimeOffset: 480),
        ]);

    // Pune - Bangalore Train
    _routes['train_pune_bangalore'] = TransitRoute(
        id: 'train_pune_bangalore',
        type: TransitType.train,
        color: Colors.teal[700],
        city: 'Pune',
        polyline: [
          LatLng(18.5204, 73.8567), // Pune
          LatLng(17.6868, 74.0183), // Satara
          LatLng(15.8497, 74.4977), // Belgaum
          LatLng(12.9716, 77.5946), // Bangalore
        ],
        stops: [
          TransitStop(
              name: "Pune Junction",
              position: LatLng(18.5204, 73.8567),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Satara",
              position: LatLng(17.6868, 74.0183),
              arrivalTimeOffset: 120),
          TransitStop(
              name: "Belgaum",
              position: LatLng(15.8497, 74.4977),
              arrivalTimeOffset: 360),
          TransitStop(
              name: "Bangalore City",
              position: LatLng(12.9716, 77.5946),
              arrivalTimeOffset: 660),
        ]);

    // Pune - Bangalore Bus
    _routes['bus_pune_bangalore'] = const TransitRoute(
        id: 'bus_pune_bangalore',
        type: TransitType.bus,
        color: Colors.indigo,
        city: 'Pune',
        polyline: [
          LatLng(18.5204, 73.8567), // Pune
          LatLng(16.7050, 74.2433), // Kolhapur
          LatLng(15.8497, 74.4977), // Belgaum
          LatLng(15.3647, 75.1240), // Hubli
          LatLng(12.9716, 77.5946), // Bangalore
        ],
        stops: [
          TransitStop(
              name: "Pune Swargate",
              position: LatLng(18.5204, 73.8567),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Kolhapur",
              position: LatLng(16.7050, 74.2433),
              arrivalTimeOffset: 240),
          TransitStop(
              name: "Belgaum",
              position: LatLng(15.8497, 74.4977),
              arrivalTimeOffset: 360),
          TransitStop(
              name: "Bangalore Majestic",
              position: LatLng(12.9716, 77.5946),
              arrivalTimeOffset: 660),
        ]);

    // Delhi - Chandigarh Train
    _routes['train_delhi_chandigarh'] = TransitRoute(
        id: 'train_delhi_chandigarh',
        type: TransitType.train,
        color: Colors.green[700],
        city: 'Delhi',
        polyline: [
          LatLng(28.6423, 77.2196), // New Delhi
          LatLng(29.9456, 76.8232), // Ambala
          LatLng(30.7333, 76.7794), // Chandigarh
        ],
        stops: [
          TransitStop(
              name: "New Delhi",
              position: LatLng(28.6423, 77.2196),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Ambala Cantt",
              position: LatLng(29.9456, 76.8232),
              arrivalTimeOffset: 150),
          TransitStop(
              name: "Chandigarh",
              position: LatLng(30.7333, 76.7794),
              arrivalTimeOffset: 210),
        ]);

    // Delhi - Chandigarh Bus
    _routes['bus_delhi_chandigarh'] = const TransitRoute(
        id: 'bus_delhi_chandigarh',
        type: TransitType.bus,
        color: Colors.lightBlue,
        city: 'Delhi',
        polyline: [
          LatLng(28.6139, 77.2090), // Delhi
          LatLng(29.1492, 75.7217), // Karnal
          LatLng(30.7333, 76.7794), // Chandigarh
        ],
        stops: [
          TransitStop(
              name: "Delhi ISBT",
              position: LatLng(28.6139, 77.2090),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Karnal",
              position: LatLng(29.1492, 75.7217),
              arrivalTimeOffset: 120),
          TransitStop(
              name: "Chandigarh ISBT",
              position: LatLng(30.7333, 76.7794),
              arrivalTimeOffset: 300),
        ]);

    // Hyderabad - Mumbai Train
    _routes['train_hyderabad_mumbai'] = TransitRoute(
        id: 'train_hyderabad_mumbai',
        type: TransitType.train,
        color: Colors.pink[700],
        city: 'Hyderabad',
        polyline: [
          LatLng(17.4334, 78.5013), // Secunderabad
          LatLng(19.8762, 75.3433), // Aurangabad
          LatLng(18.9322, 72.8264), // Mumbai CSMT
        ],
        stops: [
          TransitStop(
              name: "Secunderabad",
              position: LatLng(17.4334, 78.5013),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Aurangabad",
              position: LatLng(19.8762, 75.3433),
              arrivalTimeOffset: 420),
          TransitStop(
              name: "Mumbai CSMT",
              position: LatLng(18.9322, 72.8264),
              arrivalTimeOffset: 780),
        ]);

    // Hyderabad - Mumbai Bus
    _routes['bus_hyderabad_mumbai'] = const TransitRoute(
        id: 'bus_hyderabad_mumbai',
        type: TransitType.bus,
        color: Colors.deepPurple,
        city: 'Hyderabad',
        polyline: [
          LatLng(17.3850, 78.4867), // Hyderabad
          LatLng(18.5204, 73.8567), // Pune
          LatLng(19.0760, 72.8777), // Mumbai
        ],
        stops: [
          TransitStop(
              name: "Hyderabad MGBS",
              position: LatLng(17.3850, 78.4867),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Pune",
              position: LatLng(18.5204, 73.8567),
              arrivalTimeOffset: 540),
          TransitStop(
              name: "Mumbai Dadar",
              position: LatLng(19.0760, 72.8777),
              arrivalTimeOffset: 720),
        ]);
    // --- NEW ADDITIONS (Trams, Metro, Vande Bharat) ---

    // 36. Kolkata Tram Route 25 (Ballygunge - Tollygunge)
    _routes['kolkata_tram_25'] = const TransitRoute(
        id: 'kolkata_tram_25',
        type: TransitType.tram,
        color: Colors.purpleAccent,
        city: 'Kolkata',
        polyline: [
          LatLng(22.5280, 88.3650), // Ballygunge
          LatLng(22.5200, 88.3600), // Gariahat
          LatLng(22.5100, 88.3500), // Lake Gardens
          LatLng(22.4950, 88.3450), // Tollygunge
        ],
        stops: [
          TransitStop(
              name: "Ballygunge",
              position: LatLng(22.5280, 88.3650),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Gariahat",
              position: LatLng(22.5200, 88.3600),
              arrivalTimeOffset: 120),
          TransitStop(
              name: "Tollygunge",
              position: LatLng(22.4950, 88.3450),
              arrivalTimeOffset: 300),
        ]);

    // 37. Kolkata Tram Route 36 (Esplanade - Kidderpore)
    _routes['kolkata_tram_36'] = const TransitRoute(
        id: 'kolkata_tram_36',
        type: TransitType.tram,
        color: Colors.purpleAccent,
        city: 'Kolkata',
        polyline: [
          LatLng(22.5644, 88.3517), // Esplanade
          LatLng(22.5500, 88.3300), // Fort William
          LatLng(22.5350, 88.3200), // Kidderpore
        ],
        stops: [
          TransitStop(
              name: "Esplanade",
              position: LatLng(22.5644, 88.3517),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Kidderpore",
              position: LatLng(22.5350, 88.3200),
              arrivalTimeOffset: 240),
        ]);

    // 38. Mumbai Metro Aqua Line 3 (Underground)
    _routes['mum_metro_aqua'] = const TransitRoute(
        id: 'mum_metro_aqua',
        city: 'Mumbai',
        type: TransitType.metro,
        color: Colors.cyanAccent,
        polyline: [
          LatLng(19.1300, 72.8700), // Aarey
          LatLng(19.1100, 72.8600), // SEEPZ
          LatLng(19.0600, 72.8400), // BKC
          LatLng(19.0178, 72.8478), // Dadar
          LatLng(18.9696, 72.8193), // Mumbai Central
          LatLng(18.9322, 72.8264), // Churchgate
          LatLng(18.9100, 72.8200), // Cuffe Parade
        ],
        stops: [
          TransitStop(
              name: "Aarey Colony",
              position: LatLng(19.1300, 72.8700),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "BKC",
              position: LatLng(19.0600, 72.8400),
              arrivalTimeOffset: 300),
          TransitStop(
              name: "Cuffe Parade",
              position: LatLng(18.9100, 72.8200),
              arrivalTimeOffset: 900),
        ]);

    // 39. Pune Metro Purple Line
    _routes['pune_metro_purple'] = const TransitRoute(
        id: 'pune_metro_purple',
        city: 'Pune',
        type: TransitType.metro,
        color: Colors.purple,
        polyline: [
          LatLng(18.6500, 73.8000), // PCMC
          LatLng(18.5800, 73.8200), // Dapodi
          LatLng(18.5204, 73.8567), // Shivajinagar
          LatLng(18.5100, 73.8600), // Swargate
        ],
        stops: [
          TransitStop(
              name: "PCMC Bhavan",
              position: LatLng(18.6500, 73.8000),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Shivajinagar",
              position: LatLng(18.5204, 73.8567),
              arrivalTimeOffset: 300),
          TransitStop(
              name: "Swargate",
              position: LatLng(18.5100, 73.8600),
              arrivalTimeOffset: 420),
        ]);

    // 40. Delhi Airport Express (Orange Line)
    _routes['delhi_metro_orange'] = const TransitRoute(
        id: 'delhi_metro_orange',
        city: 'Delhi',
        type: TransitType.metro,
        color: Colors.orange,
        polyline: [
          LatLng(28.6423, 77.2196), // New Delhi
          LatLng(28.6250, 77.2100), // Shivaji Stadium
          LatLng(28.5900, 77.1600), // Dhaula Kuan
          LatLng(28.5562, 77.1000), // Aerocity
          LatLng(28.5550, 77.0850), // IGI Airport
          LatLng(28.6280, 77.0600), // Dwarka 21
        ],
        stops: [
          TransitStop(
              name: "New Delhi",
              position: LatLng(28.6423, 77.2196),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Dhaula Kuan",
              position: LatLng(28.5900, 77.1600),
              arrivalTimeOffset: 120),
          TransitStop(
              name: "IGI Airport T3",
              position: LatLng(28.5550, 77.0850),
              arrivalTimeOffset: 240),
        ]);

    // 41. Mumbai - Goa Vande Bharat (Train)
    _routes['train_mumbai_goa_vb'] = TransitRoute(
        id: 'train_mumbai_goa_vb',
        type: TransitType.train,
        color: Colors.white, // Vande Bharat White/Blue
        city: 'Mumbai',
        polyline: [
          LatLng(18.9322, 72.8264), // CSMT
          LatLng(19.0178, 72.8478), // Dadar
          LatLng(18.9894, 73.1175), // Panvel
          LatLng(16.9904, 73.3120), // Ratnagiri
          LatLng(15.2832, 73.9862), // Madgaon
        ],
        stops: [
          TransitStop(
              name: "Mumbai CSMT",
              position: LatLng(18.9322, 72.8264),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "Ratnagiri",
              position: LatLng(16.9904, 73.3120),
              arrivalTimeOffset: 240),
          TransitStop(
              name: "Madgaon (Goa)",
              position: LatLng(15.2832, 73.9862),
              arrivalTimeOffset: 480),
        ]);

    // 42. Hyderabad Airport Pushpak (Bus)
    _routes['bus_hyd_airport'] = const TransitRoute(
        id: 'bus_hyd_airport',
        type: TransitType.bus,
        color: Colors.lightGreenAccent,
        city: 'Hyderabad',
        polyline: [
          LatLng(17.4334, 78.5013), // Secunderabad
          LatLng(17.4400, 78.4400), // Ameerpet
          LatLng(17.4000, 78.4000), // Gachibowli
          LatLng(17.2403, 78.4294), // RGIA Airport
        ],
        stops: [
          TransitStop(
              name: "Secunderabad",
              position: LatLng(17.4334, 78.5013),
              arrivalTimeOffset: 0),
          TransitStop(
              name: "RGIA Airport",
              position: LatLng(17.2403, 78.4294),
              arrivalTimeOffset: 90),
        ]);
  }

  TransitRoute _generateGenericRoute(String routeId) {
    return TransitRoute(id: routeId, polyline: [], stops: []);
  }

  // --- Generation Logic ---

  void _generateInitialVehicles() {
    _vehicles.clear();
    _routes.forEach((routeId, route) {
      int count = 5; // HIGH DENSITY DEFAULT

      // Metro lines get HIGH volume
      if (route.type == TransitType.metro) count = 8;

      // Trams are frequent
      if (route.type == TransitType.tram) count = 6;

      // Intercity trains get medium count
      if (routeId.contains('train_')) count = 4;

      // Long distance buses
      if (routeId.contains('bus_') && !routeId.contains('brts')) count = 4;

      // BRTS gets high volume
      if (routeId.contains('brts')) count = 10;

      for (int i = 0; i < count; i++) {
        _spawnVehicleOnRoute(routeId, route, i);
      }
    });

    _vehiclesController.add(List.from(_vehicles));
  }
}
