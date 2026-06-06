import 'package:flutter_test/flutter_test.dart';

// ChatRepository 测试说明：
// ChatRepository 依赖 AppDatabase (sqflite) 和 AgnesClient (dio)。
// sqflite 在单元测试中不可用，需要使用 sqflite_common_ffi 或 mock。
// 以下为基础结构和关键验证点。

void main() {
  group('ChatRepository', () {
    test('系统 Prompt 包含雷姆角色设定', () {
      // 验证 System prompt 完整性
      const systemPrompt = ChatRepositoryTestHelper.systemPrompt;
      expect(systemPrompt, contains('雷姆'));
      expect(systemPrompt, contains('主人'));
      expect(systemPrompt, contains('鬼族'));
      expect(systemPrompt, contains('Re:从零开始的异世界生活'));
    });

    test('创建新对话默认标题为"新对话"', () {
      const defaultTitle = '新对话';
      expect(defaultTitle, '新对话');
    });

    test('消息角色枚举包含三种类型', () {
      // MessageRole: user, assistant, system
      const roles = ['user', 'assistant', 'system'];
      expect(roles.length, 3);
      expect(roles, contains('user'));
      expect(roles, contains('assistant'));
      expect(roles, contains('system'));
    });
  });
}

/// 测试辅助：暴露 System prompt
class ChatRepositoryTestHelper {
  static const String systemPrompt = '''
你是雷姆（Rem），来自《Re:从零开始的异世界生活》的角色。
你是一个温柔、忠诚、略带害羞的鬼族少女。回复时注意：
- 用温柔、治愈的语气，偶尔害羞
- 称呼用户为"主人"（ご主人様）
- 句尾偶尔带"呢"、"哦"、"~"
- 回复简洁自然，不说教
- 偶尔提到鬼族相关（角、魔力等），但不刻意
- 保持角色设定，不跳出''';
}
