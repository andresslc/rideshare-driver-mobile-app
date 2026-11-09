import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:driver_app/core/constants/socket_events.dart';
import 'package:driver_app/core/services/socket_service.dart';
import 'package:driver_app/features/ride_room/data/models/chat_model.dart';
import 'package:driver_app/features/ride_room/data/models/driver_location_model.dart';
import 'package:driver_app/features/ride_room/data/models/ride_response.model.dart';
import 'package:driver_app/features/ride_room/data/models/ride_models.dart';
import 'package:driver_app/features/ride_room/data/models/ride_taken_model.dart';
import 'package:driver_app/features/ride_room/domain/entities/message_delivery_status.dart';

class RideSocketListener {
  final SocketService socketService;

  RideSocketListener({required this.socketService});

  // ================================
  // Stream Controllers (broadcast)
  // ================================
  final _incomingRidesController = StreamController<RideModel>.broadcast();
  final _rideTakenController = StreamController<RideTakenModel>.broadcast();
  final _rideResumeController = StreamController<RideResponseModel>.broadcast();
  final _rideStatusUpdateController =
      StreamController<RideResponseModel>.broadcast();
  RideResponseModel? _lastRideResume;
  String? _lastPublishedResumeKey;
  final _driverOnlineController = StreamController<String>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _chatController = StreamController<ChatMessageModel>.broadcast();
  final _chatStatusUpdateController =
      StreamController<ChatStatusUpdate>.broadcast();
  final _shiftExceededController = StreamController<String>.broadcast();
  Stream<ChatMessageModel> get chatStream => _chatController.stream;
  Stream<ChatStatusUpdate> get chatStatusUpdateStream =>
      _chatStatusUpdateController.stream;

  // ================================
  // Public Streams
  // ================================
  Stream<RideModel> get incomingRidesStream => _incomingRidesController.stream;
  Stream<RideTakenModel> get rideTakenStream => _rideTakenController.stream;
  Stream<RideResponseModel> get rideResumeStream async* {
    final RideResponseModel? cached = _lastRideResume;
    if (cached != null) {
      yield cached;
    }
    yield* _rideResumeController.stream;
  }

  Stream<RideResponseModel> get rideStatusUpdateStream =>
      _rideStatusUpdateController.stream;
  RideResponseModel? get lastRideResume => _lastRideResume;
  Stream<String> get driverOnlineStream => _driverOnlineController.stream;
  Stream<String> get shiftExceededStream => _shiftExceededController.stream;
  Stream<String> get errorStream => _errorController.stream;
  StreamSubscription<String>? _serviceErrorSubscription;

  /// -------------------------------
  /// Driver Location Stream & Listener
  /// -------------------------------
  final _driverLocationController =
      StreamController<DriverLocationModel>.broadcast();

  Stream<DriverLocationModel> get driverLocationStream =>
      _driverLocationController.stream;

  void Function(dynamic)? _driverLocationHandler;

  // ================================
  // Handlers
  // ================================
  void Function(dynamic)? _incomingRidesHandler;
  void Function(dynamic)? _rideTakenHandler;
  void Function(dynamic)? _rideResumeHandler;
  void Function(dynamic)? _rideStatusUpdateHandler;
  void Function(dynamic)? _driverOnlineHandler;
  void Function(dynamic)? _errorHandler;
  void Function(dynamic)? _chatHandler;
  void Function(dynamic)? _chatStatusUpdateHandler;
  void Function(dynamic)? _shiftExceededHandler;

  /// Coalesces concurrent [start] calls (e.g. chat reconnect + status callbacks).
  Future<void>? _startFuture;

  void publishRideStatusUpdateFromPayload(dynamic payload) {
    try {
      log('ride status update publish payload: $payload', name: 'ride socket');
      final Map<String, dynamic> data = _toMap(payload);
      final RideResponseModel model = RideResponseModel.fromJson(data);
      _lastRideResume = model;
      _rideStatusUpdateController.add(model);
    } catch (e, st) {
      log(
        '[RideSocketListener] rideStatusUpdate publish error: $e\n$st',
        name: 'ride socket',
      );
      _rideStatusUpdateController.addError(
        'Invalid ride status update payload',
      );
    }
  }

