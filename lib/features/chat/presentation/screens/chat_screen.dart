import 'dart:async';

import 'package:driver_app/core/constants/app_icons.dart';
import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/date_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/core/params/chat_params.dart';
import 'package:driver_app/core/theme/app_colors.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:driver_app/features/carpool/presentation/states/carpool_socket_states.dart';
import 'package:driver_app/features/chat/presentation/chat_screen_args.dart';
import 'package:driver_app/features/ride_room/data/datasources/ride_socket_datasource.dart';
import 'package:driver_app/features/ride_room/presentation/providers/chat_history_provider.dart';
import 'package:driver_app/features/ride_room/presentation/states/chat_state.dart';
import 'package:driver_app/features/user_profile/presentation/providers/user_profile_provider.dart';
import 'package:driver_app/features/user_profile/presentation/states/user_states.dart';
import 'package:driver_app/shared/shared.dart';
import 'package:driver_app/shared/widgets/circular_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/routes.dart';
import '../../../ride_room/domain/entities/chat_entity.dart';
import '../../../ride_room/presentation/providers/ride_provider.dart';
import '../../../ride_room/presentation/states/ride_state.dart';

/// Local-only demo chat (no API or socket).
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.args});

  final ChatScreenArgs? args;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

// class _DummyMessage {
//   const _DummyMessage({
//     required this.text,
//     required this.at,
//     required this.isOutgoing,
//   });
//
//   final String text;
//   final DateTime at;
//   final bool isOutgoing;
// }

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // late List<_DummyMessage> _messages;

  /// Cursor into [rideSocketProvider.chatMessages] so we only append new rows.
  int _rideChatSyncIndex = 0;

  /// Last context id we successfully requested history for (dedupes repeat calls).
  String? _lastSyncedContextId;
  bool _isLeavingChat = false;
  StreamSubscription<ChatStatusUpdate>? _chatStatusSub;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncChatHistoryIfNeeded();
      _registerStatusListener();

      ref.read(rideSocketProvider.notifier).setChatOpen();
      ref.read(rideSocketProvider.notifier).clearChatBadge();
      final String? passengerUserId = widget.args?.riderId?.trim();
      if (passengerUserId != null && passengerUserId.isNotEmpty) {
        ref
            .read(rideSocketProvider.notifier)
            .clearCarpoolChatBadgeForPassengerUser(passengerUserId);
      }
      if (widget.args?.isCarpool == 'true') {
        if (passengerUserId != null && passengerUserId.isNotEmpty) {
          ref
              .read(rideSocketProvider.notifier)
              .setActiveCarpoolChatPassengerUserId(passengerUserId);
        }
      }
      _rideChatSyncIndex = ref.read(rideSocketProvider).chatMessages.length;
    });
  }

  void _registerStatusListener() {
    unawaited(_chatStatusSub?.cancel());
    _chatStatusSub = locator<RideSocketDataSource>().chatStatusUpdates().listen(
      (ChatStatusUpdate update) {
        if (!mounted) return;
        ref.read(chatHistoryProvider.notifier).applyStatusUpdate(update);
      },
      onError: (Object e, StackTrace st) {
        debugPrint('[chat:status_updated] stream error: $e\n$st');
      },
    );
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool argsChanged =
        oldWidget.args?.rideId != widget.args?.rideId ||
        oldWidget.args?.riderId != widget.args?.riderId ||
        oldWidget.args?.isCarpool != widget.args?.isCarpool;
    if (argsChanged) {
      _lastSyncedContextId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncChatHistoryIfNeeded();
        if (widget.args?.isCarpool == 'true') {
          final String? passengerUserId = widget.args?.riderId?.trim();
          ref
              .read(rideSocketProvider.notifier)
              .setActiveCarpoolChatPassengerUserId(
                (passengerUserId != null && passengerUserId.isNotEmpty)
                    ? passengerUserId
                    : null,
              );
        }
        _rideChatSyncIndex = ref.read(rideSocketProvider).chatMessages.length;
      });
    }
  }

  /// Carpool: this DM is for the open passenger when they are [sender] (inbound)
  /// or [receiver] (driver’s own lines echoed from the socket).
  bool _carpoolIncomingMatchesOpenPassenger(ChatMessageEntity msg) {
    final String? open = widget.args?.riderId?.trim().toLowerCase();
    if (open == null || open.isEmpty) {
      return true;
    }
    return chatMessageSenderCanonIds(msg).contains(open) ||
        senderReceiverCanonIds(msg.receiver).contains(open);
  }

  /// Rows appended by [RideRoomProvider] — same source as the red dot.
  bool _rideSocketChatBelongsToThisScreen(ChatMessageEntity m) {
    if (_isCarpoolChat) {
      return _carpoolIncomingMatchesOpenPassenger(m);
    }
    return _normalRideSocketChatBelongs(m);
  }

  /// Solo ride: backend often uses `contextId` == ride id while `conversationId`
  /// is a separate thread id, so matching only [conversationId] drops every
  /// `chat:receive` row even though the badge (no filter) still updates.
  bool _normalRideSocketChatBelongs(ChatMessageEntity m) {
    final String? ctx = _effectiveContextId();
    if (ctx == null || ctx.isEmpty) {
      return true;
    }
    final String conv = m.conversationId.trim().toLowerCase();
    final String cid = m.contextId.trim().toLowerCase();
    // Same logical ride may surface as different ids (ride doc vs context vs thread).
    final Set<String> knownRideIds = _lowerCanonSet(<String?>[
      ctx,
      widget.args?.rideId,
      ref.read(rideSocketProvider).ride?.id,
    ]);
    for (final String k in knownRideIds) {
      if (k.isNotEmpty && (k == conv || k == cid)) {
        return true;
      }
    }
    final String ct = m.contextType.trim().toLowerCase();
    final bool soloContext = ct == 'ride' || ct.isEmpty;
    if (soloContext && conv.isNotEmpty) {
      final List<ChatMessageEntity> chats = ref.read(chatHistoryProvider).chats;
      if (chats.any(
        (ChatMessageEntity e) => e.conversationId.trim().toLowerCase() == conv,
      )) {
        return true;
      }
    }
    // Payloads often omit `contextId`; `conversationId` is the chat thread, not
    // the ride `_id`. Match the open ride's passenger + driver against both
    // [sender] (object) and [receiver] (often a plain driver id string).
    final Set<String> passengerKeys = _passengerCanonIdsForNormalRide();
    final Set<String> driverKeys = _driverCanonIdsForNormalRide();
    if (passengerKeys.isNotEmpty && _messageTouchesCanonSet(m, passengerKeys)) {
      if (driverKeys.isEmpty || _messageTouchesCanonSet(m, driverKeys)) {
        return true;
      }
    }
    return false;
  }

  static Set<String> _lowerCanonSet(Iterable<String?> raw) {
    final Set<String> out = <String>{};
    for (final String? s in raw) {
      final String t = (s ?? '').trim().toLowerCase();
      if (t.isNotEmpty) {
        out.add(t);
      }
    }
    return out;
  }

  Set<String> _passengerCanonIdsForNormalRide() {
    final ride = ref.read(rideSocketProvider).ride;
    return _lowerCanonSet(<String?>[
      widget.args?.riderId,
      ride?.user?.id,
      ride?.userId,
    ]);
  }

  Set<String> _driverCanonIdsForNormalRide() {
    final ride = ref.read(rideSocketProvider).ride;
    return _lowerCanonSet(<String?>[
      ref.read(userProfileProvider).profile?.user.id,
      ride?.driverId,
      ride?.driver?.id,
    ]);
  }

  static bool _messageTouchesCanonSet(ChatMessageEntity m, Set<String> keys) {
    if (keys.isEmpty) {
      return false;
    }
    final Set<String> parts = <String>{
      ...chatMessageSenderCanonIds(m),
      ...senderReceiverCanonIds(m.receiver),
    };
    return parts.any(keys.contains);
  }

  /// Carpool: booking/ride id from route args. Regular ride: prefer live socket ride id.
  String? _effectiveContextId() {
    if (widget.args?.isCarpool == 'true') {
      final String? id = widget.args?.rideId?.trim();
      return (id != null && id.isNotEmpty) ? id : null;
    }
    final String? rawSocketId = ref.read(rideSocketProvider).ride?.id;
    if (rawSocketId != null) {
      final String socketId = rawSocketId.trim();
      if (socketId.isNotEmpty) return socketId;
    }
    final String? argsId = widget.args?.rideId?.trim();
    if (argsId != null && argsId.isNotEmpty) return argsId;
    return null;
  }

  void _syncChatHistoryIfNeeded() {
    if (!mounted) return;
    final String? contextId = _effectiveContextId();
    if (contextId == null || contextId.isEmpty) return;
    if (contextId == _lastSyncedContextId) return;
    _lastSyncedContextId = contextId;
    ref.read(chatHistoryProvider.notifier).getChatHistory(contextId);
  }

  @override
  void dispose() {
    unawaited(_chatStatusSub?.cancel());
    _chatStatusSub = null;
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isCarpoolChat => widget.args?.isCarpool == 'true';

  String? get _currentCarpoolBookingId {
    if (!_isCarpoolChat) {
      return null;
    }
    final String? bookingId = widget.args?.rideId?.trim();
    return bookingId != null && bookingId.isNotEmpty ? bookingId : null;
  }

  void _queueChatClose() {
    final rideSocketNotifier = ref.read(rideSocketProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) rideSocketNotifier.setChatClose();
    });
  }

  void _leaveChat({bool goHome = false, bool resetCarpoolState = false}) {
    if (_isLeavingChat) {
      return;
    }
    _isLeavingChat = true;
    _queueChatClose();
    final carpoolNotifier = ref.read(carpoolSocketProvider.notifier);

    scheduleMicrotask(() {
      if (!mounted || !context.mounted) {
        return;
      }

      if (resetCarpoolState) {
        carpoolNotifier.clearRecoveredCarpoolState();
      }

      if (!goHome && Navigator.of(context).canPop()) {
        context.pop();
        return;
      }

      context.goNamed(Routes.home.name);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    String receiverId = '';
    String contextId = '';
    String contextType = '';

    if (widget.args?.isCarpool == 'true') {
      receiverId = widget.args?.riderId ?? 'receiverId';
      final String? cid = widget.args?.rideId?.trim();
      contextId = (cid != null && cid.isNotEmpty) ? cid : 'rideId';
      contextType = 'CarpoolBooking';
    } else {
      final ride = ref.read(rideSocketProvider).ride;
      receiverId = ride?.user?.id ?? 'receiverId';
      final String? socketRideId = ride?.id.trim();
      contextId = (socketRideId != null && socketRideId.isNotEmpty)
          ? socketRideId
          : (_effectiveContextId() ?? 'rideId');
      contextType = 'Ride';
    }
    final params = SendMessageParams(
      receiverId: receiverId,
      message: text,
      contextId: contextId,
      contextType: contextType,
    );
    ref.read(chatHistoryProvider.notifier).sendMessage(params);
  }

  void _markIncomingReadIfNeeded(ChatMessageEntity message) {
    final String myUserId =
        (ref.read(userProfileProvider).profile?.user.id ?? '')
            .trim()
            .toLowerCase();
    if (myUserId.isEmpty) return;

    final bool isOutgoing = chatMessageSenderCanonIds(
      message,
    ).contains(myUserId);
    if (isOutgoing) return;

    final String conversationId = message.conversationId.trim();
    if (conversationId.isEmpty) return;

    unawaited(
      locator<RideSocketDataSource>().markConversationRead(conversationId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final args = widget.args;
    final riderName = args?.riderName ?? 'Passenger';
    final riderImage = args?.riderProfileImage;
    final state = ref.watch(chatHistoryProvider);
    final userState = ref.watch(userProfileProvider);

    ref.listen<RideSocketState>(rideSocketProvider, (previous, next) {
      if (!mounted) return;
      final List<ChatMessageEntity> list = next.chatMessages;
      if (list.length <= _rideChatSyncIndex) {
        return;
      }
      for (int i = _rideChatSyncIndex; i < list.length; i++) {
        final ChatMessageEntity e = list[i];
        if (!_rideSocketChatBelongsToThisScreen(e)) {
          continue;
        }
        ref.read(chatHistoryProvider.notifier).appendIncomingMessage(e);
        _markIncomingReadIfNeeded(e);
      }
      _rideChatSyncIndex = list.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToBottom();
        }
      });
    });

    // New active ride id from socket → refetch history with updated context id.
    ref.listen<String?>(rideSocketProvider.select((s) => s.ride?.id), (
      previous,
      next,
    ) {
      if (!mounted) return;
      if (_isCarpoolChat) return;
      _syncChatHistoryIfNeeded();
    });

    // Cancel clears ride while chat may still be on the stack; ensure we leave
    // to home if provider navigation was delayed (same microtask pattern).
    ref.listen<RideSocketState>(rideSocketProvider, (previous, next) {
      if (!mounted) return;
      if (_isCarpoolChat) return;
      final String? openRideId = _effectiveContextId();
      final String? prevRideId = previous?.ride?.id?.trim();
      if (prevRideId == null || prevRideId.isEmpty) return;
      if (next.ride != null) return;
      if (openRideId != null &&
          openRideId.isNotEmpty &&
          prevRideId != openRideId) {
        return;
      }
      _leaveChat(goHome: true);
    });

    ref.listen<CarpoolSocketState>(carpoolSocketProvider, (previous, next) {
      if (!mounted) return;
      if (!_isCarpoolChat) {
        return;
      }

      final String? bookingId = _currentCarpoolBookingId;
      if (bookingId == null) {
        return;
      }

      final bool wholeCarpoolCancelled =
          previous?.action != next.action &&
          next.action == CarpoolSocketAction.rideCancel;
      final String nextCancelledBookingId = (next.lastCancelledBookingId ?? '')
          .trim();
      final bool currentBookingCancelled =
          previous?.lastCancelledBookingId != next.lastCancelledBookingId &&
          nextCancelledBookingId == bookingId;

      if (wholeCarpoolCancelled) {
        _leaveChat(goHome: true, resetCarpoolState: true);
        return;
      }

      if (currentBookingCancelled) {
        _leaveChat();
      }
    });

    // Listen to socket messages safely
    // ref.listen<RideSocketState>(rideSocketProvider, (previous, next) {
    //   final lastMessage = next.lastChatMessage;
    //   if (lastMessage != null) {
    //     final chatNotifier = ref.read(chatHistoryProvider.notifier);
    //     final updatedChats = [...chatNotifier.state.chats, lastMessage];
    //     chatNotifier.state = chatNotifier.state.copyWith(chats: updatedChats);
    //
    //     // Optionally scroll to bottom when new message arrives
    //     _scrollToBottom();
    //   }
    // });

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          return;
        }
        _queueChatClose();
      },
      child: AppScaffold(
        padding: EdgeInsets.zero,
        scrollable: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: colors.border),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: colors.textPrimary,
              size: AppSizes.iconMedium,
            ),
            onPressed: () {
              _leaveChat();
            },
          ),
          title: Row(
            children: [
              CircularProfile(image: riderImage, size: 36),
              const SizedBox(width: AppSizes.p12),
              Expanded(
                child: Text(
                  riderName,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          titleSpacing: 0,
        ),
        child: Column(
          children: [
            Expanded(child: _buildChatHistoryWidget(state, userState)),
            _ChatInput(
              messageController: _messageController,
              colors: colors,
              textTheme: textTheme,
              onSend: () => _sendMessage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHistoryWidget(
    ChatState chatState,
    UserProfileState userState,
  ) {
    if (chatState.chatHistoryStatus == ChatStatus.error) {
      return Center(child: Text(chatState.message));
    }

    final bool loading = chatState.chatHistoryStatus == ChatStatus.loading;
    if (loading && chatState.chats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatState.chats.isEmpty) {
      return Center(child: Text(context.l10n.start_chat_fallback));
    }

    final userId = userState.profile?.user.id;

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p16,
      ),
      itemCount: chatState.chats.length,
      itemBuilder: (context, index) {
        final combinedChats = [...chatState.chats]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final message = combinedChats[index];
        final isOutgoing = userId == message.sender.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.p12),
          child: _ChatBubble(
            text: message.message,
            time: message.createdAt.toLocal().timeOnly,
            isOutgoing: isOutgoing,
            status: isOutgoing ? message.status : null,
          ),
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.text,
    required this.time,
    required this.isOutgoing,
    this.status,
  });

  final String text;
  final String time;
  final bool isOutgoing;
  final MessageDeliveryStatus? status;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;

    final bubbleColor = isOutgoing
        ? colors.brand
        : Color.lerp(colors.brand, colors.surface, 0.5) ?? colors.surface;

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.screenWidth * 0.78),
        child: Column(
          crossAxisAlignment: isOutgoing
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p16,
                vertical: AppSizes.p12,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppSizes.radiusMedium),
                  topRight: const Radius.circular(AppSizes.radiusMedium),
                  bottomLeft: Radius.circular(
                    isOutgoing ? AppSizes.radiusMedium : 4,
                  ),
                  bottomRight: Radius.circular(
                    isOutgoing ? 4 : AppSizes.radiusMedium,
                  ),
                ),
              ),
              child: Text(
                text,
                style: textTheme.bodyMedium?.copyWith(color: colors.onBrand),
              ),
            ),
            const SizedBox(height: AppSizes.p4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  if (isOutgoing && status != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      status!.isDoubleTick ? Icons.done_all : Icons.done,
                      size: 14,
                      color: status!.isRead
                          ? const Color(0xFF34B7F1)
                          : colors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.messageController,
    required this.colors,
    required this.textTheme,
    required this.onSend,
  });

  final TextEditingController messageController;
  final AppThemeColors colors;
  final TextTheme textTheme;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.p16,
        AppSizes.p12,
        AppSizes.p8,
        AppSizes.p16,
      ),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: SafeArea(
        top: false,
        child: AppTextField(
          controller: messageController,
          hintText: context.l10n.chat_message_hint,
          maxlines: 1,
          maxLength: 500,

          textInputAction: TextInputAction.send,
          radius: AppSizes.radiusRound,
          suffixIcon: Container(
            margin: const EdgeInsets.all(10),
            child: Material(
              color: colors.brand,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onSend,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p8),
                  child: Image.asset(
                    AppIcons.send,
                    height: 20,
                    width: 20,
                    color: colors.onBrand,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
