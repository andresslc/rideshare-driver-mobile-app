import 'dart:async';

import 'package:driver_app/core/config/ride_config_model.dart';
import 'package:driver_app/core/constants/api_endpoints.dart';
import 'package:driver_app/core/services/api_service.dart';
import 'package:driver_app/core/services/storage_service.dart';
import 'package:driver_app/core/utils/app_log.dart';

/// Reads and caches `GET /api/config/ride`.
///
/// The endpoint is public (no token) and owns the distance unit, the dispatch
/// ladder and the dispatch texts, so none of that is compiled into the build.
/// On failure the last cached value is kept; if there is none, defaults apply.
class RideConfigService {
  final ApiService apiService;
  final StorageService storage;

  RideConfigService({required this.apiService, required this.storage});

  RideConfigModel _config = const RideConfigModel.defaults();
  bool _loadedFromCache = false;
  Future<RideConfigModel>? _inFlight;

  final StreamController<RideConfigModel> _changes =
      StreamController<RideConfigModel>.broadcast();

  /// Latest known configuration: fresh, else cached, else defaults.
  RideConfigModel get config {
    if (!_loadedFromCache) {
      final RideConfigModel? cached = RideConfigModel.decode(
        storage.getRideConfig,
      );
      if (cached != null) _config = cached;
      _loadedFromCache = true;
    }
    return _config;
  }

  /// Unit every distance in the app is printed in. Never converted client side.
  String get distanceUnit => config.distanceUnit;

  Stream<RideConfigModel> get changes => _changes.stream;

  /// Fetches the configuration and caches it. Concurrent calls share one
  /// request. Never throws: on error the current value is returned.
  Future<RideConfigModel> load({String? locale}) {
    return _inFlight ??= _load(locale: locale).whenComplete(() {
      _inFlight = null;
    });
  }

  Future<RideConfigModel> _load({String? locale}) async {
    final String resolvedLocale = (locale ?? storage.getLanguageCode ?? '')
        .trim();

    try {
      final response = await apiService.get(
        ApiEndpoints.rideConfig,
        queryParameters: resolvedLocale.isEmpty
            ? null
            : <String, dynamic>{'locale': resolvedLocale},
      );

      final dynamic body = response.data;
      if (body is! Map) {
        log('Unexpected ride config payload', name: 'RideConfigService');
        return config;
      }

      final RideConfigModel parsed = RideConfigModel.fromJson(
        Map<String, dynamic>.from(body),
      );

      _config = parsed;
      _loadedFromCache = true;
      unawaited(storage.setRideConfig(parsed.encode()));
      if (!_changes.isClosed) _changes.add(parsed);

      log(
        'Ride config loaded: unit=${parsed.distanceUnit} '
        'rings=${parsed.dispatch.totalRings}',
        name: 'RideConfigService',
      );
      return parsed;
    } catch (e) {
      // Offline or the endpoint is down: keep the cached value.
      log('Failed to load ride config: $e', name: 'RideConfigService');
      return config;
    }
  }

  void dispose() {
    unawaited(_changes.close());
  }
}
