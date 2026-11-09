import 'package:driver_app/features/ride_room/domain/entities/chat_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/driver_location_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:driver_app/features/ride_room/presentation/enums/ride_enum.dart';

enum SocketStatus { initial, loading, success, error }

enum SocketAction {
  none,
  initialize,
  driverOnline,
  driverLocationUpdate,
  rideRequestAccept,

  /// Ring dispatch: another driver won the ride. Expected outcome, not an error:
  /// the card leaves the screen and the queue is repainted.
  rideRequestTaken,

  /// The request closed itself because nobody took it before the ring ladder
  /// ran out.
  rideRequestExpired,
  rideIncoming,
  rideResume,
  rideStatusUpdate,
  driverArrive,
  rideStart,
  rideCancel,
  rideComplete,
  availableRides,
  chatReceived,
  shiftExceeded,
}

class RideSocketState {
  final SocketStatus status;
  final SocketAction action;
  final String? message;
  final RideEntity? ride;
  final String? driverId;
  final DriverLocationEntity? driverLocation;
  final bool isOnline;
  final List<RideEntity> incomingRides;
  final RideSheetsType currentSheet;
  final String? otp;
  final bool isChatOpen;
  final DateTime? pickupWaitStartedAt;
  final Duration pickupWaitDuration;
  final String? pickupWaitRideId;
  final String? acceptingRideId;
  final DateTime? lastSyncAt;

  final List<ChatMessageEntity> chatMessages;
  final ChatMessageEntity? lastChatMessage;
  final bool showBadge;

  /// Carpool: passenger user ids (`passengerId`) with unread inbound messages.
  final Set<String> carpoolUnreadPassengerUserIds;

  /// Carpool chat open for this passenger user id (matches list `passengerId`).
  final String? activeCarpoolChatPassengerUserId;

  const RideSocketState({
    this.status = SocketStatus.initial,
    this.action = SocketAction.none,
    this.message,
    this.ride,
    this.driverId,
    this.driverLocation,
    this.isOnline = false,
    this.incomingRides = const [],
    this.currentSheet = RideSheetsType.pickupDetails,
    this.otp,
    this.chatMessages = const [],
    this.lastChatMessage,
    this.showBadge = false,
    this.isChatOpen = false,
    this.pickupWaitStartedAt,
    this.pickupWaitDuration = const Duration(minutes: 5),
    this.pickupWaitRideId,
    this.acceptingRideId,
    this.lastSyncAt,
    this.carpoolUnreadPassengerUserIds = const <String>{},
    this.activeCarpoolChatPassengerUserId,
  });

  RideSocketState copyWith({
    SocketStatus? status,
    SocketAction? action,
    String? message,
    RideEntity? ride,
    String? driverId,
    DriverLocationEntity? driverLocation,
    bool? isOnline,
    List<RideEntity>? incomingRides,
    RideSheetsType? currentSheet,
    bool clearMessage = false,
    bool clearRide = false,
    String? otp,
    List<ChatMessageEntity>? chatMessages,
    ChatMessageEntity? lastChatMessage,
    bool? isChatOpen,
    DateTime? pickupWaitStartedAt,
    Duration? pickupWaitDuration,
    String? pickupWaitRideId,
    String? acceptingRideId,
    DateTime? lastSyncAt,
    bool clearPickupWait = false,
    bool clearChatNotification = false,
    bool? showBadge,
    Set<String>? carpoolUnreadPassengerUserIds,
    String? activeCarpoolChatPassengerUserId,
    bool clearActiveCarpoolChatPassengerUserId = false,
    bool clearAcceptingRideId = false,
  }) {
    return RideSocketState(
      status: status ?? this.status,
      action: action ?? this.action,
      message: clearMessage ? null : (message ?? this.message),
      ride: clearRide ? null : (ride ?? this.ride),
      driverId: driverId ?? this.driverId,
      driverLocation: driverLocation ?? this.driverLocation,
      isOnline: isOnline ?? this.isOnline,
      incomingRides: incomingRides ?? this.incomingRides,
      currentSheet: currentSheet ?? this.currentSheet,
      otp: otp ?? this.otp,
      chatMessages: clearChatNotification
          ? const <ChatMessageEntity>[]
          : (chatMessages ?? this.chatMessages),
      lastChatMessage: clearChatNotification
          ? null
          : (lastChatMessage ?? this.lastChatMessage),
      showBadge: clearChatNotification ? false : (showBadge ?? this.showBadge),
      isChatOpen: isChatOpen ?? this.isChatOpen,
      pickupWaitStartedAt: clearPickupWait
          ? null
          : (pickupWaitStartedAt ?? this.pickupWaitStartedAt),
      pickupWaitDuration: clearPickupWait
          ? const Duration(minutes: 5)
          : (pickupWaitDuration ?? this.pickupWaitDuration),
      pickupWaitRideId: clearPickupWait
          ? null
          : (pickupWaitRideId ?? this.pickupWaitRideId),
      acceptingRideId: clearAcceptingRideId
          ? null
          : (acceptingRideId ?? this.acceptingRideId),
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      carpoolUnreadPassengerUserIds: clearChatNotification
          ? const <String>{}
          : (carpoolUnreadPassengerUserIds ??
                this.carpoolUnreadPassengerUserIds),
      activeCarpoolChatPassengerUserId:
          clearChatNotification || clearActiveCarpoolChatPassengerUserId
          ? null
          : (activeCarpoolChatPassengerUserId ??
                this.activeCarpoolChatPassengerUserId),
    );
  }

  /// Red dot on normal-ride sheet chat icon (driven only by socket [showBadge]).
  bool unreadChatDotForParticipant(String? _) {
    if (!showBadge || isChatOpen) return false;
    return true;
  }

  /// Carpool passenger list: red dot when unread for this passenger's user ids.
  bool unreadChatDotForCarpoolPassengerUser(
    String? passengerUserId, [
    String? userSignUpRecord,
  ]) {
    final String viewing = (activeCarpoolChatPassengerUserId ?? '')
        .trim()
        .toLowerCase();
    for (final String? raw in <String?>[passengerUserId, userSignUpRecord]) {
      final String pid = (raw ?? '').trim().toLowerCase();
      if (pid.isEmpty) continue;
      if (viewing == pid) {
        return false;
      }
      if (carpoolUnreadPassengerUserIds.contains(pid)) {
        return true;
      }
    }
    return false;
  }

  @override
  String toString() {
    return 'RideSocketState(status: $status, action: $action, message: $message, ride: $ride, driverId: $driverId, driverLocation: $driverLocation, isOnline: $isOnline, chatMessages: ${chatMessages.length}, showBadge: $showBadge, isChatOpen: $isChatOpen, pickupWaitStartedAt: $pickupWaitStartedAt, pickupWaitRideId: $pickupWaitRideId, acceptingRideId: $acceptingRideId, lastSyncAt: $lastSyncAt)';
  }
}
