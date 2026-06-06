class Conversation {
  final int? id;
  final String title;
  final bool pinned;
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    this.id,
    required this.title,
    this.pinned = false,
    this.avatarPath,
    required this.createdAt,
    required this.updatedAt,
  });

  Conversation copyWith({
    int? id,
    String? title,
    bool? pinned,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      pinned: pinned ?? this.pinned,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'pinned': pinned ? 1 : 0,
      'avatar_path': avatarPath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '新对话',
      pinned: (map['pinned'] as int? ?? 0) == 1,
      avatarPath: map['avatar_path'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
