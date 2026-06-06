import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 雷姆风主题 —— 冰蓝色主调，治愈系 ACG 氛围
class RemTheme {
  RemTheme._();

  // ─── 色板 ───

  /// 冰蓝（主色）
  static const Color iceBlue = Color(0xFF7EC8E3);

  /// 浅蓝（背景辅助）
  static const Color lightBlue = Color(0xFFA8D8EA);

  /// 极浅蓝（卡片背景）
  static const Color paleBlue = Color(0xFFE8F4F8);

  /// 淡粉（强调色——雷姆发饰）
  static const Color pink = Color(0xFFF4A7B9);

  /// 深蓝（暗色主题用）
  static const Color darkBlue = Color(0xFF2C3E50);

  /// 纯白
  static const Color white = Color(0xFFFCFCFC);

  /// 用户气泡灰
  static const Color bubbleGray = Color(0xFFF0F0F0);

  /// AI 气泡冰蓝
  static const Color bubbleIce = Color(0xFFD6EEF5);

  // ─── 亮色主题 ───

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: iceBlue,
        secondary: pink,
        surface: white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF333333),
      ),
      scaffoldBackgroundColor: white,
      appBarTheme: const AppBarTheme(
        backgroundColor: iceBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: pink,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paleBlue.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      iconTheme: const IconThemeData(color: iceBlue),
    );
  }

  // ─── 暗色主题 ───

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: iceBlue,
        secondary: pink,
        surface: Color(0xFF1A1A2E),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFE0E0E0),
      ),
      scaffoldBackgroundColor: const Color(0xFF16213E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F3460),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: pink,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