  void publishRideCancelled({String? message}) {
    publishRideStatusUpdateFromPayload(<String, dynamic>{
      'type': 'cancelled',
      'message': message ?? 'Ride has been cancelled',
    });
  }

  void publishRideResumeFromPayload(dynamic payload, {bool force = false}) {
    try {
      log('ride resume payload: $payload', name: 'ride socket');
      final Map<String, dynamic> data = _toMap(payload);
      final RideResponseModel model = RideResponseModel.fromJson(data);
      _publishRideResumeModel(model, force: force);
    } catch (e, st) {
      log(
        '[RideSocketListener] rideResume publish error: $e\n$st',
        name: 'ride socket',
      );
      _rideResumeController.addError('Invalid ride resume payload');
    }
  }

  /// Asks the server for the driver's current ride context (active ride, offers, etc.).
  Future<void> requestResumeFromServer({bool force = false}) async {
    try {
      final SocketAckResponse response = await socketService
          .emitWithAckResponse(
            SocketEvent.rideResume,
            {},
            timeout: const Duration(seconds: 5),
          );

      if (response.data != null) {
        publishRideResumeFromPayload(response.data, force: force);
      }

      log(
        'Requested ${SocketEvent.rideResume} success=${response.success}',
        name: 'ride socket',
      );
    } on TimeoutException {
      socketService.emit(SocketEvent.rideResume);
      log(
        'Ack timed out for ${SocketEvent.rideResume}. Fallback emit sent.',
        name: 'ride socket',
      );
    } catch (e, st) {
      log(
        'Failed to request ${SocketEvent.rideResume}: $e\n$st',
        name: 'ride socket',
      );
    }
  }

  void _publishRideResumeModel(RideResponseModel model, {bool force = false}) {
    final String publishKey = _resumePublishKey(model);
    if (!force && publishKey == _lastPublishedResumeKey) {
      log(
        'Skipping duplicate ride resume publish key=$publishKey',
        name: 'ride socket',
      );
      return;
    }

    _lastPublishedResumeKey = publishKey;
    _lastRideResume = model;
    _rideResumeController.add(model);
    log(
      'Published ride resume type=${model.type} rideId=${model.rideId}',
      name: 'ride socket',
    );
  }

  String _resumePublishKey(RideResponseModel model) {
    final String rideId = (model.rideId ?? model.ride?.id ?? '')
        .toString()
        .trim();
    final String type = (model.type ?? '').trim().toLowerCase();
    return '$rideId::$type';
  }

  // ================================
  // Start Listening
  // ================================
  Future<void> start() {
    return _startFuture ??= _performStart();
  }

