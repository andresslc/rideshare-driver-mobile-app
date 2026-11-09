import 'dart:async';
import 'dart:io';

import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/params/driver_location_params.dart';
import 'package:driver_app/core/services/socket_service.dart';
import 'package:driver_app/features/ride_room/data/models/ride_response.model.dart';
import 'package:driver_app/features/ride_room/data/models/ride_models.dart';
import 'package:driver_app/features/ride_room/data/models/ride_taken_model.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/constants/socket_events.dart';
import '../models/chat_model.dart';
import '../../domain/entities/message_delivery_status.dart';
import 'ride_socket_listener.dart';

abstract class RideSocketDataSource {
  /// When [forceReconnect] is true, tears down listeners and opens a new socket
  /// (used e.g. when opening chat so `chat:receive` subscriptions are fresh).
  Future<void> connect({bool forceReconnect = false});
  Future<void> disconnect();

  Stream<ChatMessageModel> chatStream();
  Stream<ChatStatusUpdate> chatStatusUpdates();
  Stream<RideModel> incomingRidesUpdate();
  Stream<RideTakenModel> rideTakenUpdate();
  Stream<RideResponseModel> rideResumeUpdate();
  Stream<RideResponseModel> rideStatusUpdate();
  Stream<String> driverOnlineUpdateStream();
  // Stream<DriverLocationModel> driverLocationUpdateStream();
  Stream<String> shiftExceededStream();
  Stream<String> watchErrors();

  /// Marks inbound messages as read while the viewer is on the chat screen.
  /// Backend expects: `chat:read` with `{ conversationId }`.
  Future<void> markConversationRead(String conversationId);

  FutureEither<String> toggleDriverOnline();
  FutureEither<String> toggleDriverOffline();
  FutureEither<String> driverLocationUpdate(DriverLocationParams location);

  /// Ring dispatch: claims the ride with `ride:request:accept`.
  /// Losing the race is the normal outcome and comes back as a
  /// [SocketAckFailure] whose `isRideTaken` is true — not a hard error.
  FutureEither<String> acceptRideRequest(String rideId);
  FutureEither<String> driverArrive(
    String rideId, {
    required double lat,
    required double lng,
  });
  FutureEither<String> rideStart(String rideId, {int? otp});
  FutureEither<String> rideCancel(
    String rideId, {
    required String cancellationReason,
  });
  FutureEither<String> rideComplete(String rideId);
}

class RideSocketDataSourceImpl implements RideSocketDataSource {
  final SocketService socketService;
  final RideSocketListener listener;
  RideSocketDataSourceImpl({
    required this.socketService,
    required this.listener,
  });

  @override
  Future<void> connect({bool forceReconnect = false}) async {
    if (forceReconnect) {
      listener.stop();
      await socketService.connect(forceReconnect: true);
      await listener.start();
      return;
    }

    if (!socketService.isConnected) {
      await socketService.connect();
    }

    // Always re-attach native `socket.on` handlers. After a network drop the
    // client may get a new underlying socket; skipping this left `chat:receive`
    // unbound while the app still looked "connected".
    await listener.start();
  }

  @override
  Future<void> disconnect() async {
    listener.stop();
    socketService.disconnect();
  }

  // ================================
  // Properly matching abstract names
  // ================================

  // Stream<ChatMessageModel> chatStream() => listener.chatStream;

  @override
  Stream<RideModel> incomingRidesUpdate() => listener.incomingRidesStream;

  @override
  Stream<RideTakenModel> rideTakenUpdate() => listener.rideTakenStream;

  @override
  Stream<RideResponseModel> rideResumeUpdate() => listener.rideResumeStream;

  @override
  Stream<RideResponseModel> rideStatusUpdate() =>
      listener.rideStatusUpdateStream;
  // ================================
  // Properly matching abstract names
  // ================================
  @override
  Stream<ChatMessageModel> chatStream() => listener.chatStream;

