import '../../../../core/models/pagination_models.dart';
import '../../domain/entities/driver_referral_item_entity.dart';

class DriverReferralItemModel extends DriverReferralItemEntity {
  const DriverReferralItemModel({
    required super.id,
    super.riderFirstName,
    super.riderProfilePicture,
    required super.status,
    super.rawStatus,
    super.bonusAmount,
    super.savedAt,
    super.completedAt,
    super.voidedAt,
  });

  factory DriverReferralItemModel.fromJson(Map<String, dynamic> json) {
    return DriverReferralItemModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      riderFirstName: json['riderFirstName'] as String?,
      riderProfilePicture: json['riderProfilePicture'] as String?,
      status: DriverReferralStatus.fromString(json['status'] as String?),
      rawStatus: json['status']?.toString(),
      bonusAmount: (json['bonusAmount'] as num?)?.toDouble(),
      savedAt: _parseDate(json['savedAt']),
      completedAt: _parseDate(json['completedAt']),
      voidedAt: _parseDate(json['voidedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}

/// Response of `GET /api/driver-referral/driver/history`:
/// `data: []` plus `pagination: { page, limit, total, totalPages }`.
class DriverReferralHistoryModel extends DriverReferralHistoryEntity {
  const DriverReferralHistoryModel({
    required super.items,
    required super.pagination,
  });

  factory DriverReferralHistoryModel.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return DriverReferralHistoryModel(
      items:
          (json['data'] as List?)
              ?.map(
                (e) =>
                    DriverReferralItemModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      // This endpoint uses page/limit/total instead of the
      // currentPage/itemsPerPage/totalItems keys PaginationModel expects.
      pagination: PaginationModel(
        itemsPerPage: pagination['limit'] ?? 0,
        currentPage: pagination['page'] ?? 0,
        totalItems: pagination['total'] ?? 0,
        totalPages: pagination['totalPages'] ?? 0,
      ),
    );
  }
}
