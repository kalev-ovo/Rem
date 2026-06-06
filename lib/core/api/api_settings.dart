import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API 配置管理 —— 应用内设置优先，fallback 到 .env
class ApiSettings {
  static const _keyApiKey = 'agnes_api_key';
  static const _keyBaseUrl = 'agnes_base_url';
  static const _keyModel = 'agnes_model';
  static const defaultModel = 'agnes-1.5-flash';

  /// 可用模型列表
  static const availableModels = [
    'agnes-1.5-flash',
    'agnes-2.0-flash',
  ];

  /// 获取选中的模型
  static Future<String> getModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyModel) ?? defaultModel;
  }

  /// 保存模型选择
  static Future<void> setModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyModel, model);
  }

  /// 获取 API Key（应用设置优先 → .env fallback）
  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyApiKey);
    if (stored != null && stored.isNotEmpty) return stored;
    return dotenv.env['AGNES_API_KEY'] ?? '';
  }

  /// 保存 API Key
  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiKey, key);
  }

  /// 获取 Base URL（应用设置优先 → .env fallback）
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyBaseUrl);
    if (stored != null && stored.isNotEmpty) return stored;
    return dotenv.env['AGNES_BASE_URL'] ?? 'https://apihub.agnes-ai.com/v1';
  }

  /// 保存 Base URL
  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, url);
  }

  /// 是否有可用的 API Key
  static Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key.isNotEmpty;
  }
}
