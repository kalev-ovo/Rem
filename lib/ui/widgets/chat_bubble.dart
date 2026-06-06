import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/api/user_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/message.dart';
import 'rem_avatar.dart';

/// 聊天气泡 —— 雷姆风
class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isLastAiMessage;

  const ChatBubble({
    super.key,
    required this.message,
    this.isLastAiMessage = false,
  });

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    // AI 头像（仅 AI 消息，放在气泡下方左侧）
    const aiAvatar = Padding(
      padding: EdgeInsets.only(top: 4),
      child: RemAvatar(size: 30, showBadge: true),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isUser) ...[
            aiAvatar,
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.imagePaths != null)
                  ...message.imagePaths!.map((path) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _ImageWidget(
                            path: path,
                            width: 200,
                            height: 150,
                          ),
                        ),
                      )),
                GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: message.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已复制'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isUser ? RemTheme.bubbleGray : RemTheme.bubbleIce,
                      borderRadius: _bubbleRadius,
                    ),
                    child: _isUser
                        ? Text(
                            message.content,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Color(0xFF333333),
                            ),
                          )
                        : MarkdownBody(
                            data: message.content,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Color(0xFF333333),
                              ),
                              code: TextStyle(
                                fontSize: 13,
                                backgroundColor:
                                    RemTheme.iceBlue.withValues(alpha: 0.2),
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (_isUser) ...[
            const SizedBox(width: 8),
            const _UserBubbleAvatar(),
          ],
        ],
      ),
    );
  }

  BorderRadius get _bubbleRadius {
    if (_isUser) {
      return const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      );
    }
    return const BorderRadius.only(
      topLeft: Radius.circular(4), // 贴头像侧尖角
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    );
  }
}

/// 自适应图片组件：支持网络URL / base64 data URI / 本地文件路径
class _ImageWidget extends StatelessWidget {
  final String path;
  final double width;
  final double height;

  const _ImageWidget({
    required this.path,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('data:')) {
      // base64 data URI
      return Image.memory(
        base64Decode(path.split(',').last),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: _errorBuilder,
      );
    }
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: _errorBuilder,
      );
    }
    // 本地文件
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: _errorBuilder,
    );
  }

  static Widget _errorBuilder(_, __, ___) => Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
}

/// 用户气泡头像（从设置读取）
class _UserBubbleAvatar extends StatefulWidget {
  const _UserBubbleAvatar();

  @override
  State<_UserBubbleAvatar> createState() => _UserBubbleAvatarState();
}

class _UserBubbleAvatarState extends State<_UserBubbleAvatar> {
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    UserSettings.getAvatarPath().then((p) {
      if (mounted) setState(() => _avatarPath = p);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_avatarPath != null && File(_avatarPath!).existsSync()) {
      return ClipOval(
        child: Image.file(File(_avatarPath!), width: 34, height: 34, fit: BoxFit.cover),
      );
    }
    return const CircleAvatar(
      radius: 17,
      backgroundColor: RemTheme.pink,
      child: Icon(Icons.person, color: Colors.white, size: 20),
    );
  }
}
