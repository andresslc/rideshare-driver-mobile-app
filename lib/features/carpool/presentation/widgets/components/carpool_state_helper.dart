import 'package:driver_app/features/carpool/presentation/states/carpool_socket_states.dart';
import 'package:driver_app/shared/screens/place_picker_screen.dart';

import 'carpool_bottomsheet_types.dart';

mixin CarpoolStateHelper {
  List<SelectedLocation> restoredStopsFromSocketState(
    CarpoolSocketState state,
  ) {
    final payload = state.lastRideResume ?? const <String, dynamic>{};
    if (payload.isEmpty) return const <SelectedLocation>[];

    final orderedStops = <SelectedLocation>[
      ..._selectedLocationsFromPayload(payload['startingPoint']),
      ..._selectedLocationsFromRoutes(payload['routes']),
      ..._selectedLocationsFromPayload(payload['destination']),
    ];

    final deduped = <SelectedLocation>[];
    for (final stop in orderedStops) {
      final exists = deduped.any(
        (item) =>
            item.formattedAddress == stop.formattedAddress &&
            (item.latitude - stop.latitude).abs() <= 0.00001 &&
            (item.longitude - stop.longitude).abs() <= 0.00001,
      );
      if (!exists) deduped.add(stop);
    }
    return deduped;
  }

  RideBottomSheetType sheetForCarpoolState(CarpoolSocketState state) {
    final payload = state.lastRideResume ?? const <String, dynamic>{};
    final status = (payload['type'] ?? payload['status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final hasRecoverableRoute = hasRecoverableRouteState(state);

    if (status == 'in_progress' ||
        status == 'in-progress' ||
        status == 'started' ||
        status == 'active' ||
        state.hasActiveRide ||
        state.isRideStarted) {
      return RideBottomSheetType.rideProgress;
    }
    if (state.incomingRequests.isNotEmpty ||
        state.acceptedRequests.isNotEmpty ||
        _resumePassengers(payload).isNotEmpty) {
      return RideBottomSheetType.carpoolRequest;
    }
    if (status == 'open' || hasRecoverableRoute) {
      return RideBottomSheetType.searchCarpoolRide;
    }
    return RideBottomSheetType.addStops;
  }

  bool hasRecoverableRouteState(CarpoolSocketState state) {
    final payload = state.lastRideResume ?? const <String, dynamic>{};
    final status = (payload['type'] ?? payload['status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    if (status == 'completed' ||
        status == 'cancelled' ||
        status == 'canceled') {
      return false;
    }

    final hasCarpoolId =
        (state.activeCarpoolId?.trim().isNotEmpty ?? false) ||
        ((payload['carpoolId'] ?? payload['_id'] ?? payload['id'] ?? '')
            .toString()
            .trim()
            .isNotEmpty);
    final hasRouteShape =
        payload['startingPoint'] != null ||
        payload['destination'] != null ||
        payload['routes'] is List;

    return hasCarpoolId && hasRouteShape;
  }

  bool shouldReplaceRideStops(
    List<SelectedLocation?> currentStops,
    List<SelectedLocation> restoredStops,
  ) {
    if (restoredStops.isEmpty) return false;
    final effectiveCurrent = currentStops
        .whereType<SelectedLocation>()
        .toList();
    if (effectiveCurrent.length != restoredStops.length) return true;

    for (var i = 0; i < effectiveCurrent.length; i++) {
      if ((effectiveCurrent[i].latitude - restoredStops[i].latitude).abs() >
              0.00001 ||
          (effectiveCurrent[i].longitude - restoredStops[i].longitude).abs() >
              0.00001 ||
          effectiveCurrent[i].formattedAddress !=
              restoredStops[i].formattedAddress) {
        return true;
      }
    }
    return false;
  }

  List<SelectedLocation> _selectedLocationsFromRoutes(dynamic rawRoutes) {
    if (rawRoutes is! List) return const <SelectedLocation>[];

    final routes = rawRoutes
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    routes.sort(
      (a, b) => ((a['order'] as num?)?.toInt() ?? 0).compareTo(
        (b['order'] as num?)?.toInt() ?? 0,
      ),
    );

    return routes.expand(_selectedLocationsFromPayload).toList();
  }

  List<SelectedLocation> _selectedLocationsFromPayload(dynamic rawStop) {
    if (rawStop is! Map) return const <SelectedLocation>[];
    final stop = Map<String, dynamic>.from(rawStop);
    final coords = stop['location']?['coordinates'] ?? stop['coordinates'];
    if (coords is! List || coords.length < 2) return const <SelectedLocation>[];

    final lat = (coords[1] as num?)?.toDouble();
    final lng = (coords[0] as num?)?.toDouble();
    if (lat == null || lng == null) return const <SelectedLocation>[];

    return [
      SelectedLocation(
        latitude: lat,
        longitude: lng,
        formattedAddress: (stop['placeName'] ?? '').toString(),
      ),
    ];
  }

  List<Map<String, dynamic>> _resumePassengers(Map<String, dynamic> payload) {
    final passengers = payload['passengers'];
    if (passengers is! List) return const <Map<String, dynamic>>[];
    return passengers
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
