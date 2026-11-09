class CarpoolPassengerEntity {
  final String? id;
  /// Same person as [id] when list uses `signUpRecord` vs Mongo `_id`.
  final String? userSignUpRecord;
  final String bookingId;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final double rating;
  final String pickup;
  final String dropOff;
  final String status;
  final bool otpVerified;
  final int? requiredSeats;
  final double fareCharged;
  final double? avgTime;
  final double? distance;

  CarpoolPassengerEntity({
    this.id,
    this.userSignUpRecord,
    required this.bookingId,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    required this.rating,
    required this.pickup,
    required this.dropOff,
    required this.status,
    required this.otpVerified,
    this.requiredSeats,
    this.fareCharged = 0,
    this.avgTime,
    this.distance,
  });

  String get displayName => _resolveDisplayName(firstName, lastName);
  String get name => displayName;
}

String _resolveDisplayName(String? firstName, String lastName) {
  final parts = <String>[
    firstName?.trim() ?? '',
    lastName.trim(),
  ].where((part) => part.isNotEmpty);
  return parts.join(' ');
}

class CarpoolPassengerListEntity {
  final String carpoolId;
  final List<CarpoolPassengerEntity> passengers;

  CarpoolPassengerListEntity({
    required this.carpoolId,
    required this.passengers,
  });
}
