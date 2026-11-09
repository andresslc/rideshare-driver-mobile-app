import 'message_delivery_status.dart';

export 'message_delivery_status.dart';

/// Stable key for deduping chat rows (some payloads omit `_id`).
String chatMessageDedupeKey(ChatMessageEntity m) {
  final String id = m.id.trim();
  if (id.isNotEmpty) {
    return id;
  }
  // Avoid collapsing distinct socket rows that omit `_id` but share second precision.
  final String sid = m.sender.id.trim();
  final String rid = m.receiver.id.trim();
  return '${m.conversationId}_${m.createdAt.toIso8601String()}_${sid}_${rid}_${m.message}';
}

/// Same chat line delivered twice (socket vs HTTP) often has different `_id` /
/// synthetic ids. Merge and append use this so the list does not show duplicates.
bool chatMessagesLikelyDuplicate(ChatMessageEntity a, ChatMessageEntity b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.message.trim() != b.message.trim()) {
    return false;
  }
  if ((a.createdAt.difference(b.createdAt).inMilliseconds).abs() > 120000) {
    return false;
  }
  if (!_senderReceiverAlign(a.sender, b.sender)) {
    return false;
  }
  if (!_senderReceiverAlign(a.receiver, b.receiver)) {
    return false;
  }
  return _threadIdsCompatible(a, b);
}

bool _senderReceiverAlign(SenderReceiverEntity x, SenderReceiverEntity y) {
  final Set<String> xs = senderReceiverCanonIds(x);
  final Set<String> ys = senderReceiverCanonIds(y);
  if (xs.isEmpty && ys.isEmpty) {
    return true;
  }
  if (xs.isEmpty || ys.isEmpty) {
    return false;
  }
  for (final String id in xs) {
    if (ys.contains(id)) {
      return true;
    }
  }
  return false;
}

bool _threadIdsCompatible(ChatMessageEntity a, ChatMessageEntity b) {
  final String ac = a.conversationId.trim().toLowerCase();
  final String bc = b.conversationId.trim().toLowerCase();
  final String ax = a.contextId.trim().toLowerCase();
  final String bx = b.contextId.trim().toLowerCase();
  bool nz(String s) => s.isNotEmpty;
  if (nz(ac) && nz(bc) && ac == bc) {
    return true;
  }
  if (nz(ax) && nz(bx) && ax == bx) {
    return true;
  }
  if (nz(ac) && nz(bx) && ac == bx) {
    return true;
  }
  if (nz(ax) && nz(bc) && ax == bc) {
    return true;
  }
  if (!nz(ac) && !nz(ax) && !nz(bc) && !nz(bx)) {
    return true;
  }
  return false;
}

class SenderReceiverEntity {
  final String id;
  final String type;
  /// Same person as [id] when API uses Mongo `_id` vs `signUpRecord` interchangeably.
  final String signUpRecord;

  const SenderReceiverEntity({
    required this.id,
    required this.type,
    this.signUpRecord = '',
  });
}

/// All lowercased non-empty ids for matching socket user ↔ passenger list.
Set<String> senderReceiverCanonIds(SenderReceiverEntity s) {
  final Set<String> out = <String>{};
  final String a = s.id.trim().toLowerCase();
  if (a.isNotEmpty) {
    out.add(a);
  }
  final String b = s.signUpRecord.trim().toLowerCase();
  if (b.isNotEmpty) {
    out.add(b);
  }
  return out;
}

/// Sender-side ids for carpool passenger matching / unread keys.
Set<String> chatMessageSenderCanonIds(ChatMessageEntity m) =>
    senderReceiverCanonIds(m.sender);

class ChatMessageEntity {
  final String id;
  final String conversationId;
  final String contextId;
  final String contextType;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MessageDeliveryStatus status;

  final SenderReceiverEntity sender;
  final SenderReceiverEntity receiver;

  const ChatMessageEntity({
    required this.id,
    required this.conversationId,
    this.contextId = '',
    this.contextType = '',
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    this.status = MessageDeliveryStatus.sent,
    required this.sender,
    required this.receiver,
  });

