class SendMessageParams {
  final String receiverId;
  final String message;
  final String contextId;
  final String contextType;

  SendMessageParams({
    required this.receiverId,
    required this.message,
    required this.contextId,
    required this.contextType,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'message': message,
      'contextId': contextId,
      'contextType': contextType,
    };
  }
}