import '../../../../shared/entity/bank_entity.dart';

class TransactionEntity {
  final String id;
  final double amount;
  final String type; // 'debit' or 'credit'
  final String identifierKey;
  final BankEntity? bank;
  final String status;
  final DateTime createdAt;
  final bool isRewarded;
  final String? balanceSource;

  /// Why the transaction exists, e.g. `driver_referral_bonus`, `admin_reward`.
  final String? purpose;
  final Map<String, dynamic>? metadata;
  final String? rideId;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.identifierKey,
    this.bank,
    required this.status,
    required this.createdAt,
    this.isRewarded = false,
    this.balanceSource,
    this.purpose,
    this.metadata,
    this.rideId,
  });
}
