import 'transaction_entity.dart';

class WalletDataEntity {
  final double balance;
  final double rewardedBalance;
  final double totalBalance;
  final bool isBankAccountAttached;
  final List<TransactionEntity> transactions;
  final String? stripePayoutCapability;
  final String? stripeTransfersCapability;

  const WalletDataEntity({
    required this.balance,
    required this.rewardedBalance,
    required this.totalBalance,
    required this.isBankAccountAttached,
    required this.transactions,
    this.stripePayoutCapability,
    this.stripeTransfersCapability,
  });
}
