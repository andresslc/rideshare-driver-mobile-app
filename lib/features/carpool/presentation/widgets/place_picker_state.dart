import 'package:driver_app/core/location/service_region.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacePickerState {
  final LatLng currentPosition;
  final String address;
  final String locationTitle;
  final bool isFetchingAddress;
  final bool isDragging;
  final String? regionErrorMessage;

  const PlacePickerState({
    required this.currentPosition,
    required this.address,
    this.locationTitle = '',
    required this.isFetchingAddress,
    this.isDragging = false,
    this.regionErrorMessage,
  });

  factory PlacePickerState.initial() {
    return PlacePickerState(
      currentPosition: ServiceRegionConfig.active.center,
      address: 'Select a location',
      locationTitle: '',
      isFetchingAddress: false,
      isDragging: false,
    );
  }

  PlacePickerState copyWith({
    LatLng? currentPosition,
    String? address,
    String? locationTitle,
    bool? isFetchingAddress,
    bool? isDragging,
    String? regionErrorMessage,
    bool clearRegionErrorMessage = false,
  }) {
    return PlacePickerState(
      currentPosition: currentPosition ?? this.currentPosition,
      address: address ?? this.address,
      locationTitle: locationTitle ?? this.locationTitle,
      isFetchingAddress: isFetchingAddress ?? this.isFetchingAddress,
      isDragging: isDragging ?? this.isDragging,
      regionErrorMessage: clearRegionErrorMessage
          ? null
          : (regionErrorMessage ?? this.regionErrorMessage),
    );
  }
}
