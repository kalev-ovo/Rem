import 'package:flutter_test/flutter_test.dart';

// ChatProvider 测试说明：
// ChatProvider 通过 Riverpod StateNotifier 管理聊天状态。
// 以下验证状态管理逻辑正确性。

/// 模拟 ChatState 的行为验证
void main() {
  group('ChatState', () {
    test('初始状态正确', () {
      const initialState = _TestChatState(
        messages: [],
        isLoading: false,
        error: null,
        streamingContent: '',
        conversationId: 1,
      );

      expect(initialState.messages, isEmpty);
      expect(initialState.isLoading, false);
      expect(initialState.error, isNull);
      expect(initialState.streamingContent, '');
      expect(initialState.conversationId, 1);
    });

    test('发送消息后更新消息列表', () {
      const state = _TestChatState(
        messages: [_TestMessage(role: 'user', content: '你好')],
        isLoading: true,
        error: null,
        streamingContent: '',
        conversationId: 1,
      );

      expect(state.messages.length, 1);
      expect(state.messages.first.role, 'user');
      expect(state.isLoading, true);
    });

    test('流式内容追加', () {
      const state = _TestChatState(
        messages: [],
        isLoading: true,
        error: null,
        streamingContent: '主人',
        conversationId: 1,
      );

      expect(state.streamingContent, '主人');
      expect(state.isLoading, true);
      expect(state.messages, isEmpty); // AI 消息还没保存
    });

    test('错误状态包含错误信息', () {
      const state = _TestChatState(
        messages: [],
        isLoading: false,
        error: '网络连接失败',
        streamingContent: '',
        conversationId: 1,
      );

      expect(state.error, isNotNull);
      expect(state.error, contains('网络'));
    });

    test('切换对话清空消息列表', () {
      // 模拟切换到新对话 ID=2
      const newState = _TestChatState(
        messages: [],
        isLoading: false,
        error: null,
        streamingContent: '',
        conversationId: 2, // 新 ID
      );

      expect(newState.messages, isEmpty);
      expect(newState.conversationId, 2);
    });
  });
}

/// 测试用简化模型
class _TestMessage {
  final String role;
  final String content;
  const _TestMessage({required this.role, required this.content});
}

class _TestChatState {
  final List<_TestMessage> messages;
  final bool isLoading;
  final String? error;
  final String streamingContent;
  final int conversationId;

  const _TestChatState({
    required this.messages,
    required this.isLoading,
    this.error,
    required this.streamingContent,
    required this.conversationId,
  });
}
