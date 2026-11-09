import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/notification_route_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/usecases/get_bank_list_usecase.dart';
import '../../domain/usecases/get_transaction_history_usecase.dart';
import '../../domain/usecases/setup_account_usecase.dart';
import '../../domain/usecases/withdraw_funds_usecase.dart';
import '../states/wallet_states.dart';

final walletProvider =
    StateNotifierProvider.autoDispose<WalletNotifier, WalletState>((ref) {
      return WalletNotifier(
        ref,
        getTransactionHistoryUseCase: locator<GetTransactionHistoryUseCase>(),
        setupAccountUseCase: locator<SetupAccountUseCase>(),
        getBankListUseCase: locator<GetBankListUseCase>(),
        withdrawFundsUseCase: locator<WithdrawFundsUseCase>(),
      );
    });

class WalletNotifier extends StateNotifier<WalletState> {
  final Ref _ref;
  final GetTransactionHistoryUseCase getTransactionHistoryUseCase;
  final SetupAccountUseCase setupAccountUseCase;
  final GetBankListUseCase getBankListUseCase;
  final WithdrawFundsUseCase withdrawFundsUseCase;

  WalletNotifier(
    this._ref, {
    required this.getTransactionHistoryUseCase,
    required this.setupAccountUseCase,
    required this.getBankListUseCase,
    required this.withdrawFundsUseCase,
  }) : super(const WalletState()) {
    _listenToReferralBonus();
  }

  StreamSubscription<Map<String, dynamic>>? _notificationPayloadSub;

  /// A referral bonus lands in `rewardedBalance`: refresh without loaders.
  void _listenToReferralBonus() {
    _notificationPayloadSub = locator<NotificationServices>()
        .notificationPayloadStream
        .listen((payload) {
          final type = locator<NotificationRouteService>().notificationTypeOf(
            payload,
          );
          if (type == NotificationRouteService.driverReferralBonusType) {
            fetchWalletData(
              refresh: true,
              silentRefresh: true,
              type: state.selectedCategory,
            );
          }
        });
  }

  @override
  void dispose() {
    _notificationPayloadSub?.cancel();
    super.dispose();
  }

  int _currentPage = 1;
  bool _hasMore = true;
  double? _optimisticWithdrawBalance;
  double? _optimisticWithdrawRewardedBalance;
  double? _optimisticWithdrawTotalBalance;

