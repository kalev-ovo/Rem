import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/conversation.dart';
import '../../models/message.dart';

class AppDatabase {
  static Database? _instance;

  static Future<Database> get instance async {
    if (_instance != null) return _instance!;
    _instance = await _initDatabase();
    return _instance!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chatyui.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE conversations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL DEFAULT '新对话',
            pinned INTEGER NOT NULL DEFAULT 0,
            avatar_path TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversation_id INTEGER NOT NULL,
            role TEXT NOT NULL,
            content TEXT NOT NULL DEFAULT '',
            image_paths TEXT,
            created_at INTEGER NOT NULL,
            FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE user_facts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT NOT NULL DEFAULT '通用',
            content TEXT NOT NULL,
            source TEXT NOT NULL DEFAULT '',
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        await db.execute(
            'CREATE INDEX idx_messages_conversation ON messages(conversation_id)');
        await db.execute(
            'CREATE INDEX idx_conversations_updated ON conversations(updated_at DESC)');
        await db.execute(
            'CREATE INDEX idx_user_facts_category ON user_facts(category)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE user_facts (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              category TEXT NOT NULL DEFAULT '通用',
              content TEXT NOT NULL,
              source TEXT NOT NULL DEFAULT '',
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
          await db.execute(
              'CREATE INDEX idx_user_facts_category ON user_facts(category)');
        }
        if (oldVersion < 3) {
          await db.execute(
              'ALTER TABLE conversations ADD COLUMN pinned INTEGER NOT NULL DEFAULT 0');
        }
        if (oldVersion < 4) {
          await db.execute(
              'ALTER TABLE conversations ADD COLUMN avatar_path TEXT');
        }
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ─── Conversation CRUD ───

  static Future<Conversation> createConversation({String title = '新对话', String? avatarPath}) async {
    final db = await instance;
    final now = DateTime.now();
    final id = await db.insert('conversations', {
      'title': title,
      'avatar_path': avatarPath,
      'created_at': now.millisecondsSinceEpoch,
      'updated_at': now.millisecondsSinceEpoch,
    });
    return Conversation(
      id: id,
      title: title,
      createdAt: now,
      updatedAt: now,
    );
  }

  static Future<List<Conversation>> getConversations() async {
    final db = await instance;
    final maps = await db.query(
      'conversations',
      orderBy: 'pinned DESC, updated_at DESC',
    );
    return maps.map((m) => Conversation.fromMap(m)).toList();
  }

  static Future<Conversation?> getConversation(int id) async {
    final db = await instance;
    final maps = await db.query('conversations', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Conversation.fromMap(maps.first);
  }

  static Future<void> updateConversationTitle(int id, String title) async {
    final db = await instance;
    await db.update(
      'conversations',
      {'title': title, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteConversation(int id) async {
    final db = await instance;
    await db.delete('messages', where: 'conversation_id = ?', whereArgs: [id]);
    await db.delete('conversations', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> togglePinConversation(int id, bool pinned) async {
    final db = await instance;
    await db.update('conversations', {'pinned': pinned ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Conversation>> searchConversations(String keyword) async {
    final db = await instance;
    final like = '%$keyword%';
    final maps = await db.rawQuery('''
      SELECT DISTINCT c.* FROM conversations c
      LEFT JOIN messages m ON c.id = m.conversation_id
      WHERE c.title LIKE ? OR m.content LIKE ?
      ORDER BY c.pinned DESC, c.updated_at DESC
    ''', [like, like]);
    return maps.map((m) => Conversation.fromMap(m)).toList();
  }

  // ─── Message CRUD ───

  static Future<Message> insertMessage(Message message) async {
    final db = await instance;
    final id = await db.insert('messages', message.toMap());
    // 更新会话时间
    await db.update(
      'conversations',
      {'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [message.conversationId],
    );
    return message.copyWith(id: id);
  }

  static Future<List<Message>> getMessages(int conversationId) async {
    final db = await instance;
    final maps = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
    );
    return maps.map((m) => Message.fromMap(m)).toList();
  }

  static Future<Message?> getLastMessage(int conversationId) async {
    final db = await instance;
    final maps = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Message.fromMap(maps.first);
  }

  // ─── User Facts (用户画像) ───

  static Future<int> insertUserFact({
    required String content,
    String category = '通用',
    String source = '',
  }) async {
    final db = await instance;
    final now = DateTime.now().millisecondsSinceEpoch;
    return db.insert('user_facts', {
      'category': category,
      'content': content,
      'source': source,
      'created_at': now,
      'updated_at': now,
    });
  }

  static Future<List<Map<String, dynamic>>> getAllUserFacts() async {
    final db = await instance;
    return db.query('user_facts', orderBy: 'updated_at DESC', limit: 100);
  }

  static Future<void> deleteUserFact(int id) async {
    final db = await instance;
    await db.delete('user_facts', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearAllUserFacts() async {
    final db = await instance;
    await db.delete('user_facts');
  }

  // ─── 统计 ───

  static Future<int> getTotalConversations() async {
    final db = await instance;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM conversations');
    return result.first['c'] as int? ?? 0;
  }

  static Future<int> getTotalMessages() async {
    final db = await instance;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM messages');
    return result.first['c'] as int? ?? 0;
  }

  static Future<int> getTotalUserFacts() async {
    final db = await instance;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM user_facts');
    return result.first['c'] as int? ?? 0;
  }
}
