import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/params/carpool_params.dart';
import 'package:driver_app/core/services/socket_service.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_entity.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/socket_events.dart';
import 'carpool_socket_listener.dart';

abstract class CarpoolSocketDataSource {
  Stream<CarpoolIncomingRequestEntity> incomingRequestStream();
  Stream<Map<String, dynamic>> routeUpdateStream();
  Stream<Map<String, dynamic>> carpoolResumeStream();
  Stream<Map<String, dynamic>> passengerPickedStream();
  Stream<Map<String, dynamic>> rideCompletedStream();
  Stream<Map<String, dynamic>> bookingStatusStream();
  Stream<String> watchErrors();

  FutureEither<String> createRoute(CarpoolRideParams params);
  FutureEither<String> respondToRequest(BookingActionRequestParams params);
  FutureEither<String> pickPassenger(BookingOtpRequestParams params);
  FutureEither<String> startCarpool(String carpoolId);
  FutureEither<String> completeCarpool(String bookingId);
  FutureEither<String> arriveAtStop(CarpoolArriveRequestParams params);
  FutureEither<String> cancelRoute(String carpoolId);
  void dispose();
}

class CarpoolSocketDataSourceImpl implements CarpoolSocketDataSource {
  final SocketService socketService;
  final CarpoolSocketListener listener;
  StreamSubscription<SocketConnectionStatus>? _socketStatusSub;

  CarpoolSocketDataSourceImpl({
    required this.socketService,
    required this.listener,
  }) {
    _startListenerIfConnected();
    _socketStatusSub = socketService.statusStream.listen((status) {
      if (status == SocketConnectionStatus.connected) {
        _startListenerIfConnected();
      } else if (status == SocketConnectionStatus.disconnected) {
        listener.stop();
      }
    });
  }

  void _startListenerIfConnected() {
    if (socketService.isConnected) {
      unawaited(listener.start());
    }
  }

  Future<void> _ensureConnected() async {
    if (socketService.isConnected) {
      await listener.start();
      return;
    }

    log(
      'Socket not connected for carpool emit. Reconnecting before send.',
      name: 'CarpoolSocketDataSource',
    );
    await socketService.connect();
    await listener.start();
  }

  @override
  Stream<CarpoolIncomingRequestEntity> incomingRequestStream() =>
      listener.incomingRequestStream;

  @override
  Stream<Map<String, dynamic>> routeUpdateStream() =>
      listener.routeUpdateStream;

  @override
  Stream<Map<String, dynamic>> carpoolResumeStream() =>
      listener.carpoolResumeStream;

  @override
  Stream<Map<String, dynamic>> passengerPickedStream() =>
      listener.passengerPickedStream;

  @override
  Stream<Map<String, dynamic>> rideCompletedStream() =>
      listener.rideCompletedStream;

  @override
  Stream<Map<String, dynamic>> bookingStatusStream() =>
      listener.bookingStatusStream;

  @override
  Stream<String> watchErrors() => listener.errorStream;

