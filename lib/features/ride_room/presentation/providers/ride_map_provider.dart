import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:driver_app/core/constants/app_icons.dart';
import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/services/location_service.dart';
import 'package:driver_app/core/utils/app_log.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:driver_app/features/ride_room/presentation/enums/ride_enum.dart';
import 'package:driver_app/features/ride_room/presentation/states/ride_map_state.dart';
import 'package:driver_app/features/ride_room/presentation/states/ride_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/constants_data.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:google_maps_utils/google_maps_utils.dart' as utils;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';

final rideMapProvider = NotifierProvider<RideMapProvider, RideMapState>(
  RideMapProvider.new,
);

class RideMapProvider extends Notifier<RideMapState> {
  static const MarkerId _carMarkerId = MarkerId('ride_driver_car');
  static const MarkerId _pickupMarkerId = MarkerId('ride_pickup_marker');
  static const MarkerId _dropoffMarkerId = MarkerId('ride_dropoff_marker');
  static const PolylineId _routePolylineId = PolylineId('ride_route_polyline');
  static const double _polylineTrimToleranceMeters = 8;
  static const double _currentLocationCameraOffsetMeters = 300;
  static const String _osrmBaseUrl = 'https://router.project-osrm.org';

  late final LocationService _locationService;
  final Dio _dio = Dio();
  final PolylinePoints _polylinePoints = PolylinePoints();

  GoogleMapController? _googleMapController;
  StreamSubscription<Position>? _locationSubscription;
  BitmapDescriptor? _carMarkerIcon;
  BitmapDescriptor? _pickupMarkerIcon;
  BitmapDescriptor? _dropoffMarkerIcon;
  LatLng? _driverLatLng;
  double _driverRotation = 0;
  RideEntity? _activeRide;
  bool _isRerouting = false;
  int _driverAnimationToken = 0;
  DateTime? _lastDriverLocationTime;
  double? _initialRouteDistanceMeters;
  double? _initialRouteDurationSeconds;

  @override
  RideMapState build() {
    _locationService = locator<LocationService>();

    ref.onDispose(() {
      final subscription = _locationSubscription;
      _locationSubscription = null;
      if (subscription != null) {
        unawaited(subscription.cancel());
      }
    });

    unawaited(_initialize());
    return RideMapState.initial();
  }

  Future<void> _initialize() async {
    await _loadMarkerIcons();
    await _primeCurrentLocation();
    await _startLocationTracking();
  }

  void attachController(GoogleMapController controller) {
    _googleMapController = controller;
    if (state.markers.isNotEmpty || state.polylines.isNotEmpty) {
      _scheduleFitCameraToVisiblePoints();
    }
  }

  void detachController([GoogleMapController? controller]) {
    if (controller != null && !identical(_googleMapController, controller)) {
      return;
    }
    _googleMapController = null;
  }

  void detachForNavigation() {
    _googleMapController = null;
    state = state.copyWith(showMap: false);
  }

  void reattachAfterNavigation() {
    state = state.copyWith(showMap: true);
  }

  Future<void> syncWithSocketState(RideSocketState socketState) async {
    final RideEntity? ride = socketState.ride;
    if (ride == null) {
      _activeRide = null;
      _initialRouteDistanceMeters = null;
      _initialRouteDurationSeconds = null;
      state = RideMapState.initial();
      return;
    }

    _activeRide = ride;
    final RideMapPhase nextPhase = _resolvePhase(socketState);
    final bool rideChanged = state.activeRideId != ride.id;
    final bool phaseChanged = state.phase != nextPhase;

    final LatLng? socketDriverLatLng = _driverLatLngFromSocket(socketState);
    if (socketDriverLatLng != null) {
      unawaited(
        _handleDriverLocation(socketDriverLatLng, animateCamera: false),
      );
    } else if (nextPhase == RideMapPhase.toPickup && _driverLatLng == null) {
      final LatLng? currentDriverLatLng = await _getCurrentDriverLatLng();
      if (currentDriverLatLng != null) {
        unawaited(
          _handleDriverLocation(currentDriverLatLng, animateCamera: false),
        );
      }
    }

    if (rideChanged || phaseChanged) {
      _initialRouteDistanceMeters = null;
      _initialRouteDurationSeconds = null;
      await _rebuildRoute(phase: nextPhase, animateCamera: true);
      return;
    }

    if (socketState.action == SocketAction.rideStart ||
        socketState.action == SocketAction.driverArrive) {
      _scheduleFitCameraToVisiblePoints();
    }

    await _refreshMapMarkers(phase: nextPhase, animateCamera: false);
  }

  Future<void> _startLocationTracking() async {
    final permission = await _locationService.requestLocationPermission();
    if (permission != LocationPermissionResult.granted) {
      return;
    }

    await _locationSubscription?.cancel();
    _locationSubscription = _locationService.getPositionStream().listen((
      position,
    ) {
      unawaited(
        _handleDriverLocation(
          LatLng(position.latitude, position.longitude),
          animateCamera: false,
        ),
      );
    });
  }

