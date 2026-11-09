// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:driver_app/shared/screens/place_picker_screen.dart';

// class CarpoolMapController {
//   final PolylinePoints _polylinePoints = PolylinePoints();
//   final Dio _dio = Dio();
//   static const String _osrmBaseUrl = 'https://router.project-osrm.org';

//   Future<List<LatLng>> fetchRoadSegment({required LatLng start, required LatLng end}) async {
//     if (googleApiKey.isNotEmpty) {
//       try {
//         final result = await _polylinePoints.getRouteBetweenCoordinates(
//           googleApiKey: googleApiKey,
//           request: PolylineRequest(
//             origin: PointLatLng(start.latitude, start.longitude),
//             destination: PointLatLng(end.latitude, end.longitude),
//             mode: TravelMode.driving,
//           ),
//         );
//         if (result.points.isNotEmpty) {
//           return result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
//         }
//       } catch (_) {}
//     }

//     final osrmRoute = await _fetchRoadSegmentFromOsrm(start: start, end: end);
//     return osrmRoute.isNotEmpty ? osrmRoute : [start, end];
//   }

//   Future<List<LatLng>> _fetchRoadSegmentFromOsrm({required LatLng start, required LatLng end}) async {
//     try {
//       final coordinates = '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
//       final response = await _dio.get('$_osrmBaseUrl/route/v1/driving/$coordinates?overview=full&geometries=polyline&steps=false');
//       final data = response.data is Map ? response.data : jsonDecode(response.data.toString());
//       final routes = data['routes'] as List?;
//       if (routes == null || routes.isEmpty) return [];

//       final geometry = routes.first['geometry'] as String?;
//       if (geometry == null || geometry.isEmpty) return [];

//       return _polylinePoints.decodePolyline(geometry).map((p) => LatLng(p.latitude, p.longitude)).toList();
//     } catch (_) {
//       return [];
//     }
//   }

//   void fitCameraToStops(GoogleMapController? controller, List<SelectedLocation> stops) {
//     if (controller == null || stops.isEmpty) return;

//     if (stops.length == 1) {
//       controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(stops.first.latitude, stops.first.longitude), 15));
//       return;
//     }

//     double minLat = stops.first.latitude, maxLat = stops.first.latitude;
//     double minLng = stops.first.longitude, maxLng = stops.first.longitude;

//     for (var s in stops) {
//       if (s.latitude < minLat) minLat = s.latitude;
//       if (s.latitude > maxLat) maxLat = s.latitude;
//       if (s.longitude < minLng) minLng = s.longitude;
//       if (s.longitude > maxLng) maxLng = s.longitude;
//     }

//     final bounds = LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
//     controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
//   }

//   LatLng snapToRoute(LatLng point, List<LatLng> routePoints) {
//     if (routePoints.isEmpty) return point;
//     return routePoints[nearestRoutePointIndex(point, routePoints)];
//   }

//   int nearestRoutePointIndex(LatLng point, List<LatLng> routePoints) {
//     int nearest = 0;
//     double minDistance = double.infinity;

//     for (int i = 0; i < routePoints.length; i++) {
//       final d = Geolocator.distanceBetween(point.latitude, point.longitude, routePoints[i].latitude, routePoints[i].longitude);
//       if (d < minDistance) {
//         minDistance = d;
//         nearest = i;
//       }
//     }
//     return nearest;
//   }
// }
