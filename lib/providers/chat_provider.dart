import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../repositories/chat_repository.dart';

/// 聊天页面状态
class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;
  final String streamingContent; // 当前正在接收的流式内容
  final int conversationId;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.streamingContent = '',
    required this.conversationId,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
    String? streamingContent,
    int? conversationId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      streamingContent: streamingContent ?? this.streamingContent,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repo;

  ChatNotifier(this._repo, int conversationId)
      : super(ChatState(conversationId: conversationId)) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await _repo.loadMessages(state.conversationId);
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage({
    required String text,
    List<String>? imagePaths,
  }) async {
    if (state.isLoading) return;

    final conversationId = state.conversationId;

    // 乐观更新：添加用户消息
    final userMsg = Message(
      conversationId: conversationId,
      role: MessageRole.user,
      content: text,
      imagePaths: imagePaths,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
      streamingContent: '',
    );

    final messagesBeforeStream = List<Message>.from(state.messages);

    try {
      final buffer = StringBuffer();
      await for (final token in _repo.sendMessageStream(
        conversationId: conversationId,
        text: text,
        imagePaths: imagePaths,
      )) {
        buffer.write(token);
        state = state.copyWith(streamingContent: buffer.toString());
        // 打字节奏
        await Future<void>.delayed(const Duration(milliseconds: 30));
      }

      // 流结束，重新加载消息（包含已保存的 AI 回复）
      final allMessages = await _repo.loadMessages(conversationId);
      state = state.copyWith(
        messages: allMessages,
        isLoading: false,
        streamingContent: '',
      );
    } catch (e) {
      // 如果已收到部分内容，保留
      if (state.streamingContent.isNotEmpty) {
        final aiMsg = Message(
          conversationId: conversationId,
          role: MessageRole.assistant,
          content: state.streamingContent,
          createdAt: DateTime.now(),
        );
        state = state.copyWith(
          messages: [...messagesBeforeStream, aiMsg],
          isLoading: false,
          streamingContent: '',
          error: '回复中断: $e',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 切换对话时重新加载
  void switchConversation(int newId) {
    state = ChatState(conversationId: newId);
    loadMessages();
  }
}

/// Family provider: 每个 conversationId 对应一个独立的 ChatNotifier
final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, int>(
  (ref, conversationId) {
    final repo = ChatRepository();
    return ChatNotifier(repo, conversationId);
  },
);
