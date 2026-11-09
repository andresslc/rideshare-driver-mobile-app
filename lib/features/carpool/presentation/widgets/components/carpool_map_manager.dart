// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:driver_app/shared/screens/place_picker_screen.dart';
// import 'package:driver_app/core/constants/app_icons.dart';
// import 'carpool_map_controller.dart';

// class CarpoolMapManager {
//   final CarpoolMapController _utility = CarpoolMapController();

//   GoogleMapController? controller;
//   BitmapDescriptor? carMarkerIcon;

//   final Set<Marker> markers = {};
//   final Set<Polyline> polylines = {};
//   final Set<Circle> circles = {};
//   final List<LatLng> trackedPathPoints = [];

//   static const double _averageDrivingSpeedKmh = 35;

//   LatLng cameraTarget = const LatLng(27.6648, -81.5158);
//   double routeDistanceKm = 0;
//   double routeAvgTimeMinutes = 0;

//   static const MarkerId currentLocationMarkerId = MarkerId(
//     'carpool_current_location',
//   );
//   static const MarkerId pickupMarkerId = MarkerId('carpool_pickup');
//   static const MarkerId dropOffMarkerId = MarkerId('carpool_dropoff');
//   static const PolylineId currentPathPolylineId = PolylineId(
//     'carpool_current_path',
//   );
//   static const PolylineId pickupDropoffPolylineId = PolylineId(
//     'carpool_pickup_dropoff_path',
//   );
//   static const String _routeStopMarkerPrefix = 'carpool_route_stop_';

//   Future<void> loadCarMarkerIcon() async {
//     try {
//       carMarkerIcon = await BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(size: Size(24, 24)),
//         AppIcons.car,
//       );
//     } catch (_) {}
//   }

//   void updateMarkers(Set<Marker> nextMarkers) {
//     markers.clear();
//     markers.addAll(nextMarkers);
//   }

//   void updatePolylines(Set<Polyline> nextPolylines) {
//     polylines.clear();
//     polylines.addAll(nextPolylines);
//   }

//   void updateCircles(Set<Circle> nextCircles) {
//     circles.clear();
//     circles.addAll(nextCircles);
//   }

//   void fitCamera(List<SelectedLocation> stops) {
//     _utility.fitCameraToStops(controller, stops);
//   }

//   Future<void> setRoadPolyline(
//     List<SelectedLocation> stops, {
//     required bool autoFit,
//   }) async {
//     if (stops.length < 2) {
//       polylines.removeWhere((p) => p.polylineId == pickupDropoffPolylineId);
//       markers.removeWhere(
//         (m) => m.markerId.value.startsWith(_routeStopMarkerPrefix),
//       );
//       routeDistanceKm = 0;
//       routeAvgTimeMinutes = 0;
//       return;
//     }

//     final routePoints = <LatLng>[];
//     for (var i = 0; i < stops.length - 1; i++) {
//       final start = LatLng(stops[i].latitude, stops[i].longitude);
//       final end = LatLng(stops[i + 1].latitude, stops[i + 1].longitude);
//       final segment = await _utility.fetchRoadSegment(start: start, end: end);

//       if (segment.isEmpty) {
//         routePoints.addAll([start, end]);
//         continue;
//       }

//       if (routePoints.isNotEmpty && routePoints.last == segment.first) {
//         routePoints.addAll(segment.skip(1));
//       } else {
//         routePoints.addAll(segment);
//       }
//     }

//     routeDistanceKm = _calculateRouteDistanceKm(routePoints);
//     routeAvgTimeMinutes = routeDistanceKm <= 0
//         ? 0
//         : (routeDistanceKm / _averageDrivingSpeedKmh) * 60;

//     polylines.removeWhere((p) => p.polylineId == pickupDropoffPolylineId);
//     polylines.add(
//       Polyline(
//         polylineId: pickupDropoffPolylineId,
//         points: routePoints,
//         color: Colors.blue,
//         width: 6,
//         geodesic: true,
//       ),
//     );
//     _updateRouteStopMarkers(stops);

//     if (autoFit) {
//       fitCamera(stops);
//     }
//   }

