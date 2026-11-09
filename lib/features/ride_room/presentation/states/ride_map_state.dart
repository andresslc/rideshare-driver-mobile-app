import 'package:driver_app/core/location/service_region.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum RideMapPhase { idle, toPickup, toDropoff }

class RideMapState {
  final LatLng cameraTarget;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final RideMapPhase phase;
  final String? activeRideId;
  final bool showMap;

  const RideMapState({
    required this.cameraTarget,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.circles = const <Circle>{},
    this.phase = RideMapPhase.idle,
    this.activeRideId,
    this.showMap = true,
  });

  factory RideMapState.initial() {
    return RideMapState(cameraTarget: ServiceRegionConfig.active.center, showMap: true);
  }

  RideMapState copyWith({
    LatLng? cameraTarget,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    Set<Circle>? circles,
    RideMapPhase? phase,
    String? activeRideId,
    bool clearRide = false,
    bool? showMap,
  }) {
    return RideMapState(
      cameraTarget: cameraTarget ?? this.cameraTarget,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      circles: circles ?? this.circles,
      phase: phase ?? this.phase,
      activeRideId: clearRide ? null : (activeRideId ?? this.activeRideId),
      showMap: showMap ?? this.showMap,
    );
  }

  @override
  int get hashCode => Object.hash(
    cameraTarget,
    Object.hashAll(markers),
    Object.hashAll(polylines),
    Object.hashAll(circles),
    phase,
    activeRideId,
    showMap,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideMapState &&
        other.cameraTarget == cameraTarget &&
        setEquals(other.markers, markers) &&
        setEquals(other.polylines, polylines) &&
        setEquals(other.circles, circles) &&
        other.phase == phase &&
        other.activeRideId == activeRideId &&
        other.showMap == showMap;
  }
}
