import 'package:flutter/material.dart';
import '../../core/db/database.dart';
import '../../core/theme/app_theme.dart';

/// 对话搜索
class ChatSearchDelegate extends SearchDelegate<String> {
  final void Function(int convId) onTap;

  ChatSearchDelegate({required this.onTap}) : super(
    searchFieldLabel: '搜索对话...',
  );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    if (query.isEmpty) return const SizedBox.shrink();
    return FutureBuilder(
      future: AppDatabase.searchConversations(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data!;
        if (results.isEmpty) {
          return const Center(
            child: Text('没找到相关对话', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final conv = results[index];
            return ListTile(
              leading: ClipOval(
                child: Image.asset(
                  'assets/images/app_icon.jpeg',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(conv.title),
              subtitle: Text(
                _formatDate(conv.updatedAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                close(context, '');
                onTap(conv.id!);
              },
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    return '${date.month}/${date.day}';
  }
}
