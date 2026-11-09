import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:driver_app/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../shared/location_component/location_models/address_details.dart';
import '../constants/api_endpoints.dart';
import '../constants/constants_data.dart';
import '../location/service_region.dart';
import '../utils/app_log.dart';
import 'address_search_controller.dart';
import 'places_search_service.dart';

enum LocationPermissionResult {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
  error,
}

enum ServiceRegionAccessStatus { inside, outside, unavailable }

class LocationService {
  LocationService({
    Dio? dio,
    PlacesObserver? placesObserver,
    required StorageService storage,
  }) : _dio = dio ?? Dio(),
       _storage = storage {
    placesSearch = PlacesSearchService(
      application: 'driver',
      platform: defaultTargetPlatform.name,
      dio: _dio,
      observer: placesObserver,
      legacySearch: (query, context) async {
        final origin = context.geography['origin'];
        final results = await getPlaceSuggestions(
          query,
          origin: origin is Map
              ? LatLng(
                  origin['latitude'] as double,
                  origin['longitude'] as double,
                )
              : null,
        );
        return results.map((m) {
          final structured = m['structured_formatting'] as Map?;
          return PlaceSuggestion(
            placeId: m['place_id'] as String,
            label: m['description'] as String,
            primaryText: (structured?['main_text'] ?? '') as String,
            secondaryText: (structured?['secondary_text'] ?? '') as String,
          );
        }).toList();
      },
      legacyResolve: (suggestion, context) async {
        final position = await getPlaceDetails(
          suggestion.placeId,
          address: suggestion.label,
        );
        if (position == null) return null;
        return ResolvedPlace(
          placeId: suggestion.placeId,
          label: suggestion.label,
          formattedAddress: suggestion.label,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      },
    );
  }

  late final PlacesSearchService placesSearch;

  PlacesContext placesContext({LatLng? origin}) {
    final region = _serviceRegion;
    final geography = <String, dynamic>{};
    if (origin != null &&
        ResolvedPlace.validCoordinates(origin.latitude, origin.longitude)) {
      geography['origin'] = {
        'latitude': origin.latitude,
        'longitude': origin.longitude,
      };
    }
    if (!region.isGlobal) {
      geography['locationBias'] = {
        'rectangle': {
          'low': {
            'latitude': region.bounds.southwest.latitude,
            'longitude': region.bounds.southwest.longitude,
          },
          'high': {
            'latitude': region.bounds.northeast.latitude,
            'longitude': region.bounds.northeast.longitude,
          },
        },
      };
      if (region.countryCode.isNotEmpty) {
        geography['includedRegionCodes'] = [region.countryCode];
      }
    } else if (geography.containsKey('origin')) {
      geography['locationBias'] = {
        'circle': {'center': geography['origin'], 'radius': 50000.0},
      };
    }
    return PlacesContext(
      enabled: remoteConfigModel.addressSearchV2Enabled,
      apiKey: ApiEndpoints.mapApiKey,
      language: _storage.getLanguageCode ?? 'en',
      region: region.id.name,
      geography: geography,
      accepts: (place) =>
          region.isGlobal ||
          (region.contains(LatLng(place.latitude, place.longitude)) &&
              (region.matchesAdministrativeArea(place.state) ||
                  region.matchesAdministrativeArea(place.stateCode))),
    );
  }

  final Set<AddressSearchController> _addressSearches = {};
  void invalidateAddressSearches() {
    for (final controller in _addressSearches.toList()) {
      controller.abandon();
    }
  }

  AddressSearchController createAddressSearch({
    required void Function() onChanged,
    LatLng? Function()? origin,
    bool legacyDeviceOrigin = true,
    void Function(LatLng)? onLegacyOriginResolved,
    Duration legacyDebounce = const Duration(milliseconds: 300),
  }) {
    late final AddressSearchController controller;
    controller = AddressSearchController(
      service: placesSearch,
      contextProvider: () => placesContext(origin: origin?.call()),
      legacyDebounce: legacyDebounce,
      prepareContext: (context) async {
        if (context.geography.containsKey('origin')) return context;
        if (!context.enabled && !legacyDeviceOrigin) return context;
        // The disabled strategy retains its original fresh-fix-first policy.
        // The enabled strategy snapshots cached origin once per interaction.
        Position? position;
        if (!context.enabled) {
          try {
            position = await getCurrentPosition();
          } catch (_) {
            /* Fall back to the cached fix. */
          }
        }
        final last = position ?? await getLastKnownPosition();
        if (last == null) return context;
        if (!context.enabled)
          onLegacyOriginResolved?.call(LatLng(last.latitude, last.longitude));
        final prepared = placesContext(
          origin: LatLng(last.latitude, last.longitude),
        );
        return PlacesContext(
          enabled: context.enabled,
          apiKey: context.apiKey,
          language: context.language,
          region: context.region,
          geography: prepared.geography,
          accepts: context.accepts,
        );
      },
      onChanged: onChanged,
      onDispose: () => _addressSearches.remove(controller),
    );
    _addressSearches.add(controller);
    return controller;
  }

  final Dio _dio;
  final StorageService _storage;

  ServiceRegion get _serviceRegion => ServiceRegionConfig.active;

  /// Check if location services are enabled and permissions are granted.
  Future<bool> isLocationAvailable() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Request location permission and return the result.
  Future<LocationPermissionResult> requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionResult.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationPermissionResult.denied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionResult.permanentlyDenied;
      }

