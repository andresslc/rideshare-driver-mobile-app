import 'dart:async';
import 'dart:convert';

import 'package:driver_app/core/constants/socket_events.dart';
import 'package:driver_app/core/utils/app_log.dart';
import 'package:driver_app/core/services/socket_service.dart';
import 'package:driver_app/features/carpool/data/models/carpool_model.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_entity.dart';

class CarpoolSocketListener {
  final SocketService socketService;
  bool _isStarted = false;

  /// Coalesces concurrent [start] calls (status stream + emits).
  Future<void>? _startFuture;

  final _incomingRequestController =
      StreamController<CarpoolIncomingRequestEntity>.broadcast();
  final _routeUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _carpoolResumeController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _passengerPickedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _rideCompletedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _bookingStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  void Function(dynamic)? _incomingRequestHandler;
  void Function(dynamic)? _routeUpdateHandler;
  void Function(dynamic)? _carpoolResumeHandler;
  void Function(dynamic)? _stopArrivedHandler;
  void Function(dynamic)? _passengerPickedHandler;
  void Function(dynamic)? _rideCompletedHandler;
  void Function(dynamic)? _bookingStatusHandler;
  void Function(dynamic)? _errorHandler;

  CarpoolSocketListener({required this.socketService});

  // Streams
  Stream<CarpoolIncomingRequestEntity> get incomingRequestStream =>
      _incomingRequestController.stream;
  Stream<Map<String, dynamic>> get routeUpdateStream =>
      _routeUpdateController.stream;
  Stream<Map<String, dynamic>> get carpoolResumeStream =>
      _carpoolResumeController.stream;
  Stream<Map<String, dynamic>> get passengerPickedStream =>
      _passengerPickedController.stream;
  Stream<Map<String, dynamic>> get rideCompletedStream =>
      _rideCompletedController.stream;
  Stream<Map<String, dynamic>> get bookingStatusStream =>
      _bookingStatusController.stream;
  Stream<String> get errorStream => _errorController.stream;

  Future<void> start() {
    return _startFuture ??= _performStart();
  }

  Future<void> _performStart() async {
    try {
      stop();
      if (!socketService.isConnected) return;

      _incomingRequestHandler ??= (data) {
        try {
          final payload = _toMap(data);
          log(
            'incoming_request payload: $payload',
            name: 'CarpoolSocketListener',
          );
          _incomingRequestController.add(
            CarpoolIncomingRequestModel.fromJson(payload),
          );
        } catch (_) {
          _errorController.add('Invalid carpool incoming request payload');
        }
      };

      _routeUpdateHandler ??= (data) {
        _addMapEvent(
          data: data,
          target: _routeUpdateController,
          fallbackError: 'Invalid carpool route update payload',
          eventName: SocketEvent.carpoolRouteUpdate,
        );
      };

      _carpoolResumeHandler ??= (data) {
        _addMapEvent(
          data: data,
          target: _carpoolResumeController,
          fallbackError: 'Invalid carpool resume payload',
          eventName: SocketEvent.carpoolResume,
        );
      };

      _stopArrivedHandler ??= (data) {
        _addMapEvent(
          data: data,
          target: _routeUpdateController,
          fallbackError: 'Invalid carpool stop arrived payload',
          eventName: SocketEvent.carpoolStopArrived,
        );
      };

      _passengerPickedHandler ??= (data) {
        _addMapEvent(
          data: data,
          target: _passengerPickedController,
          fallbackError: 'Invalid carpool passenger picked payload',
          eventName: SocketEvent.carpoolPassengerPickedUp,
        );
      };

      _rideCompletedHandler ??= (data) {
        _addMapEvent(
          data: data,
          target: _rideCompletedController,
          fallbackError: 'Invalid carpool ride completed payload',
          eventName: SocketEvent.carpoolRideCompleted,
        );
      };

      _bookingStatusHandler ??= (data) {
        _addMapEvent(
          data: data,
          target: _bookingStatusController,
          fallbackError: 'Invalid carpool booking status payload',
          eventName: SocketEvent.carpoolBookingStatus,
        );
      };

      _errorHandler ??= (data) {
        final normalized = _normalizeErrorMessage(data);
        if (normalized.isNotEmpty) {
          _errorController.add(normalized);
        }
      };

      await socketService.withConnectedSocket((socket) {
        socket.on(SocketEvent.carpoolIncomingRequest, _incomingRequestHandler!);
        socket.on(SocketEvent.carpoolRouteUpdate, _routeUpdateHandler!);
        socket.on(SocketEvent.carpoolResume, _carpoolResumeHandler!);
        socket.on(SocketEvent.carpoolStopArrived, _stopArrivedHandler!);
        socket.on(
          SocketEvent.carpoolPassengerPickedUp,
          _passengerPickedHandler!,
        );
        socket.on(SocketEvent.carpoolRideCompleted, _rideCompletedHandler!);
        socket.on(SocketEvent.carpoolBookingStatus, _bookingStatusHandler!);
        socket.on(SocketEvent.socketError, _errorHandler!);
      });

      _isStarted = true;
    } finally {
      _startFuture = null;
    }
  }

