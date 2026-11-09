import '../../../../core/entities.dart/pagination_entity.dart';

enum DriverReferralStatus {
  saved,
  applied,
  completed,
  voided,

  /// Fallback so a future backend status doesn't crash the list.
  unknown;

  static DriverReferralStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'saved':
        return DriverReferralStatus.saved;
      case 'applied':
        return DriverReferralStatus.applied;
      case 'completed':
        return DriverReferralStatus.completed;
      case 'voided':
        return DriverReferralStatus.voided;
      default:
        return DriverReferralStatus.unknown;
    }
  }
}

class DriverReferralItemEntity {
  final String id;
  final String? riderFirstName;
  final String? riderProfilePicture;
  final DriverReferralStatus status;

  /// Status exactly as the API sent it; shown when [status] is `unknown`.
  final String? rawStatus;

  /// Set only when [status] is [DriverReferralStatus.completed].
  final double? bonusAmount;
  final DateTime? savedAt;
  final DateTime? completedAt;
  final DateTime? voidedAt;

  const DriverReferralItemEntity({
    required this.id,
    this.riderFirstName,
    this.riderProfilePicture,
    required this.status,
    this.rawStatus,
    this.bonusAmount,
    this.savedAt,
    this.completedAt,
    this.voidedAt,
  });

  /// The date that best describes the current status.
  DateTime? get displayDate => completedAt ?? voidedAt ?? savedAt;
}

class DriverReferralHistoryEntity {
  final List<DriverReferralItemEntity> items;
  final PaginationEntity pagination;

  const DriverReferralHistoryEntity({
    required this.items,
    required this.pagination,
  });
}
