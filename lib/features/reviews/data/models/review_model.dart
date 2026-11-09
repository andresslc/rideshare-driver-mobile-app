import 'package:driver_app/core/utils/name_utils.dart';
import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  ReviewModel({
    required super.id,
    required super.reviewerName,
    required super.reviewerImage,
    required super.receiverName,
    required super.receiverImage,
    required super.reviewerType,
    required super.receiverType,
    required super.stars,
    required super.description,
    required super.isOwn,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'],
      reviewerName: _displayName(json['reviewer']),
      reviewerImage: json['reviewer']['profilePicture'] ?? "",
      receiverName: _displayName(json['receiver']),
      receiverImage: json['receiver']['profilePicture'] ?? "",
      reviewerType: json['reviewerType'],
      receiverType: json['receiverType'],
      stars: json['stars'],
      description: json['description'] ?? "",
      isOwn: json['isOwn'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

String _displayName(dynamic user) {
  if (user is! Map<String, dynamic>) return '';
  return fallbackDisplayName(
    firstName: user['firstName']?.toString(),
    lastName: user['lastName']?.toString(),
    fallback: '',
  );
}
