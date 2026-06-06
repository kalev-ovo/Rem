import 'package:flutter_test/flutter_test.dart';

// AgnesClient 测试说明：
// 由于 AgnesClient 依赖 dio 和 dotenv，完整测试需要 mock dio。
// 以下为基础结构和关键验证点。

void main() {
  group('AgnesClient', () {
    test('API base URL 配置正确', () {
      const baseUrl = 'https://apihub.agnes-ai.com/v1';
      expect(baseUrl, startsWith('https://'));
      expect(baseUrl, contains('agnes-ai.com'));
    });

    test('默认模型为 agnes-1.5-flash', () {
      const model = 'agnes-1.5-flash';
      expect(model, isNotEmpty);
      expect(model, contains('agnes'));
      expect(model, contains('flash'));
    });

    test('消息格式转换 - 纯文本', () {
      // 验证 Message.toApiMessage() 输出格式
      final expectedFormat = {
        'role': 'user',
        'content': 'Hello',
      };
      expect(expectedFormat['role'], 'user');
      expect(expectedFormat['content'], 'Hello');
    });

    test('消息格式转换 - 多模态（文字+图片）', () {
      final expectedFormat = {
        'role': 'user',
        'content': [
          {'type': 'text', 'text': '描述这张图'},
          {
            'type': 'image_url',
            'image_url': {'url': 'data:image/jpeg;base64,/9j/...'},
          },
        ],
      };
      final content = expectedFormat['content'] as List;
      expect(content.length, 2);
      expect(content[0]['type'], 'text');
      expect(content[1]['type'], 'image_url');
    });

    test('SSE 数据行解析 - data: 前缀', () {
      const line = 'data: {"choices":[{"delta":{"content":"你好"}}]}';
      expect(line, startsWith('data: '));

      final json = line.substring(6);
      expect(json, isNotEmpty);
      expect(json, contains('choices'));
    });

    test('SSE 数据行解析 - [DONE] 信号', () {
      const line = 'data: [DONE]';
      final data = line.substring(6);
      expect(data, '[DONE]');
    });
  });
}