  @override
  Stream<ChatStatusUpdate> chatStatusUpdates() =>
      listener.chatStatusUpdateStream;

  @override
  Future<void> markConversationRead(String conversationId) async {
    final String id = conversationId.trim();
    if (id.isEmpty) return;
    if (!socketService.isConnected) return;
    try {
      await socketService.emitWithAck(SocketEvent.chatRead, <String, dynamic>{
        'conversationId': id,
      });
      log(
        'emitted ${SocketEvent.chatRead} conversationId=$id',
        name: 'RideSocketDat  aSource',
      );
    } catch (e, st) {
      log(
        'failed ${SocketEvent.chatRead}: $e\n$st',
        name: 'RideSocketDataSource',
      );
    }
  }

  @override
  Stream<String> driverOnlineUpdateStream() => listener.driverOnlineStream;

  // @override
  // Stream<DriverLocationModel> driverLocationUpdateStream() => listener.driverLocationStream;

  @override
  Stream<String> shiftExceededStream() => listener.shiftExceededStream;

  @override
  Stream<String> watchErrors() => listener.errorStream;

  @override
  FutureEither<String> toggleDriverOnline() async {
    const eventName = SocketEvent.driverOnline;

    try {
      log('[RideSocketDataSource] Emitting $eventName');

      final res = await socketService
          .emitWithAckResponse(eventName, {})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException(
              'The request is taking longer than expected. Please try again in a moment.',
            ),
          );

      log(
        '[RideSocketDataSource] ACK -> success: ${res.success}, message: ${res.message}',
      );

      if (!res.success) {
        return Left(
          NetworkFailure(
            message: res.message.isNotEmpty
                ? res.message
                : 'Unable to update driver status',
          ),
        );
      }

      return Right(res.message);
    } on TimeoutException {
      return Left(
        NetworkFailure(
          message:
              'The request is taking longer than expected. Please try again in a moment.',
        ),
      );
    } on SocketException {
      return Left(
        NetworkFailure(
          message:
              'You\'re offline or your internet connection is unstable. Please check your connection and try again.',
        ),
      );
    } catch (e) {
      return Left(
        NetworkFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  FutureEither<String> toggleDriverOffline() async {
    const eventName = SocketEvent.driverOffline;

    try {
      log('[RideSocketDataSource] Emitting $eventName');

      final res = await socketService
          .emitWithAckResponse(eventName, {})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException(
              'The request is taking longer than expected. Please try again in a moment.',
            ),
          );

      log(
        '[RideSocketDataSource] ACK -> success: ${res.success}, message: ${res.message}',
      );

      if (!res.success) {
        return Left(
          NetworkFailure(
            message: res.message.isNotEmpty
                ? res.message
                : 'Unable to update driver status',
          ),
        );
      }

      return Right(res.message);
    } on TimeoutException {
      return Left(
        NetworkFailure(
          message:
              'The request is taking longer than expected. Please try again in a moment.',
        ),
      );
    } on SocketException {
      return Left(
        NetworkFailure(
          message:
              'You\'re offline or your internet connection is unstable. Please check your connection and try again.',
        ),
      );
    } catch (e) {
      return Left(
        NetworkFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  FutureEither<String> driverLocationUpdate(
    DriverLocationParams location,
  ) async {
    const eventName = SocketEvent.driverLocationUpdate;

    try {
      log('[RideSocketDataSource] Emitting $eventName');

      socketService.emit(eventName, location.toJson());
      log("1");

      return const Right('Location updated');
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  /// Backend code behind a rejected ack. It travels as `code` or `reason`
  /// depending on the branch; the `message` itself is already translated.
  String _ackCode(SocketAckResponse res) {
    for (final String key in <String>['code', 'reason', 'errorCode']) {
      final String value = res.raw[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  @override
  FutureEither<String> acceptRideRequest(String rideId) async {
    const eventName = SocketEvent.rideAccept;

    try {
      log('[RideSocketDataSource] Emitting $eventName with rideId: $rideId');

      final res = await socketService
          .emitWithAckResponse(eventName, {'rideId': rideId})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException(
              'The request is taking longer than expected. Please try again in a moment.',
            ),
          );

      log(
        '[RideSocketDataSource] ACK -> success: ${res.success}, message: ${res.message}',
      );

      if (!res.success) {
        return Left(
          SocketAckFailure(
            message: res.message.isNotEmpty
                ? res.message
                : 'Unable to accept ride request',
            code: _ackCode(res),
          ),
        );
      }

      return Right(res.message);
    } on TimeoutException {
      return Left(
        NetworkFailure(
          message:
              'The request is taking longer than expected. Please try again in a moment.',
        ),
      );
    } on SocketException {
      return Left(
        NetworkFailure(
          message:
              'You\'re offline or your internet connection is unstable. Please check your connection and try again.',
        ),
      );
    } catch (e) {
      return Left(
        NetworkFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  FutureEither<String> driverArrive(
    String rideId, {
    required double lat,
    required double lng,
  }) async {
    const eventName = SocketEvent.driverArrive;

    try {
      log(
        '[RideSocketDataSource] Emitting $eventName with rideId: $rideId, lat: $lat, lng: $lng',
      );

      final res = await socketService
          .emitWithAckResponse(eventName, {
            'rideId': rideId,
            // 'lat': lat,
            // 'lng': lng,
            "location": {
              "type": "Point",
              "coordinates": [lng, lat],
            },
          })
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException(
              'The request is taking longer than expected. Please try again in a moment.',
            ),
          );

      log(
        '[RideSocketDataSource] ACK -> success: ${res.success}, message: ${res.message}',
      );

      if (!res.success) {
        return Left(
          NetworkFailure(
            message: res.message.isNotEmpty
                ? res.message
                : 'Unable to mark driver arrival',
          ),
        );
      }

      return Right(res.message);
    } on TimeoutException {
      return Left(
        NetworkFailure(
          message:
              'The request is taking longer than expected. Please try again in a moment.',
        ),
      );
    } on SocketException {
      return Left(
        NetworkFailure(
          message:
              'You\'re offline or your internet connection is unstable. Please check your connection and try again.',
        ),
      );
    } catch (e) {
      return Left(
        NetworkFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  FutureEither<String> rideStart(String rideId, {int? otp}) async {
    try {
      final Map<String, dynamic> payload = <String, dynamic>{'rideId': rideId};
      if (otp != null) {
        payload['otp'] = otp;
      }

      final SocketAckResponse res = await socketService.emitWithAckResponse(
        SocketEvent.rideStart,
        payload,
      );

      if (!res.success) {
        return Left(
          NetworkFailure(
            message: res.message.isEmpty
                ? 'Socket ack returned unsuccessful response.'
                : res.message,
          ),
        );
      }

      return Right(res.message);
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<String> rideComplete(String rideId) async {
    try {
      final SocketAckResponse res = await socketService.emitWithAckResponse(
        SocketEvent.rideComplete,
        {'rideId': rideId},
      );

      if (!res.success) {
        return Left(
          NetworkFailure(
            message: res.message.isEmpty
                ? 'Socket ack returned unsuccessful response.'
                : res.message,
          ),
        );
      }

      return Right(res.message);
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<String> rideCancel(
    String rideId, {
    required String cancellationReason,
  }) async {
    try {
      final SocketAckResponse res = await socketService.emitWithAckResponse(
        SocketEvent.rideCancel,
        {'rideId': rideId, 'cancellationReason': cancellationReason},
      );

      if (!res.success) {
        return Left(
          NetworkFailure(
            message: res.message.isEmpty
                ? 'Socket ack returned unsuccessful response.'
                : res.message,
          ),
        );
      }

      return Right(res.message);
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }
}
