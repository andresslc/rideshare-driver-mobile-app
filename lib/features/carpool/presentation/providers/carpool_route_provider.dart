import 'dart:convert';

import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/services/location_service.dart';
import 'package:driver_app/core/services/storage_service.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_location_entity.dart';
import 'package:driver_app/features/carpool/presentation/states/carpool_route_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/services/address_search_controller.dart';
import '../../../../core/services/places_search_service.dart';

final carpoolRouteProvider =
    NotifierProvider<CarpoolRouteNotifier, CarpoolRouteState>(
      CarpoolRouteNotifier.new,
    );

class CarpoolRouteNotifier extends Notifier<CarpoolRouteState> {
  static const String _keyRecentCarpoolLocations = 'recent_carpool_locations';
  late LocationService _locationService;
  late StorageService _storageService;
  late AddressSearchController _search;
  String _field = 'dropoff';
  LatLng? _searchOrigin;

  @override
  CarpoolRouteState build() {
    _locationService = locator<LocationService>();
    _storageService = locator<StorageService>();
    _search = _locationService.createAddressSearch(
      origin: () => _searchOrigin,
      onLegacyOriginResolved: (value) => _searchOrigin = value,
      onChanged: () {
        if (!ref.mounted) return;
        state = state.copyWith(
          searchResults: _search.suggestions,
          isFetchingSuggestions: _search.loading,
          isResolvingSelection: _search.selecting,
          searchError: _search.error,
          clearError: _search.error == null,
        );
      },
    );
    ref.onDispose(_search.dispose);
    return const CarpoolRouteState();
  }

  Future<void> initialize({LatLng? initialOrigin}) async {
    _search.abandon();
    _searchOrigin = initialOrigin;
    state = state.copyWith(
      isLoading: true,
      searchQuery: '',
      searchResults: const [],
      clearError: true,
    );
    try {
      final recents = await getRecentLocations();
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        recents: recents,
        searchQuery: '',
        searchResults: const [],
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        searchQuery: '',
        searchResults: const [],
      );
    }
  }

  void setSearchOrigin(LatLng? origin) {
    _searchOrigin = origin;
  }

  Future<List<CarpoolLocationEntity>> getRecentLocations() async {
    try {
      final raw = _storageService.getString(_keyRecentCarpoolLocations);
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded
          .map(
            (item) =>
                CarpoolLocationEntity.fromJson(item as Map<String, dynamic>),
          )
          .where(_isConfirmedRecent)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecentLocation(CarpoolLocationEntity location) async {
    if (!_isConfirmedRecent(location)) {
      return;
    }
    try {
      final current = await getRecentLocations();
      final filtered = current.where((l) {
        if (l.name.toLowerCase() == location.name.toLowerCase() &&
            l.address.toLowerCase() == location.address.toLowerCase()) {
          return false;
        }
        final distance =
            (l.latitude - location.latitude).abs() +
            (l.longitude - location.longitude).abs();
        return distance > 0.0001;
      }).toList();

      filtered.insert(0, location);
      if (filtered.length > 20) {
        filtered.removeRange(20, filtered.length);
      }

      await _storageService.setString(
        _keyRecentCarpoolLocations,
        jsonEncode(filtered.map((e) => e.toJson()).toList()),
      );
      if (ref.mounted) {
        state = state.copyWith(recents: filtered);
      }
    } catch (_) {}
  }

  void activateField(String field) {
    if (_field == field) return;
    _field = field;
    abandonSearch();
  }

  void abandonSearch({bool notify = true}) {
    _search.abandon(notify: notify);
    // Screen disposal retires requests without notifying a tree being unmounted.
    // Initialization clears the visible state when the screen opens again.
    if (!notify || !ref.mounted) return;
    state = state.copyWith(searchQuery: '', searchResults: const []);
  }

  void onSearchQueryChanged(
    String query, {
    LatLng? origin,
    String field = 'dropoff',
  }) {
    activateField(field);
    if (origin != null) _searchOrigin = origin;
    state = state.copyWith(searchQuery: query.trim());
    _search.edit(query, field: 'carpool.$field');
  }

  Future<CarpoolLocationEntity?> resolveSelectedLocation(
    Object location,
  ) async {
    if (location is CarpoolLocationEntity) {
      abandonSearch();
      return _isConfirmedRecent(location) ? location : null;
    }
    if (location is! PlaceSuggestion) return null;
    final place = await _search.select(location);
    return place == null || !ref.mounted ? null : _fromResolved(place);
  }

  bool _isConfirmedRecent(CarpoolLocationEntity location) =>
      ResolvedPlace.validCoordinates(location.latitude, location.longitude) &&
      (location.latitude != 0 ||
          location.longitude != 0 ||
          location.resolvedPlace != null);

  CarpoolLocationEntity _fromResolved(ResolvedPlace place) =>
      CarpoolLocationEntity(
        resolvedPlace: place,
        id: place.placeId,
        name: place.label.split(',').first,
        address: place.formattedAddress,
        latitude: place.latitude,
        longitude: place.longitude,
        timestamp: DateTime.now(),
      );

  Future<CarpoolLocationEntity?> retrySelection() async {
    if (!_search.canRetrySelection) {
      _search.retrySearch();
      return null;
    }
    final place = await _search.retrySelection();
    return place == null || !ref.mounted ? null : _fromResolved(place);
  }
}