  Future<void> _primeCurrentLocation() async {
    final LatLng? latLng = await _getCurrentDriverLatLng();
    if (latLng == null) {
      return;
    }

    await _handleDriverLocation(latLng, animateCamera: true);
  }

  Future<void> _handleDriverLocation(
    LatLng latLng, {
    required bool animateCamera,
  }) async {
    if (_driverLatLng == null) {
      _driverLatLng = latLng;
      _driverRotation = 0.0;
      _lastDriverLocationTime = DateTime.now();

      if (_activeRide == null) {
        state = state.copyWith(
          cameraTarget: _withCameraOffset(latLng),
          markers: _buildMarkers(),
          circles: const <Circle>{},
        );
        if (animateCamera) {
          await _animateCameraSafely(
            CameraUpdate.newLatLngZoom(_withCameraOffset(latLng), 15),
          );
        }
        return;
      }

      _trimRoutePolylineToDriver(latLng);
      _checkArrivalProximity(latLng);
      await _checkDeviationAndReroute(latLng);
      await _refreshMapMarkers(
        phase: state.phase,
        animateCamera: animateCamera,
      );
      return;
    }

    final LatLng startPosition = _driverLatLng!;
    final double startRotation = _driverRotation;
    final double distanceMeters = _calculateDistanceMeters(
      startPosition,
      latLng,
    );

    if (distanceMeters < 0.3) {
      return;
    }

    final double targetBearing = distanceMeters >= 1.0
        ? _calculateBearing(startPosition, latLng)
        : startRotation;

    final DateTime now = DateTime.now();
    int totalDurationMs = 3500;
    if (_lastDriverLocationTime != null) {
      final int elapsedMs = now
          .difference(_lastDriverLocationTime!)
          .inMilliseconds;
      if (elapsedMs >= 1000 && elapsedMs <= 10000) {
        totalDurationMs = (elapsedMs * 0.95).round();
      }
    }
    _lastDriverLocationTime = now;

    final int token = ++_driverAnimationToken;
    const int frameIntervalMs = 40; // ~25 FPS smooth updates
    final int steps = math.max(16, (totalDurationMs / frameIntervalMs).round());
    final int stepDurationMs = math.max(1, totalDurationMs ~/ steps);
    final Stopwatch stopwatch = Stopwatch()..start();

    for (int i = 1; i <= steps; i++) {
      if (token != _driverAnimationToken) return;

      await Future.delayed(Duration(milliseconds: stepDurationMs));
      if (token != _driverAnimationToken) return;

      final double t = math.min(
        1.0,
        stopwatch.elapsedMilliseconds / totalDurationMs,
      );
      final LatLng intermediate = LatLng(
        startPosition.latitude + (latLng.latitude - startPosition.latitude) * t,
        startPosition.longitude +
            (latLng.longitude - startPosition.longitude) * t,
      );

      final double currentRotation = _lerpRotation(
        startRotation,
        targetBearing,
        t,
      );
      _driverLatLng = intermediate;
      _driverRotation = currentRotation;

      final bool isLastStep = i == steps || t >= 1.0;
      final bool shouldTrimPolyline = (i % 4 == 0) || isLastStep;

      if (_activeRide == null) {
        state = state.copyWith(
          cameraTarget: _withCameraOffset(intermediate),
          markers: _buildMarkers(),
          circles: const <Circle>{},
        );
        if (animateCamera && isLastStep) {
          await _animateCameraSafely(
            CameraUpdate.newLatLngZoom(_withCameraOffset(intermediate), 15),
          );
        }
      } else {
        if (shouldTrimPolyline) {
          _trimRoutePolylineToDriver(intermediate);
        }
        _checkArrivalProximity(intermediate);
        if (isLastStep) {
          await _checkDeviationAndReroute(intermediate);
        }
        await _refreshMapMarkers(
          phase: state.phase,
          animateCamera: animateCamera && isLastStep,
        );
      }
    }
  }

  Future<void> _rebuildRoute({
    required RideMapPhase phase,
    required bool animateCamera,
  }) async {
    final ride = _activeRide;
    if (ride == null) {
      return;
    }

    final LatLng? pickupLatLng = _ridePointToLatLng(ride.pickupPoint);
    final LatLng? dropoffLatLng = _ridePointToLatLng(
      ride.dropOffPointRequested,
    );

    if (phase == RideMapPhase.idle) {
      state = state.copyWith(
        phase: phase,
        activeRideId: ride.id,
        markers: _buildMarkers(),
        polylines: const <Polyline>{},
        circles: const <Circle>{},
      );
      return;
    }

    LatLng? origin;
    LatLng? destination;
    if (phase == RideMapPhase.toPickup) {
      origin = _driverLatLng ?? pickupLatLng;
      destination = pickupLatLng;
    } else {
      origin = pickupLatLng;
      destination = dropoffLatLng;
    }

    if (origin == null || destination == null) {
      state = state.copyWith(
        phase: phase,
        activeRideId: ride.id,
        markers: _buildMarkers(phase: phase),
        polylines: const <Polyline>{},
        circles: _buildCircles(phase: phase),
      );
      return;
    }

    final _RouteBuildResult route = await _buildPolyline(
      base: state.polylines,
      phase: phase,
      origin: origin,
      pickup: pickupLatLng!,
      dropOff: dropoffLatLng,
    );

    if (route.duration != null) {
      final minutes = math.max(1, (route.duration! / 60).round());
      final etaText = "$minutes min";
      ref.read(rideSocketProvider.notifier).updateEta(etaText);
    }

    state = state.copyWith(
      phase: phase,
      activeRideId: ride.id,
      cameraTarget: _withCameraOffset(_driverLatLng ?? origin),
      markers: _buildMarkers(phase: phase),
      polylines: route.polylines,
      circles: _buildCircles(phase: phase),
    );

    if (animateCamera) {
      _scheduleFitCameraToVisiblePoints();
    }
  }

