import 'dart:convert';

enum MessageRole { user, assistant, system }

class Message {
  final int? id;
  final int conversationId;
  final MessageRole role;
  final String content;
  final List<String>? imagePaths;
  final DateTime createdAt;

  const Message({
    this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.imagePaths,
    required this.createdAt,
  });

  Message copyWith({
    int? id,
    int? conversationId,
    MessageRole? role,
    String? content,
    List<String>? imagePaths,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'conversation_id': conversationId,
      'role': role.name,
      'content': content,
      'image_paths': imagePaths != null ? jsonEncode(imagePaths) : null,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    final pathsStr = map['image_paths'] as String?;
    return Message(
      id: map['id'] as int?,
      conversationId: map['conversation_id'] as int,
      role: MessageRole.values.byName(map['role'] as String),
      content: map['content'] as String? ?? '',
      imagePaths: pathsStr != null && pathsStr.isNotEmpty
          ? (jsonDecode(pathsStr) as List).cast<String>()
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// 转换为发送给 API 的消息格式
  Map<String, dynamic> toApiMessage() {
    if (imagePaths != null && imagePaths!.isNotEmpty) {
      return {
        'role': role == MessageRole.assistant ? 'assistant' : 'user',
        'content': [
          {'type': 'text', 'text': content},
          ...imagePaths!.map((path) => {
                'type': 'image_url',
                'image_url': {'url': path},
              }),
        ],
      };
    }
    return {
      'role': role == MessageRole.assistant
          ? 'assistant'
          : role == MessageRole.system
              ? 'system'
              : 'user',
      'content': content,
    };
  }
}
