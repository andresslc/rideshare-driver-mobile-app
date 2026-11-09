import 'package:driver_app/features/ride_room/data/models/ride_models.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_taken_entity.dart';

class RideTakenModel extends RideTakenEntity {
  const RideTakenModel({
    required super.rideId,
    super.reason,
    super.availableRides,
  });

  factory RideTakenModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> body = _asMap(json['data']) ?? json;

    return RideTakenModel(
      rideId: (body['rideId'] ?? body['_id'] ?? body['id'] ?? '')
          .toString()
          .trim(),
      reason: (body['reason'] ?? body['code'] ?? '').toString().trim(),
      availableRides: _parseAvailableRides(
        body['availableRides'] ?? json['availableRides'],
      ),
    );
  }

  /// The event ships the queue either as a plain list or wrapped in
  /// `{ data: [...] }`, the same envelope the HTTP list uses.
  static List<RideEntity>? _parseAvailableRides(dynamic value) {
    final dynamic raw = value is Map
        ? (_asMap(value)?['data'] ?? value)
        : value;
    if (raw is! List) return null;

    return raw
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .map<RideEntity>(RideModel.fromJson)
        .toList(growable: false);
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
