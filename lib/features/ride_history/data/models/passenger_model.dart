// models/passenger_model.dart

import 'package:driver_app/features/ride_history/domain/enitities/passenger_entity.dart';

class PassengerDetailedModel extends PassengerDetailedEntity {
  PassengerDetailedModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.profilePicture,
    required super.rating,
    required super.pickupPlace,
    required super.pickupLat,
    required super.pickupLng,
    required super.dropOffPlace,
    required super.dropOffLat,
    required super.dropOffLng,
    required super.avgTime,
    required super.distance,
    required super.fareCharged,
    required super.totalSeatsBooked,
    required super.status,
    ReviewModel? super.review,
  });

  factory PassengerDetailedModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final pickup = json['pickupStop'] ?? {};
    final dropOff = json['dropOffStop'] ?? {};
    final reviewJson = json['review'];

    return PassengerDetailedModel(
      id: user['_id'] ?? '',
      firstName: user['firstName']?.toString() ?? '',
      lastName: user['lastName']?.toString() ?? '',
      profilePicture: user['profilePicture'], // optional
      rating: (user['rating'] != null)
          ? (user['rating'] as num).toDouble()
          : 0.0,
      avgTime: json['avgTime'] ?? 0, // ✅ NEW
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0, // ✅ NEW
      fareCharged: (json['fareCharged'] as num?)?.toDouble() ?? 0.0,
      pickupPlace: pickup['placeName'] ?? '',
      pickupLat: (pickup['location']?['coordinates']?[1] != null)
          ? (pickup['location']['coordinates'][1] as num).toDouble()
          : 0.0,
      pickupLng: (pickup['location']?['coordinates']?[0] != null)
          ? (pickup['location']['coordinates'][0] as num).toDouble()
          : 0.0,
      dropOffPlace: dropOff['placeName'] ?? '',
      dropOffLat: (dropOff['location']?['coordinates']?[1] != null)
          ? (dropOff['location']['coordinates'][1] as num).toDouble()
          : 0.0,
      dropOffLng: (dropOff['location']?['coordinates']?[0] != null)
          ? (dropOff['location']['coordinates'][0] as num).toDouble()
          : 0.0,
      totalSeatsBooked: json['totalSeatsBooked'] ?? 0,
      status: json['status'] ?? '',
      review: reviewJson != null ? ReviewModel.fromJson(reviewJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {
        '_id': id,
        'firstName': firstName,
        'lastName': lastName,
        'profilePicture': profilePicture,
        'rating': rating,
      },
      'pickupStop': {
        'placeName': pickupPlace,
        'location': {
          'type': 'Point',
          'coordinates': [pickupLng, pickupLat],
        },
      },
      'dropOffStop': {
        'placeName': dropOffPlace,
        'location': {
          'type': 'Point',
          'coordinates': [dropOffLng, dropOffLat],
        },
      },
      'totalSeatsBooked': totalSeatsBooked,
      'status': status,
      'review': review,
    };
  }
}

class ReviewModel extends ReviewEntity {
  ReviewModel({
    required super.stars,
    required super.description,
    required super.isAnonymous,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      stars: json['stars'] ?? 0,
      description: json['description'] ?? '',
      isAnonymous: json['isAnonymous'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stars': stars,
      'description': description,
      'isAnonymous': isAnonymous,
    };
  }
}
