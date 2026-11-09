import 'package:driver_app/features/ride_room/domain/entities/chat_entity.dart';

enum ChatStatus { initial, loading, success, error }

class ChatState {
  final ChatStatus chatHistoryStatus;
  final ChatStatus sendMessageStatus;
  final List<ChatMessageEntity> chats;
  final String message;
  final bool showBadge; // NEW

  ChatState({
    this.chatHistoryStatus = ChatStatus.initial,
    this.sendMessageStatus = ChatStatus.initial,
    this.chats = const [],
    this.message = '',
    this.showBadge = false, // default false
  });

  ChatState copyWith({
    ChatStatus? chatHistoryStatus,
    ChatStatus? sendMessageStatus,
    List<ChatMessageEntity>? chats,
    String? message,
    bool? showBadge, // NEW
  }) {
    return ChatState(
      chatHistoryStatus: chatHistoryStatus ?? this.chatHistoryStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      chats: chats ?? this.chats,
      message: message ?? this.message,
      showBadge: showBadge ?? this.showBadge, // NEW
    );
  }
}