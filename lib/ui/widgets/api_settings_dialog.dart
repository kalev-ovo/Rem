import 'package:flutter/material.dart';
import '../../core/api/api_settings.dart';
import '../../core/theme/app_theme.dart';

/// API 设置对话框
class ApiSettingsDialog extends StatefulWidget {
  const ApiSettingsDialog({super.key});

  @override
  State<ApiSettingsDialog> createState() => _ApiSettingsDialogState();
}

class _ApiSettingsDialogState extends State<ApiSettingsDialog> {
  final _keyController = TextEditingController();
  final _urlController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final key = await ApiSettings.getApiKey();
    final url = await ApiSettings.getBaseUrl();
    _keyController.text = key;
    _urlController.text = url;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ApiSettings.setApiKey(_keyController.text.trim());
    await ApiSettings.setBaseUrl(_urlController.text.trim());
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('设置已保存，重新打开对话生效 ✨'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Text('⚙️ '),
          Text('API 设置'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API Key',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _keyController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '输入 Agnes API Key',
                hintStyle: const TextStyle(fontSize: 13),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.visibility, size: 18),
                  onPressed: () {
                    // toggle visibility
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Base URL',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'https://apihub.agnes-ai.com/v1',
                hintStyle: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '修改后需重新打开对话生效',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: RemTheme.pink,
            foregroundColor: Colors.white,
          ),
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('保存'),
        ),
      ],
    );
  }
}
