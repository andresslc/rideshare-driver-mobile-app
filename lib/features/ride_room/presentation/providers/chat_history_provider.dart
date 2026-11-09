import 'package:driver_app/features/ride_room/domain/entities/chat_entity.dart';
import 'package:driver_app/features/ride_room/domain/usecases/get_chat_history_use_case.dart';
import 'package:driver_app/features/ride_room/domain/usecases/send_message_use_case.dart';
import 'package:driver_app/features/ride_room/presentation/states/chat_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/params/chat_params.dart';

final chatHistoryProvider = NotifierProvider<ChatHistoryController, ChatState>(
  ChatHistoryController.new,
);

class ChatHistoryController extends Notifier<ChatState> {
  late GetChatHistoryUseCase getChatHistoryUseCase;
  late SendMessageUseCase sendMessageUseCase;

  @override
  ChatState build() {
    getChatHistoryUseCase = locator<GetChatHistoryUseCase>();
    sendMessageUseCase = locator<SendMessageUseCase>();
    return ChatState(
      chatHistoryStatus: ChatStatus.initial,
      sendMessageStatus: ChatStatus.initial,
    );
  }

  /// Clears in-memory messages (solo ride ended, carpool switch, or new ride id).
  void clearConversation() {
    state = ChatState(
      chatHistoryStatus: ChatStatus.initial,
      sendMessageStatus: ChatStatus.initial,
      chats: const [],
      message: '',
      showBadge: false,
    );
  }


  Future<void> getChatHistory(String rideId) async {
    final String trimmed = rideId.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        chatHistoryStatus: ChatStatus.error,
        message: 'Missing ride id for chat history',
        chats: const [],
      );
      return;
    }

    // Never clear [chats] here: socket `chat:receive` can append while this HTTP
    // request is in flight; wiping would drop rows the user already saw.
    state = state.copyWith(chatHistoryStatus: ChatStatus.loading);

    final result = await getChatHistoryUseCase.call(trimmed);

    result.fold(
      (failure) {
        state = state.copyWith(
          chatHistoryStatus: ChatStatus.error,
          message: failure.message,
        );
      },
      (List<ChatMessageEntity> response) {
        // Socket can deliver messages while this HTTP call is in flight.
        // Replacing [chats] with [response] alone drops those real-time rows.
        final List<ChatMessageEntity> merged = _mergeChatMessagesUnion(
          server: response,
          also: state.chats,
        );
        state = state.copyWith(
          chatHistoryStatus: ChatStatus.success,
          chats: merged,
        );
      },
    );
  }

  void appendIncomingMessage(ChatMessageEntity message) {
    final String key = chatMessageDedupeKey(message);
    if (state.chats.any((ChatMessageEntity m) {
      return chatMessageDedupeKey(m) == key ||
          chatMessagesLikelyDuplicate(m, message);
    })) {
      // Prefer higher delivery status when the same row arrives again.
      final List<ChatMessageEntity> upgraded = state.chats.map((m) {
        final bool same =
            chatMessageDedupeKey(m) == key ||
            chatMessagesLikelyDuplicate(m, message);
        if (!same) return m;
        final MessageDeliveryStatus next = MessageDeliveryStatus.upgrade(
          m.status,
          message.status,
        );
        return next == m.status ? m : m.copyWith(status: next);
      }).toList();
      state = state.copyWith(chats: upgraded);
      return;
    }
    state = state.copyWith(
      chats: <ChatMessageEntity>[...state.chats, message],
      // [ChatScreen] only renders the list in [ChatStatus.success]; keep loading
      // for an empty list, but once socket rows exist we must show them.
      chatHistoryStatus: ChatStatus.success,
    );
  }

  /// Applies `chat:status_updated` to outgoing rows in this conversation.
  void applyStatusUpdate(ChatStatusUpdate update) {
    final String conv = update.conversationId.trim().toLowerCase();
    if (conv.isEmpty) return;

    final String? msgId = update.messageId?.trim().toLowerCase();
    final String? updatedBy = update.updatedBy?.trim().toLowerCase();
    bool changed = false;

    final List<ChatMessageEntity> nextChats = state.chats.map((m) {
      if (m.conversationId.trim().toLowerCase() != conv) return m;

      if (msgId != null &&
          msgId.isNotEmpty &&
          m.id.trim().toLowerCase() != msgId) {
        return m;
      }

      // `updatedBy` is the reader/receiver — do not change their own outbound lines.
      if (updatedBy != null &&
          updatedBy.isNotEmpty &&
          m.sender.id.trim().toLowerCase() == updatedBy) {
        return m;
      }

      final MessageDeliveryStatus next = MessageDeliveryStatus.upgrade(
        m.status,
        update.status,
      );
      if (next == m.status) return m;
      changed = true;
      return m.copyWith(status: next);
    }).toList();

    if (changed) {
      state = state.copyWith(chats: nextChats);
    }
  }

  Future<void> sendMessage(SendMessageParams params) async {
    state = state.copyWith(sendMessageStatus: ChatStatus.loading);

    final result = await sendMessageUseCase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          sendMessageStatus: ChatStatus.error,
          message: failure.message,
        );
      },
      (response) {
        if(response == false) return state;
        state = state.copyWith(sendMessageStatus: ChatStatus.success);
      },
    );
  }
}

/// Prefer server ordering for duplicates; keep socket-only messages not in API yet.
List<ChatMessageEntity> _mergeChatMessagesUnion({
  required List<ChatMessageEntity> server,
  required List<ChatMessageEntity> also,
}) {
  final Map<String, ChatMessageEntity> byKey = {
    for (final ChatMessageEntity m in server) chatMessageDedupeKey(m): m,
  };
  for (final ChatMessageEntity m in also) {
    final String k = chatMessageDedupeKey(m);
    final ChatMessageEntity? existingByKey = byKey[k];
    if (existingByKey != null) {
      final MessageDeliveryStatus next = MessageDeliveryStatus.upgrade(
        existingByKey.status,
        m.status,
      );
      if (next != existingByKey.status) {
        byKey[k] = existingByKey.copyWith(status: next);
      }
      continue;
    }
    var isDup = false;
    for (final ChatMessageEntity existing in byKey.values) {
      if (chatMessagesLikelyDuplicate(existing, m)) {
        isDup = true;
        final MessageDeliveryStatus next = MessageDeliveryStatus.upgrade(
          existing.status,
          m.status,
        );
        if (next != existing.status) {
          byKey[chatMessageDedupeKey(existing)] = existing.copyWith(
            status: next,
          );
        }
        break;
      }
    }
    if (isDup) {
      continue;
    }
    byKey[k] = m;
  }
  final List<ChatMessageEntity> out = byKey.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return out;
}
