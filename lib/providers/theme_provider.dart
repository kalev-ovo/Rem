import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';

enum AppThemeMode { light, dark }

class ThemeState {
  final AppThemeMode mode;
  final ThemeData themeData;

  const ThemeState({required this.mode, required this.themeData});
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(ThemeState(
          mode: AppThemeMode.light,
          themeData: RemTheme.lightTheme,
        ));

  void toggle() {
    if (state.mode == AppThemeMode.light) {
      state = ThemeState(
        mode: AppThemeMode.dark,
        themeData: RemTheme.darkTheme,
      );
    } else {
      state = ThemeState(
        mode: AppThemeMode.light,
        themeData: RemTheme.lightTheme,
      );
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