  Future<void> _refreshMapMarkers({
    required RideMapPhase phase,
    required bool animateCamera,
  }) async {
    final nextMarkers = _buildMarkers(phase: phase);
    state = state.copyWith(
      phase: phase,
      activeRideId: _activeRide?.id,
      cameraTarget: _driverLatLng != null
          ? _withCameraOffset(_driverLatLng!)
          : state.cameraTarget,
      markers: nextMarkers,
      circles: _buildCircles(phase: phase),
    );

    if (animateCamera && _driverLatLng != null) {
      await _animateCameraSafely(
        CameraUpdate.newLatLngZoom(_withCameraOffset(_driverLatLng!), 15),
      );
    }
  }

  Set<Marker> _buildMarkers({RideMapPhase? phase}) {
    final currentPhase = phase ?? state.phase;
    final Set<Marker> markers = <Marker>{};

    if (_driverLatLng != null) {
      markers.add(
        Marker(
          markerId: _carMarkerId,
          position: _driverLatLng!,
          anchor: const Offset(0.5, 0.5),
          rotation: _driverRotation,
          flat: true,
          infoWindow: const InfoWindow(title: 'Driver'),
          icon:
              _carMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    final pickupLatLng = _ridePointToLatLng(_activeRide?.pickupPoint);
    if (pickupLatLng != null &&
        (currentPhase == RideMapPhase.toPickup ||
            currentPhase == RideMapPhase.toDropoff)) {
      markers.add(
        Marker(
          markerId: _pickupMarkerId,
          position: pickupLatLng,
          infoWindow: InfoWindow(
            title: 'Pickup',
            snippet: _activeRide?.pickupPoint?.placeName ?? '',
          ),
          icon:
              _pickupMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    final dropoffLatLng = _ridePointToLatLng(
      _activeRide?.dropOffPointRequested,
    );
    if (dropoffLatLng != null && currentPhase == RideMapPhase.toDropoff) {
      markers.add(
        Marker(
          markerId: _dropoffMarkerId,
          position: dropoffLatLng,
          infoWindow: InfoWindow(
            title: 'Dropoff',
            snippet: _activeRide?.dropOffPointRequested?.placeName ?? '',
          ),
          icon:
              _dropoffMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return Set<Marker>.unmodifiable(markers);
  }

  Set<Circle> _buildCircles({RideMapPhase? phase}) {
    final currentPhase = phase ?? state.phase;
    final Set<Circle> circles = <Circle>{};

    if (currentPhase == RideMapPhase.toPickup) {
      final pickupLatLng = _ridePointToLatLng(_activeRide?.pickupPoint);
      if (pickupLatLng != null) {
        if (_driverLatLng == null) {
          circles.add(
            Circle(
              circleId: const CircleId('ride_pickup_radius_circle'),
              center: pickupLatLng,
              radius: 100,
              fillColor: AppColors.brand.withOpacity(0.15),
              // strokeColor: AppColors.brand,
              strokeWidth: 0,
            ),
          );
        } else {
          final double distanceMeters = Geolocator.distanceBetween(
            _driverLatLng!.latitude,
            _driverLatLng!.longitude,
            pickupLatLng.latitude,
            pickupLatLng.longitude,
          );

          if (distanceMeters > 100) {
            circles.add(
              Circle(
                circleId: const CircleId('ride_pickup_radius_circle'),
                center: pickupLatLng,
                radius: 100,
                fillColor: AppColors.brand.withOpacity(0.15),
                // strokeColor: AppColors.brand,
                strokeWidth: 0,
              ),
            );
          }
        }
      }
    }

    return Set<Circle>.unmodifiable(circles);
  }

  RideMapPhase _resolvePhase(RideSocketState socketState) {
    final String rideStatus = (socketState.ride?.rideStatus ?? '')
        .trim()
        .toLowerCase();

    if (socketState.currentSheet == RideSheetsType.reachedPickup ||
        socketState.currentSheet == RideSheetsType.rideInProgress ||
        rideStatus == 'arrived' ||
        rideStatus == 'in-progress' ||
        rideStatus == 'in_progress' ||
        rideStatus == 'started' ||
        rideStatus == 'active') {
      return RideMapPhase.toDropoff;
    }

    if (rideStatus == 'completed' || rideStatus == 'cancelled') {
      return RideMapPhase.idle;
    }

    return RideMapPhase.toPickup;
  }

  LatLng? _driverLatLngFromSocket(RideSocketState socketState) {
    final location = socketState.driverLocation;
    if (location == null) {
      return null;
    }
    return LatLng(location.latitude, location.longitude);
  }

  LatLng? _ridePointToLatLng(RidePointEntity? point) {
    if (point == null) {
      return null;
    }
    return LatLng(point.location.latitude, point.location.longitude);
  }

  void _updateDriverLatLng(LatLng nextLatLng) {
    final LatLng? previousLatLng = _driverLatLng;
    if (previousLatLng != null && previousLatLng != nextLatLng) {
      _driverRotation = _calculateBearing(previousLatLng, nextLatLng);
    }
    _driverLatLng = nextLatLng;
  }

  double _calculateDistanceMeters(LatLng start, LatLng end) {
    final double lat1 = start.latitude * math.pi / 180;
    final double lng1 = start.longitude * math.pi / 180;
    final double lat2 = end.latitude * math.pi / 180;
    final double lng2 = end.longitude * math.pi / 180;

    final double dLat = lat2 - lat1;
    final double dLng = lng2 - lng1;

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return 6371000 * c;
  }

  double _calculatePolylineDistanceMeters(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += _calculateDistanceMeters(points[i], points[i + 1]);
    }
    debugPrint("total distance: $total");
    return total;
  }

  double _lerpRotation(double start, double end, double t) {
    double diff = (end - start + 180) % 360 - 180;
    if (diff < -180) diff += 360;
    return (start + diff * t + 360) % 360;
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final double lat1 = start.latitude * math.pi / 180;
    final double lng1 = start.longitude * math.pi / 180;
    final double lat2 = end.latitude * math.pi / 180;
    final double lng2 = end.longitude * math.pi / 180;

    final double dLng = lng2 - lng1;
    final double y = math.sin(dLng) * math.cos(lat2);
    final double x =
        (math.cos(lat1) * math.sin(lat2)) -
        (math.sin(lat1) * math.cos(lat2) * math.cos(dLng));
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  Future<_RouteBuildResult> _buildPolyline({
    required Set<Polyline> base,
    required RideMapPhase phase,
    required LatLng origin,
    required LatLng pickup,
    required LatLng? dropOff,
  }) async {
    if (phase == RideMapPhase.toPickup) {
      return _buildRoutePolyline(
        base: base,
        start: origin,
        end: pickup,
        color: AppColors.brand,
      );
    }

    return _buildRoutePolyline(
      base: base,
      start: pickup,
      end: dropOff,
      color: AppColors.brand,
    );
  }

  Future<_RouteBuildResult> _buildRoutePolyline({
    required Set<Polyline> base,
    required LatLng start,
    required LatLng? end,
    required Color color,
  }) async {
    if (end == null) {
      return _RouteBuildResult(
        polylines: _syncRoutePolyline(
          base: base,
          routePoints: const <LatLng>[],
          color: color,
        ),
      );
    }

    // Debug path: use OSRM for both polyline and duration (free).
    if (ApiEndpoints.useOsrmInDebug) {
      final _RouteMetrics? osrmRoute = await _fetchOsrmRouteMetrics(
        start: start,
        end: end,
      );
      if (osrmRoute != null && osrmRoute.points.length >= 2) {
        return _buildRouteResult(
          base: base,
          routePoints: osrmRoute.points,
          color: color,
          duration: osrmRoute.duration,
        );
      }
    }

    // Production path: Google Directions API for polyline + duration in one call.
    final String apiKey = remoteConfigModel.mapApiKey.trim();
    if (apiKey.isNotEmpty) {
      final _RouteMetrics? googleRoute = await _fetchGoogleRouteMetrics(
        start: start,
        end: end,
        apiKey: apiKey,
      );
      if (googleRoute != null && googleRoute.points.length >= 2) {
        return _buildRouteResult(
          base: base,
          routePoints: googleRoute.points,
          color: color,
          duration: googleRoute.duration,
        );
      }
    }

    // Fallback: OSRM (free) if Google fails or API key is empty.
    final _RouteMetrics? osrmFallback = ApiEndpoints.useOsrmInDebug
        ? null // Already tried above.
        : await _fetchOsrmRouteMetrics(start: start, end: end);
    if (osrmFallback != null && osrmFallback.points.length >= 2) {
      return _buildRouteResult(
        base: base,
        routePoints: osrmFallback.points,
        color: color,
        duration: osrmFallback.duration,
      );
    }

    // Last resort: straight line, no ETA.
    return _buildRouteResult(
      base: base,
      routePoints: <LatLng>[start, end],
      color: color,
    );
  }

  _RouteBuildResult _buildRouteResult({
    required Set<Polyline> base,
    required List<LatLng> routePoints,
    required Color color,
    double? duration,
  }) {
    if (routePoints.length >= 2 && duration != null && duration > 0) {
      _initialRouteDistanceMeters = _calculatePolylineDistanceMeters(
        routePoints,
      );
      _initialRouteDurationSeconds = duration;
      debugPrint(
        '🚗 [RideMapProvider] _buildRouteResult: routePoints=${routePoints.length}, '
        'initDist=${_initialRouteDistanceMeters?.toStringAsFixed(1)}m, '
        'initDur=${duration.toStringAsFixed(1)}s (${(duration / 60).round()} min)',
      );
    } else {
      debugPrint(
        '⚠️ [RideMapProvider] _buildRouteResult without metrics: '
        'routePoints=${routePoints.length}, duration=$duration',
      );
    }

    return _RouteBuildResult(
      polylines: _syncRoutePolyline(
        base: base,
        routePoints: routePoints,
        color: color,
      ),
      duration: duration,
    );
  }

  Set<Polyline> _syncRoutePolyline({
    required Set<Polyline> base,
    required List<LatLng> routePoints,
    required Color color,
  }) {
    final Set<Polyline> next = Set<Polyline>.from(base)
      ..removeWhere((polyline) => polyline.polylineId == _routePolylineId);

    if (routePoints.length >= 2) {
      next.add(
        Polyline(
          polylineId: _routePolylineId,
          points: routePoints,
          color: color,
          width: 3,
          geodesic: true,
        ),
      );
    }

    return Set<Polyline>.unmodifiable(next);
  }

  void _trimRoutePolylineToDriver(LatLng driverLocation) {
    final Polyline? routePolyline = state.polylines.where((polyline) {
      return polyline.polylineId == _routePolylineId;
    }).firstOrNull;

    if (routePolyline == null || routePolyline.points.length < 2) {
      return;
    }

    final List<LatLng> points = routePolyline.points;

    final math.Point<num> driverPoint = math.Point<num>(
      driverLocation.longitude,
      driverLocation.latitude,
    );

    int nearestIndex = -1;
    double minDistance = double.infinity;

    // 🔥 Find nearest SEGMENT (not point)
    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];

      final math.Point<num> p1 = math.Point(a.longitude, a.latitude);
      final math.Point<num> p2 = math.Point(b.longitude, b.latitude);

      final double distance = utils.PolyUtils.distanceToLine(
        driverPoint,
        p1,
        p2,
      ).toDouble();

      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    // 🔥 STRICT tolerance check (prevents wrong-road movement)
    const double toleranceMeters = 15;

    if (nearestIndex == -1 || minDistance > toleranceMeters) {
      debugPrint(
        '⚠️ [RideMapProvider] _trimRoutePolylineToDriver SKIPPED: '
        'nearestIndex=$nearestIndex, minDistance=${minDistance.toStringAsFixed(1)}m > tol=$toleranceMeters m',
      );
      return;
    }

    // 🔥 SNAP driver to route segment (prevents drift issues)
    final LatLng snappedDriver = _snapToSegment(
      driverLocation,
      points[nearestIndex],
      points[nearestIndex + 1],
    );

    final List<LatLng> remainingPoints = <LatLng>[
      snappedDriver,
      ...points.skip(nearestIndex + 1),
    ];

    final Set<Polyline> nextPolylines = Set<Polyline>.from(state.polylines)
      ..removeWhere((polyline) => polyline.polylineId == _routePolylineId);

    if (remainingPoints.length >= 2) {
      nextPolylines.add(routePolyline.copyWith(pointsParam: remainingPoints));
      if (state.phase == RideMapPhase.toPickup &&
          _initialRouteDistanceMeters != null &&
          _initialRouteDistanceMeters! > 0 &&
          _initialRouteDurationSeconds != null &&
          _initialRouteDurationSeconds! > 0) {
        final double remainingDistance = _calculatePolylineDistanceMeters(
          remainingPoints,
        );
        final double progressRatio =
            (remainingDistance / _initialRouteDistanceMeters!).clamp(0.0, 1.0);
        final double remainingDuration =
            _initialRouteDurationSeconds! * progressRatio;
        final int minutes = math.max(1, (remainingDuration / 60).round());
        final String etaText = "$minutes min";
        debugPrint(
          '📍 [RideMapProvider] _trimRoutePolylineToDriver: remaining=${remainingPoints.length} pts, '
          'remDist=${remainingDistance.toStringAsFixed(1)}m / initDist=${_initialRouteDistanceMeters?.toStringAsFixed(1)}m, '
          'ratio=${progressRatio.toStringAsFixed(2)}, remDur=${remainingDuration.toStringAsFixed(1)}s -> ETA=$etaText',
        );
        ref.read(rideSocketProvider.notifier).updateEta(etaText);
      } else {
        debugPrint(
          '⚠️ [RideMapProvider] _trimRoutePolylineToDriver: Cannot calc ETA: '
          'phase=${state.phase}, initDist=$_initialRouteDistanceMeters, initDur=$_initialRouteDurationSeconds',
        );
      }
    }

    state = state.copyWith(
      polylines: Set<Polyline>.unmodifiable(nextPolylines),
      circles: _buildCircles(),
    );

    if (remainingPoints.length < 2) {
      _checkArrivalProximity(driverLocation, routeFinished: true);
    }
  }

  void _checkArrivalProximity(
    LatLng driverLocation, {
    bool routeFinished = false,
  }) {
    if (state.phase != RideMapPhase.toPickup || _activeRide == null) return;
    final LatLng? pickupLatLng = _ridePointToLatLng(_activeRide?.pickupPoint);
    if (pickupLatLng == null) return;

    final double distToPickup = _calculateDistanceMeters(
      driverLocation,
      pickupLatLng,
    );
    if (distToPickup <= 60 || routeFinished) {
      debugPrint(
        '🎯 [RideMapProvider] _checkArrivalProximity TRIGGERED: '
        'distToPickup=${distToPickup.toStringAsFixed(1)}m, routeFinished=$routeFinished -> ETA=1 min',
      );
      ref.read(rideSocketProvider.notifier).updateEta('1 min');
    }
  }

  Future<void> _checkDeviationAndReroute(LatLng driverLatLng) async {
    if (_isRerouting) return;
    if (_activeRide == null || state.phase == RideMapPhase.idle) return;

    final current = state;

    final LatLng? destination = state.phase == RideMapPhase.toPickup
        ? _ridePointToLatLng(_activeRide?.pickupPoint)
        : _ridePointToLatLng(_activeRide?.dropOffPointRequested);

    if (destination == null) return;

    final Polyline? routePolyline = current.polylines
        .where((p) => p.polylineId == _routePolylineId)
        .cast<Polyline?>()
        .firstWhere((p) => p != null, orElse: () => null);

    final bool isRouteInvalid =
        routePolyline == null || routePolyline.points.length < 2;

    bool hasDeviated = false;
    if (!isRouteInvalid) {
      final detector = RouteDeviationDetector(deviationThresholdMeters: 40);
      hasDeviated = detector.hasDeviated(driverLatLng, routePolyline!.points);
    }

    if (isRouteInvalid || hasDeviated) {
      final String reason = isRouteInvalid
          ? 'Route is empty or invalid. Initializing route...'
          : 'Driver has deviated from route. Rerouting...';
      log(reason, name: 'RideMapProvider');
      _isRerouting = true;
      try {
        final _RouteBuildResult routeResult = await _buildRoutePolyline(
          base: state.polylines,
          start: driverLatLng,
          end: destination,
          color: AppColors.brand,
        );

        if (routeResult.polylines.isNotEmpty) {
          state = state.copyWith(
            polylines: routeResult.polylines,
            circles: _buildCircles(),
          );
          if (routeResult.duration != null) {
            final minutes = math.max(1, (routeResult.duration! / 60).round());
            final etaText = "$minutes min";
            ref.read(rideSocketProvider.notifier).updateEta(etaText);
          }
        }
      } catch (e, s) {
        log('Rerouting failed: $e', name: 'RideMapProvider');
      } finally {
        _isRerouting = false;
      }
    }
  }

  LatLng _snapToSegment(LatLng p, LatLng a, LatLng b) {
    final double ax = a.longitude;
    final double ay = a.latitude;
    final double bx = b.longitude;
    final double by = b.latitude;
    final double px = p.longitude;
    final double py = p.latitude;

    final double dx = bx - ax;
    final double dy = by - ay;

    if (dx == 0 && dy == 0) return a;

    final double t = ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy);

    final double clampedT = t.clamp(0.0, 1.0);

    return LatLng(ay + clampedT * dy, ax + clampedT * dx);
  }

  // void _trimRoutePolylineToDriver(LatLng driverLocation) {
  //   final Polyline? routePolyline = state.polylines.where((polyline) {
  //     return polyline.polylineId == _routePolylineId;
  //   }).firstOrNull;
  //   if (routePolyline == null || routePolyline.points.length < 2) {
  //     return;
  //   }

  //   final List<LatLng> points = routePolyline.points;
  //   final math.Point<num> driverPoint = math.Point<num>(
  //     driverLocation.longitude,
  //     driverLocation.latitude,
  //   );
  //   final List<math.Point<num>> polylinePath = points
  //       .map((point) => math.Point<num>(point.longitude, point.latitude))
  //       .toList(growable: false);

  //   final bool isOnPath = utils.PolyUtils.isLocationOnPathTolerance(
  //     driverPoint,
  //     polylinePath,
  //     false,
  //     _polylineTrimToleranceMeters,
  //   );
  //   if (!isOnPath) {
  //     return;
  //   }

  //   int nearestIndex = -1;
  //   double? nearestDistanceMeters;
  //   for (int i = 0; i < points.length; i++) {
  //     final LatLng point = points[i];
  //     final double distanceMeters = utils.SphericalUtils.computeDistanceBetween(
  //       driverPoint,
  //       math.Point<num>(point.longitude, point.latitude),
  //     ).toDouble();

  //     if (nearestDistanceMeters == null ||
  //         distanceMeters < nearestDistanceMeters) {
  //       nearestDistanceMeters = distanceMeters;
  //       nearestIndex = i;
  //     }
  //   }

  //   if (nearestIndex == -1 ||
  //       nearestDistanceMeters == null ||
  //       nearestDistanceMeters > _polylineTrimToleranceMeters) {
  //     return;
  //   }

  //   final List<LatLng> remainingPoints = <LatLng>[
  //     driverLocation,
  //     ...points.skip(nearestIndex + 1),
  //   ];

  //   final Set<Polyline> nextPolylines = Set<Polyline>.from(state.polylines)
  //     ..removeWhere((polyline) => polyline.polylineId == _routePolylineId);

  //   if (remainingPoints.length >= 2) {
  //     nextPolylines.add(routePolyline.copyWith(pointsParam: remainingPoints));
  //   }

  //   state = state.copyWith(
  //     polylines: Set<Polyline>.unmodifiable(nextPolylines),
  //   );
  // }

  Future<_RouteMetrics?> _fetchOsrmRouteMetrics({
    required LatLng start,
    required LatLng end,
  }) async {
    try {
      final String coordinates =
          '${start.longitude},${start.latitude};'
          '${end.longitude},${end.latitude}';
      final Uri uri = Uri.parse(
        '$_osrmBaseUrl/route/v1/driving/$coordinates'
        '?overview=full&geometries=polyline&steps=false',
      );

      final Response<dynamic> response = await _dio.getUri(uri);
      final dynamic payload = response.data;
      final Map<String, dynamic> data = payload is Map<String, dynamic>
          ? payload
          : Map<String, dynamic>.from(jsonDecode(payload.toString()) as Map);

      final List<dynamic> routes =
          data['routes'] as List<dynamic>? ?? <dynamic>[];
      if (routes.isEmpty) return null;

      final Map<String, dynamic> firstRoute =
          routes.first is Map<String, dynamic>
          ? routes.first as Map<String, dynamic>
          : Map<String, dynamic>.from(routes.first as Map);

      final String geometry = (firstRoute['geometry'] ?? '').toString();
      if (geometry.isEmpty) return null;

      final List<PointLatLng> decoded = _polylinePoints.decodePolyline(
        geometry,
      );
      if (decoded.isEmpty) return null;

      final List<LatLng> points = decoded
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList(growable: false);

      final double? duration = firstRoute['duration'] == null
          ? null
          : (firstRoute['duration'] as num).toDouble();

      return _RouteMetrics(points: points, duration: duration);
    } catch (e) {
      log('OSRM route fetch failed: $e', name: 'RideMapProvider');
      return null;
    }
  }

  /// Fetches route polyline + duration from Google Directions API in one call.
  Future<_RouteMetrics?> _fetchGoogleRouteMetrics({
    required LatLng start,
    required LatLng end,
    required String apiKey,
  }) async {
    try {
      final Uri uri =
          Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
            'origin': '${start.latitude},${start.longitude}',
            'destination': '${end.latitude},${end.longitude}',
            'mode': 'driving',
            'key': apiKey,
          });

      final Response<dynamic> response = await _dio.getUri(uri);
      final dynamic payload = response.data;
      final Map<String, dynamic> data = payload is Map<String, dynamic>
          ? payload
          : Map<String, dynamic>.from(jsonDecode(payload.toString()) as Map);

      if (data['status'] != 'OK') {
        log(
          'Google Directions status: ${data['status']}',
          name: 'RideMapProvider',
        );
        return null;
      }

      final List<dynamic> routes =
          data['routes'] as List<dynamic>? ?? <dynamic>[];
      if (routes.isEmpty) return null;

      final Map<String, dynamic> route = Map<String, dynamic>.from(
        routes.first as Map,
      );

      // Decode polyline.
      final String encoded = (route['overview_polyline']?['points'] ?? '')
          .toString();
      if (encoded.isEmpty) return null;

      final List<PointLatLng> decoded = _polylinePoints.decodePolyline(encoded);
      if (decoded.isEmpty) return null;

      final List<LatLng> points = decoded
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList(growable: false);

      // Parse duration (seconds) from the first leg.
      double? duration;
      final List<dynamic> legs = route['legs'] as List<dynamic>? ?? <dynamic>[];
      if (legs.isNotEmpty) {
        final Map<String, dynamic> leg = Map<String, dynamic>.from(
          legs.first as Map,
        );
        duration = (leg['duration']?['value'] as num?)?.toDouble();
      }

      return _RouteMetrics(points: points, duration: duration);
    } catch (e) {
      log('Google Directions fetch failed: $e', name: 'RideMapProvider');
      return null;
    }
  }

  Future<void> _fitCameraToVisiblePoints() async {
    final controller = _googleMapController;
    if (controller == null) {
      return;
    }

    final List<LatLng> points = <LatLng>[];
    final LatLng? pickupLatLng = _ridePointToLatLng(_activeRide?.pickupPoint);
    final LatLng? dropoffLatLng = _ridePointToLatLng(
      _activeRide?.dropOffPointRequested,
    );

    if (_driverLatLng != null) {
      points.add(_driverLatLng!);
    }

    if (state.phase == RideMapPhase.toPickup && pickupLatLng != null) {
      points.add(pickupLatLng);
    } else if (state.phase == RideMapPhase.toDropoff && dropoffLatLng != null) {
      points.add(dropoffLatLng);
    }

    if (points.isEmpty) {
      return;
    }

    if (points.length == 1) {
      await _animateCameraSafely(
        CameraUpdate.newLatLngZoom(_withCameraOffset(points.first), 15),
        controller: controller,
      );
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    await _animateCameraSafely(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100,
      ),
      controller: controller,
    );
  }

  void _scheduleFitCameraToVisiblePoints() {
    final GoogleMapController? controller = _googleMapController;
    if (controller == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!identical(_googleMapController, controller)) {
        return;
      }

      unawaited(_fitCameraToVisiblePoints());
      unawaited(_retryFitCameraToVisiblePoints(controller));
    });
  }

  Future<void> _retryFitCameraToVisiblePoints(
    GoogleMapController controller,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!identical(_googleMapController, controller)) {
      return;
    }
    await _fitCameraToVisiblePoints();
  }

  Future<void> _animateCameraSafely(
    CameraUpdate update, {
    GoogleMapController? controller,
  }) async {
    final GoogleMapController? targetController =
        controller ?? _googleMapController;
    if (targetController == null) {
      return;
    }

    try {
      await targetController.animateCamera(update);
    } on StateError catch (error) {
      if (_isDisposedControllerError(error)) {
        if (identical(_googleMapController, targetController)) {
          _googleMapController = null;
        }
        log(
          'Ignoring camera update for disposed GoogleMapController: $error',
          name: 'RideMapProvider',
        );
        return;
      }
      rethrow;
    }
  }

  bool _isDisposedControllerError(StateError error) {
    return error.message.contains(
      'was used after the associated GoogleMap widget had already been disposed',
    );
  }

  Future<void> _loadMarkerIcons() async {
    _carMarkerIcon = await _loadMarkerIcon(
      assetPath: AppIcons.car,
      size: const Size(40, 40),
    );
    _pickupMarkerIcon = await _loadMarkerIcon(
      assetPath: AppIcons.locationMarker,
      size: const Size(35, 35),
    );
    _dropoffMarkerIcon = await _loadMarkerIcon(
      assetPath: AppIcons.stopMarker,
      size: const Size(40, 40),
    );
  }

  Future<BitmapDescriptor?> _loadMarkerIcon({
    required String assetPath,
    required Size size,
  }) async {
    try {
      return await BitmapDescriptor.asset(
        const ImageConfiguration(),
        assetPath,
        height: size.height,
      );
    } catch (_) {
      return null;
    }
  }

  Future<LatLng?> _getCurrentDriverLatLng() async {
    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      return null;
    }

    return LatLng(position.latitude, position.longitude);
  }

  LatLng _withCameraOffset(LatLng source) {
    const double metersPerLatitudeDegree = 111320;
    const double latitudeOffset =
        _currentLocationCameraOffsetMeters / metersPerLatitudeDegree;
    return LatLng(source.latitude - latitudeOffset, source.longitude);
  }
}

class _RouteBuildResult {
  final Set<Polyline> polylines;
  final double? duration;

