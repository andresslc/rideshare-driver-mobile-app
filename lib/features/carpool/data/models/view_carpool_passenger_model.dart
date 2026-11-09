import 'package:driver_app/features/carpool/domain/entities/view_carpool_passenger_entity.dart';

class CarpoolPassengerModel extends CarpoolPassengerEntity {
  CarpoolPassengerModel({
    super.id,
    super.userSignUpRecord,
    required super.bookingId,
    required super.firstName,
    required super.lastName,
    required super.profilePicture,
    required super.rating,
    required super.pickup,
    required super.dropOff,
    required super.status,
    required super.otpVerified,
    super.requiredSeats,
    required super.fareCharged,
    super.avgTime,
    super.distance,
  });

  static String? _passengerUserIdFromJson(Map<String, dynamic> json) {
    const keys = <String>[
      'passengerId',
      'passenger_id',
      'userId',
      'user_id',
    ];
    for (final String k in keys) {
      final Object? v = json[k];
      if (v == null) continue;
      final String s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    final Object? nested = json['passenger'];
    if (nested is Map) {
      final Map<String, dynamic> m = Map<String, dynamic>.from(
        Map<dynamic, dynamic>.from(nested),
      );
      final String inner =
          (m['_id'] ?? m['id'] ?? '').toString().trim();
      if (inner.isNotEmpty) return inner;
    }
    return null;
  }

  static String? _passengerSignUpRecordFromJson(Map<String, dynamic> json) {
    const keys = <String>['signUpRecord', 'sign_up_record'];
    for (final String k in keys) {
      final Object? v = json[k];
      if (v == null) continue;
      final String s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    final Object? nested = json['passenger'];
    if (nested is Map) {
      final Map<String, dynamic> m = Map<String, dynamic>.from(
        Map<dynamic, dynamic>.from(nested),
      );
      final String sur =
          (m['signUpRecord'] ?? m['sign_up_record'] ?? '').toString().trim();
      if (sur.isNotEmpty) return sur;
    }
    return null;
  }

  factory CarpoolPassengerModel.fromJson(Map<String, dynamic> json) {
    return CarpoolPassengerModel(
      id: _passengerUserIdFromJson(json),
      userSignUpRecord: _passengerSignUpRecordFromJson(json),
      bookingId:
          (json['bookingId'] ??
                  json['booking_id'] ??
                  json['id'] ??
                  json['_id'] ??
                  '')
              .toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      profilePicture: json['profilePicture'],
      rating: (json['rating'] ?? 0).toDouble(),
      pickup: json['pickup'] ?? '',
      dropOff: json['dropOff'] ?? '',
      status: json['status'] ?? '',
      otpVerified: json['otpVerified'] == true,
      requiredSeats: _readInt(json, const ['requiredSeats', 'seats']),
      fareCharged: (json['fareCharged'] ?? json['fare'] ?? 0).toDouble(),
      avgTime: (json['avgTime'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }
}
