import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/app_config.dart';
import '../di/service_locator.dart';
import '../utils/app_log.dart';

import 'storage_service.dart';

class SocketService {
  final StorageService _storageService;
  final void Function(String message)? onAuthRequired;

  io.Socket? _socket;
  final StreamController<SocketConnectionStatus> _statusController =
      StreamController<SocketConnectionStatus>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  String? _lastErrorMessage;
  bool _isDisconnecting = false;
  bool _isHandlingAuthFailure = false;
  bool _isConnecting = false;

  SocketService(this._storageService, {this.onAuthRequired});

  Stream<SocketConnectionStatus> get statusStream => _statusController.stream;
  Stream<String> get errorStream => _errorController.stream;
  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect({
    String? socketUrl,
    String? token,
    Map<String, dynamic>? query,
    bool forceReconnect = true,
    Duration timeout = const Duration(seconds: 12),
  }) async {
    if (_isConnecting) {
      log(
        'Socket connection already in progress, skipping...',
        name: 'SocketService',
      );
      return;
    }

    if (isConnected && !forceReconnect) return;

    _isConnecting = true;
    try {
      if (forceReconnect) {
        disconnect();
      }

      final String resolvedSocketUrl =
          (socketUrl ?? locator<AppConfig>().baseUrl).trim();
      if (resolvedSocketUrl.isEmpty) {
        throw const FormatException('Socket URL is empty.');
      }

      final String? authToken = token ?? _storageService.getToken;
      if (authToken == null || authToken.isEmpty) {
        _isConnecting = false;
        return;
      }
      final Map<String, String> headers = <String, String>{};
      headers['token'] = authToken;

      _statusController.add(SocketConnectionStatus.connecting);
      _isDisconnecting = false;

      final Completer<void> connectedCompleter = Completer<void>();

      _socket = io.io(
        resolvedSocketUrl,
        io.OptionBuilder()
            .setTransports(<String>['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .enableForceNew()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(5000)
            .setReconnectionDelayMax(5000)
            .setExtraHeaders(headers)
            .setTimeout(60000)
            .build(),
      );

      _registerCoreListeners(connectedCompleter);
      _socket?.connect();

      await connectedCompleter.future.timeout(
        timeout,
        onTimeout: () => throw TimeoutException(
          'The request is taking longer than expected. Please try again in a moment.',
        ),
      );
    } finally {
      _isConnecting = false;
    }
  }

  Future<dynamic> emitWithAck(
    String event,
    dynamic data, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final io.Socket socket = await _requireConnectedSocket();
    final Completer<dynamic> ackCompleter = Completer<dynamic>();

    log(
      'Socket emitWithAck <$event> request: ${_stringifyPayload(data)}',
      name: 'SocketService',
    );

    final Timer timer = Timer(timeout, () {
      log(
        'Socket emitWithAck <$event> timed out after ${timeout.inSeconds}s',
        name: 'SocketService',
      );
      if (!ackCompleter.isCompleted) {
        ackCompleter.completeError(
          TimeoutException(
            'The request is taking longer than expected. Please try again in a moment.',
          ),
        );
      }
    });

    socket.emitWithAck(
      event,
      data,
      ack: (dynamic ackPayload) {
        log(
          'Socket emitWithAck <$event> raw ack: ${_stringifyPayload(ackPayload)}',
          name: 'SocketService',
        );
        if (!ackCompleter.isCompleted) {
          final normalizedAck = _normalizeAckPayload(ackPayload);
          log(
            'Socket emitWithAck <$event> normalized ack: ${_stringifyPayload(normalizedAck)}',
            name: 'SocketService',
          );
          ackCompleter.complete(normalizedAck);
        }
      },
    );

    try {
      return await ackCompleter.future;
    } finally {
      timer.cancel();
    }
  }

  Future<SocketAckResponse> emitWithAckResponse(
    String event,
    dynamic data, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final dynamic raw = await emitWithAck(event, data, timeout: timeout);
    final response = SocketAckResponse.fromDynamic(raw);
    log(
      'Socket emitWithAckResponse <$event> parsed ack: success=${response.success}, message=${response.message}, data=${_stringifyPayload(response.data)}, raw=${_stringifyPayload(response.raw)}',
      name: 'SocketService',
    );
    return response;
  }

  void emit(String event, [dynamic data]) async {
    final io.Socket socket = await _requireConnectedSocket();
    socket.emit(event, data);
    log('Socket emit <$event>: $data', name: 'SocketService');
  }

  void on(String event, void Function(dynamic payload) callback) async {
    log('socket on: $event', name: 'ride socket');

    ((await _requireConnectedSocket()).on(event, callback));
  }

  /// Runs [register] with a single connected [io.Socket] so all `.on` calls are
  /// synchronous on that instance. Prefer this over multiple async [on] calls,
  /// which can overlap across reconnects and register duplicate handlers.
  Future<void> withConnectedSocket(
    void Function(io.Socket socket) register,
  ) async {
    final io.Socket socket = await _requireConnectedSocket();
    register(socket);
  }

  void onAny(void Function(String event, dynamic payload) callback) async {
    final io.Socket socket = await _requireConnectedSocket();
    socket.onAny((dynamic event, dynamic payload) {
      // Log the event and payload before calling the callback
      log('Received event: $event');
      log('Received payload: $payload');
      log('Received event: $event');
      log('Received payload: $payload');

      // Call the provided callback function
      callback(event.toString(), payload);

      // Log after callback
      log('Callback executed for event: $event');
    });
  }

  void off(String event, [void Function(dynamic payload)? callback]) {
    final io.Socket? socket = _socket;
    if (socket == null) return;
    if (callback == null) {
      socket.off(event);
      return;
    }
    socket.off(event, callback);
  }

  void offAny() {
    _socket?.offAny();
  }

  Future<void> refreshConnectionWithLatestToken() async {
    final bool wasConnected = isConnected;
    if (!wasConnected) return;
    final String socketUrl = _socket?.io.uri ?? locator<AppConfig>().baseUrl;
    disconnect();
    await connect(socketUrl: socketUrl, forceReconnect: true);
  }

  /// Update the socket URL at runtime (e.g. from Remote Config).
  /// If the URL has changed and the socket is connected, it will reconnect.
  Future<void> updateSocketUrl(String newSocketUrl) async {
    if (newSocketUrl.isEmpty) return;
    final String currentUrl = _socket?.io.uri ?? '';
    if (currentUrl != newSocketUrl) {
      log('🔄 Socket URL updated → $newSocketUrl', name: 'SocketService');
      final bool wasConnected = isConnected;
      if (wasConnected) {
        disconnect();
        await connect(socketUrl: newSocketUrl, forceReconnect: true);
      }
    }
  }

  void disconnect() {
    final io.Socket? socket = _socket;
    _isConnecting = false;
    _isDisconnecting = true;

    if (socket != null) {
      log(
        '🔌 Violently disconnecting old socket instance...',
        name: 'SocketService',
      );
      socket.offAny();
      socket.clearListeners(); // Remove all event listeners
      socket.disconnect();
      socket.dispose();
      socket.destroy(); // Force manager cleanup
    }

    _socket = null;
    _statusController.add(SocketConnectionStatus.disconnected);
    log('✅ Socket fully cleared.', name: 'SocketService');
  }

  void dispose() {
    disconnect();
    _errorController.close();
    _statusController.close();
  }

  Future<io.Socket> _requireConnectedSocket({
    int maxAttempts = 4,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    final io.Socket? socket = _socket;
    if (socket == null) {
      throw 'Socket is not initialized!';
    }

    if (socket.connected) return socket;

    // Not connected — attempt to reconnect up to maxAttempts times.
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      log(
        'Socket not connected. Reconnect attempt $attempt/$maxAttempts…',
        name: 'SocketService',
      );
      _statusController.add(SocketConnectionStatus.reconnecting);
      // socket.disconnect();
      socket.connect();

      // Wait for the connection to establish (or the delay to elapse).
      await Future<void>.delayed(retryDelay);

      if (_socket != null && _socket!.connected) {
        log('Reconnect succeeded on attempt $attempt.', name: 'SocketService');
        return _socket!;
      }
    }

    // All attempts exhausted.
    log(
      'Socket reconnect failed after $maxAttempts attempts.',
      name: 'SocketService',
    );
    throw 'Internal Server Error';
  }

  void _registerCoreListeners(Completer<void> connectedCompleter) {
    _socket?.onConnect((_) {
      log('Socket connected', name: 'SocketService');
      debugPrint(_green('Socket connected'));
      _lastErrorMessage = null;
      _isHandlingAuthFailure = false;
      _isDisconnecting = false;
      _statusController.add(SocketConnectionStatus.connected);
      if (!connectedCompleter.isCompleted) {
        connectedCompleter.complete();
      }
    });

    _socket?.onDisconnect((dynamic reason) {
      log('Socket disconnected: $reason', name: 'SocketService');
      debugPrint(_green('Socket disconnected: $reason'));
      _statusController.add(SocketConnectionStatus.disconnected);
      if (_isDisconnecting) return;
      final String? message = _normalizeDisconnectReason(reason);
      if (message != null) {
        _publishError(message);
      }
    });

    _socket?.onReconnectAttempt((_) {
      log('Socket reconnect attempt', name: 'SocketService');
      _statusController.add(SocketConnectionStatus.reconnecting);
    });

    _socket?.onError((dynamic error) {
      log('Socket error: $error', name: 'SocketService');
      _statusController.add(SocketConnectionStatus.error);
      final String message = _normalizeSocketErrorMessage(error);
      _handleAuthFailureIfNeeded(error, message);
      _publishError(message);
      if (!connectedCompleter.isCompleted) {
        connectedCompleter.completeError(SocketConnectionException(message));
      }
    });

    _socket?.onConnectError((dynamic error) {
      log('Socket connect error: $error', name: 'SocketService');
      _statusController.add(SocketConnectionStatus.error);
      final String message = _normalizeSocketErrorMessage(error);
      _handleAuthFailureIfNeeded(error, message);
      _publishError(message);
      if (!connectedCompleter.isCompleted) {
        connectedCompleter.completeError(SocketConnectionException(message));
      }
    });

    _socket?.onAny((dynamic event, dynamic payload) {
      log(
        'Socket incoming <$event>: ${_stringifyPayload(payload)}',
        name: 'SocketService',
      );
      log('Socket incoming <$event>: ${_stringifyPayload(payload)}');
      if (event.toString() != 'error') {
        return;
      }

      final String message = _normalizeSocketErrorMessage(payload);
      _handleAuthFailureIfNeeded(payload, message);
      _publishError(message);
    });
  }

  void _publishError(String message) {
    final String normalized = message.trim();
    if (normalized.isEmpty) return;
    if (_lastErrorMessage == normalized) return;
    _lastErrorMessage = normalized;
    if (!_errorController.isClosed) {
      _errorController.add(normalized);
    }
  }

  String _normalizeSocketErrorMessage(dynamic error) {
    final String raw = _extractErrorMessage(error);
    final String lower = raw.toLowerCase();

    if (lower.contains('status code: 502')) {
      return 'Live ride updates are temporarily unavailable. Please try again.';
    }

    if (lower.contains('status code: 401') ||
        lower.contains('status code: 403')) {
      return 'Your session expired. Please sign in again.';
    }

    if (lower.contains('timeout')) {
      return 'Unable to connect to live ride updates right now. Please try again.';
    }

    if (lower.contains('socketexception') ||
        lower.contains('websocketexception') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('failed host lookup')) {
      return 'Please check your internet connection and try again.';
    }

    if (raw.isEmpty) {
      return 'Unable to connect to live ride updates right now.';
    }

    return raw;
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Map) {
      final dynamic message = error['message'];
      if (message != null) {
        return message.toString().trim();
      }
      return error.toString().trim();
    }

    if (error is List && error.isNotEmpty) {
      return _extractErrorMessage(error.first);
    }

    return error?.toString().trim() ?? '';
  }

  bool _isAuthFailureMessage(String message) {
    final String lower = message.toLowerCase();
    return lower.contains('re-login') ||
        lower.contains('relgin') ||
        lower.contains('sign in again') ||
        lower.contains('session expired') ||
        lower.contains('unauthorized') ||
        lower.contains('token expired') ||
        lower.contains('Access denied') ||
        lower.contains('please re-login');
  }

  void _handleAuthFailureIfNeeded(dynamic error, String message) {
    if (!_isAuthFailureMessage(message)) {
      return;
    }

    if (_isHandlingAuthFailure) {
      return;
    }
    _isHandlingAuthFailure = true;

    disconnect();
    onAuthRequired?.call(message);
  }

  String? _normalizeDisconnectReason(dynamic reason) {
    final String raw = reason?.toString().trim() ?? '';
    if (raw.isEmpty || raw == 'io client disconnect') {
      return null;
    }

    final String lower = raw.toLowerCase();
    if (lower == 'transport close' ||
        lower == 'ping timeout' ||
        lower == 'transport error') {
      return 'Connection to live ride updates was lost. Retrying...';
    }

    return null;
  }

  dynamic _normalizeAckPayload(dynamic ackPayload) {
    if (ackPayload is List<dynamic>) {
      if (ackPayload.isEmpty) return <String, dynamic>{};
      return _normalizeAckPayload(ackPayload.first);
    }

    if (ackPayload is String) {
      final dynamic decoded = _tryParseJson(ackPayload);
      return decoded ?? ackPayload;
    }

    return ackPayload;
  }

  dynamic _tryParseJson(String source) {
    try {
      return jsonDecode(source);
    } catch (_) {
      return null;
    }
  }

  String _stringifyPayload(dynamic payload) {
    if (payload == null) {
      return 'null';
    }
    if (payload is String) {
      return payload;
    }

    try {
      return jsonEncode(payload);
    } catch (_) {
      return payload.toString();
    }
  }

  String _green(String text) => '\x1B[32m$text\x1B[0m';
}

enum SocketConnectionStatus {
  initial,
  connecting,
  connected,
  reconnecting,
  disconnected,
  error,
}

class SocketAckResponse {
  final bool success;
  final String message;
  final dynamic data;
  final Map<String, dynamic> raw;

