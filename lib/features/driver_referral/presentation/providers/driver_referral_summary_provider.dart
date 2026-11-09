import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/notification_route_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/usecases/get_driver_referral_summary_usecase.dart';
import '../states/driver_referral_states.dart';

final driverReferralSummaryProvider =
    StateNotifierProvider.autoDispose<
      DriverReferralSummaryNotifier,
      DriverReferralSummaryState
    >((ref) {
      return DriverReferralSummaryNotifier(
        getSummaryUseCase: locator<GetDriverReferralSummaryUseCase>(),
      );
    });

class DriverReferralSummaryNotifier
    extends StateNotifier<DriverReferralSummaryState> {
  final GetDriverReferralSummaryUseCase getSummaryUseCase;
  StreamSubscription<Map<String, dynamic>>? _notificationPayloadSub;

  DriverReferralSummaryNotifier({required this.getSummaryUseCase})
    : super(const DriverReferralSummaryState()) {
    _listenToReferralBonus();
  }

  /// The first call also creates the driver's code, so the screen shows a
  /// loader rather than an empty code.
  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await getSummaryUseCase();
    if (!mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (summary) => state = state.copyWith(isLoading: false, summary: summary),
    );
  }

  Future<void> refresh() => load();

  /// Stats change when a referred rider completes a ride.
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
}
