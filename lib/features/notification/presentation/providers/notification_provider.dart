import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/features/notification/domain/usecase/delete_all_notifications_use_case.dart';
import 'package:driver_app/features/notification/domain/usecase/delete_notification_use_case.dart';
import 'package:driver_app/features/notification/domain/usecase/toggle_notification_usecase.dart';
import 'package:driver_app/features/notification/presentation/states/notification_state.dart';
import 'package:driver_app/features/user_profile/presentation/providers/user_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/params/notification_params.dart';
import '../../domain/usecase/get_notification_use_case.dart';

final notificationProvider =
    NotifierProvider<NotificationController, NotificationState>(
      NotificationController.new,
    );

class NotificationController extends Notifier<NotificationState> {
  late ToggleNotificationUsecase _toggleNotification;
  late DeleteNotificationUseCase _deleteNotificationUseCase;
  late DeleteAllNotificationsUseCase _deleteAllNotificationsUseCase;
  GetNotificationUseCase get getNotificationUseCase =>
      locator<GetNotificationUseCase>();

  @override
  NotificationState build() {
    _toggleNotification = locator<ToggleNotificationUsecase>();
    _deleteNotificationUseCase = locator<DeleteNotificationUseCase>();
    _deleteAllNotificationsUseCase = locator<DeleteAllNotificationsUseCase>();
    final profile = ref.read(userProfileProvider).profile;
    return NotificationState(
      isNotificationEnabled: profile?.user.isNotificationEnabled ?? true,
    );
  }

  void setInitialValue(bool value) {
    state = state.copyWith(isNotificationEnabled: value);
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }

  Future<void> toggleNotification(bool value, String? fcm) async {
    state = state.copyWith(
      status: NotificationStatus.loading,
      isNotificationEnabled: value,
    );

    final result = await _toggleNotification(isEnabled: value, fcm: fcm);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: NotificationStatus.error,
          message: failure.message,
          isNotificationEnabled: !value, // Revert on failure
        );
      },
      (response) {
        state = state.copyWith(
          status: NotificationStatus.success,
          isNotificationEnabled: value,
        );
        // Sync with UserProfileProvider
        ref.read(userProfileProvider.notifier).updateNotificationStatus(value);
      },
    );
  }

  Future<void> getNotifications({required NotificationParams params}) async {
    final isFirstPage = params.page == 1;

    if (isFirstPage) {
      state = state.copyWith(
        getNotifStatus: NotificationStatus.loading,
        page: 1,
        hasMore: true,
      );
    } else {
      if (state.isLoadingMore || !state.hasMore) return;

      state = state.copyWith(isLoadingMore: true);
    }

    final result = await getNotificationUseCase.call(params: params);

    result.fold(
      (failure) {
        state = state.copyWith(
          message: failure.message,
          getNotifStatus: NotificationStatus.error,
          isLoadingMore: false,
        );
      },
      (newNotifications) {
        final isLastPage = newNotifications.isEmpty;

        state = state.copyWith(
          getNotifStatus: NotificationStatus.success,
          notifications: isFirstPage
              ? newNotifications
              : [...state.notifications, ...newNotifications],
          page: params.page,
          hasMore: !isLastPage,
          isLoadingMore: false,
        );
      },
    );
  }

  Future<bool> deleteNotification(String notificationId) async {
    if (state.deletingNotificationId != "" || state.isDeletingAll) {
      return false;
    }

    try {
      state = state.copyWith(deletingNotificationId: notificationId);

      final result = await _deleteNotificationUseCase(
        notificationId: notificationId,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            deletingNotificationId: "",
            message: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(
            deletingNotificationId: "",
            notifications: state.notifications
                .where((e) => e.id != notificationId)
                .toList(),
          );
          return true;
        },
      );
    } catch (_) {
      state = state.copyWith(deletingNotificationId: "");
      return false;
    }
  }

  // Future<bool> deleteNotification(String notificationId) async {
  //   if (state.deletingNotificationId != "" || state.isDeletingAll) {
  //     return false;
  //   }

  //   state = state.copyWith(
  //     deletingNotificationId: notificationId,
  //     message: null,
  //   );

  //   final result = await _deleteNotificationUseCase(
  //     notificationId: notificationId,
  //   );

  //   final isSuccess = result.fold(
  //     (failure) {
  //       state = state.copyWith(
  //         deletingNotificationId: "",
  //         isDeletingAll: false,
  //         message: failure.message,
  //       );
  //       return false;
  //     },
  //     (_) {
  //       state = state.copyWith(
  //         deletingNotificationId: "",
  //         isDeletingAll: false,
  //         notifications: state.notifications
  //             .where((notification) => notification.id != notificationId)
  //             .toList(),
  //       );
  //       return true;
  //     },
  //   );

  //   return isSuccess;
  // }

  Future<bool> deleteAllNotifications() async {
    if (state.isDeletingAll || state.deletingNotificationId != "") {
      return false;
    }
    try {
      state = state.copyWith(isDeletingAll: true, message: null);

      final result = await _deleteAllNotificationsUseCase();

      return result.fold(
        (failure) {
          state = state.copyWith(
            isDeletingAll: false,
            message: failure.message,
            deletingNotificationId: "",
          );
          return false;
        },
        (_) {
          state = state.copyWith(
            isDeletingAll: false,
            notifications: const [],
            hasMore: false,
            page: 1,
            deletingNotificationId: "",
          );
          return true;
        },
      );
    } catch (_) {
      state = state.copyWith(deletingNotificationId: "", isDeletingAll: false);
      return false;
    }
  }

  void clearDeletingNotificationId() {
    state = state.copyWith(deletingNotificationId: "");
  }
}
