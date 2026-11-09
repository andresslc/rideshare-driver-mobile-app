import 'package:driver_app/core/services/storage_service.dart';
import 'package:driver_app/core/usecase/usecase.dart';
import 'package:driver_app/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:driver_app/features/dashboard/domain/usecases/get_dashboard_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:driver_app/core/di/service_locator.dart';
import 'package:flutter_riverpod/legacy.dart';

final dashboardProvider =
StateNotifierProvider<DashboardNotifier, AsyncValue<DriverDashboardEntity>>(
        (ref) {
      final getDashboardUseCase = locator<GetDashboardUseCase>();
      final storageService = locator<StorageService>();
      return DashboardNotifier(getDashboardUseCase, storageService);
    });

class DashboardNotifier extends StateNotifier<AsyncValue<DriverDashboardEntity>> {
  final GetDashboardUseCase _getDashboardUseCase;
  final StorageService _storageService;
  num? _pendingBalanceOverride;
  num? _pendingRewardedBalanceOverride;

  DashboardNotifier(this._getDashboardUseCase, this._storageService)
      : super(const AsyncValue.loading());

  /// Refreshes dashboard from the server.
  ///
  /// When [showLoading] is false, existing dashboard data stays visible (no
  /// full-screen spinner). Use after wallet withdrawal or other background syncs.
  Future<void> getDashboardData({bool showLoading = true}) async {
    final String? token = _storageService.getToken;
    if (token == null || token.isEmpty) {
      state = const AsyncValue.loading();
      return;
    }

    DriverDashboardEntity? previousData;
    state.maybeWhen(
      data: (d) => previousData = d,
      orElse: () {},
    );

    if (showLoading) {
      state = const AsyncValue.loading();
    }

    final result = await _getDashboardUseCase(NoParams());

    result.fold(
      (failure) {
        if (showLoading) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        } else if (previousData != null) {
          state = AsyncValue.data(previousData!);
        } else {
          state = AsyncValue.error(failure.message, StackTrace.current);
        }
      },
      (data) {
        DriverDashboardEntity next = data;
        final pending = _pendingBalanceOverride;
        final pendingRewarded = _pendingRewardedBalanceOverride;
        if (pending != null) {
          final server = data.driver.balance;
          if ((server - pending).abs() < 0.01) {
            _pendingBalanceOverride = null;
            _pendingRewardedBalanceOverride = null;
          } else {
            final nextRewarded = pendingRewarded ?? data.driver.rewardedBalance;
            next = data.copyWith(
              driver: data.driver.copyWith(
                balance: pending,
                rewardedBalance: nextRewarded,
                totalBalance: pending + nextRewarded,
              ),
            );
          }
        }
        state = AsyncValue.data(next);
      },
    );
  }

  /// Updates the displayed driver balance without a network call (e.g. after withdrawal).
  void updateDriverBalance(num newBalance, {num? newRewardedBalance}) {
    _pendingBalanceOverride = newBalance;
    if (newRewardedBalance != null) {
      _pendingRewardedBalanceOverride = newRewardedBalance;
    }
    state.maybeWhen(
      data: (currentData) {
        final nextRewarded = newRewardedBalance ?? currentData.driver.rewardedBalance;
        final updated = currentData.copyWith(
          driver: currentData.driver.copyWith(
            balance: newBalance,
            rewardedBalance: nextRewarded,
            totalBalance: newBalance + nextRewarded,
          ),
        );
        state = AsyncValue.data(updated);
      },
      orElse: () {},
    );
  }


  /// Increment completed rides by 1 and todayRides by 1
  void incrementCompletedRides() {
    state.maybeWhen(
      data: (currentData) {
        final updated = currentData.copyWith(
          completedRides: currentData.completedRides + 1,
          todayRides: currentData.todayRides + 1,
        );
        state = AsyncValue.data(updated);
      },
      orElse: () {},
    );
  }

  /// Increment cancelled rides by 1 and todayRides by 1
  void incrementCancelledRides() {
    state.maybeWhen(
      data: (currentData) {
        final updated = currentData.copyWith(
          cancelledRides: currentData.cancelledRides + 1,
          todayRides: currentData.todayRides + 1,
        );
        state = AsyncValue.data(updated);
      },
      orElse: () {},
    );
  }
}