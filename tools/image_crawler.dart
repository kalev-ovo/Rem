import 'dart:convert';
import 'dart:io';

/// 从已知图片 ID 构造直链下载
void main() async {
  final outDir = Directory('assets/images/rem_wallpapers');
  if (!await outDir.exists()) await outDir.create(recursive: true);

  print('=== Rem 图片下载 ===\n');

  // wallhaven 直链格式: https://w.wallhaven.cc/full/{id前2位}/wallhaven-{id}.{ext}
  // 来源：web search 结果中找到的 Rem 壁纸 ID
  final wallhavenIds = [
    'o53eol',  // Rem portrait, flowers
    'mp8d99',  // Rem white bg, maid
    '6lk5kx',  // Rem & Ram twins
    '966y6x',  // Rem & Ram fireworks, yukata
    'lmomqr',  // Rem anime
    '961kk8',  // Rem & Ram
    'dgyq1m',  // Rem cat girl
    'rq213m',  // Rem cosplay
    'wq7m6x',  // Rem artwork (additional)
    '1p3vjw',  // Rem wallpaper (additional)
  ];

  var count = 0;
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 10);

  for (final id in wallhavenIds) {
    final prefix = id.substring(0, 2);
    // 尝试 .jpg 和 .png
    var ok = false;
    for (final ext in ['jpg', 'png']) {
      final url = 'https://w.wallhaven.cc/full/$prefix/wallhaven-$id.$ext';
      final filename = 'wallhaven-$id.$ext';
      ok = await _tryDownload(client, url, '${outDir.path}/$filename');
      if (ok) {
        count++;
        break;
      }
    }
    if (!ok) print('  ✗ $id');
  }

  // 也尝试一些已知的直链图片网站
  print('\n[附加] 尝试其他来源...');

  // 使用 picsum 生成一些占位图（直到找到更好的来源）
  // 实际：尝试从 anime 图站获取

  client.close();
  print('\n完成: $count 张 → ${outDir.path}');
}

Future<bool> _tryDownload(HttpClient client, String url, String path) async {
  final file = File(path);
  if (await file.exists()) {
    print('  ✓ ${file.uri.pathSegments.last} (已有)');
    return true;
  }
  try {
    final uri = Uri.parse(url);
    final req = await client.getUrl(uri);
    req.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');
    req.headers.set('Referer', 'https://wallhaven.cc/');
    final res = await req.close();
    if (res.statusCode == 200) {
      final bytes = await res.fold<List<int>>(<int>[], (prev, c) => prev..addAll(c));
      if (bytes.length > 10000) {
        await file.writeAsBytes(bytes);
        print('  ✓ ${file.uri.pathSegments.last} (${(bytes.length / 1024).toStringAsFixed(0)}KB)');
        return true;
      }
    }
  } catch (_) {}
  return false;
}
