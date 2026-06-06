import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/conversation.dart';
import '../../models/message.dart';

/// 对话列表项
class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final Message? lastMessage;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onTogglePin;
  final VoidCallback? onExport;

  const ConversationTile({
    super.key,
    required this.conversation,
    this.lastMessage,
    required this.onTap,
    required this.onDelete,
    this.onTogglePin,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final preview = lastMessage?.content ?? '还没有消息呢...';
    final isUser = lastMessage?.role == MessageRole.user;

    return Dismissible(
      key: Key('conv_${conversation.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.withValues(alpha: 0.3),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('删除对话'),
            content: const Text('确定要删除这个对话吗？消息记录无法恢复哦。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child:
                    const Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: ClipOval(
              child: Image.asset(
                conversation.avatarPath ?? 'assets/images/app_icon.jpeg',
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const CircleAvatar(
                  radius: 22,
                  backgroundColor: RemTheme.iceBlue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
            title: Row(
              children: [
                if (conversation.pinned)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.push_pin, size: 14, color: RemTheme.pink),
                  ),
                Expanded(
                  child: Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              isUser ? '你: $preview' : '雷姆: $preview',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            trailing: Text(
              _formatDate(conversation.updatedAt),
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                conversation.pinned
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
              ),
              title: Text(conversation.pinned ? '取消置顶' : '置顶'),
              onTap: () {
                Navigator.pop(ctx);
                onTogglePin?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text('导出对话'),
              onTap: () {
                Navigator.pop(ctx);
                onExport?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${date.month}/${date.day}';
  }
}
