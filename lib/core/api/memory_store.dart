import '../db/database.dart';
import '../../models/message.dart';
import 'agnes_client.dart';

/// 用户画像 + 跨对话记忆系统
class MemoryStore {
  static final _profileClient = AgnesClient();

  /// 关键词初筛（本地，零延迟）
  static Future<void> extractFacts(Message userMsg) async {
    await _profileClient.init();
    final text = userMsg.content;
    if (text.length < 4) return;

    String? cat;
    if (_hasKeywords(text, ['喜欢', '爱', '最爱', '想', '想要', '希望', '讨厌', '不喜欢', '烦'])) cat = '偏好';
    if (_hasKeywords(text, ['我是', '我叫', '我姓', '我的名字', '我今年', '我住在', '我在', '我的工作是', '我的职业', '我的专业', '我是做'])) cat = '身份';
    if (_hasKeywords(text, ['我以前', '我过去', '我小时候', '我曾经', '我有过', '我记得', '我去过', '我见过'])) cat = '经历';
    if (_hasKeywords(text, ['我妈妈', '我爸爸', '我女朋友', '我男朋友', '我对象', '我老婆', '我老公', '我女儿', '我儿子', '我朋友', '我同学', '我同事', '我老板', '我老师', '我家'])) cat = '人际关系';
    if (_hasKeywords(text, ['我打算', '我计划', '我要去', '我准备', '我明天', '我下周', '我下个月', '我以后', '我将来'])) cat = '计划';
    if (_hasKeywords(text, ['我每天', '我经常', '我总是', '我习惯', '我一直', '我从不', '我很少', '我偶尔', '我一般', '我通常'])) cat = '习惯';
    if (_hasKeywords(text, ['玩', '看', '追', '打', '听', '音乐', '游戏', '动漫', '电影', '书', '运动', '健身', '跑步', '篮球', '足球', '画画', '拍照'])) cat = '兴趣爱好';
    if (cat == null) return;

    final short = text.length > 60 ? '${text.substring(0, 60)}...' : text;
    await AppDatabase.insertUserFact(
      content: short, category: cat, source: 'conv_${userMsg.conversationId}',
    );
  }

  /// AI 提炼（对话结束后异步跑，不阻塞 UI）
  static Future<void> aiExtract(int conversationId) async {
    try {
      await _profileClient.init();
      final msgs = await AppDatabase.getMessages(conversationId);
      if (msgs.length < 2) return;

      // 取最近 10 轮对话
      final history = msgs
          .where((m) => m.role != MessageRole.system)
          .toList();
      if (history.length < 2) return;
      final recent = history.length > 20 ? history.sublist(history.length - 20) : history;

      final dialog = recent.map((m) {
        final role = m.role == MessageRole.user ? '主人' : '雷姆';
        return '$role: ${m.content}';
      }).join('\n');

      final prompt = '''分析以下对话，提取关于**主人（用户）**的关键信息。
输出格式：每行一条，格式为 "类别:内容"。最多 5 条，不要编造。
类别只能从以下选：偏好、身份、经历、人际关系、计划、习惯、兴趣爱好、其他。

只输出提取的信息，不要解释。

对话：
$dialog''';

      final result = await _profileClient.dio.post('/chat/completions', data: {
        'model': 'agnes-2.0-flash',
        'messages': [{'role': 'user', 'content': prompt}],
        'max_tokens': 500,
        'temperature': 0.3,
      });

      final text = result.data['choices'][0]['message']['content'] as String;
      for (final line in text.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || !trimmed.contains(':')) continue;
        final parts = trimmed.split(':');
        if (parts.length < 2) continue;
        final cat = parts[0].trim();
        final val = parts.sublist(1).join(':').trim();
        if (val.length < 2) continue;
        await AppDatabase.insertUserFact(
          content: val, category: cat, source: 'ai_conv_$conversationId',
        );
      }
    } catch (_) {
      // 静默失败，不影响聊天
    }
  }

  /// 获取完整用户画像
  static Future<String> getUserProfile() async {
    final facts = await AppDatabase.getAllUserFacts();
    if (facts.isEmpty) return '';

    final grouped = <String, List<String>>{};
    for (final f in facts) {
      final cat = f['category'] as String? ?? '通用';
      final content = f['content'] as String? ?? '';
      if (content.isEmpty) continue;
      grouped.putIfAbsent(cat, () => []);
      if (grouped[cat]!.length < 12) grouped[cat]!.add(content);
    }

    final buffer = StringBuffer();
    buffer.writeln();
    buffer.writeln('## 关于主人的重要信息（请记住并在合适时自然提及）：');
    for (final entry in grouped.entries) {
      buffer.writeln('【${entry.key}】');
      for (final fact in entry.value.toSet().take(8)) {
        buffer.writeln('- $fact');
      }
    }
    buffer.writeln();
    buffer.writeln('请在对话中自然地展现你记住了这些信息。当主人提到相关话题时，可以自然地联系之前的信息。不要刻意罗列或背诵这些内容。');
    return buffer.toString();
  }

  static bool _hasKeywords(String text, List<String> keywords) =>
      keywords.any((kw) => text.contains(kw));
}