      return LocationPermissionResult.granted;
    } catch (e) {
      log('Error requesting location permission: $e', name: 'LocationService');
      return LocationPermissionResult.error;
    }
  }

  /// Open app settings to allow user to grant permission.
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get the current position of the device.
  /// Get the last known position of the device.
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      log('Error getting last known position: $e', name: 'LocationService');
      return null;
    }
  }

  Future<Position?> getCurrentPosition() async {
    try {
      if (!await isLocationAvailable()) return null;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );
      return _positionWithinServiceRegion(position) ? position : null;
    } catch (e) {
      log('Error getting current position: $e', name: 'LocationService');
      return null;
    }
  }

  Future<ServiceRegionAccessStatus>
  getCurrentServiceRegionAccessStatus() async {
    try {
      if (!await isLocationAvailable()) {
        return ServiceRegionAccessStatus.unavailable;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );

      return _positionWithinServiceRegion(position)
          ? ServiceRegionAccessStatus.inside
          : ServiceRegionAccessStatus.outside;
    } catch (e) {
      log('Error checking service region access: $e', name: 'LocationService');
      return ServiceRegionAccessStatus.unavailable;
    }
  }

  /// Get a stream of location updates.
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(locationSettings: _locationSettings);
  }

  /// Get a stream of GPS service status changes.
  Stream<ServiceStatus> getServiceStatusStream() {
    return Geolocator.getServiceStatusStream();
  }

  LocationSettings get _locationSettings {
    if (kIsWeb) {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          intervalDuration: Duration(seconds: 5),
          foregroundNotificationConfig: ForegroundNotificationConfig(
            notificationTitle: 'Driver App',
            notificationText: 'Updating your live location for active rides',
            enableWakeLock: true,
          ),
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          activityType: ActivityType.automotiveNavigation,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
        );
      default:
        return const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        );
    }
  }

  Future<Map<String, dynamic>?> getAddressFromCoordinates(
    double lat,
    double lng, {
    required String reason,
  }) async {
    final apiKey = ApiEndpoints.mapApiKey;
    if (apiKey.isEmpty) return null;

    final watch = Stopwatch()..start();
    var status = 'success';
    placesSearch.observe({
      'event': 'request_started',
      'method': 'reverse_geocode',
      'field': 'location.lookup',
      'reason': reason,
    });
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': apiKey,
          'language': _storage.getLanguageCode,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        status = 'malformed';
        return null;
      }
      status = switch (data['status']) {
        'OK' => 'success',
        'ZERO_RESULTS' => 'incomplete',
        'OVER_QUERY_LIMIT' => 'quota',
        'REQUEST_DENIED' || 'INVALID_REQUEST' => 'configuration',
        'UNKNOWN_ERROR' => 'network',
        _ => 'malformed',
      };
      if (status == 'success') {
        if (data['results'] is! List) {
          status = 'malformed';
        } else if ((data['results'] as List).isEmpty) {
          status = 'incomplete';
        }
      }
      return status == 'success' ? data : null;
    } on DioException catch (error) {
      status = switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout => 'timeout',
        DioExceptionType.cancel => 'cancelled',
        _ => switch (error.response?.statusCode) {
          429 => 'quota',
          400 || 401 || 403 => 'configuration',
          _ => 'network',
        },
      };
      return null;
    } catch (_) {
      status = 'malformed';
      return null;
    } finally {
      placesSearch.observe({
        'event': 'request_finished',
        'method': 'reverse_geocode',
        'field': 'location.lookup',
        'reason': reason,
        'status': status,
        'elapsed_ms': watch.elapsedMilliseconds,
      });
    }
  }

  Future<String?> getAddressFromLatLng(
    double lat,
    double lng, {
    String fallback = 'Unknown location',
    required String reason,
  }) async {
    final response = await getAddressFromCoordinates(lat, lng, reason: reason);
    if (response == null) return fallback;

    final List<dynamic> results = (response['results'] as List<dynamic>? ?? []);
    if (results.isEmpty) return fallback;

    final Map<String, dynamic> first = results.first is Map<String, dynamic>
        ? results.first as Map<String, dynamic>
        : Map<String, dynamic>.from(results.first as Map);
    final String formatted = (first['formatted_address'] ?? '').toString();
    if (formatted.isNotEmpty) return formatted;
    return fallback;
  }

  /// Get address from coordinates.
  // Future<String?> getAddressFromLatLng(double lat, double lng) async {
  //   try {
  //     final placemarks = await placemarkFromCoordinates(lat, lng);
  //     if (placemarks.isEmpty) return null;
  //     final placemark = placemarks.first;

  //     return [
  //       placemark.name,
  //       placemark.subLocality,
  //       placemark.locality,
  //       placemark.administrativeArea,
  //       placemark.country,
  //     ].where((e) => e != null && e.isNotEmpty).join(', ');
  //   } catch (e) {
  //     return null;
  //   }
  // }

  Future<List<Map<String, dynamic>>> getPlaceSuggestions(
    String query, {
    LatLng? origin,
  }) async {
    final apiKey = ApiEndpoints.mapApiKey;
    if (apiKey.isEmpty) return [];

    try {
      // ── Build the request body ──────────────────────────────────────────
      final Map<String, dynamic> body = <String, dynamic>{
        'textQuery': query,
        'languageCode': _storage.getLanguageCode ?? 'en',
        'pageSize': 10,
      };

      // Determine the center for location biasing.
      final LatLng? biasCenter = _resolveBiasCenter(origin);

      if (biasCenter != null) {
        final double rawRadius = !_serviceRegion.isGlobal
            ? _serviceRegion.autocompleteRadiusMeters
            : 50000.0;
        final double safeRadius = rawRadius.clamp(0.0, 50000.0);

        body['rankPreference'] = 'DISTANCE';
        body['locationBias'] = <String, dynamic>{
          'circle': <String, dynamic>{
            'center': <String, dynamic>{
              'latitude': biasCenter.latitude,
              'longitude': biasCenter.longitude,
            },
            'radius': safeRadius,
          },
        };
      }

      // ── Field mask: only request what we need ──────────────────────────
      const String fieldMask =
          'places.id,places.displayName,places.formattedAddress,'
          'places.location,places.shortFormattedAddress';

      final dio = Dio();
      final response = await dio.post(
        'https://places.googleapis.com/v1/places:searchText',
        data: body,
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey,
            'X-Goog-FieldMask': fieldMask,
          },
        ),
      );

      final List<dynamic> places =
          (response.data['places'] as List<dynamic>?) ?? <dynamic>[];
      if (places.isEmpty) return [];

      // ── Map each result to the legacy shape ────────────────────────────
      final List<Map<String, dynamic>> mapped = places.map((dynamic place) {
        final Map<String, dynamic> p = place is Map<String, dynamic>
            ? place
            : Map<String, dynamic>.from(place as Map);

        final String placeId = (p['id'] ?? '').toString();
        final String formattedAddress = (p['formattedAddress'] ?? '')
            .toString();
        final String shortAddress = (p['shortFormattedAddress'] ?? '')
            .toString();

        // displayName can be a map with a 'text' field or a plain string.
        final dynamic dn = p['displayName'];
        final String displayName = dn is Map
            ? (dn['text'] ?? '').toString()
            : (dn ?? '').toString();

        // Build the "secondary" text by stripping the display name from the
        // formatted address, similar to the old structured_formatting.
        String secondaryText = formattedAddress;
        if (displayName.isNotEmpty &&
            formattedAddress.startsWith(displayName)) {
          secondaryText = formattedAddress.substring(displayName.length);
          // Strip leading commas and whitespace.
          int i = 0;
          while (i < secondaryText.length &&
              (secondaryText[i] == ',' || secondaryText[i] == ' ')) {
            i++;
          }
          if (i > 0) secondaryText = secondaryText.substring(i);
        }

        // Compute distance from origin if available.
        int? distanceMeters;
        final LatLng? distanceOrigin = origin ?? biasCenter;
        if (distanceOrigin != null && p['location'] is Map) {
          final Map<String, dynamic> loc = Map<String, dynamic>.from(
            p['location'] as Map,
          );
          final double? lat = (loc['latitude'] as num?)?.toDouble();
          final double? lng = (loc['longitude'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            distanceMeters = Geolocator.distanceBetween(
              distanceOrigin.latitude,
              distanceOrigin.longitude,
              lat,
              lng,
            ).round();
          }
        }

        // Build a description that includes the place name so the user sees
        // e.g. "Subway, 123 Main St, City" instead of just the address.
        final String addressPart = shortAddress.isNotEmpty
            ? shortAddress
            : formattedAddress;
        final String description =
            displayName.isNotEmpty && !addressPart.startsWith(displayName)
            ? '$displayName, $addressPart'
            : addressPart;

        LatLng? location;
        if (p['location'] is Map) {
          final Map<String, dynamic> loc = Map<String, dynamic>.from(
            p['location'] as Map,
          );
          final double? lat = (loc['latitude'] as num?)?.toDouble();
          final double? lng = (loc['longitude'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            location = LatLng(lat, lng);
          }
        }

        return <String, dynamic>{
          'place_id': placeId,
          'description': description,
          'structured_formatting': <String, dynamic>{
            'main_text': displayName,
            'secondary_text': secondaryText,
          },
          if (location != null) 'location': location,
          if (distanceMeters != null) 'distance_meters': distanceMeters,
        };
      }).toList();

      // Filter to active region & sort nearest-first.
      final List<Map<String, dynamic>> filtered = mapped
          .where(_predictionMatchesActiveRegion)
          .toList(growable: true);
      // _sortByProximity(filtered);
      return List<Map<String, dynamic>>.unmodifiable(filtered);
    } catch (e) {
      log('Unable to get place suggestions', name: 'LocationService');
      return [];
    }
  }

  LatLng? _resolveBiasCenter(LatLng? origin) {
    if (!_serviceRegion.isGlobal) {
      return (origin != null && _serviceRegion.contains(origin))
          ? origin
          : _serviceRegion.center;
    }
    return origin;
  }

  bool _predictionMatchesActiveRegion(Map<String, dynamic> prediction) {
    if (_serviceRegion.isGlobal) {
      return true;
    }
    final dynamic structured = prediction['structured_formatting'];
    final Map<String, dynamic> structuredMap =
        structured is Map<String, dynamic> ? structured : <String, dynamic>{};
    final String secondaryText = (structuredMap['secondary_text'] ?? '')
        .toString()
        .toLowerCase();
    final String description = (prediction['description'] ?? '')
        .toString()
        .toLowerCase();

    return _serviceRegion.administrativeAreaMatches.any(
      (match) => secondaryText.contains(match) || description.contains(match),
    );
  }

  // Future<List<Map<String, dynamic>>> getPlaceSuggestions(String query) async {
  //   final trimmedQuery = query.trim();
  //   if (trimmedQuery.isEmpty) {
  //     return <Map<String, dynamic>>[];
  //   }

  //   final apiKey = remoteConfigModel.mapApiKey.trim();
  //   final baseUrl = 'https://maps.googleapis.com/maps/api/';

  //   if (apiKey.isEmpty) {
  //     log(
  //       'Google Maps API key is missing; cannot fetch place suggestions.',
  //       name: 'LocationService',
  //     );
  //     return <Map<String, dynamic>>[];
  //   }

  //   try {
  //     final Map<String, String> queryParameters = <String, String>{
  //       'input': trimmedQuery,
  //       'key': apiKey,
  //     };

  //     if (!_serviceRegion.isGlobal) {
  //       queryParameters.addAll(<String, String>{
  //         'components': 'country:${_serviceRegion.countryCode}',
  //         'location': _latLngString(_serviceRegion.center),
  //         'radius': _serviceRegion.autocompleteRadiusMeters.round().toString(),
  //       });
  //     }

  //     final uri = Uri.parse(
  //       '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}place/autocomplete/json',
  //     ).replace(queryParameters: queryParameters);

  //     final response = await _dio.getUri(uri);
  //     final data = _normalizeResponse(response.data);
  //     final predictions = data['predictions'] as List<dynamic>? ?? <dynamic>[];

  //     return predictions
  //         .whereType<Map>()
  //         .map(
  //           (prediction) =>
  //               Map<String, dynamic>.from(prediction.cast<String, dynamic>()),
  //         )
  //         .where(_predictionMatchesServiceRegion)
  //         .toList(growable: false);
  //   } catch (e) {
  //     log('Error fetching place suggestions: $e', name: 'LocationService');
  //     return <Map<String, dynamic>>[];
  //   }
  // }

  Future<Position?> getPlaceDetails(String placeId, {String? address}) async {
    final trimmedPlaceId = placeId.trim();
    if (trimmedPlaceId.isEmpty) {
      return _getPositionFromAddress(address);
    }

    final apiKey = remoteConfigModel.mapApiKey.trim();
    final baseUrl = 'https://maps.googleapis.com/maps/api/';

    if (apiKey.isEmpty) {
      log(
        'Google Maps API key is missing; falling back to geocoding search.',
        name: 'LocationService',
      );
      return _getPositionFromAddress(address);
    }

    try {
      final uri =
          Uri.parse(
            '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}place/details/json',
          ).replace(
            queryParameters: <String, String>{
              'place_id': trimmedPlaceId,
              'fields': 'geometry',
              'key': apiKey,
            },
          );

      final response = await _dio.getUri(uri);
      final data = _normalizeResponse(response.data);
      final result = data['result'];

      if (result is Map<String, dynamic>) {
        final geometry = result['geometry'];
        if (geometry is Map<String, dynamic>) {
          final location = geometry['location'];
          if (location is Map<String, dynamic>) {
            final lat = (location['lat'] as num?)?.toDouble();
            final lng = (location['lng'] as num?)?.toDouble();
            if (lat != null && lng != null) {
              final position = Position(
                longitude: lng,
                latitude: lat,
                timestamp: DateTime.now(),
                accuracy: 0,
                altitude: 0,
                altitudeAccuracy: 0,
                heading: 0,
                headingAccuracy: 0,
                speed: 0,
                speedAccuracy: 0,
              );
              if (_positionWithinServiceRegion(position)) {
                return position;
              }

              log(
                'Place details result is outside the active service region.',
                name: 'LocationService',
              );
            }
          }
        }
      }
    } catch (e) {
      log('Unable to get place details', name: 'LocationService');
    }

    return _getPositionFromAddress(address);
  }

  /// Get address details (city, state, country, lat, lng) from Place ID.
  Future<AddressDetails?> getAddressDetailsFromPlaceId(String placeId) async {
    final trimmedPlaceId = placeId.trim();
    if (trimmedPlaceId.isEmpty) return null;

    final apiKey = remoteConfigModel.mapApiKey.trim();
    final baseUrl = 'https://maps.googleapis.com/maps/api/';
    if (apiKey.isEmpty) return null;

    try {
      final uri =
          Uri.parse(
            '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}place/details/json',
          ).replace(
            queryParameters: <String, String>{
              'place_id': trimmedPlaceId,
              'key': apiKey,
              'fields': 'geometry,address_components,formatted_address',
            },
          );

      final response = await _dio.getUri(uri);
      final data = _normalizeResponse(response.data);
      if (data['status'] != 'OK') return null;

      final result = data['result'];
      if (result is! Map) return null;
      final resultMap = result is Map<String, dynamic>
          ? result
          : Map<String, dynamic>.from(result);

      final geometry = resultMap['geometry'];
      final geometryMap = geometry is Map
          ? Map<String, dynamic>.from(geometry)
          : null;
      final location = geometryMap?['location'];
      final locationMap = location is Map
          ? Map<String, dynamic>.from(location)
          : null;

      final double lat = (locationMap?['lat'] as num?)?.toDouble() ?? 0.0;
      final double lng = (locationMap?['lng'] as num?)?.toDouble() ?? 0.0;

      String street = '';
      String city = '';
      String state = '';
      String country = '';
      String zipCode = '';

      final components =
          resultMap['address_components'] as List<dynamic>? ??
          const <dynamic>[];

      for (final raw in components) {
        if (raw is! Map) continue;
        final component = Map<String, dynamic>.from(raw);
        final types = component['types'] as List<dynamic>? ?? [];

        if (types.contains('street_number')) {
          final numStr = (component['long_name'] ?? '').toString();
          street = street.isEmpty ? numStr : '$numStr $street';
        } else if (types.contains('route')) {
          final routeStr = (component['long_name'] ?? '').toString();
          street = street.isEmpty ? routeStr : '$street $routeStr';
        }

        if (types.contains('locality')) {
          city = (component['long_name'] ?? '').toString();
        } else if (city.isEmpty &&
            (types.contains('sublocality_level_1') ||
                types.contains('sublocality') ||
                types.contains('administrative_area_level_2'))) {
          city = (component['long_name'] ?? '').toString();
        }

        if (types.contains('administrative_area_level_1')) {
          state = (component['long_name'] ?? '').toString();
        }

        if (types.contains('country')) {
          country = (component['long_name'] ?? '').toString();
        }

        if (types.contains('postal_code')) {
          zipCode = (component['long_name'] ?? '').toString();
        }
      }

      return AddressDetails(
        latitude: lat,
        longitude: lng,
        street: street,
        city: city,
        state: state,
        country: country,
        zipCode: zipCode,
      );
    } catch (e) {
      log('Unable to get address details', name: 'LocationService');
      return null;
    }
  }

  Future<Position?> _getPositionFromAddress(String? address) async {
    final trimmedAddress = address?.trim() ?? '';
    if (trimmedAddress.isEmpty) {
      return null;
    }

    try {
      final locations = await locationFromAddress(trimmedAddress);
      if (locations.isEmpty) {
        return null;
      }

      final location = locations.first;
      final position = Position(
        longitude: location.longitude,
        latitude: location.latitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      return _positionWithinServiceRegion(position) ? position : null;
    } catch (e) {
      log('Unable to resolve address', name: 'LocationService');
      return null;
    }
  }

  bool _positionWithinServiceRegion(Position position) {
    return _serviceRegion.contains(
      LatLng(position.latitude, position.longitude),
    );
  }

  Map<String, dynamic> _normalizeResponse(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }

    if (payload is Map) {
      return payload.map((key, value) => MapEntry(key.toString(), value));
    }

    return Map<String, dynamic>.from(
      jsonDecode(payload.toString()) as Map<String, dynamic>,
    );
  }
}