  void stop() {
    if (!_isStarted) {
      return;
    }
    if (_incomingRequestHandler != null) {
      socketService.off(
        SocketEvent.carpoolIncomingRequest,
        _incomingRequestHandler!,
      );
    }
    if (_routeUpdateHandler != null) {
      socketService.off(SocketEvent.carpoolRouteUpdate, _routeUpdateHandler!);
    }
    if (_carpoolResumeHandler != null) {
      socketService.off(SocketEvent.carpoolResume, _carpoolResumeHandler!);
    }
    if (_stopArrivedHandler != null) {
      socketService.off(SocketEvent.carpoolStopArrived, _stopArrivedHandler!);
    }
    if (_passengerPickedHandler != null) {
      socketService.off(
        SocketEvent.carpoolPassengerPickedUp,
        _passengerPickedHandler!,
      );
    }
    if (_rideCompletedHandler != null) {
      socketService.off(
        SocketEvent.carpoolRideCompleted,
        _rideCompletedHandler!,
      );
    }
    if (_bookingStatusHandler != null) {
      socketService.off(
        SocketEvent.carpoolBookingStatus,
        _bookingStatusHandler!,
      );
    }
    if (_errorHandler != null) {
      socketService.off(SocketEvent.socketError, _errorHandler!);
    }

    _incomingRequestHandler = null;
    _routeUpdateHandler = null;
    _carpoolResumeHandler = null;
    _stopArrivedHandler = null;
    _passengerPickedHandler = null;
    _rideCompletedHandler = null;
    _bookingStatusHandler = null;
    _errorHandler = null;
    _isStarted = false;
  }

  void dispose() {
    stop();
    _incomingRequestController.close();
    _routeUpdateController.close();
    _carpoolResumeController.close();
    _passengerPickedController.close();
    _rideCompletedController.close();
    _bookingStatusController.close();
    _errorController.close();
  }

  void _addMapEvent({
    required dynamic data,
    required StreamController<Map<String, dynamic>> target,
    required String fallbackError,
    required String eventName,
  }) {
    try {
      final payload = _toMap(data);
      log('$eventName payload: $payload', name: 'CarpoolSocketListener');
      target.add(payload);
    } catch (_) {
      _errorController.add(fallbackError);
    }
  }

  Map<String, dynamic> _toMap(dynamic payload) {
    if (payload is List) {
      if (payload.isEmpty) {
        return <String, dynamic>{};
      }
      return _toMap(payload.first);
    }

    if (payload is String) {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      throw const FormatException('Payload is not a JSON object');
    }

    if (payload is Map<String, dynamic>) {
      return payload;
    }

    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }

    throw FormatException('Something went wrong: ${payload.runtimeType}');
  }

  String _normalizeErrorMessage(dynamic payload) {
    if (payload == null) {
      return 'Socket error';
    }

    if (payload is String) {
      final value = payload.trim();
      return value.isEmpty ? 'Socket error' : value;
    }

    try {
      final map = _toMap(payload);
      for (final key in const <String>['message', 'error', 'reason']) {
        final value = (map[key] ?? '').toString().trim();
        if (value.isNotEmpty) {
          return value;
        }
      }
    } catch (_) {}

    final fallback = payload.toString().trim();
    return fallback.isEmpty ? 'Socket error' : fallback;
  }
}
