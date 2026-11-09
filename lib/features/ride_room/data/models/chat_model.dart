import 'dart:convert' show jsonDecode;

import '../../../../core/utils/app_log.dart';
import '../../domain/entities/chat_entity.dart';

DateTime _parseDateTimeLoose(dynamic value, {DateTime? fallback}) {
  if (value == null) {
    return fallback ?? DateTime.now();
  }
  if (value is DateTime) {
    return value;
  }
  if (value is int) {
    // Heuristic: > 1e12 → epoch ms; else → epoch seconds (socket / BSON).
    if (value > 1000000000000) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
  }
  if (value is double) {
    final int v = value.round();
    if (v > 1000000000000) {
      return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
    }
    return DateTime.fromMillisecondsSinceEpoch(v * 1000, isUtc: true);
  }
  final String s = value.toString().trim();
  if (s.isEmpty) {
    return fallback ?? DateTime.now();
  }
  try {
    return DateTime.parse(s);
  } catch (_) {
    return fallback ?? DateTime.now();
  }
}

String _stringField(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString().trim();
}

String? _firstNonEmptyString(Map<String, dynamic> json, List<String> keys) {
  for (final String k in keys) {
    final Object? v = json[k];
    if (v == null) continue;
    final String s = v.toString().trim();
    if (s.isNotEmpty) return s;
  }
  return null;
}

/// Skips [Map] / [List] / [bool] so we never treat nested objects as user ids.
String? _scalarStringField(Object? v) {
  if (v == null || v is Map || v is List || v is bool) {
    return null;
  }
  final String s = v.toString().trim();
  if (s.isEmpty || s.startsWith('{')) {
    return null;
  }
  return s;
}

String? _firstScalarStringFromMap(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final String k in keys) {
    final String? s = _scalarStringField(json[k]);
    if (s != null) {
      return s;
    }
  }
  return null;
}

Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    try {
      final Map<String, dynamic> out = <String, dynamic>{};
      value.forEach((dynamic k, dynamic v) {
        out[k.toString()] = v;
      });
      return out;
    } catch (_) {
      return null;
    }
  }
  return null;
}

/// Carpool / admin payloads nest full user docs; ids may sit on [user] / [driver].
String? _extractPersonIdFromMap(Map<String, dynamic> m, {int depth = 0}) {
  if (depth > 4) {
    return null;
  }
  final String? direct = _firstScalarStringFromMap(m, const <String>[
    '_id',
    'id',
    'userId',
    'user_id',
    'driverId',
    'passengerId',
    'riderId',
  ]);
  if (direct != null) {
    return direct;
  }
  for (final String nestKey in const <String>[
    'user',
    'driver',
    'sender',
    'receiver',
    'rider',
    'passenger',
    'profile',
    'account',
  ]) {
    final Map<String, dynamic>? child = _asStringKeyedMap(m[nestKey]);
    if (child != null) {
      final String? hit = _extractPersonIdFromMap(child, depth: depth + 1);
      if (hit != null) {
        return hit;
      }
    }
  }
  return null;
}

/// Accept decoded JSON as [Map], [String], or loosely typed maps from sockets.
Map<String, dynamic>? _coerceJsonMap(dynamic json) {
  if (json == null) {
    return null;
  }
  final Map<String, dynamic>? direct = _asStringKeyedMap(json);
  if (direct != null) {
    return direct;
  }
  if (json is String) {
    final String t = json.trim();
    if (t.isEmpty) {
      return null;
    }
    try {
      final dynamic v = jsonDecode(t);
      return _asStringKeyedMap(v);
    } catch (_) {
      return null;
    }
  }
  return null;
}

String _readContextId(Map<String, dynamic> json) {
  final String? direct = _firstScalarStringFromMap(json, const <String>[
    'contextId',
    'context_id',
    'bookingId',
    'booking_id',
    'carpoolBookingId',
    'carpool_booking_id',
  ]);
  if (direct != null) {
    return direct;
  }

  final Object? ctx = json['context'];
  final Map<String, dynamic>? nestedMap = _asStringKeyedMap(ctx);
  if (nestedMap != null) {
    final String? nested = _firstScalarStringFromMap(nestedMap, const <String>[
      'id',
      '_id',
      'bookingId',
      'booking_id',
      'contextId',
      'context_id',
    ]);
    if (nested != null) {
      return nested;
    }
  }
  return '';
}

String _readContextIdSafe(Map<String, dynamic> json) {
  try {
    return _readContextId(json);
  } catch (_) {
    return _stringField(json['contextId'] ?? json['context_id']);
  }
}

String _readContextType(Map<String, dynamic> json) {
  return _firstScalarStringFromMap(json, const <String>[
        'contextType',
        'context_type',
      ]) ??
      _firstNonEmptyString(json, const <String>[
        'contextType',
        'context_type',
      ]) ??
      '';
}

class SenderReceiverModel extends SenderReceiverEntity {
  const SenderReceiverModel({
    required super.id,
    required super.type,
    super.signUpRecord = '',
  });

  /// Tolerant: string id, number, flat map, nested user doc, or list of maps.
  factory SenderReceiverModel.fromJson(dynamic json) {
    try {
      return SenderReceiverModel._parse(json);
    } catch (e, st) {
      // ignore: avoid_print
      log('[SenderReceiverModel.fromJson] $e\n$st');
      return const SenderReceiverModel(id: '', type: '');
    }
  }

