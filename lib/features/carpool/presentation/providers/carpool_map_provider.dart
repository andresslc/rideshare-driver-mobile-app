import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:driver_app/core/constants/app_icons.dart';
import 'package:driver_app/core/theme/app_colors.dart';
import 'package:driver_app/core/utils/app_log.dart';
import 'package:driver_app/features/carpool/presentation/states/carpool_map_state.dart';
import 'package:driver_app/shared/screens/place_picker_screen.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/constants_data.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_utils/google_maps_utils.dart' as utils;
import 'package:google_maps_flutter/google_maps_flutter.dart';

final carpoolMapProvider =
    NotifierProvider<CarpoolMapProvider, CarpoolMapState>(
      CarpoolMapProvider.new,
    );

class CarpoolMapProvider extends Notifier<CarpoolMapState> {
  static const MarkerId _driverMarkerId = MarkerId('carpool_driver_marker');
  static const MarkerId _pickupMarkerId = MarkerId('carpool_pickup_marker');
  static const MarkerId _dropoffMarkerId = MarkerId('carpool_dropoff_marker');
  static const String _stopMarkerPrefix = 'carpool_stop_marker_';
  static const PolylineId _routePolylineId = PolylineId(
    'carpool_route_polyline',
  );
  static const String _osrmBaseUrl = 'https://router.project-osrm.org';
  static const double _currentLocationCameraOffsetMeters = 300;
  static const double _averageDrivingSpeedKmh = 35;
  static const double _kilometersToMiles = 0.621371;
  static const double _polylineTrimToleranceMeters = 15;

  final Dio _dio = Dio();
  final PolylinePoints _polylinePoints = PolylinePoints();

  GoogleMapController? _googleMapController;
  BitmapDescriptor? _driverMarkerIcon;
  BitmapDescriptor? _pickupMarkerIcon;
  BitmapDescriptor? _dropoffMarkerIcon;
  BitmapDescriptor? _stopMarkerIcon;
  LatLng? _driverLatLng;
  double _driverRotation = 0;
  List<SelectedLocation> _routeStops = const <SelectedLocation>[];
  bool _isRideStarted = false;

  void setRideStarted(bool isStarted) {
    _isRideStarted = isStarted;
    if (_isRideStarted && _driverLatLng != null) {
      _trimRoutePolylineToDriver(_driverLatLng!);
    }
  }

