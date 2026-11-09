import 'dart:convert';

/// One ring of the dispatch ladder.
class RideConfigRing {
  final int ring;

  /// Raw value, always in miles.
  final double radiusMiles;

  /// Same radius expressed in [RideConfigModel.distanceUnit] — what gets printed.
  final double radius;

  const RideConfigRing({
    required this.ring,
    required this.radiusMiles,
    required this.radius,
  });

  factory RideConfigRing.fromJson(Map<String, dynamic> json) {
    final double miles = (json['radiusMiles'] as num?)?.toDouble() ?? 0;
    return RideConfigRing(
      ring: (json['ring'] as num?)?.toInt() ?? 0,
      radiusMiles: miles,
      radius: (json['radius'] as num?)?.toDouble() ?? miles,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'ring': ring,
    'radiusMiles': radiusMiles,
    'radius': radius,
  };
}

/// Dispatch ladder as configured from the admin panel.
class RideConfigDispatch {
  final int totalRings;
  final int ringTimeoutSeconds;
  final int maxSearchSeconds;
  final List<RideConfigRing> rings;

  const RideConfigDispatch({
    this.totalRings = 0,
    this.ringTimeoutSeconds = 0,
    this.maxSearchSeconds = 0,
    this.rings = const <RideConfigRing>[],
  });

  factory RideConfigDispatch.fromJson(Map<String, dynamic> json) {
    final dynamic rawRings = json['rings'];
    return RideConfigDispatch(
      totalRings: (json['totalRings'] as num?)?.toInt() ?? 0,
      ringTimeoutSeconds: (json['ringTimeoutSeconds'] as num?)?.toInt() ?? 0,
      maxSearchSeconds: (json['maxSearchSeconds'] as num?)?.toInt() ?? 0,
      rings: rawRings is List
          ? rawRings
                .whereType<Map>()
                .map(
                  (dynamic e) =>
                      RideConfigRing.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList(growable: false)
          : const <RideConfigRing>[],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'totalRings': totalRings,
    'ringTimeoutSeconds': ringTimeoutSeconds,
    'maxSearchSeconds': maxSearchSeconds,
    'rings': rings.map((RideConfigRing r) => r.toJson()).toList(),
  };
}

/// Server-owned ride configuration from `GET /api/config/ride`.
///
/// Distances and dispatch texts belong to the backend: the app prints
/// [distanceUnit] as given and never converts, so changing the unit in the
/// admin panel takes effect without a release.
class RideConfigModel {
  final String locale;
  final String distanceUnit;
  final RideConfigDispatch dispatch;
  final Map<String, String> messages;
  final DateTime? updatedAt;

  const RideConfigModel({
    this.locale = '',
    this.distanceUnit = defaultDistanceUnit,
    this.dispatch = const RideConfigDispatch(),
    this.messages = const <String, String>{},
    this.updatedAt,
  });

  /// Used until the first successful fetch, and if the endpoint is unreachable
  /// with nothing cached.
  static const String defaultDistanceUnit = 'mi';

  const RideConfigModel.defaults() : this();

  factory RideConfigModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = _asMap(json['data']) ?? json;
    final String unit = data['distanceUnit']?.toString().trim() ?? '';
    final Map<String, dynamic>? rawMessages = _asMap(data['messages']);

    return RideConfigModel(
      locale: data['locale']?.toString().trim() ?? '',
      distanceUnit: unit.isEmpty ? defaultDistanceUnit : unit,
      dispatch: RideConfigDispatch.fromJson(
        _asMap(data['dispatch']) ?? <String, dynamic>{},
      ),
      messages: rawMessages == null
          ? const <String, String>{}
          : rawMessages.map(
              (String key, dynamic value) =>
                  MapEntry<String, String>(key, value?.toString() ?? ''),
            ),
      updatedAt: DateTime.tryParse(data['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'locale': locale,
    'distanceUnit': distanceUnit,
    'dispatch': dispatch.toJson(),
    'messages': messages,
    'updatedAt': updatedAt?.toIso8601String(),
  };

  String encode() => jsonEncode(toJson());

  static RideConfigModel? decode(String? source) {
    if (source == null || source.trim().isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(source);
      if (decoded is Map) {
        return RideConfigModel.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
