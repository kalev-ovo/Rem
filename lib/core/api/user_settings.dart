import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 用户配置：昵称、头像路径
class UserSettings {
  static const _keyNickname = 'user_nickname';
  static const _keyAvatarPath = 'user_avatar_path';
  static const defaultNickname = '昴君';

  /// 获取昵称
  static Future<String> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNickname) ?? defaultNickname;
  }

  /// 设置昵称
  static Future<void> setNickname(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNickname, name.trim().isEmpty ? defaultNickname : name.trim());
  }

  /// 获取头像路径（null = 用默认素材）
  static Future<String?> getAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAvatarPath);
  }

  /// 从相册选图并保存到 app 目录
  static Future<String?> pickAndSaveAvatar() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 85);
    if (xfile == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final avatarDir = Directory('${dir.path}/avatars');
    if (!await avatarDir.exists()) await avatarDir.create(recursive: true);

    // 每次用新文件名避免 overwrite 冲突
    final destPath = '${avatarDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.png';
    final destFile = File(destPath);
    await File(xfile.path).copy(destPath);
    // 删旧头像（保留最新 3 个）
    final oldFiles = await avatarDir.list().toList();
    // ignore: unused_local_variable
    for (final f in oldFiles.whereType<File>()) {
      if (f.path != destPath) await f.delete();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatarPath, destPath);
    return destPath;
  }
}