  Future<void> fetchWalletData({
    bool refresh = false,
    String? type,
    bool preserveOptimisticWithdrawBalance = false,
    bool silentRefresh = false,
  }) async {
    if (refresh && !silentRefresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    final int? savedPage = silentRefresh ? _currentPage : null;
    final bool? savedHasMore = silentRefresh ? _hasMore : null;

    if (refresh && silentRefresh) {
      state = state.copyWith(
        operation: WalletOperation.silentSyncWallet,
        errorMessage: "",
        withdrawalSuccess: "",
        selectedCategory: type ?? state.selectedCategory,
      );
    } else if (refresh) {
      state = state.copyWith(
        operation: WalletOperation.loadWallet,
        errorMessage: "",
        withdrawalSuccess: "",
        selectedCategory: type ?? state.selectedCategory,
      );
    } else {
      state = state.copyWith(
        operation: WalletOperation.loadMore,
        errorMessage: "",
        withdrawalSuccess: "",
      );
    }

    final int requestPage = silentRefresh ? 1 : _currentPage;

    final result = await getTransactionHistoryUseCase(
      page: requestPage,
      type: type,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          operation: WalletOperation.none,
          errorMessage: failure.message,
        );
      },
      (data) {
        var nextBalance = data.balance;
        var nextRewardedBalance = data.rewardedBalance;
        var nextTotalBalance = data.totalBalance;
        if (preserveOptimisticWithdrawBalance &&
            _optimisticWithdrawBalance != null &&
            data.balance > _optimisticWithdrawBalance!) {
          // Keep optimistic value if backend is temporarily stale.
          nextBalance = _optimisticWithdrawBalance!;
          nextRewardedBalance = _optimisticWithdrawRewardedBalance ?? data.rewardedBalance;
          nextTotalBalance = _optimisticWithdrawTotalBalance ?? (nextBalance + nextRewardedBalance);
        } else if (_optimisticWithdrawBalance != null &&
            data.balance <= _optimisticWithdrawBalance!) {
          // Backend caught up with withdrawal amount.
          _optimisticWithdrawBalance = null;
          _optimisticWithdrawRewardedBalance = null;
          _optimisticWithdrawTotalBalance = null;
        }

        if (silentRefresh) {
          if (savedPage != null) {
            _currentPage = savedPage;
          }
          if (savedHasMore != null) {
            _hasMore = savedHasMore;
          }
          final existingIds = state.transactions.map((t) => t.id).toSet();
          final newRows = data.transactions
              .where((t) => !existingIds.contains(t.id))
              .toList();
          final merged = [...newRows, ...state.transactions];
          final isAttached = data.isBankAccountAttached &&
              data.stripePayoutCapability?.trim().toLowerCase() != 'inactive' &&
              data.stripeTransfersCapability?.trim().toLowerCase() != 'inactive';

          state = state.copyWith(
            operation: WalletOperation.none,
            balance: nextBalance,
            rewardedBalance: nextRewardedBalance,
            totalBalance: nextTotalBalance,
            bankStatus: isAttached
                ? BankStatus.attached
                : BankStatus.notAttached,
            transactions: merged,
          );
          return;
        }

        _hasMore = data.transactions.length >= 20;
        _currentPage++;

        final isAttached = data.isBankAccountAttached &&
            data.stripePayoutCapability?.trim().toLowerCase() != 'inactive' &&
            data.stripeTransfersCapability?.trim().toLowerCase() != 'inactive';

        state = state.copyWith(
          operation: WalletOperation.none,
          balance: nextBalance,
          rewardedBalance: nextRewardedBalance,
          totalBalance: nextTotalBalance,
          bankStatus: isAttached
              ? BankStatus.attached
              : BankStatus.notAttached,
          transactions: refresh
              ? data.transactions
              : [...state.transactions, ...data.transactions],
        );
      },
    );
  }

  Future<void> setupBankAccount() async {
    state = state.copyWith(
      operation: WalletOperation.attachBank,
      errorMessage: "",
      withdrawalSuccess: "",
      setupUrl: "",
    );

    final result = await setupAccountUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          operation: WalletOperation.none,
          errorMessage: failure.message,
        );
      },
      (data) {
        state = state.copyWith(
          operation: WalletOperation.none,
          setupUrl: data.url,
        );
      },
    );
  }

  Future<void> fetchBanks() async {
    state = state.copyWith(
      operation: WalletOperation.loadBanks,
      errorMessage: "",
      withdrawalSuccess: "",
    );

    final result = await getBankListUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          operation: WalletOperation.none,
          errorMessage: failure.message,
        );
      },
      (banks) {
        state = state.copyWith(operation: WalletOperation.none, banks: banks);
      },
    );
  }

  Future<void> withdraw({
    required double amount,
    required String bankId,
  }) async {
    state = state.copyWith(
      operation: WalletOperation.withdraw,
      errorMessage: "",
      withdrawalSuccess: "",
    );

    final result = await withdrawFundsUseCase(amount: amount, bankId: bankId);

    result.fold(
      (failure) {
        state = state.copyWith(
          operation: WalletOperation.none,
          errorMessage: failure.message,
        );
      },
      (message) {
        double remainingAmount = amount;
        double newBalance = state.balance;
        double newRewardedBalance = state.rewardedBalance;

        if (newBalance >= remainingAmount) {
          newBalance -= remainingAmount;
          remainingAmount = 0;
        } else {
          remainingAmount -= newBalance;
          newBalance = 0;
        }

        if (remainingAmount > 0) {
          newRewardedBalance = (newRewardedBalance - remainingAmount).clamp(0.0, double.infinity);
        }

        final updatedBalance = newBalance.toDouble();
        final updatedRewardedBalance = newRewardedBalance.toDouble();
        final updatedTotalBalance = (state.totalBalance - amount)
            .clamp(0.0, double.infinity)
            .toDouble();

        _optimisticWithdrawBalance = updatedBalance;
        _optimisticWithdrawRewardedBalance = updatedRewardedBalance;
        _optimisticWithdrawTotalBalance = updatedTotalBalance;

        state = state.copyWith(
          operation: WalletOperation.none,
          withdrawalSuccess: message,
          balance: updatedBalance,
          rewardedBalance: updatedRewardedBalance,
          totalBalance: updatedTotalBalance,
        );
        _ref
            .read(dashboardProvider.notifier)
            .updateDriverBalance(updatedBalance, newRewardedBalance: updatedRewardedBalance);
      },
    );
  }
}