  Future<void> _performStart() async {
    try {
      stop(); // remove any previous handlers

      _chatHandler ??= (dynamic payload) {
        try {
          log('chat receive payload: $payload', name: 'ride socket');
          if (payload == null) return;
          // Socket.IO often sends JSON as a String, or [map]; _toMap handles both.
          final Map<String, dynamic> root = _toMap(payload);
          final dynamic nested = root['data'];
          final Map<String, dynamic> map;
          if (nested is Map) {
            // Booking / context ids often sit on the outer envelope while body is in `data`.
            map = _mergeChatRootFieldsIntoMessageMap(
              root,
              Map<String, dynamic>.from(Map<dynamic, dynamic>.from(nested)),
            );
          } else if (root.containsKey('sender') ||
              root.containsKey('conversationId') ||
              root.containsKey('conversation_id') ||
              root.containsKey('contextId') ||
              root.containsKey('context_id')) {
            map = root;
          } else {
            return;
          }

          _chatController.add(ChatMessageModel.fromJson(map));
        } catch (e, st) {
          log('❌ Error processing chat:receive: $e\n$st', name: 'ride socket');
          _chatController.addError('Invalid chat:receive payload');
        }
      };

      _chatStatusUpdateHandler ??= (dynamic payload) {
        try {
          log('chat status update payload: $payload', name: 'ride socket');
          if (payload == null) return;
          final Map<String, dynamic> root = _toMap(payload);
          final dynamic nested = root['data'];
          final Map<String, dynamic> body = nested is Map
              ? Map<String, dynamic>.from(Map<dynamic, dynamic>.from(nested))
              : root;
          final ChatStatusUpdate? update = ChatStatusUpdate.fromJson(body);
          if (update == null) return;
          _chatStatusUpdateController.add(update);
        } catch (e, st) {
          log(
            '❌ Error processing chat:status_updated: $e\n$st',
            name: 'ride socket',
          );
          _chatStatusUpdateController.addError(
            'Invalid chat:status_updated payload',
          );
        }
      };

      _incomingRidesHandler ??= (payload) {
        try {
          log('[RideSocketListener] ride:incoming payload: $payload');
          final data = _toMap(payload);
          final Map<String, dynamic> rideData = _extractRidePayload(data);
          final model = RideModel.fromJson(rideData);
          _incomingRidesController.add(model);
        } catch (e, st) {
          log('[RideSocketListener] ride:incoming parse error: $e\n$st');
          _incomingRidesController.addError('Invalid ride incoming payload');
        }
      };

      // Ring dispatch: someone else won this ride. The event brings the fresh
      // queue with it, so no extra HTTP round trip is needed.
      _rideTakenHandler ??= (payload) {
        try {
          log('[RideSocketListener] ride:request:taken payload: $payload');
          final RideTakenModel model = RideTakenModel.fromJson(_toMap(payload));
          if (model.rideId.isEmpty) return;
          _rideTakenController.add(model);
        } catch (e, st) {
          log('[RideSocketListener] ride:request:taken parse error: $e\n$st');
        }
      };

      _rideResumeHandler ??= (payload) {
        publishRideResumeFromPayload(payload);
      };

      _rideStatusUpdateHandler ??= (payload) {
        log('ride:status:update payload: $payload', name: 'ride socket');
        publishRideStatusUpdateFromPayload(payload);
      };

      _driverOnlineHandler ??= (payload) {
        try {
          log('[RideSocketListener] driver:online payload: $payload');
          final message = payload?.toString() ?? 'Driver is online';
          _driverOnlineController.add(message);
        } catch (e, st) {
          log('[RideSocketListener] driver:online error: $e\n$st');
          _driverOnlineController.addError('Error processing driver:online');
        }
      };

      // ================================
      // Driver Location
      // ================================
      _driverLocationHandler ??= (payload) {
        try {
          log('[RideSocketListener] driver:location:update payload: $payload');
          final data = _toMap(payload);
          final model = DriverLocationModel.fromMap(
            data,
          ); // create a model for driver location
          _driverLocationController.add(model);
        } catch (e, st) {
          log('[RideSocketListener] driver:location parse error: $e\n$st');
          _driverLocationController.addError('Invalid driver location payload');
        }
      };

      _errorHandler ??= (payload) {
        // final message = payload?.toString() ?? 'Socket error';
        final String message = _normalizeErrorMessage(payload);
        _errorController.add(message);
      };

      _shiftExceededHandler ??= (payload) {
        try {
          log('[RideSocketListener] SHIFT_EXCEEDED: $payload');
          final message = payload?.toString() ?? 'Shift exceeded';
          _shiftExceededController.add(message);
        } catch (e) {
          _shiftExceededController.add('Shift exceeded');
        }
      };

      // ================================
      // Attach to correct socket events (single batch — avoids duplicate handlers)
      // ================================
      await socketService.withConnectedSocket((socket) {
        socket.on(SocketEvent.chatReceive, _chatHandler!);
        socket.on(SocketEvent.chatStatusUpdated, _chatStatusUpdateHandler!);
        socket.on(SocketEvent.driverOnline, _driverOnlineHandler!);
        socket.on(SocketEvent.driverLocationUpdate, _driverLocationHandler!);
        socket.on(SocketEvent.rideIncoming, _incomingRidesHandler!);
        socket.on(SocketEvent.rideRequestTaken, _rideTakenHandler!);
        socket.on(SocketEvent.rideResume, _rideResumeHandler!);
        socket.on(SocketEvent.rideStatusUpdate, _rideStatusUpdateHandler!);
        socket.on(SocketEvent.socketError, _errorHandler!);
        socket.on(SocketEvent.shiftExceeded, _shiftExceededHandler!);
      });

      log(
        '[RideSocketListener] All listeners successfully attached to socket instance',
      );
    } finally {
      _startFuture = null;
    }
  }

