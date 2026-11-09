class CarpoolIncomingRequestEntity {
  final String bookingId;
  final PassengerEntity passenger;
  final CarpoolStopEntity pickupStop;
  final CarpoolStopEntity dropOffStop;
  final int requiredSeats;
  final double fareCharged;
  final double? distance;

  const CarpoolIncomingRequestEntity({
    required this.bookingId,
    required this.passenger,
    required this.pickupStop,
    required this.dropOffStop,
    required this.requiredSeats,
    required this.fareCharged,
    this.distance,
  });
}

class PassengerEntity {
  final String passengerId;
  final String firstName;
  final String lastName;
  final String image;
  final num rating;

  const PassengerEntity({
    required this.passengerId,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.rating,
  });

  String get displayName => _resolveDisplayName(firstName, lastName);
  String get name => displayName;
}

class CarpoolStopEntity {
  final String placeName;
  final List<double> coordinates;
  final int order;

  const CarpoolStopEntity({
    required this.placeName,
    required this.coordinates,
    required this.order,
  });
}

String _resolveDisplayName(String? firstName, String lastName) {
  final parts = <String>[
    firstName?.trim() ?? '',
    lastName.trim(),
  ].where((part) => part.isNotEmpty);
  return parts.join(' ');
}