  FutureEither<String> _emitWithAck(
    String eventName,
    Map<String, dynamic> payload,
    String timeoutMessage,
    String defaultErrorMsg,
  ) async {
    try {
      await _ensureConnected();
      log('Emitting "$eventName"', name: 'CarpoolSocketDataSource');
      log('Payload: $payload', name: 'CarpoolSocketDataSource');

      final res = await socketService
          .emitWithAckResponse(eventName, payload)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException(timeoutMessage),
          );

      log(
        'ACK for "$eventName" -> success: ${res.success}, message: ${res.message} ',
        name: 'CarpoolSocketDataSource',
      );

      if (!res.success) {
        return Left(
          NetworkFailure(
            message: res.message.isNotEmpty ? res.message : defaultErrorMsg,
          ),
        );
      }

      return Right(res.message);
    } on TimeoutException {
      log('Timeout for "$eventName"', name: 'CarpoolSocketDataSource');
      return Left(
        NetworkFailure(
          message:
              'The request is taking longer than expected. Please try again in a moment.',
        ),
      );
    } on SocketException {
      log('Socket exception for "$eventName"', name: 'CarpoolSocketDataSource');
      return Left(
        NetworkFailure(
          message:
              'You\'re offline or your internet connection is unstable. Please check your connection and try again.',
        ),
      );
    } catch (e) {
      log(
        'Unexpected error for "$eventName": $e',
        name: 'CarpoolSocketDataSource',
      );
      return Left(
        NetworkFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  FutureEither<String> createRoute(CarpoolRideParams params) async {
    try {
      await _ensureConnected();
      final payload = params.toJson();
      log(
        'Emitting "${SocketEvent.carpoolCreateRoute}"',
        name: 'CarpoolSocketDataSource',
      );
      log('Payload: $payload', name: 'CarpoolSocketDataSource');

      final res = await socketService
          .emitWithAckResponse(SocketEvent.carpoolCreateRoute, payload)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException(
              'The request is taking longer than expected. Please try again in a moment.',
            ),
          );

      log(
        'ACK for "${SocketEvent.carpoolCreateRoute}" -> success: ${res.success}, message: ${res.message} data: ${res.data}',
        name: 'CarpoolSocketDataSource',
      );

      if (!res.success) {
        return Left(
          NetworkFailure(
            message: res.message.isNotEmpty
                ? res.message
                : 'Unable to create carpool route',
          ),
        );
      }

      final responsePayload = res.raw.isNotEmpty
          ? res.raw
          : <String, dynamic>{
              'success': res.success,
              'message': res.message,
              'data': res.data,
            };
      return Right(jsonEncode(responsePayload));
    } on TimeoutException {
      log(
        'Timeout for "${SocketEvent.carpoolCreateRoute}"',
        name: 'CarpoolSocketDataSource',
      );
      return Left(
        NetworkFailure(
          message:
              'The request is taking longer than expected. Please try again in a moment.',
        ),
      );
    } on SocketException {
      log(
        'Socket exception for "${SocketEvent.carpoolCreateRoute}"',
        name: 'CarpoolSocketDataSource',
      );
      return Left(
        NetworkFailure(
          message:
              'You\'re offline or your internet connection is unstable. Please check your connection and try again.',
        ),
      );
    } catch (e) {
      log(
        'Unexpected error for "${SocketEvent.carpoolCreateRoute}": $e',
        name: 'CarpoolSocketDataSource',
      );
      return Left(
        NetworkFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  FutureEither<String> respondToRequest(
    BookingActionRequestParams params,
  ) async {
    return _emitWithAck(
      SocketEvent.carpoolRespond,
      params.toJson(),
      'Respond ACK timeout',
      'Unable to respond to request',
    );
  }

  @override
  FutureEither<String> pickPassenger(BookingOtpRequestParams params) async {
    return _emitWithAck(
      SocketEvent.carpoolPickPassenger,
      params.toJson(),
      'Pick passenger ACK timeout',
      'Unable to pick passenger',
    );
  }

  @override
  FutureEither<String> startCarpool(String carpoolId) async {
    return _emitWithAck(
      SocketEvent.carpoolStart,
      {'carpoolId': carpoolId},
      'Start carpool ACK timeout',
      'Unable to start carpool',
    );
  }

  @override
  FutureEither<String> completeCarpool(String bookingId) async {
    return _emitWithAck(
      SocketEvent.carpoolComplete,
      {'bookingId': bookingId},
      'Complete carpool ACK timeout',
      'Unable to complete carpool',
    );
  }

  @override
  FutureEither<String> arriveAtStop(CarpoolArriveRequestParams params) async {
    return _emitWithAck(
      SocketEvent.carpoolArrive,
      params.toJson(),
      'Arrive stop ACK timeout',
      'Unable to send arrive event',
    );
  }

  @override
  FutureEither<String> cancelRoute(String carpoolId) async {
    return _emitWithAck(
      SocketEvent.carpoolCancelRoute,
      {'carpoolId': carpoolId},
      'Cancel route ACK timeout',
      'Unable to cancel carpool route',
    );
  }

  @override
  void dispose() {
    _socketStatusSub?.cancel();
    listener.stop();
  }
}
