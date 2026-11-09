class ReviewEntity {
  final String id;
  final String reviewerName;
  final String reviewerImage;
  final String receiverName;
  final String receiverImage;
  final String reviewerType;
  final String receiverType;
  final int stars;
  final String description;
  final bool isOwn;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.reviewerName,
    required this.reviewerImage,
    required this.receiverName,
    required this.receiverImage,
    required this.reviewerType,
    required this.receiverType,
    required this.stars,
    required this.description,
    required this.isOwn,
    required this.createdAt,
  });
}
