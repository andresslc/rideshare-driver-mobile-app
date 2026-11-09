import 'package:driver_app/core/location/service_region.dart';
import 'package:driver_app/shared/screens/place_picker_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CarpoolMapState {
  final LatLng cameraTarget;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final List<SelectedLocation> stops;
  final double routeDistanceMiles;
  final double routeAvgTimeMinutes;
  final String routeKey;

  const CarpoolMapState({
    required this.cameraTarget,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.circles = const <Circle>{},
    this.stops = const <SelectedLocation>[],
    this.routeDistanceMiles = 0,
    this.routeAvgTimeMinutes = 0,
    this.routeKey = '',
  });

  factory CarpoolMapState.initial() {
    return CarpoolMapState(cameraTarget: ServiceRegionConfig.active.center);
  }

  CarpoolMapState copyWith({
    LatLng? cameraTarget,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    Set<Circle>? circles,
    List<SelectedLocation>? stops,
    double? routeDistanceMiles,
    double? routeAvgTimeMinutes,
    String? routeKey,
  }) {
    return CarpoolMapState(
      cameraTarget: cameraTarget ?? this.cameraTarget,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      circles: circles ?? this.circles,
      stops: stops ?? this.stops,
      routeDistanceMiles: routeDistanceMiles ?? this.routeDistanceMiles,
      routeAvgTimeMinutes: routeAvgTimeMinutes ?? this.routeAvgTimeMinutes,
      routeKey: routeKey ?? this.routeKey,
    );
  }

  @override
  int get hashCode => Object.hash(
    cameraTarget,
    Object.hashAll(markers),
    Object.hashAll(polylines),
    Object.hashAll(circles),
    Object.hashAll(stops),
    routeDistanceMiles,
    routeAvgTimeMinutes,
    routeKey,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarpoolMapState &&
        other.cameraTarget == cameraTarget &&
        setEquals(other.markers, markers) &&
        setEquals(other.polylines, polylines) &&
        setEquals(other.circles, circles) &&
        listEquals(other.stops, stops) &&
        other.routeDistanceMiles == routeDistanceMiles &&
        other.routeAvgTimeMinutes == routeAvgTimeMinutes &&
        other.routeKey == routeKey;
  }
}
