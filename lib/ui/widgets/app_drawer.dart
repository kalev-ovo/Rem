import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/user_settings.dart';
import '../../core/db/database.dart';
import '../../core/theme/app_theme.dart';

/// 侧边栏抽屉
class AppDrawer extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onClearMemories;

  const AppDrawer({
    super.key,
    required this.onToggleTheme,
    required this.onClearMemories,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _nickname = UserSettings.defaultNickname;
  String? _avatarPath;
  int _convCount = 0;
  int _msgCount = 0;
  int _factCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      UserSettings.getNickname(),
      UserSettings.getAvatarPath(),
      AppDatabase.getTotalConversations(),
      AppDatabase.getTotalMessages(),
      AppDatabase.getTotalUserFacts(),
    ]);
    if (mounted) {
      setState(() {
        _nickname = results[0] as String;
        _avatarPath = results[1] as String?;
        _convCount = results[2] as int;
        _msgCount = results[3] as int;
        _factCount = results[4] as int;
      });
    }
  }

  Widget _avatar() {
    if (_avatarPath != null && File(_avatarPath!).existsSync()) {
      return ClipOval(
        child: Image.file(File(_avatarPath!), width: 56, height: 56, fit: BoxFit.cover),
      );
    }
    return ClipOval(
      child: Image.asset('assets/images/default_avatar.png', width: 56, height: 56, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // 用户区
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [RemTheme.iceBlue, RemTheme.lightBlue],
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                    child: _avatar(),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                    child: Text(
                      _nickname,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                    child: const Text(
                      '个人主页 ›',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            // 统计
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('对话', _convCount),
                  _stat('消息', _msgCount),
                  _stat('记忆', _factCount),
                ],
              ),
            ),
            const Divider(height: 1),
            // 菜单
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('主题切换'),
              onTap: () {
                Navigator.pop(context);
                widget.onToggleTheme();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('API 设置'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => const _ApiSettingsFromDrawer(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined, color: Colors.orange),
              title: const Text('清除所有记忆', style: TextStyle(color: Colors.orange)),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('清除所有记忆'),
                    content: const Text('确定要清除雷姆学到的所有关于你的信息吗？'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('清除', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (ok == true) {
                  widget.onClearMemories();
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Rem v1.0.0', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, int count) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}

// 从抽屉调 API 设置对话框（独立于首页）
class _ApiSettingsFromDrawer extends StatelessWidget {
  const _ApiSettingsFromDrawer();

  @override
  Widget build(BuildContext context) {
    // 复用 api_settings_dialog.dart 的内容
    return const _ApiSettingsContent();
  }
}

class _ApiSettingsContent extends StatefulWidget {
  const _ApiSettingsContent();

  @override
  State<_ApiSettingsContent> createState() => _ApiSettingsContentState();
}

class _ApiSettingsContentState extends State<_ApiSettingsContent> {
  final _keyCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  String _model = 'agnes-1.5-flash';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await SharedPreferences.getInstance();
    _keyCtrl.text = settings.getString('agnes_api_key') ?? '';
    _urlCtrl.text = settings.getString('agnes_base_url') ?? 'https://apihub.agnes-ai.com/v1';
    _model = settings.getString('agnes_model') ?? 'agnes-1.5-flash';
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final settings = await SharedPreferences.getInstance();
    await settings.setString('agnes_api_key', _keyCtrl.text.trim());
    await settings.setString('agnes_base_url', _urlCtrl.text.trim());
    await settings.setString('agnes_model', _model);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('设置已保存，重新打开对话生效 ✨'), duration: Duration(seconds: 2)));
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('⚙️ API 设置'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _keyCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'API Key', isDense: true)),
            const SizedBox(height: 8),
            TextField(controller: _urlCtrl, decoration: const InputDecoration(hintText: 'Base URL', isDense: true)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _model,
              decoration: const InputDecoration(isDense: true),
              items: const [
                DropdownMenuItem(value: 'agnes-1.5-flash', child: Text('1.5-flash 多模态', style: TextStyle(fontSize: 14))),
                DropdownMenuItem(value: 'agnes-2.0-flash', child: Text('2.0-flash 思考', style: TextStyle(fontSize: 14))),
              ],
              onChanged: (v) => setState(() => _model = v ?? _model),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: RemTheme.pink, foregroundColor: Colors.white),
          child: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('保存'),
        ),
      ],
    );
  }
}