  // ================================
  // Stop Listening
  // ================================
  void stop() {
    if (_chatHandler != null) {
      socketService.off(SocketEvent.chatReceive, _chatHandler!);
      // _chatHandler = null;
    }
    if (_chatStatusUpdateHandler != null) {
      socketService.off(
        SocketEvent.chatStatusUpdated,
        _chatStatusUpdateHandler!,
      );
    }

    if (_incomingRidesHandler != null) {
      socketService.off(SocketEvent.rideIncoming, _incomingRidesHandler!);
    }
    if (_rideTakenHandler != null) {
      socketService.off(SocketEvent.rideRequestTaken, _rideTakenHandler!);
    }
    if (_rideResumeHandler != null) {
      socketService.off(SocketEvent.rideResume, _rideResumeHandler!);
    }
    if (_rideStatusUpdateHandler != null) {
      socketService.off(
        SocketEvent.rideStatusUpdate,
        _rideStatusUpdateHandler!,
      );
    }
    if (_driverOnlineHandler != null) {
      socketService.off(SocketEvent.driverOnline, _driverOnlineHandler!);
    }
    if (_driverLocationHandler != null) {
      socketService.off(
        SocketEvent.driverLocationUpdate,
        _driverLocationHandler!,
      );
    }
    if (_errorHandler != null) {
      socketService.off(SocketEvent.socketError, _errorHandler!);
    }

    if (_shiftExceededHandler != null) {
      socketService.off(SocketEvent.shiftExceeded, _shiftExceededHandler!);
    }

    _incomingRidesHandler = null;
    _rideTakenHandler = null;
    _rideResumeHandler = null;
    _rideStatusUpdateHandler = null;
    _driverOnlineHandler = null;
    _driverLocationHandler = null;
    _errorHandler = null;
    _chatHandler = null;
    _chatStatusUpdateHandler = null;
    _shiftExceededHandler = null;
    log('[RideSocketListener] Listeners removed from socket');
  }

  // ================================
  // Dispose
  // ================================
  void dispose() {
    stop();
    _chatController.close();
    _chatStatusUpdateController.close();
    _incomingRidesController.close();
    _rideTakenController.close();
    _rideResumeController.close();
    _rideStatusUpdateController.close();
    _driverLocationController.close();
    _driverOnlineController.close();
    _errorController.close();
    _shiftExceededController.close();
  }

  // ================================
  // Helper to convert payload to Map
  // ================================
  /// Fills `data` with top-level chat fields (e.g. `contextId`) when the server
  /// splits envelope vs message body.
  Map<String, dynamic> _mergeChatRootFieldsIntoMessageMap(
    Map<String, dynamic> root,
    Map<String, dynamic> inner,
  ) {
    root.forEach((String k, dynamic v) {
      if (k == 'data' || v == null) return;
      inner.putIfAbsent(k, () => v);
    });
    return inner;
  }

  Map<String, dynamic> _toMap(dynamic payload) {
    if (payload is List) {
      if (payload.isEmpty) return <String, dynamic>{};
      return _toMap(payload.first);
    }

    if (payload is String) {
      final dynamic decoded = _tryParseJson(payload);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw const FormatException('String payload is not valid JSON object');
    }

    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    throw FormatException('Something went wrong: ${payload.runtimeType}');
  }

  Map<String, dynamic> _extractRidePayload(Map<String, dynamic> data) {
    final dynamic ride = data['ride'];
    if (ride is Map<String, dynamic>) return ride;
    if (ride is Map) return Map<String, dynamic>.from(ride);
    return data;
  }

  String _normalizeErrorMessage(dynamic payload) {
    if (payload == null) return 'Socket error';
    if (payload is String) {
      final String normalized = payload.trim();
      return normalized.isEmpty ? 'Socket error' : normalized;
    }

    final dynamic decoded = payload is Map || payload is List
        ? payload
        : _tryParseJson(payload.toString());

    if (decoded is Map<String, dynamic>) {
      return _messageFromMap(decoded);
    }
    if (decoded is Map) {
      return _messageFromMap(Map<String, dynamic>.from(decoded));
    }

    final String fallback = payload.toString().trim();
    return fallback.isEmpty ? 'Socket error' : fallback;
  }

  String _messageFromMap(Map<String, dynamic> data) {
    for (final String key in <String>['message', 'error', 'reason']) {
      final String value = data[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }
    return 'Socket error';
  }

  dynamic _tryParseJson(String source) {
    try {
      return jsonDecode(source);
    } catch (_) {
      return null;
    }
  }
}
