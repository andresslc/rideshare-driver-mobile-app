/// Display-only args for the demo chat screen (ride sheets pass rider info).
class ChatScreenArgs {
  const ChatScreenArgs({
    required this.riderName,
    this.riderProfileImage,
    this.rideId,
    this.riderId,
    this.isCarpool = 'false',
  });

  final String riderName;
  final String? riderProfileImage;
  final String? rideId;
  final String? riderId;
  final String isCarpool;
}
