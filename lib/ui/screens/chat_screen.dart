import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';
import '../../models/message.dart';
import '../../core/api/image_assets.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/sakura_particles.dart';
import '../../core/theme/app_theme.dart';

/// 聊天页面（微信式：从上往下，带时间分隔）
class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final show =
        max > 0 && _scrollController.position.pixels < max - 200;
    if (show != _showScrollToBottom) {
      setState(() => _showScrollToBottom = show);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final max = _scrollController.position.maxScrollExtent;
        if (_scrollController.position.pixels >= max - 300) {
          _scrollController.jumpTo(max);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider(widget.conversationId));
    final notifier =
        ref.read(chatProvider(widget.conversationId).notifier);

    ref.listen(chatProvider(widget.conversationId), (prev, next) {
      _autoScroll();
    });

    // 构建消息+时间分隔的扁平列表
    final items = _buildItems(state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('雷姆'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: SakuraParticles(
        count: 12,
        child: Column(
          children: [
            Expanded(
              child: state.messages.isEmpty && !state.isLoading
                  ? const _WelcomeMessage()
                  : GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding:
                            const EdgeInsets.only(top: 12, bottom: 4),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          if (item is _TimeItem) {
                            return _TimeSeparator(text: item.text);
                          }
                          if (item is Message) {
                            return ChatBubble(message: item);
                          }
                          if (item is _StreamingItem) {
                            return _StreamingBubble(
                                content: item.content);
                          }
                          if (item is _LoadingItem) {
                            return const TypingIndicator();
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
            ),
            if (state.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                color: Colors.orange.shade50,
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(state.error!,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700)),
                    ),
                    GestureDetector(
                      onTap: () => notifier.clearError(),
                      child: Icon(Icons.close,
                          size: 16, color: Colors.orange.shade700),
                    ),
                  ],
                ),
              ),
            MessageInput(
              enabled: !state.isLoading,
              onSend: (text, images) async {
                await notifier.sendMessage(
                    text: text, imagePaths: images);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: _showScrollToBottom
          ? FloatingActionButton.small(
              onPressed: _scrollToBottom,
              child: const Icon(Icons.keyboard_arrow_down),
            )
          : null,
    );
  }

  List<Object> _buildItems(ChatState state) {
    final items = <Object>[];

    for (int i = 0; i < state.messages.length; i++) {
      // 当前消息与前一条消息间隔 > 5 分钟则插入时间分隔
      if (i == 0 ||
          state.messages[i]
                  .createdAt
                  .difference(state.messages[i - 1].createdAt)
                  .inMinutes >=
              5) {
        items.add(_TimeItem(
            text: _formatTime(state.messages[i].createdAt)));
      }
      items.add(state.messages[i]);
    }

    // 流式内容 / 加载指示器
    if (state.streamingContent.isNotEmpty) {
      items.add(_StreamingItem(content: state.streamingContent));
    } else if (state.isLoading) {
      items.add(const _LoadingItem());
    }

    return items;
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(dt.year, dt.month, dt.day);

    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '上午' : (hour < 13 ? '中午' : '下午');
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    final timeStr = '$period $displayHour:$minute';

    if (msgDay == today) {
      return timeStr;
    } else if (msgDay == yesterday) {
      return '昨天 $timeStr';
    } else if (dt.year == now.year) {
      return '${dt.month}月${dt.day}日 $timeStr';
    } else {
      return '${dt.year}年${dt.month}月${dt.day}日 $timeStr';
    }
  }
}

/// 时间分隔标记
class _TimeItem {
  final String text;
  const _TimeItem({required this.text});
}

class _StreamingItem {
  final String content;
  const _StreamingItem({required this.content});
}

class _LoadingItem {
  const _LoadingItem();
}

/// 时间分隔 UI
class _TimeSeparator extends StatelessWidget {
  final String text;
  const _TimeSeparator({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFD6E0E8),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// 欢迎消息
class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: RemTheme.iceBlue.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                ImageAssets.randomWelcome ?? 'assets/images/welcome_bg.jpeg',
                width: 180,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [RemTheme.iceBlue, RemTheme.lightBlue],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.favorite, size: 50, color: Colors.white70),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '欢迎回来',
            style: TextStyle(fontSize: 20, color: Color(0xFF333333), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            '和雷姆聊聊天吧~',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

/// 流式内容气泡
class _StreamingBubble extends StatelessWidget {
  final String content;
  const _StreamingBubble({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ClipOval(
              child: Image.asset(
                'assets/images/app_icon.jpeg',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFD6EEF5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                content,
                style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF333333)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
