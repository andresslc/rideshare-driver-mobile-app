class PassengerDetailedEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final double rating;
  final String pickupPlace;
  final double pickupLat;
  final double pickupLng;
  final String dropOffPlace;
  final double dropOffLat;
  final double dropOffLng;
  final int totalSeatsBooked;
  final String status;
  final int avgTime;
  final double distance;
  final num fareCharged;
  final ReviewEntity? review;

  PassengerDetailedEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    required this.rating,
    required this.pickupPlace,
    required this.pickupLat,
    required this.avgTime,
    required this.distance,
    this.fareCharged = 0.0,
    required this.pickupLng,
    required this.dropOffPlace,
    required this.dropOffLat,
    required this.dropOffLng,
    required this.totalSeatsBooked,
    required this.status,
    this.review,
  });

  String get displayName => [firstName.trim(), lastName.trim()]
      .where((part) => part.isNotEmpty)
      .join(' ');
  String get name => displayName;
}

class ReviewEntity {
  final int stars;
  final String description;
  final bool isAnonymous;

  ReviewEntity({
    required this.stars,
    required this.description,
    required this.isAnonymous,
  });
}
