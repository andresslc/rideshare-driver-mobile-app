class DriverReferralStatsEntity {
  /// Riders who saved the code but have not ridden yet.
  final int saved;

  /// Riders whose first ride is in progress.
  final int applied;

  /// Riders who completed their first ride (bonus paid).
  final int completed;

  /// First rides cancelled after they started (no bonus).
  final int voided;

  /// Sum of bonuses paid to the driver.
  final double totalEarned;

  const DriverReferralStatsEntity({
    this.saved = 0,
    this.applied = 0,
    this.completed = 0,
    this.voided = 0,
    this.totalEarned = 0,
  });
}

class DriverReferralSummaryEntity {
  /// 7-character alphanumeric code, e.g. `K7M4QXR`.
  final String referralCode;

  /// When false the programme is paused: show a banner and hide Share.
  final bool enabled;

  /// What the rider saves on their first ride.
  final double riderDiscountAmount;

  /// What this driver earns per completed referral.
  final double driverBonusAmount;

  final DriverReferralStatsEntity stats;

  const DriverReferralSummaryEntity({
    required this.referralCode,
    required this.enabled,
    required this.riderDiscountAmount,
    required this.driverBonusAmount,
    this.stats = const DriverReferralStatsEntity(),
  });
}
