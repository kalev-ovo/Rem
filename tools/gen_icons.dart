import 'dart:io';
import 'package:image/image.dart' as img;

/// 从 应用图标.jpeg 生成 Android mipmap 各尺寸 PNG 图标
void main() {
  final sourceFile = File('assets/images/应用图标.jpeg');
  if (!sourceFile.existsSync()) {
    print('ERROR: 找不到 assets/images/应用图标.jpeg');
    exit(1);
  }

  final bytes = sourceFile.readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('ERROR: 无法解码图片');
    exit(1);
  }

  // Android mipmap 密度对应尺寸
  final densities = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  for (final entry in densities.entries) {
    final dir = Directory('android/app/src/main/res/${entry.key}');
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final resized = img.copyResize(image, width: entry.value, height: entry.value);
    final pngBytes = img.encodePng(resized);
    final outFile = File('${dir.path}/ic_launcher.png');
    outFile.writeAsBytesSync(pngBytes);
    print('✓ ${entry.key}: ${entry.value}x${entry.value} (${pngBytes.length} bytes)');
  }

  print('\n所有图标生成完成！');
}
