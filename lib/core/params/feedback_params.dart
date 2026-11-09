class FeedbackParam {
  final String receiveId;
  final String receiverType;
  final num stars;
  final String? description;
  final String? rideId;
  final String? carpoolId; // ✅ optional carpoolId

  const FeedbackParam({
    required this.receiveId,
    required this.receiverType,
    required this.stars,
    this.description,
    this.rideId,
    this.carpoolId, // constructor me include
  });

  Map<String, dynamic> toJson() {
    return {
      "receiverId": receiveId,
      "receiverType": receiverType,
      "stars": stars,
      if (description != null) "description": description,
      if (rideId != null) "rideId": rideId, // optional field

      if (carpoolId != null) "carpoolId": carpoolId, // optional field
    };
  }
}
