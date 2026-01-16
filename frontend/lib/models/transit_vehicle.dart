import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum TransitType { bus, metro, train, tram }

enum VehicleStatus { onTime, delayed, full, breakdown }

class TransitVehicle {
  final String id;
  final String name; // e.g. "502", "Yellow Line"
  final String routeName; // e.g. "Mehrauli <-> Old Delhi"
  final TransitType type;
  final String agency; // e.g. "DTC", "BEST", "IR"
  final VehicleStatus status;
  final LatLng position;
  final double heading;
  final Color? color; // Override color for lines (Metro)

  final String? routeId;
  final double
      currentPathIndex; // Index in the polyline coordinate list (supports fractional)
  final int pathDirection; // 1 for forward, -1 for backward

  final String? city;
  final String? country;

  const TransitVehicle({
    required this.id,
    required this.name,
    required this.routeName,
    required this.type,
    required this.agency,
    required this.status,
    required this.position,
    this.heading = 0.0,
    this.color,
    this.routeId,
    this.currentPathIndex = 0.0,
    this.pathDirection = 1,
    this.city,
    this.country,
  });

  TransitVehicle copyWith({
    String? id,
    String? name,
    String? routeName,
    TransitType? type,
    String? agency,
    VehicleStatus? status,
    LatLng? position,
    double? heading,
    Color? color,
    String? routeId,
    double? currentPathIndex,
    int? pathDirection,
    String? city,
    String? country,
  }) {
    return TransitVehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      routeName: routeName ?? this.routeName,
      type: type ?? this.type,
      agency: agency ?? this.agency,
      status: status ?? this.status,
      position: position ?? this.position,
      heading: heading ?? this.heading,
      color: color ?? this.color,
      routeId: routeId ?? this.routeId,
      currentPathIndex: currentPathIndex ?? this.currentPathIndex,
      pathDirection: pathDirection ?? this.pathDirection,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }
}

class TransitStop {
  final String name;
  final LatLng position;
  final int arrivalTimeOffset; // Minutes from "now"

  const TransitStop({
    required this.name,
    required this.position,
    required this.arrivalTimeOffset,
  });
}

class TransitRoute {
  final String id;
  final List<LatLng> polyline;
  final List<TransitStop> stops;
  final Color? color; // Route specific color (e.g. Blue line)

  final String? city;
  final String? country;
  final TransitType type;

  const TransitRoute(
      {required this.id,
      required this.polyline,
      required this.stops,
      this.color,
      this.city,
      this.country,
      this.type = TransitType.bus});
}
