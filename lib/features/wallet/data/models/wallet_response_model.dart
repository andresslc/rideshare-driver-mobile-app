import '../../domain/entities/wallet_data_entity.dart';
import 'transaction_model.dart';

class WalletResponseModel extends WalletDataEntity {
  const WalletResponseModel({
    required super.balance,
    required super.rewardedBalance,
    required super.totalBalance,
    required super.isBankAccountAttached,
    required super.transactions,
    super.stripePayoutCapability,
    super.stripeTransfersCapability,
  });

  factory WalletResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    final stripeConnect = (data['stripeConnectCapabilities'] ?? json['stripeConnectCapabilities']) as Map<String, dynamic>?;
    final payout = stripeConnect?['payout']?.toString();
    final transfers = (stripeConnect?['transfers'] ?? stripeConnect?['transfers '])?.toString();

    final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
    final rewardedBalance = (data['rewardedBalance'] as num?)?.toDouble() ?? 0.0;
    final totalBalance = (data['totalBalance'] as num?)?.toDouble() ?? (balance + rewardedBalance);

    return WalletResponseModel(
      balance: balance,
      rewardedBalance: rewardedBalance,
      totalBalance: totalBalance,
      isBankAccountAttached: data['isBankAccountAttached'] ?? false,
      transactions:
          (data['transactions'] as List?)
              ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      stripePayoutCapability: payout,
      stripeTransfersCapability: transfers,
    );
  }
}