  ChatMessageEntity copyWith({
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
    return ChatMessageEntity(
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

  /// Carpool: passenger booking id for matching UI + socket handling.
  ///
  /// Prefer [contextId] (plus parser aliases in [ChatMessageModel]). If the
  /// server only labels the thread via [conversationId], use it unless this is
  /// an explicit solo ride (`contextType` == `Ride`).
  String get carpoolBookingMatchKey {
    final String c = contextId.trim();
    if (c.isNotEmpty) return c;
    if (contextType.trim().toLowerCase() == 'ride') return '';
    return conversationId.trim();
  }

  /// Carpool: whether this message belongs to the DM with [passengerUserId]
  /// (passenger list `passengerId`), using [sender] / [receiver] ids only.
  bool involvesCarpoolPassengerUser(String passengerUserId) {
    final String p = passengerUserId.trim().toLowerCase();
    if (p.isEmpty) return false;
    return sender.id.trim().toLowerCase() == p ||
        receiver.id.trim().toLowerCase() == p;
  }

  /// Solo or carpool: thread includes this passenger / rider user id.
  bool involvesParticipantUser(String participantUserId) =>
      involvesCarpoolPassengerUser(participantUserId);

  /// Same carpool vs solo-ride routing the driver socket uses for chat badges.
  ///
  /// When chat [thread] equals [activeRideId], that is normally solo ride chat.
  /// Carpool can still collide (conversation id == carpool ride id); use
  /// [activeRideType], message [contextType], or [carpoolSocketSessionActive]
  /// when [carpoolActiveRouteId] matches [activeRideId] to stay on carpool.
  bool shouldRouteCarpoolChatForDriver({
    String? activeRideId,
    String? activeRideType,
    bool carpoolSocketSessionActive = false,
    String? carpoolActiveRouteId,
  }) {
    // Some carpool payloads still label context as `Ride`. Only treat that as
    // solo-only when there is no carpool context (socket, route id, or ride type).
    if (contextType.trim().toLowerCase() == 'ride') {
      final String cap = (carpoolActiveRouteId ?? '').trim();
      final bool activeRideIsCarpool =
          activeRideType?.trim().toLowerCase().contains('carpool') ?? false;
      if (!carpoolSocketSessionActive &&
          cap.isEmpty &&
          !activeRideIsCarpool) {
        return false;
      }
    }
    final String thread = carpoolBookingMatchKey;
    final String ar = (activeRideId ?? '').trim();
    if (thread.isNotEmpty) {
      if (ar.isNotEmpty &&
          thread.toLowerCase() == ar.toLowerCase()) {
        final bool activeRideIsCarpool =
            activeRideType?.trim().toLowerCase().contains('carpool') ?? false;
        final String ct = contextType.trim().toLowerCase();
        final bool messageLooksCarpool =
            ct.contains('carpool') || ct.contains('carpoolbooking');
        final String cap = (carpoolActiveRouteId ?? '').trim().toLowerCase();
        final bool carpoolRouteMatchesRide =
            carpoolSocketSessionActive &&
                cap.isNotEmpty &&
                cap == ar.toLowerCase();
        if (!activeRideIsCarpool &&
            !messageLooksCarpool &&
            !carpoolRouteMatchesRide) {
          return false;
        }
      } else {
        // [thread] != active ride id is normal for carpool (booking/context id
        // vs route id). `hasActiveRide` / `rideType` can also be unset briefly,
        // so we must not send these down the solo path (that drops carpool dots).
        if (ar.isEmpty) {
          return false;
        }
      }
      return true;
    }
    final String conv = conversationId.trim();
    if (conv.isEmpty) return false;
    if (ar.isNotEmpty &&
        conv.toLowerCase() == ar.toLowerCase() &&
        contextId.trim().isNotEmpty) {
      return false;
    }
    return true;
  }

  /// Carpool passenger-list red dot: same thread rule as the open chat list
  /// ([involvesCarpoolPassengerUser] for `passengerId` == inbound [sender]),
  /// excluding messages sent by the driver ([driverUserIdCanon]).
  bool carpoolUnreadFromPassengerMatchesListPassenger(String driverUserIdCanon) {
    final String d = driverUserIdCanon.trim().toLowerCase();
    final String s = sender.id.trim().toLowerCase();
    if (s.isEmpty) return false;
    if (d.isNotEmpty && s == d) return false;
    return involvesParticipantUser(s);
  }

  /// Whether this message should show the unread dot for the passenger row
  /// with list id [passengerUserIdCanon] (must match inbound [sender.id]).
  bool carpoolUnreadDotForListedPassenger({
    required String passengerUserIdCanon,
    required String driverUserIdCanon,
    String? activeRideId,
    String? activeRideType,
    bool carpoolSocketSessionActive = false,
    String? carpoolActiveRouteId,
  }) {
    final String p = passengerUserIdCanon.trim().toLowerCase();
    if (p.isEmpty) return false;
    if (!shouldRouteCarpoolChatForDriver(
          activeRideId: activeRideId,
          activeRideType: activeRideType,
          carpoolSocketSessionActive: carpoolSocketSessionActive,
          carpoolActiveRouteId: carpoolActiveRouteId,
        )) {
      return false;
    }
    final String s = sender.id.trim().toLowerCase();
    if (s != p) return false;
    return carpoolUnreadFromPassengerMatchesListPassenger(driverUserIdCanon);
  }
}