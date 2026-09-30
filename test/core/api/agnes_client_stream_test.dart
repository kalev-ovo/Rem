import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_yui/core/api/agnes_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgnesClient.streamChat', () {
    test('parses multiple content events in one chunk', () async {
      final chunks = [
        utf8.encode('${_event('Hello')}${_event(' world')}data: [DONE]\n\n'),
      ];

      expect(await _streamChat(chunks), ['Hello', ' world']);
    });

    test('preserves Chinese and emoji at every byte split', () async {
      const content = '你好，雷姆 👋';
      final bytes = utf8.encode('${_event(content)}data: [DONE]\n\n');

      for (var split = 1; split < bytes.length; split++) {
        final chunks = [bytes.sublist(0, split), bytes.sublist(split)];
        expect(await _streamChat(chunks), [content],
            reason: 'Network chunk boundary at byte $split');
      }
    });

    test('preserves content when each byte arrives in a separate chunk',
        () async {
      const content = '雷姆 💙';
      final bytes = utf8.encode('${_event(content)}data: [DONE]\n\n');

      expect(await _streamChat(bytes.map((byte) => [byte])), [content]);
    });

    test('parses CRLF events split across chunks', () async {
      final event = _event('你好').replaceAll('\n', '\r\n');
      final bytes = utf8.encode('${event}data: [DONE]\r\n\r\n');
      final split = bytes.indexOf(13) + 1;

      expect(
        await _streamChat([bytes.sublist(0, split), bytes.sublist(split)]),
        ['你好'],
      );
    });

    test('stops at DONE without yielding subsequent content', () async {
      final chunks = [
        utf8.encode('${_event('Hi')}data: [DONE]\n\n${_event('ignored')}'),
      ];

      expect(await _streamChat(chunks), ['Hi']);
    });

    test('ignores comments, malformed JSON and events without content',
        () async {
      final chunks = [
        utf8.encode(': keep-alive\n\ndata: invalid\n\n'
            'data: {"choices":[]}\n\n'
            'data: {"choices":[{"delta":{"role":"assistant"}}]}\n\n'
            '${_event('Hello')}data: [DONE]\n\n'),
      ];

      expect(await _streamChat(chunks), ['Hello']);
    });
  });
}

String _event(String content) => 'data: ${jsonEncode({
          'choices': [
            {
              'delta': {'content': content},
            },
          ],
        })}\n\n';

Future<List<String>> _streamChat(Iterable<List<int>> chunks) async {
  final client = AgnesClient(apiKey: 'test-key');
  client.dio.httpClientAdapter = _StreamAdapter(chunks);
  try {
    return await client.streamChat(messages: [
      {'role': 'user', 'content': 'Hello'},
    ]).toList();
  } finally {
    client.dio.close();
  }
}

class _StreamAdapter implements HttpClientAdapter {
  final Iterable<List<int>> chunks;

  _StreamAdapter(this.chunks);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody(
      Stream<Uint8List>.fromIterable(chunks.map(Uint8List.fromList)),
      200,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