  static SenderReceiverModel _parse(dynamic json) {
    if (json == null) {
      return const SenderReceiverModel(id: '', type: '');
    }

    if (json is String || json is num) {
      return SenderReceiverModel(id: json.toString().trim(), type: '');
    }

    if (json is List) {
      for (final dynamic item in json) {
        final SenderReceiverModel m = SenderReceiverModel._parse(item);
        if (m.id.trim().isNotEmpty) {
          return m;
        }
      }
      return const SenderReceiverModel(id: '', type: '');
    }

    if (json is Map) {
      final Map<String, dynamic>? m = _asStringKeyedMap(json);
      if (m == null) {
        return const SenderReceiverModel(id: '', type: '');
      }
      final String id = _extractPersonIdFromMap(m) ?? '';
      final String sur =
          _firstScalarStringFromMap(m, const <String>[
            'signUpRecord',
            'sign_up_record',
          ]) ??
          '';
      return SenderReceiverModel(
        id: id,
        type: _scalarStringField(m['type']) ?? '',
        signUpRecord: sur,
      );
    }

    return SenderReceiverModel(id: json.toString().trim(), type: '');
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type,
      if (signUpRecord.trim().isNotEmpty) "signUpRecord": signUpRecord,
    };
  }
}

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.conversationId,
    super.contextId = '',
    super.contextType = '',
    required super.message,
    required super.createdAt,
    required super.updatedAt,
    super.status = MessageDeliveryStatus.sent,
    required super.sender,
    required super.receiver,
  });

  @override
  ChatMessageModel copyWith({
    String? id,
    String? conversationId,
    String? contextId,
    String? contextType,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    MessageDeliveryStatus? status,
    SenderReceiverEntity? sender,
    SenderReceiverEntity? receiver,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      contextId: contextId ?? this.contextId,
      contextType: contextType ?? this.contextType,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
    );
  }

  factory ChatMessageModel.fromJson(dynamic json) {
    final Map<String, dynamic>? map = _coerceJsonMap(json);
    if (map == null) {
      throw FormatException(
        'ChatMessageModel.fromJson: unsupported payload (${json.runtimeType})',
      );
    }
    try {
      return ChatMessageModel._parse(map);
    } catch (e, st) {
      // ignore: avoid_print
      log('[ChatMessageModel] fallback loose parse: $e\n$st');
      return ChatMessageModel._loose(map);
    }
  }

  static ChatMessageModel _parse(Map<String, dynamic> json) {
    final String rawId = _stringField(json['_id'] ?? json['id']);
    final String conversationId = _stringField(
      json['conversationId'] ?? json['conversation_id'],
    );
    final String contextId = _readContextId(json);
    final String contextType = _readContextType(json);
    final DateTime createdAt = _parseDateTimeLoose(
      json['createdAt'] ?? json['created_at'],
    );
    final DateTime updatedAt = _parseDateTimeLoose(
      json['updatedAt'] ?? json['updated_at'],
      fallback: createdAt,
    );
    final String id = rawId.isNotEmpty
        ? rawId
        : '${conversationId}_${createdAt.millisecondsSinceEpoch}';

    return ChatMessageModel(
      id: id.isNotEmpty
          ? id
          : (conversationId.isNotEmpty ? conversationId : 'chat'),
      conversationId: conversationId,
      contextId: contextId,
      contextType: contextType,
      message: _stringField(json['message']),
      createdAt: createdAt,
      updatedAt: updatedAt,
      status:
          MessageDeliveryStatus.tryParse(json['status']) ??
          MessageDeliveryStatus.sent,
      sender: SenderReceiverModel.fromJson(json['sender']),
      receiver: SenderReceiverModel.fromJson(json['receiver']),
    );
  }

  /// Minimal parse path — only uses helpers that do not throw.
  static ChatMessageModel _loose(Map<String, dynamic> json) {
    final DateTime now = DateTime.now();
    String contextType = '';
    try {
      contextType = _readContextType(json);
    } catch (_) {
      contextType = _stringField(json['contextType'] ?? json['context_type']);
    }
    return ChatMessageModel(
      id: _stringField(json['_id'] ?? json['id']).isNotEmpty
          ? _stringField(json['_id'] ?? json['id'])
          : 'socket_$now',
      conversationId: _stringField(
        json['conversationId'] ?? json['conversation_id'],
      ),
      contextId: _readContextIdSafe(json),
      contextType: contextType,
      message: _stringField(json['message']),
      createdAt: _parseDateTimeLoose(
        json['createdAt'] ?? json['created_at'],
        fallback: now,
      ),
      updatedAt: _parseDateTimeLoose(
        json['updatedAt'] ?? json['updated_at'],
        fallback: now,
      ),
      status:
          MessageDeliveryStatus.tryParse(json['status']) ??
          MessageDeliveryStatus.sent,
      sender: SenderReceiverModel.fromJson(json['sender']),
      receiver: SenderReceiverModel.fromJson(json['receiver']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "conversationId": conversationId,
      "contextId": contextId,
      "contextType": contextType,
      "message": message,
      "status": status.name,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "sender": (sender as SenderReceiverModel).toJson(),
      "receiver": (receiver as SenderReceiverModel).toJson(),
    };
  }
}
