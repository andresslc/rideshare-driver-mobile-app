class ReportParam {
  final String entityId;
  final String entityType;
  final String reason;
  final String description;

  const ReportParam({
    required this.entityId,
    required this.entityType,
    required this.reason,
    required this.description,
  });
  Map<String, dynamic> toJson() {
    return {
      "entityId": entityId,
      "entityType": entityType,
      if (reason.isNotEmpty) "reason": reason,
      "description": description,
    };
  }
}