  const SocketAckResponse({
    required this.success,
    required this.message,
    this.data,
    this.raw = const <String, dynamic>{},
  });

  factory SocketAckResponse.fromDynamic(dynamic source) {
    final dynamic normalized = _normalize(source);
    if (normalized is Map<String, dynamic>) {
      return SocketAckResponse(
        success: normalized['success'] == true,
        message: (normalized['message'] ?? '').toString(),
        data: normalized['data'],
        raw: normalized,
      );
    }

    if (normalized is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(normalized);
      return SocketAckResponse(
        success: map['success'] == true,
        message: (map['message'] ?? '').toString(),
        data: map['data'],
        raw: map,
      );
    }

    return SocketAckResponse(
      success: false,
      message: 'Invalid ack payload format',
      data: normalized,
      raw: <String, dynamic>{'raw': normalized},
    );
  }

  static dynamic _normalize(dynamic payload) {
    if (payload is List<dynamic>) {
      if (payload.isEmpty) return <String, dynamic>{};
      return _normalize(payload.first);
    }

    if (payload is String) {
      try {
        return jsonDecode(payload);
      } catch (_) {
        return payload;
      }
    }

    return payload;
  }
}

class SocketConnectionException implements Exception {
  final String message;

  const SocketConnectionException(this.message);

  @override
  String toString() => message;
}
