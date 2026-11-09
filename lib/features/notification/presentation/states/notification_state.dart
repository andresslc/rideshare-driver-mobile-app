import '../../domain/entities/notification_entity.dart';

enum NotificationStatus { initial, loading, success, error }

class NotificationState {
  final NotificationStatus status;
  final String? message;
  final bool isNotificationEnabled;
  final NotificationStatus getNotifStatus;
  final List<NotificationEntity> notifications;
  final String deletingNotificationId;
  final bool isDeletingAll;

  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.message,
    this.isNotificationEnabled = true,
    this.getNotifStatus = NotificationStatus.initial,
    this.notifications = const [],
    this.deletingNotificationId = "",
    this.isDeletingAll = false,
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    String? message,
    bool? isNotificationEnabled,
    NotificationStatus? getNotifStatus,
    List<NotificationEntity>? notifications,
    String? deletingNotificationId,
    bool? isDeletingAll,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationState(
      status: status ?? this.status,
      message: message,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      getNotifStatus: getNotifStatus ?? this.getNotifStatus,
      notifications: notifications ?? this.notifications,
      deletingNotificationId:
          deletingNotificationId ?? this.deletingNotificationId,
      isDeletingAll: isDeletingAll ?? this.isDeletingAll,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
