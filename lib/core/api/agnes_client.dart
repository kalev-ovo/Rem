import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'api_settings.dart';

/// Agnes AI API 客户端
class AgnesClient {
  Dio? _dio;
  String _apiKey;
  String _baseUrl;

  static const String defaultModel = 'agnes-1.5-flash';

  AgnesClient({
    String? apiKey,
    String? baseUrl,
  })  : _apiKey = apiKey ?? '',
        _baseUrl = baseUrl ?? 'https://apihub.agnes-ai.com/v1';

  /// 初始化：从存储加载 API Key
  Future<void> init() async {
    _apiKey = await ApiSettings.getApiKey();
    _baseUrl = await ApiSettings.getBaseUrl();
    _dio = _createDio();
  }

  Dio _createDio() {
    return Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
    ));
  }

  /// 动态更新 API Key（应用内设置）
  Future<void> updateApiKey(String newKey) async {
    _apiKey = newKey;
    await ApiSettings.setApiKey(newKey);
    _dio = _createDio();
  }

  /// 动态更新 Base URL
  Future<void> updateBaseUrl(String newUrl) async {
    _baseUrl = newUrl;
    await ApiSettings.setBaseUrl(newUrl);
    _dio = _createDio();
  }

  Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  /// 流式聊天
  Stream<String> streamChat({
    required List<Map<String, dynamic>> messages,
    String model = defaultModel,
    double temperature = 0.7,
    int maxTokens = 4096,
    String? systemPrompt,
  }) async* {
    final body = <String, dynamic>{
      'model': model,
      'messages': [
        if (systemPrompt != null)
          {'role': 'system', 'content': systemPrompt},
        ...messages,
      ],
      'temperature': temperature,
      'max_tokens': maxTokens,
      'stream': true,
    };

    try {
      final response = await dio.post(
        '/chat/completions',
        data: body,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      final rawStream = response.data.stream;
      String buffer = '';

      await for (final chunk in rawStream) {
        final text = utf8.decode(chunk, allowMalformed: true);
        buffer += text;

        // 按行分割处理
        while (buffer.contains('\n')) {
          final newlineIndex = buffer.indexOf('\n');
          final line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1);

          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data == '[DONE]') return;

            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              final choices = json['choices'] as List?;
              if (choices != null && choices.isNotEmpty) {
                final delta = choices[0]['delta'] as Map<String, dynamic>?;
                final content = delta?['content'] as String?;
                if (content != null) {
                  yield content;
                }
              }
            } catch (_) {}
          }
        }
      }
    } on DioException catch (e) {
      throw AgnesException(
        message: _parseError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// 生成对话标题
  Future<String> generateTitle(String firstMessage) async {
    try {
      final result = await dio.post('/chat/completions', data: {
        'model': 'agnes-2.0-flash',
        'messages': [
          {
            'role': 'user',
            'content': '请为以下对话内容生成一个简短的标题（不超过15个字，直接用中文回复标题，不要引号）：$firstMessage',
          }
        ],
        'max_tokens': 50,
      });
      final choices = result.data['choices'] as List;
      if (choices.isNotEmpty) {
        return (choices[0]['message']['content'] as String)
            .trim()
            .replaceAll('"', '')
            .replaceAll('"', '')
            .replaceAll('"', '');
      }
      return '新对话';
    } catch (_) {
      return '新对话';
    }
  }

  String _parseError(DioException e) {
    if (e.response?.data is Map) {
      final error = e.response?.data['error'] as Map<String, dynamic>?;
      return error?['message'] as String? ?? '请求失败';
    }
    return e.message ?? '网络错误';
  }
}

class AgnesException implements Exception {
  final String message;
  final int? statusCode;

  const AgnesException({required this.message, this.statusCode});

  @override
  String toString() => 'AgnesException($statusCode): $message';
}