  @override
  CarpoolMapState build() {
    unawaited(_loadMarkerIcons());
    return CarpoolMapState.initial();
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

  Future<void> syncStops(
    List<SelectedLocation> stops, {
    bool autoFit = true,
  }) async {
    final List<SelectedLocation> normalizedStops = _normalizeStops(stops);
    final String nextRouteKey = _routeKey(normalizedStops);
    final bool routeChanged = nextRouteKey != state.routeKey;

    _routeStops = normalizedStops;

    if (normalizedStops.length < 2) {
      state = state.copyWith(
        stops: normalizedStops,
        routeKey: nextRouteKey,
        markers: _buildMarkers(stops: normalizedStops),
        polylines: _syncRoutePolyline(
          base: state.polylines,
          routePoints: const <LatLng>[],
        ),
        circles: const <Circle>{},
        routeDistanceMiles: 0,
        routeAvgTimeMinutes: 0,
        cameraTarget: _driverLatLng != null
            ? _withCameraOffset(_driverLatLng!)
            : (normalizedStops.isNotEmpty
                  ? LatLng(
                      normalizedStops.first.latitude,
                      normalizedStops.first.longitude,
                    )
                  : state.cameraTarget),
      );
      return;
    }

    if (!routeChanged) {
      state = state.copyWith(
        stops: normalizedStops,
        markers: _buildMarkers(stops: normalizedStops),
      );
      if (autoFit) {
        _scheduleFitCameraToVisiblePoints();
      }
      return;
    }

    final List<LatLng> routePoints = await _buildRoutePoints(normalizedStops);
    final Set<Polyline> polylines = _syncRoutePolyline(
      base: state.polylines,
      routePoints: routePoints,
    );
    final double routeDistanceKm = _calculateRouteDistanceKm(routePoints);
    final double routeDistanceMiles = routeDistanceKm * _kilometersToMiles;
    // final double routeAvgTimeMinutes = routeDistanceKm <= 0
    //     ? 0
    //     : (routeDistanceKm / _averageDrivingSpeedKmh) * 60;
    final double routeAvgTimeMinutes = _estimateDurationMinutes(
      routeDistanceKm,
    ).toDouble();

    state = state.copyWith(
      stops: normalizedStops,
      routeKey: nextRouteKey,
      markers: _buildMarkers(stops: normalizedStops),
      polylines: polylines,
      circles: const <Circle>{},
      routeDistanceMiles: routeDistanceMiles,
      routeAvgTimeMinutes: routeAvgTimeMinutes,
      cameraTarget: _driverLatLng != null
          ? _withCameraOffset(_driverLatLng!)
          : LatLng(
              normalizedStops.first.latitude,
              normalizedStops.first.longitude,
            ),
    );

    if (_isRideStarted && _driverLatLng != null) {
      _trimRoutePolylineToDriver(_driverLatLng!);
    }

    if (autoFit) {
      _scheduleFitCameraToVisiblePoints();
    }
  }

  int _estimateDurationMinutes(double distanceKm) {
    if (distanceKm <= 0) return 0;

    // Fallback average speed (urban traffic)
    const double averageSpeedKmPerHour = 30;

    final double hours = distanceKm / averageSpeedKmPerHour;

    // convert hours → minutes
    return (hours * 60).round();
  }

  Future<void> updateDriverLocation(
    LatLng latLng, {
    required bool animateCamera,
    bool? isRideStarted,
  }) async {
    if (isRideStarted != null) {
      _isRideStarted = isRideStarted;
    }
    _updateDriverLatLng(latLng);
    if (_isRideStarted) {
      _trimRoutePolylineToDriver(latLng);
    }
    state = state.copyWith(
      cameraTarget: _withCameraOffset(latLng),
      markers: _buildMarkers(stops: _routeStops),
    );

    if (animateCamera) {
      await _animateCameraSafely(
        CameraUpdate.newLatLngZoom(_withCameraOffset(latLng), 15),
      );
    }
  }

  Future<void> animateDriverAlongRoute(LatLng destination) async {
    final Polyline? routePolyline = state.polylines
        .where((polyline) => polyline.polylineId == _routePolylineId)
        .firstOrNull;
    final LatLng? currentDriverLatLng = _driverLatLng;
    if (routePolyline == null ||
        routePolyline.points.isEmpty ||
        currentDriverLatLng == null) {
      await updateDriverLocation(destination, animateCamera: true);
      return;
    }

    final int startIndex = _nearestRoutePointIndex(
      currentDriverLatLng,
      routePolyline.points,
    );
    final int endIndex = _nearestRoutePointIndex(
      destination,
      routePolyline.points,
    );
    if (startIndex == endIndex) {
      await updateDriverLocation(destination, animateCamera: true);
      return;
    }

    final int step = endIndex > startIndex ? 1 : -1;
    for (int i = startIndex + step; i != endIndex + step; i += step) {
      await updateDriverLocation(
        routePolyline.points[i],
        animateCamera: i == endIndex,
      );
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
  }

  Set<Marker> _buildMarkers({required List<SelectedLocation> stops}) {
    final Set<Marker> markers = <Marker>{};

    if (_driverLatLng != null) {
      markers.add(
        Marker(
          markerId: _driverMarkerId,
          position: _driverLatLng!,
          anchor: const Offset(0.5, 0.5),
          rotation: _driverRotation,
          flat: true,
          infoWindow: const InfoWindow(title: 'Driver'),
          icon:
              _driverMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    for (int i = 0; i < stops.length; i++) {
      final SelectedLocation stop = stops[i];
      final bool isFirst = i == 0;
      final bool isLast = i == stops.length - 1;

      markers.add(
        Marker(
          markerId: isFirst
              ? _pickupMarkerId
              : isLast
              ? _dropoffMarkerId
              : MarkerId('$_stopMarkerPrefix$i'),
          position: LatLng(stop.latitude, stop.longitude),
          infoWindow: InfoWindow(
            title: isFirst
                ? 'Pickup'
                : isLast
                ? 'Dropoff'
                : 'Stop $i',
            snippet: stop.formattedAddress,
          ),
          icon: isFirst
              ? (_pickupMarkerIcon ??
                    BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ))
              : isLast
              ? (_dropoffMarkerIcon ??
                    BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ))
              : (_stopMarkerIcon ??
                    BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    )),
        ),
      );
    }

    return Set<Marker>.unmodifiable(markers);
  }

  Future<List<LatLng>> _buildRoutePoints(List<SelectedLocation> stops) async {
    final List<LatLng> routePoints = <LatLng>[];

    for (int i = 0; i < stops.length - 1; i++) {
      final LatLng start = LatLng(stops[i].latitude, stops[i].longitude);
      final LatLng end = LatLng(stops[i + 1].latitude, stops[i + 1].longitude);
      final List<LatLng> segment = await _fetchRouteSegment(
        start: start,
        end: end,
      );

      if (segment.isEmpty) {
        if (routePoints.isNotEmpty && routePoints.last == start) {
          routePoints.add(end);
        } else {
          routePoints.addAll(<LatLng>[start, end]);
        }
        continue;
      }

      if (routePoints.isNotEmpty && routePoints.last == segment.first) {
        routePoints.addAll(segment.skip(1));
      } else {
        routePoints.addAll(segment);
      }
    }

    return routePoints;
  }

  Future<List<LatLng>> _fetchRouteSegment({
    required LatLng start,
    required LatLng end,
  }) async {
    if (ApiEndpoints.useOsrmInDebug) {
      final List<LatLng>? osrmRoute = await _fetchOsrmRoutePoints(
        start: start,
        end: end,
      );
      if (osrmRoute != null && osrmRoute.length >= 2) {
        return osrmRoute;
      }
    }

    final String apiKey = remoteConfigModel.mapApiKey.trim();
    if (apiKey.isEmpty) {
      return <LatLng>[start, end];
    }

    try {
      final PolylineResult result = await _polylinePoints
          .getRouteBetweenCoordinates(
            googleApiKey: apiKey,
            request: PolylineRequest(
              origin: PointLatLng(start.latitude, start.longitude),
              destination: PointLatLng(end.latitude, end.longitude),
              mode: TravelMode.driving,
            ),
          );
      if (result.points.isEmpty) {
        return <LatLng>[start, end];
      }
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(growable: false);
    } catch (error) {
      log(
        'Carpool route segment fetch failed: $error',
        name: 'CarpoolMapProvider',
      );
      return <LatLng>[start, end];
    }
  }

  Future<List<LatLng>?> _fetchOsrmRoutePoints({
    required LatLng start,
    required LatLng end,
  }) async {
    try {
      final String coordinates =
          '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
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
      if (routes.isEmpty) {
        return null;
      }

      final Map<String, dynamic> firstRoute =
          routes.first is Map<String, dynamic>
          ? routes.first as Map<String, dynamic>
          : Map<String, dynamic>.from(routes.first as Map);
      final String geometry = (firstRoute['geometry'] ?? '').toString();
      if (geometry.isEmpty) {
        return null;
      }

      return _polylinePoints
          .decodePolyline(geometry)
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(growable: false);
    } catch (error) {
      log(
        'Carpool OSRM route fetch failed: $error',
        name: 'CarpoolMapProvider',
      );
      return null;
    }
  }

  Set<Polyline> _syncRoutePolyline({
    required Set<Polyline> base,
    required List<LatLng> routePoints,
  }) {
    final Set<Polyline> next = Set<Polyline>.from(base)
      ..removeWhere((polyline) => polyline.polylineId == _routePolylineId);

    if (routePoints.length >= 2) {
      next.add(
        Polyline(
          polylineId: _routePolylineId,
          points: routePoints,
          color: AppColors.brand,
          width: 3,
          geodesic: true,
        ),
      );
    }

    return Set<Polyline>.unmodifiable(next);
  }

  void _trimRoutePolylineToDriver(LatLng driverLocation) {
    if (!_isRideStarted) {
      return;
    }
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

    for (int i = 0; i < points.length - 1; i++) {
      final LatLng a = points[i];
      final LatLng b = points[i + 1];

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

    if (nearestIndex == -1 || minDistance > _polylineTrimToleranceMeters) {
      return;
    }

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
    }

    state = state.copyWith(
      polylines: Set<Polyline>.unmodifiable(nextPolylines),
    );
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

  void _updateDriverLatLng(LatLng nextLatLng) {
    final LatLng? previousLatLng = _driverLatLng;
    if (previousLatLng != null && previousLatLng != nextLatLng) {
      _driverRotation = _calculateBearing(previousLatLng, nextLatLng);
    }
    _driverLatLng = nextLatLng;
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

  int _nearestRoutePointIndex(LatLng point, List<LatLng> routePoints) {
    int nearestIndex = 0;
    double nearestDistance = double.infinity;

    for (int i = 0; i < routePoints.length; i++) {
      final LatLng routePoint = routePoints[i];
      final double distance = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        routePoint.latitude,
        routePoint.longitude,
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }

    return nearestIndex;
  }

  double _calculateRouteDistanceKm(List<LatLng> routePoints) {
    if (routePoints.length < 2) {
      return 0;
    }

    double totalMeters = 0;
    for (int i = 0; i < routePoints.length - 1; i++) {
      final LatLng start = routePoints[i];
      final LatLng end = routePoints[i + 1];
      totalMeters += Geolocator.distanceBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
    }

    return totalMeters / 1000;
  }

  List<SelectedLocation> _normalizeStops(List<SelectedLocation> stops) {
    final List<SelectedLocation> normalizedStops = <SelectedLocation>[];
    for (final SelectedLocation stop in stops) {
      final bool exists = normalizedStops.any(
        (item) =>
            (item.latitude - stop.latitude).abs() <= 0.00001 &&
            (item.longitude - stop.longitude).abs() <= 0.00001 &&
            item.formattedAddress == stop.formattedAddress,
      );
      if (!exists) {
        normalizedStops.add(stop);
      }
    }
    return List<SelectedLocation>.unmodifiable(normalizedStops);
  }

  String _routeKey(List<SelectedLocation> stops) {
    return stops
        .map(
          (stop) =>
              '${stop.latitude.toStringAsFixed(6)},${stop.longitude.toStringAsFixed(6)},${stop.formattedAddress}',
        )
        .join('|');
  }

  Future<void> _fitCameraToVisiblePoints() async {
    final GoogleMapController? controller = _googleMapController;
    if (controller == null) {
      return;
    }

    final List<LatLng> points = <LatLng>[];
    if (_driverLatLng != null) {
      points.add(_driverLatLng!);
    }
    points.addAll(
      _routeStops.map((stop) => LatLng(stop.latitude, stop.longitude)),
    );
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

    for (final LatLng point in points.skip(1)) {
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
          'Ignoring carpool map camera update for disposed controller: $error',
          name: 'CarpoolMapProvider',
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
    _driverMarkerIcon = await _loadMarkerIcon(
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
    _stopMarkerIcon = await _loadMarkerIcon(
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

  LatLng _withCameraOffset(LatLng source) {
    const double metersPerLatitudeDegree = 111320;
    const double latitudeOffset =
        _currentLocationCameraOffsetMeters / metersPerLatitudeDegree;
    return LatLng(source.latitude - latitudeOffset, source.longitude);
  }
}
