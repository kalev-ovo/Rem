import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../repositories/chat_repository.dart';

/// 对话列表状态
class ConversationState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;

  const ConversationState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  final ChatRepository _repo;

  ConversationNotifier(this._repo)
      : super(const ConversationState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final conversations = await _repo.getConversations();
      state = state.copyWith(
        conversations: conversations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<Conversation?> create() async {
    try {
      final conv = await _repo.createConversation();
      await load();
      return conv;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteConversation(id);
      await load();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  final repo = ChatRepository();
  return ConversationNotifier(repo);
});
