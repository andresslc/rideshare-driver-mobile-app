import 'dart:async';
import 'dart:collection';
import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/location/service_region.dart';
import 'package:driver_app/core/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'place_picker_state.dart';

final placePickerProvider =
    NotifierProvider<PlacePickerNotifier, PlacePickerState>(
      PlacePickerNotifier.new,
    );

class PlacePickerNotifier extends Notifier<PlacePickerState> {
  late LocationService _locationService;
  Timer? _debounce;
  LatLng? _searchOrigin;

  // 50-entry LRU Cache with ~11m (4 decimal places) resolution
  final LinkedHashMap<String, String> _reverseGeocodeCache =
      LinkedHashMap<String, String>();
  static const int _maxCacheSize = 50;

  ServiceRegion get _activeRegion => ServiceRegionConfig.active;

  @override
  PlacePickerState build() {
    _locationService = locator<LocationService>();
    ref.onDispose(() => _debounce?.cancel());
    return PlacePickerState.initial();
  }

  String _cacheKey(LatLng latLng) {
    return '${latLng.latitude.toStringAsFixed(4)},${latLng.longitude.toStringAsFixed(4)}';
  }

  String _extractTitle(String formattedAddress) {
    final parts = formattedAddress.split(',');
    return parts.first.trim();
  }

  Future<LatLng?> setInitialLocation({
    LatLng? initialPosition,
    String? initialAddress,
    bool openSettingsIfNeeded = false,
  }) async {
    if (initialPosition != null) {
      final clamped = _activeRegion.clamp(initialPosition);
      _searchOrigin ??= clamped;
      final address = initialAddress ?? state.address;
      state = state.copyWith(
        currentPosition: clamped,
        address: address,
        locationTitle: _extractTitle(address),
      );
      if (initialAddress == null) {
        unawaited(_reverseGeocode(clamped, reason: 'initial_address_fallback'));
      }
      return clamped;
    }

    try {
      var position = await _locationService.getCurrentPosition();
      if (position == null && openSettingsIfNeeded) {
        final permission = await _locationService.requestLocationPermission();
        if (permission == LocationPermissionResult.granted) {
          position = await _locationService.getCurrentPosition();
        }
      }

      if (position != null) {
        final latLng = _activeRegion.clamp(
          LatLng(position.latitude, position.longitude),
        );
        _searchOrigin = latLng;
        updatePosition(latLng, reason: 'initial_position');
        return latLng;
      }

      await _reverseGeocode(state.currentPosition, reason: 'initial_position');
      return state.currentPosition;
    } catch (_) {
      await _reverseGeocode(state.currentPosition, reason: 'initial_position');
      return state.currentPosition;
    }
  }

  void setSearchOrigin(LatLng? origin) {
    _searchOrigin = origin;
  }

  void setIsDragging(bool isDragging) {
    state = state.copyWith(isDragging: isDragging);
  }

  void updatePosition(LatLng position, {required String reason}) {
    final clamped = _activeRegion.clamp(position);
    state = state.copyWith(currentPosition: clamped, isDragging: false);
    _debouncedReverseGeocode(clamped, reason: reason);
  }

  void onCameraMove(LatLng position) {
    state = state.copyWith(currentPosition: _activeRegion.clamp(position));
  }

  void _debouncedReverseGeocode(LatLng position, {required String reason}) {
    _debounce?.cancel();
    final key = _cacheKey(position);
    if (_reverseGeocodeCache.containsKey(key)) {
      final cached = _reverseGeocodeCache[key]!;
      _reverseGeocodeCache.remove(key);
      _reverseGeocodeCache[key] = cached;
      state = state.copyWith(
        address: cached,
        locationTitle: _extractTitle(cached),
        isFetchingAddress: false,
      );
      return;
    }

    state = state.copyWith(isFetchingAddress: true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      await _reverseGeocode(position, reason: reason);
    });
  }

  Future<void> _reverseGeocode(
    LatLng position, {
    required String reason,
  }) async {
    final key = _cacheKey(position);
    if (_reverseGeocodeCache.containsKey(key)) {
      final cached = _reverseGeocodeCache[key]!;
      state = state.copyWith(
        address: cached,
        locationTitle: _extractTitle(cached),
        isFetchingAddress: false,
      );
      return;
    }

    state = state.copyWith(isFetchingAddress: true);
    try {
      final address = await _locationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
        reason: reason,
      );
      if (!ref.mounted) return;

      final resolved = (address != null && address.trim().isNotEmpty)
          ? address.trim()
          : 'Selected Location';

      if (_reverseGeocodeCache.length >= _maxCacheSize) {
        _reverseGeocodeCache.remove(_reverseGeocodeCache.keys.first);
      }
      _reverseGeocodeCache[key] = resolved;

      state = state.copyWith(
        address: resolved,
        locationTitle: _extractTitle(resolved),
        isFetchingAddress: false,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        address: 'Selected Location',
        locationTitle: 'Selected Location',
        isFetchingAddress: false,
      );
    }
  }

  void clearRegionErrorMessage() {
    state = state.copyWith(clearRegionErrorMessage: true);
  }
}
