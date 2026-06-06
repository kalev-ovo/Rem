import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/api/user_settings.dart';
import '../../core/db/database.dart';
import '../../core/theme/app_theme.dart';

/// 个人主页
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  Future<void> _editNickname() async {
    final ctrl = TextEditingController(text: _nickname);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('更改称谓'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入雷姆对你的称呼',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: RemTheme.pink, foregroundColor: Colors.white),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await UserSettings.setNickname(name);
      _load();
    }
  }

  Future<void> _changeAvatar() async {
    final path = await UserSettings.pickAndSaveAvatar();
    if (path != null) _load();
  }

  Widget _avatar() {
    if (_avatarPath != null && File(_avatarPath!).existsSync()) {
      return ClipOval(
        child: Image.file(File(_avatarPath!), width: 88, height: 88, fit: BoxFit.cover),
      );
    }
    return ClipOval(
      child: Image.asset('assets/images/default_avatar.png', width: 88, height: 88, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人主页')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _changeAvatar,
              child: Stack(
                children: [
                  _avatar(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: RemTheme.pink,
                      ),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _editNickname,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _nickname,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '雷姆会用这个名字称呼你',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 32),
            // 统计
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('对话', _convCount),
                    _stat('消息', _msgCount),
                    _stat('记忆', _factCount),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, int count) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: RemTheme.iceBlue)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      ],
    );
  }
}
