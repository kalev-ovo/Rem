import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/api/image_assets.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/app_drawer.dart';
import '../widgets/sakura_particles.dart';
import '../widgets/search_delegate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/db/database.dart';
import '../../models/message.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Map<int, Message?> _lastMessages = {};

  @override
  void initState() {
    super.initState();
    _loadLastMessages();
  }

  Future<void> _loadLastMessages() async {
    final conversations = ref.read(conversationProvider).conversations;
    for (final conv in conversations) {
      if (conv.id != null) {
        final msg = await AppDatabase.getLastMessage(conv.id!);
        if (mounted) {
          setState(() => _lastMessages[conv.id!] = msg);
        }
      }
    }
  }

  Future<void> _createAndEnter() async {
    final notifier = ref.read(conversationProvider.notifier);
    final conv = await notifier.create();
    if (conv?.id != null && mounted) {
      context.push('/chat/${conv!.id}');
      _loadLastMessages();
    }
  }

  Future<void> _togglePin(int convId, bool pinned) async {
    await AppDatabase.togglePinConversation(convId, pinned);
    ref.read(conversationProvider.notifier).load();
  }

  Future<void> _exportConversation(int convId) async {
    final msgs = await AppDatabase.getMessages(convId);
    final conv = await AppDatabase.getConversation(convId);
    if (msgs.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln('💬 ${conv?.title ?? "对话"}\n');
    for (final m in msgs) {
      final name = m.role == MessageRole.user ? '你' : '雷姆';
      final date = '${m.createdAt.month}/${m.createdAt.day} '
          '${m.createdAt.hour.toString().padLeft(2, '0')}:'
          '${m.createdAt.minute.toString().padLeft(2, '0')}';
      buffer.writeln('$name ($date):');
      buffer.writeln(m.content);
      buffer.writeln();
    }

    await Share.share(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationProvider);

    return Scaffold(
      drawer: AppDrawer(
        onToggleTheme: () => ref.read(themeProvider.notifier).toggle(),
        onClearMemories: () {
          AppDatabase.clearAllUserFacts();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('记忆已清除'), duration: Duration(seconds: 1)),
          );
        },
      ),
      appBar: AppBar(
        title: const Text('Rem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: ChatSearchDelegate(
                onTap: (convId) => context.push('/chat/$convId'),
              ),
            ),
            tooltip: '搜索',
          ),
        ],
      ),
      body: SakuraParticles(
        child: state.conversations.isEmpty
            ? _EmptyState(onStart: _createAndEnter)
            : RefreshIndicator(
                onRefresh: () async {
                  await ref.read(conversationProvider.notifier).load();
                  await _loadLastMessages();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: state.conversations.length,
                  itemBuilder: (context, index) {
                    final conv = state.conversations[index];
                    return ConversationTile(
                      conversation: conv,
                      lastMessage: _lastMessages[conv.id],
                      onTap: () async {
                        await context.push('/chat/${conv.id}');
                        ref.read(conversationProvider.notifier).load();
                        _loadLastMessages();
                      },
                      onDelete: () {
                        ref
                            .read(conversationProvider.notifier)
                            .delete(conv.id!);
                      },
                      onTogglePin: () =>
                          _togglePin(conv.id!, !conv.pinned),
                      onExport: () => _exportConversation(conv.id!),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createAndEnter,
        icon: const Icon(Icons.add),
        label: const Text('新对话'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onStart;
  const _EmptyState({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 欢迎图卡片
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: RemTheme.iceBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  ImageAssets.randomWelcome ?? 'assets/images/welcome_bg.jpeg',
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [RemTheme.iceBlue, RemTheme.lightBlue],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.favorite, size: 60, color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              '你好呀',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 8),
            Text(
              '雷姆在等你开口呢~',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 180,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                label: const Text('开始聊天', style: TextStyle(fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RemTheme.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