  const _RouteBuildResult({required this.polylines, this.duration});
}

class _RouteMetrics {
  final List<LatLng> points;
  final double? duration;

  const _RouteMetrics({required this.points, this.duration});
}

class RouteDeviationDetector {
  final double deviationThresholdMeters;

  RouteDeviationDetector({this.deviationThresholdMeters = 40.0}); // 500M

  /// Calculates the perpendicular (shortest) distance from the driver's current
  /// position to each segment of the route polyline using the Haversine formula.
  /// Returns true if the minimum distance to any segment exceeds the threshold.
  bool hasDeviated(LatLng currentPosition, List<LatLng> routePoints) {
    if (routePoints.isEmpty) return false;
    if (routePoints.length < 2) {
      final double distance = _haversineDistance(
        currentPosition,
        routePoints.first,
      );
      return distance > deviationThresholdMeters;
    }

    double minDistance = double.infinity;

    for (int i = 0; i < routePoints.length - 1; i++) {
      final LatLng a = routePoints[i];
      final LatLng b = routePoints[i + 1];

      final LatLng snapped = _projectPointOnSegment(currentPosition, a, b);
      final double distance = _haversineDistance(currentPosition, snapped);

      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    return minDistance > deviationThresholdMeters;
  }

  LatLng _projectPointOnSegment(LatLng p, LatLng a, LatLng b) {
    final double ax = a.longitude;
    final double ay = a.latitude;
    final double bx = b.longitude;
    final double by = b.latitude;
    final double px = p.longitude;
    final double py = p.latitude;

    final double dx = bx - ax;
    final double dy = by - ay;

    if (dx == 0 && dy == 0) return a;

    final double t = ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy);
    final double clampedT = t.clamp(0.0, 1.0);

    return LatLng(ay + clampedT * dy, ax + clampedT * dx);
  }

  double _haversineDistance(LatLng p1, LatLng p2) {
    const double R = 6371000; // Earth's radius in meters
    final double lat1 = p1.latitude * math.pi / 180;
    final double lat2 = p2.latitude * math.pi / 180;
    final double lon1 = p1.longitude * math.pi / 180;
    final double lon2 = p2.longitude * math.pi / 180;

    final double dlat = lat2 - lat1;
    final double dlon = lon2 - lon1;

    final double a =
        math.sin(dlat / 2) * math.sin(dlat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dlon / 2) *
            math.sin(dlon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }
}