//   void _updateRouteStopMarkers(List<SelectedLocation> stops) {
//     markers.removeWhere((m) => m.markerId.value.startsWith(_routeStopMarkerPrefix));
//     if (stops.isEmpty) return;

//     for (var i = 0; i < stops.length; i++) {
//       final stop = stops[i];
//       final isFirst = i == 0;
//       final isLast = i == stops.length - 1;

//       final title = isFirst
//           ? 'Starting Point'
//           : isLast
//           ? 'Final Destination'
//           : 'Stop $i';

//       final hue = isFirst
//           ? BitmapDescriptor.hueGreen
//           : isLast
//           ? BitmapDescriptor.hueRed
//           : BitmapDescriptor.hueAzure;

//       markers.add(
//         Marker(
//           markerId: MarkerId('$_routeStopMarkerPrefix$i'),
//           position: LatLng(stop.latitude, stop.longitude),
//           infoWindow: InfoWindow(title: title, snippet: stop.formattedAddress),
//           icon: BitmapDescriptor.defaultMarkerWithHue(hue),
//         ),
//       );
//     }
//   }

//   void updateCurrentLocation(LatLng latLng, {required bool animateCamera}) {
//     if (trackedPathPoints.isEmpty || trackedPathPoints.last != latLng) {
//       trackedPathPoints.add(latLng);
//     }

//     markers.removeWhere((m) => m.markerId == currentLocationMarkerId);
//     markers.add(
//       Marker(
//         markerId: currentLocationMarkerId,
//         position: latLng,
//         infoWindow: const InfoWindow(title: 'My Location'),
//         icon:
//             carMarkerIcon ??
//             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//       ),
//     );

//     polylines.removeWhere((p) => p.polylineId == currentPathPolylineId);
//     if (trackedPathPoints.length >= 2) {
//       polylines.add(
//         Polyline(
//           polylineId: currentPathPolylineId,
//           points: List<LatLng>.from(trackedPathPoints),
//           color: Colors.orange,
//           width: 4,
//           geodesic: true,
//         ),
//       );
//     }

//     cameraTarget = latLng;
//     if (animateCamera) {
//       controller?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
//     }
//   }

//   Future<void> animateCarAlongPolyline(
//     LatLng destination,
//     Function(LatLng, bool) onUpdate,
//   ) async {
//     final routePoints = _getRoutePoints();
//     if (routePoints.isEmpty) {
//       onUpdate(destination, true);
//       return;
//     }

//     final snappedDestination = _utility.snapToRoute(destination, routePoints);
//     final current = markers
//         .firstWhere(
//           (m) => m.markerId == currentLocationMarkerId,
//           orElse: () =>
//               Marker(markerId: const MarkerId(''), position: routePoints.first),
//         )
//         .position;

//     final startIndex = _utility.nearestRoutePointIndex(current, routePoints);
//     final endIndex = _utility.nearestRoutePointIndex(snappedDestination, routePoints);

//     if (startIndex == endIndex) {
//       onUpdate(routePoints[endIndex], true);
//       return;
//     }

//     final step = endIndex > startIndex ? 1 : -1;
//     for (int i = startIndex + step; i != endIndex + step; i += step) {
//       onUpdate(routePoints[i], false);
//       await Future<void>.delayed(const Duration(milliseconds: 40));
//     }

//     onUpdate(routePoints[endIndex], true);
//   }

//   List<LatLng> _getRoutePoints() {
//     final p = polylines.firstWhere(
//       (p) => p.polylineId == pickupDropoffPolylineId,
//       orElse: () => const Polyline(polylineId: PolylineId('')),
//     );
//     return p.points;
//   }

//   double _calculateRouteDistanceKm(List<LatLng> routePoints) {
//     if (routePoints.length < 2) {
//       return 0;
//     }

//     double totalMeters = 0;
//     for (var i = 0; i < routePoints.length - 1; i++) {
//       final start = routePoints[i];
//       final end = routePoints[i + 1];
//       totalMeters += Geolocator.distanceBetween(
//         start.latitude,
//         start.longitude,
//         end.latitude,
//         end.longitude,
//       );
//     }

//     return totalMeters / 1000;
//   }
// }
