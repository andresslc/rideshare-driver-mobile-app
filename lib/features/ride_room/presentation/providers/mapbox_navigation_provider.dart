import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class MapboxNavigationState {
  final bool isLoadingLocation;
  final String? errorMessage;

  const MapboxNavigationState({
    this.isLoadingLocation = false,
    this.errorMessage,
  });

  MapboxNavigationState copyWith({
    bool? isLoadingLocation,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MapboxNavigationState(
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final mapboxNavigationProvider =
    NotifierProvider<MapboxNavigationController, MapboxNavigationState>(
  MapboxNavigationController.new,
);

class MapboxNavigationController extends Notifier<MapboxNavigationState> {
  late final LocationService _locationService;

  @override
  MapboxNavigationState build() {
    _locationService = locator<LocationService>();
    return const MapboxNavigationState();
  }

  /// Fetches the driver's current location from the global location service.
  Future<Position?> getDriverCurrentPosition() async {
    state = state.copyWith(isLoadingLocation: true, clearError: true);
    try {
      final position = await _locationService.getCurrentPosition();
      state = state.copyWith(isLoadingLocation: false);
      return position;
    } catch (e) {
      state = state.copyWith(
        isLoadingLocation: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }
}
