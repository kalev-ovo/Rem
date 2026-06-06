import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/api/image_assets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const RemApp());
}

/// 带开屏图的入口
class RemApp extends StatefulWidget {
  const RemApp({super.key});

  @override
  State<RemApp> createState() => _RemAppState();
}

class _RemAppState extends State<RemApp> {
  bool _showSplash = true;
  late final String _splashImage;

  @override
  void initState() {
    super.initState();
    _splashImage = ImageAssets.randomSplash ?? 'assets/images/splash_bg.jpg';
    Timer(const Duration(seconds: 3), () {
      if (mounted) _hideSplash();
    });
  }

  void _hideSplash() {
    if (mounted) {
      setState(() => _showSplash = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: GestureDetector(
            onTap: _hideSplash,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 全屏背景图
                Image.asset(
                  _splashImage ?? 'assets/images/splash_bg.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF7EC8E3), Color(0xFFA8D8EA)],
                      ),
                    ),
                  ),
                ),
                // 底部渐变遮罩 + 文字
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 60, top: 80),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rem',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '昴君，雷姆一直在等你',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 跳过按钮
                Positioned(
                  top: 60,
                  right: 20,
                  child: GestureDetector(
                    onTap: _hideSplash,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                      ),
                      child: const Text(
                        '跳过',
                        style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const ProviderScope(child: ChatYuiApp());
  }
}
