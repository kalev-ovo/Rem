import 'dart:convert';
import 'dart:io';
import '../core/api/agnes_client.dart';
import '../core/api/api_settings.dart';
import '../core/api/image_assets.dart';
import '../core/api/rem_knowledge.dart';
import '../core/api/memory_store.dart';
import '../core/api/user_settings.dart';
import '../core/db/database.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ChatRepository {
  final AgnesClient _client;

  ChatRepository({AgnesClient? client}) : _client = client ?? AgnesClient();

  /// 发送消息并获取流式回复
  Stream<String> sendMessageStream({
    required int conversationId,
    required String text,
    List<String>? imagePaths,
  }) async* {
    // 0. 确保 client 已从 SharedPreferences 加载配置
    await _client.init();

    // 1. 保存用户消息并提取画像
    final savedMsg = await AppDatabase.insertMessage(Message(
      conversationId: conversationId,
      role: MessageRole.user,
      content: text,
      imagePaths: imagePaths,
      createdAt: DateTime.now(),
    ));
    // 后台提取用户画像（轻量关键词匹配，不影响速度）
    MemoryStore.extractFacts(savedMsg);

    // 2. 构建上下文
    final history = await AppDatabase.getMessages(conversationId);

    // 将本地图片转为 base64 data URI
    final processedMessages = <Map<String, dynamic>>[];
    for (final msg in history) {
      processedMessages.add(await _processMessageImages(msg));
    }

    // 3. 流式请求（动态注入用户画像）
    final profile = await MemoryStore.getUserProfile();
    final basePrompt = await buildSystemPrompt();
    final fullPrompt = [
      basePrompt,
      if (profile.isNotEmpty) profile,
    ].join('\n\n');

    final buffer = StringBuffer();
    try {
      await for (final token in _client.streamChat(
        messages: processedMessages,
        systemPrompt: fullPrompt,
        model: await ApiSettings.getModel(),
      )) {
        buffer.write(token);
        yield token;
      }
    } catch (e) {
      if (buffer.isEmpty) rethrow;
    }

    // 4. 保存 AI 回复
    if (buffer.isNotEmpty) {
      await AppDatabase.insertMessage(Message(
        conversationId: conversationId,
        role: MessageRole.assistant,
        content: buffer.toString(),
        createdAt: DateTime.now(),
      ));

      // 后台 AI 提炼画像（不 await，静默运行）
      MemoryStore.aiExtract(conversationId);
    }

    // 5. 自动生成标题（仅首次）
    final conversation = await AppDatabase.getConversation(conversationId);
    if (conversation != null && conversation.title == '新对话') {
      try {
        final title = await _client.generateTitle(text);
        await AppDatabase.updateConversationTitle(conversationId, title);
      } catch (_) {}
    }
  }

  /// 处理消息中的图片路径，转 base64
  Future<Map<String, dynamic>> _processMessageImages(Message msg) async {
    final apiMsg = msg.toApiMessage();
    if (msg.imagePaths != null && msg.imagePaths!.isNotEmpty) {
      final content = apiMsg['content'] as List;
      final processed = <Map<String, dynamic>>[];
      for (final item in content) {
        if (item['type'] == 'image_url') {
          final url = item['image_url']['url'] as String;
          // 如果是本地文件路径，转为 base64 data URI
          if (!url.startsWith('http') && !url.startsWith('data:')) {
            final file = File(url);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              final base64 = base64Encode(bytes);
              final ext = url.split('.').last;
              processed.add({
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/$ext;base64,$base64',
                },
              });
              continue;
            }
          }
        }
        processed.add(item);
      }
      apiMsg['content'] = processed;
    }
    return apiMsg;
  }

  /// 加载对话消息
  Future<List<Message>> loadMessages(int conversationId) async {
    return AppDatabase.getMessages(conversationId);
  }

  /// 新建对话（随机头像）
  Future<Conversation> createConversation() async {
    return AppDatabase.createConversation(
      avatarPath: ImageAssets.randomAvatar ?? 'assets/images/app_icon.jpeg',
    );
  }

  /// 获取所有对话
  Future<List<Conversation>> getConversations() async {
    return AppDatabase.getConversations();
  }

  /// 删除对话
  Future<void> deleteConversation(int id) async {
    await AppDatabase.deleteConversation(id);
  }

  static String get systemPrompt => RemKnowledge.systemPrompt;

  /// 注入用户昵称后的完整提示词
  static Future<String> buildSystemPrompt() async {
    final nickname = await UserSettings.getNickname();
    return systemPrompt.replaceAll('{nickname}', nickname);
  }
}
