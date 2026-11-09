import 'package:driver_app/features/ride_room/data/models/ride_models.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_response_entity.dart';

class RideResponseModel extends RideResponseEntity {
  const RideResponseModel({
    super.type,
    super.message,
    super.ride,
    super.rideOtp,
    super.rideId,
    super.offersCount,
    super.driverFare,
  });

  factory RideResponseModel.fromJson(Map<String, dynamic> json) {
    final double? driverFare = (json['driverFare'] as num?)?.toDouble();
    final Map<String, dynamic> rideMap = _normalizeRideMap(
      _asMap(json['ride']) ?? <String, dynamic>{},
      // `driverFare` travels beside `ride`, not inside it.
      driverFare: driverFare,
      fallbackRideId: json['rideId']?.toString(),
    );

    return RideResponseModel(
      rideId: json['rideId']?.toString(),
      type: json['status'] ?? json['type']?.toString(),
      message: json['message']?.toString(),
      ride: rideMap.isNotEmpty ? RideModel.fromJson(rideMap) : null,
      rideOtp: json['rideOTP']?.toString() ?? json['rideOtp']?.toString(),
      offersCount: json['count'] is int
          ? json['count']
          : int.tryParse(json['count']?.toString() ?? ''),
      driverFare: driverFare,
    );
  }

  Map<String, dynamic> toJson() {
    final RideModel? rideModel = ride is RideModel ? ride as RideModel : null;
    return <String, dynamic>{
      'type': type,
      'message': message,
      'ride': rideModel?.toJson(),
      'rideOTP': rideOtp,
      'rideId': rideId,
      'count': offersCount,
    };
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  /// The status event ships the ride with `id`/`status`/`fare` where the rest
  /// of the app expects `_id`/`rideStatus`/`rideFare`.
  static Map<String, dynamic> _normalizeRideMap(
    Map<String, dynamic> source, {
    double? driverFare,
    String? fallbackRideId,
  }) {
    if (source.isEmpty) return source;

    final Map<String, dynamic> normalized = Map<String, dynamic>.from(source);

    if (driverFare != null) {
      normalized['driverFare'] = normalized['driverFare'] ?? driverFare;
    }

    normalized['_id'] =
        normalized['_id'] ?? normalized['id'] ?? fallbackRideId ?? '';
    normalized['rideStatus'] =
        normalized['rideStatus'] ?? normalized['status'] ?? '';
    normalized['rideFare'] = normalized['rideFare'] ?? normalized['fare'] ?? 0;
    normalized['rideDistance'] =
        normalized['rideDistance'] ?? normalized['distance'] ?? 0;
    normalized['averageTime'] =
        normalized['averageTime'] ?? normalized['duration'] ?? 0;

    if (normalized['dropOffPointRequested'] == null &&
        normalized['dropOffPoint'] != null) {
      normalized['dropOffPointRequested'] = normalized['dropOffPoint'];
    }

    if (normalized['driver'] is Map) {
      final Map<String, dynamic> driver = Map<String, dynamic>.from(
        normalized['driver'] as Map,
      );
      normalized['driver'] = (driver['_id'] ?? driver['id'] ?? '').toString();
    }

    if (normalized['user'] is Map) {
      final Map<String, dynamic> user = Map<String, dynamic>.from(
        normalized['user'] as Map,
      );
      user['_id'] = user['_id'] ?? user['id'] ?? '';
      normalized['user'] = user;
    }

    return normalized;
  }
}
