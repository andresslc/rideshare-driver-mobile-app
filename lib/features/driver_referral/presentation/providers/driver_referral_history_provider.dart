import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/notification_route_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/usecases/get_driver_referral_history_usecase.dart';
import '../states/driver_referral_states.dart';

final driverReferralHistoryProvider =
    StateNotifierProvider.autoDispose<
      DriverReferralHistoryNotifier,
      DriverReferralHistoryState
    >((ref) {
      return DriverReferralHistoryNotifier(
        getHistoryUseCase: locator<GetDriverReferralHistoryUseCase>(),
      );
    });

class DriverReferralHistoryNotifier
    extends StateNotifier<DriverReferralHistoryState> {
  final GetDriverReferralHistoryUseCase getHistoryUseCase;

  StreamSubscription<Map<String, dynamic>>? _notificationPayloadSub;

  DriverReferralHistoryNotifier({required this.getHistoryUseCase})
    : super(const DriverReferralHistoryState()) {
    _listenToReferralBonus();
  }

  /// A referred ride completed: its row moves to `completed`.
  void _listenToReferralBonus() {
    _notificationPayloadSub = locator<NotificationServices>()
        .notificationPayloadStream
        .listen((payload) {
          final type = locator<NotificationRouteService>().notificationTypeOf(
            payload,
          );
          if (type == NotificationRouteService.driverReferralBonusType) {
            refresh();
          }
        });
  }

  @override
  void dispose() {
    _notificationPayloadSub?.cancel();
    super.dispose();
  }

  static const _limit = 20;

  /// Loads the first page, replacing the current list.
  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await getHistoryUseCase(page: 1, limit: _limit);
    if (!mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (history) => state = DriverReferralHistoryState(
        items: history.items,
        page: 1,
        hasMore: history.pagination.hasMore,
      ),
    );
  }

  Future<void> refresh() => load();

  /// Appends the next page. Uses `page < totalPages` from the response.
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    final nextPage = state.page + 1;
    final result = await getHistoryUseCase(page: nextPage, limit: _limit);
    if (!mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingMore: false,
        errorMessage: failure.message,
      ),
      (history) => state = state.copyWith(
        items: [...state.items, ...history.items],
        page: nextPage,
        hasMore: history.pagination.hasMore,
        isLoadingMore: false,
      ),
    );
  }
}
