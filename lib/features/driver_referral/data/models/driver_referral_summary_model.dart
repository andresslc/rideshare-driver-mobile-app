import '../../domain/entities/driver_referral_summary_entity.dart';

class DriverReferralStatsModel extends DriverReferralStatsEntity {
  const DriverReferralStatsModel({
    super.saved,
    super.applied,
    super.completed,
    super.voided,
    super.totalEarned,
  });

  factory DriverReferralStatsModel.fromJson(Map<String, dynamic> json) {
    return DriverReferralStatsModel(
      saved: (json['saved'] as num?)?.toInt() ?? 0,
      applied: (json['applied'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      voided: (json['voided'] as num?)?.toInt() ?? 0,
      totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// `data` of `GET /api/driver-referral/driver/me`.
class DriverReferralSummaryModel extends DriverReferralSummaryEntity {
  const DriverReferralSummaryModel({
    required super.referralCode,
    required super.enabled,
    required super.riderDiscountAmount,
    required super.driverBonusAmount,
    super.stats,
  });

  factory DriverReferralSummaryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return DriverReferralSummaryModel(
      referralCode: (data['referralCode'] ?? '').toString().toUpperCase(),
      enabled: data['enabled'] as bool? ?? true,
      riderDiscountAmount:
          (data['riderDiscountAmount'] as num?)?.toDouble() ?? 0.0,
      driverBonusAmount: (data['driverBonusAmount'] as num?)?.toDouble() ?? 0.0,
      stats: DriverReferralStatsModel.fromJson(
        data['stats'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
