import 'dart:math';
import 'package:flutter/services.dart';

/// 从资源目录随机选图
class ImageAssets {
  static final _random = Random();

  /// 获取某目录下所有图片路径
  static Future<List<String>> _listDir(String dir) async {
    final manifest = await rootBundle.loadString('AssetManifest.json');
    // AssetManifest 不可直接解析，用简单方式
    return [];
  }

  /// 手动维护的素材清单（按分类）
  static const avatars = <String>[];
  static const splash = <String>[];
  static const welcome = <String>[];
  static const drawer = <String>[];

  /// 随机取一张
  static String? randomFrom(List<String> pool) {
    if (pool.isEmpty) return null;
    return pool[_random.nextInt(pool.length)];
  }
}
