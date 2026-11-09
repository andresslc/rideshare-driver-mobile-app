import '../../domain/entities/transaction_entity.dart';
import '../../../../shared/entity/bank_entity.dart';

enum WalletOperation {
  none,
  loadWallet,
  /// Refreshes wallet + page-1 transactions without clearing the list or loaders.
  silentSyncWallet,
  withdraw,
  attachBank,
  loadBanks,
  loadMore,
}

enum BankStatus { none, attached, notAttached }

class WalletState {
  final WalletOperation operation;
  final double balance;
  final double rewardedBalance;
  final double totalBalance;
  final List<TransactionEntity> transactions;
  final List<BankEntity> banks;
  final String? setupUrl;
  final BankStatus bankStatus;
  final String? withdrawalSuccess;
  final String? errorMessage;
  final String selectedCategory;

  const WalletState({
    this.operation = WalletOperation.none,
    this.balance = 0.0,
    this.rewardedBalance = 0.0,
    this.totalBalance = 0.0,
    this.transactions = const [],
    this.banks = const [],
    this.setupUrl,
    this.bankStatus = BankStatus.none,
    this.withdrawalSuccess,
    this.errorMessage,
    this.selectedCategory = 'all',
  });

  WalletState copyWith({
    WalletOperation? operation,
    double? balance,
    double? rewardedBalance,
    double? totalBalance,
    List<TransactionEntity>? transactions,
    List<BankEntity>? banks,
    BankStatus? bankStatus,
    String? setupUrl,
    String? withdrawalSuccess,
    String? errorMessage,
    String? selectedCategory,
  }) {
    return WalletState(
      operation: operation ?? this.operation,
      balance: balance ?? this.balance,
      rewardedBalance: rewardedBalance ?? this.rewardedBalance,
      totalBalance: totalBalance ?? this.totalBalance,
      transactions: transactions ?? this.transactions,
      banks: banks ?? this.banks,
      bankStatus: bankStatus ?? this.bankStatus,
      setupUrl: setupUrl ?? this.setupUrl,
      withdrawalSuccess: withdrawalSuccess ?? this.withdrawalSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
