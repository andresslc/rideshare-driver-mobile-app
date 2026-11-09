import 'dart:convert';
import 'dart:async';

import 'package:driver_app/core/constants/socket_events.dart';
import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/navigation/routes.dart';
import 'package:driver_app/core/utils/app_log.dart';
import 'package:driver_app/features/ride_room/data/datasources/ride_socket_listener.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationRouteService {
  /// Push sent to the code owner when a referred rider completes a ride.
  static const String driverReferralBonusType = 'DRIVER_REFERRAL_BONUS';

  static const Set<String> _rideResumeNotificationTypes = <String>{
    'RIDE_ACCEPTED',
    'RIDE_ACCEPT',
    'ACCEPTED',
    'PASSENGER_ACCEPTED',
    'RIDE_STARTED',
    'TRIP_STARTED',
    'ARRIVED',
    'DRIVER_ARRIVED',
  };

  void handleNotificationTap(BuildContext context, Map<String, dynamic> meta) {
    final String type = notificationTypeOf(meta);

    // Only sync state (like requesting ride resume) for notification types that require it.
    if (_rideResumeNotificationTypes.contains(type)) {
      syncRideStateFromNotification(meta);
    }

    final router = GoRouter.of(context);
    final String currentLocation = router.location();

    void navigateIfNeeded(String targetLocation, VoidCallback navigate) {
      debugPrint('Current Location: $currentLocation');
      debugPrint('Target Location: $targetLocation');
      if (currentLocation == targetLocation) return;
      navigate();
    }

    switch (type) {
      // Driver receives a review from passenger -> Open ReviewsScreen
      case 'REVIEW_RECEIVED':
      case 'NEW_REVIEW':
      case 'PENDING_REVIEW':
      case 'PASSENGER_REVIEW':
        navigateIfNeeded(
          router.namedLocation(Routes.reviews.name),
          () => context.pushNamed(Routes.reviews.name),
        );
        break;

      // Review submitted / ride history
      case 'REVIEW_SUBMITTED':
      case 'REVIEW_GIVEN':
      case 'RIDE_REVIEWED':
      case 'RIDE_REVIEW':
      case 'GIVE_REVIEW':
      case 'SUBMIT_REVIEW':
      case 'REVIEW':
        navigateIfNeeded(
          router.namedLocation(Routes.ridehistory.name),
          () => context.pushNamed(
            Routes.ridehistory.name,
            extra: <String, String>{'status': 'completed'},
          ),
        );
        break;

      case 'NEW_MESSAGE':
      case 'CHAT':
      case 'CHAT_MESSAGE':
      case 'MESSAGE':
      case 'NEW_CHAT_MESSAGE':
        final Map<String, dynamic> dataMap =
            (meta['data'] is Map<String, dynamic>)
            ? meta['data'] as Map<String, dynamic>
            : meta;
        final String rideId = (dataMap['rideId'] ?? meta['rideId'] ?? '')
            .toString();
        final String riderId = (dataMap['riderId'] ?? meta['riderId'] ?? '')
            .toString();
        final String riderName =
            (dataMap['riderName'] ?? meta['riderName'] ?? 'Passenger')
                .toString();
        final String riderProfileImage =
            (dataMap['riderProfileImage'] ?? meta['riderProfileImage'] ?? '')
                .toString();
        final String isCarpool =
            (dataMap['isCarpool'] ?? meta['isCarpool'] ?? 'false').toString();

        if (rideId.isNotEmpty) {
          final Map<String, String> queryParams = {
            'rideId': rideId,
            'riderId': riderId,
            'riderName': riderName.isNotEmpty ? riderName : 'Passenger',
            if (riderProfileImage.isNotEmpty)
              'riderProfileImage': riderProfileImage,
            'isCarpool': isCarpool,
          };

          final String targetPath = router.namedLocation(
            Routes.chat.name,
            queryParameters: queryParams,
          );

          navigateIfNeeded(
            targetPath,
            () => context.pushNamed(
              Routes.chat.name,
              queryParameters: queryParams,
            ),
          );
        }
        break;

      case 'RIDE_ACCEPTED':
      case 'RIDE_ACCEPT':
      case 'ACCEPTED':
      case 'PASSENGER_ACCEPTED':
      case 'RIDE_STARTED':
      case 'TRIP_STARTED':
      case 'ARRIVED':
      case 'DRIVER_ARRIVED':
        navigateIfNeeded(
          router.namedLocation(Routes.rideRoom.name),
          () => context.pushNamed(Routes.rideRoom.name),
        );
        break;

      case 'PAYMENT':
      case 'ADMIN_REWARD':
      case 'REWARD':
      case 'WALLET':
      case 'TOPUP':
      case 'PAYMENT_RECEIVED':
      case 'WITHDRAWAL':
        navigateIfNeeded(router.namedLocation(Routes.wallet.name), () {
          log(
            "Navigating to wallet from notification",
            name: "NotificationRouteService",
          );
          context.pushNamed(Routes.wallet.name);
        });
        break;

      // A rider who used this driver's code finished their first ride.
      case driverReferralBonusType:
        navigateIfNeeded(
          router.namedLocation(Routes.driverReferral.name),
          () => context.pushNamed(Routes.driverReferral.name),
        );
        break;

      case 'NOTIFICATION':
      case 'NOTIFICATIONS':
      case 'SYSTEM_NOTIFICATION':
        navigateIfNeeded(
          router.namedLocation(Routes.notificationsScreen.name),
          () => context.pushNamed(Routes.notificationsScreen.name),
        );
        break;

      case 'RIDE_CANCELLED':
      case 'RIDE_CANCEL':
      case 'CANCELLED':
      case 'RIDE_CANCELLED_BY_PASSENGER':
        navigateIfNeeded(
          router.namedLocation(Routes.ridehistory.name),
          () => context.pushNamed(
            Routes.ridehistory.name,
            extra: <String, String>{'status': 'cancelled'},
          ),
        );
        break;

      case 'NEW_RIDE_REQUEST':
      case 'RIDE_INCOMING':
      case 'RIDE_REQUEST':
      case 'INCOMING_RIDE':
        // Ring dispatch puts the ride id in the push metadata, so the tap can
        // land on that request's card instead of on the queue in general.
        final String newRideId = _rideIdFromMeta(meta);
        final Map<String, String> queryParameters = newRideId.isEmpty
            ? const <String, String>{}
            : <String, String>{'rideId': newRideId};

        navigateIfNeeded(
          router.namedLocation(
            Routes.rideRequest.name,
            queryParameters: queryParameters,
          ),
          () => context.pushNamed(
            Routes.rideRequest.name,
            queryParameters: queryParameters,
          ),
        );
        break;

      case 'RIDE_COMPLETED':
      case 'RIDE_COMPLETE':
      case 'COMPLETED':
        navigateIfNeeded(
          router.namedLocation(Routes.ridehistory.name),
          () => context.pushNamed(
            Routes.ridehistory.name,
            extra: <String, String>{'status': 'completed'},
          ),
        );
        break;

      case 'CARPOOL_CANCELLED':
      case 'CARPOOL_ENDED':
      case 'CARPOOL_CANCEL':
        navigateIfNeeded(
          router.namedLocation(Routes.ridehistory.name),
          () => context.pushNamed(
            Routes.ridehistory.name,
            extra: <String, String>{'status': 'carpool'},
          ),
        );
        break;

      default:
        log(
          'No explicit notification route mapping for type=$type payload=$meta',
          name: 'FCM',
        );
        break;
    }
  }

  /// Ride id on a new-request push. The backend sends it as `id` inside the
  /// notification metadata; the other spellings cover older payloads and the
  /// `{ data: {...} }` envelope FCM sometimes wraps things in.
  String _rideIdFromMeta(Map<String, dynamic> meta) {
    Map<String, dynamic>? asMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      if (value is String) {
        final String text = value.trim();
        if (!text.startsWith('{') || !text.endsWith('}')) return null;
        try {
          final dynamic decoded = jsonDecode(text);
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        } catch (_) {}
      }
      return null;
    }

    for (final Map<String, dynamic>? source in <Map<String, dynamic>?>[
      meta,
      asMap(meta['data']),
      asMap(meta['payload']),
      asMap(meta['metadata']),
    ]) {
      if (source == null) continue;
      for (final String key in <String>['id', 'rideId', 'ride_id']) {
        final String value = source[key]?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
    }

    return '';
  }

  void syncRideStateFromNotification(Map<String, dynamic> meta) {
    final String type = notificationTypeOf(meta);

    if (type == 'RIDE_CANCELLED' ||
        type == 'RIDE_CANCEL' ||
        type == 'CANCELLED' ||
        type == 'RIDE_CANCELLED_BY_PASSENGER') {
      log(
        'Applying ride cancellation from notification payload=$meta',
        name: 'FCM',
      );
      locator<RideSocketListener>().publishRideCancelled();
      return;
    }

    if (!_rideResumeNotificationTypes.contains(type)) {
      return;
    }

    log(
      'Syncing ride state from notification type=$type payload=$meta',
      name: 'FCM',
    );
    unawaited(_requestRideResume(type: type));
  }

  String notificationTypeOf(Map<String, dynamic> meta) {
    for (final String key in <String>[
      'type',
      'notificationType',
      'notification_type',
      'eventType',
      'event_type',
      'screen',
      'screen_type',
      'action',
      'click_action',
      'target',
    ]) {
      final dynamic val = meta[key];
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString().trim().toUpperCase();
      }
    }

    String parseChild(dynamic child) {
      if (child is Map<String, dynamic>) {
        return notificationTypeOf(child);
      }
      if (child is String && child.trim().isNotEmpty) {
        final str = child.trim();
        if (str.startsWith('{') && str.endsWith('}')) {
          try {
            final decoded = jsonDecode(str);
            if (decoded is Map<String, dynamic>) {
              return notificationTypeOf(decoded);
            }
          } catch (_) {}
        }
      }
      return '';
    }

    final dataResult = parseChild(meta['data']);
    if (dataResult.isNotEmpty) return dataResult;

    final payloadResult = parseChild(meta['payload']);
    if (payloadResult.isNotEmpty) return payloadResult;

    final bodyResult = parseChild(meta['body']);
    if (bodyResult.isNotEmpty) return bodyResult;

    return '';
  }

  Future<void> _requestRideResume({required String type}) async {
    log(
      'Requesting ${SocketEvent.rideResume} after notification type=$type',
      name: 'FCM',
    );
    await locator<RideSocketListener>().requestResumeFromServer(force: true);
  }
}

/// Extension same as working file
extension GoRouterExtension on GoRouter {
  String location() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;

    return matchList.uri.toString();
  }
}
