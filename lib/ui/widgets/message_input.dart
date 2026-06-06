import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/theme/app_theme.dart';

/// 消息输入栏：文字 + 图片 + 语音 + 发送
class MessageInput extends StatefulWidget {
  final Future<void> Function(String text, List<String>? imagePaths) onSend;
  final bool enabled;

  const MessageInput({
    super.key,
    required this.onSend,
    this.enabled = true,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _picker = ImagePicker();
  late final stt.SpeechToText _speech;
  List<String> _selectedImages = [];
  bool _isSending = false;
  bool _isListening = false;
  bool _hasSpeech = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _speech.initialize().then((available) {
      if (mounted) setState(() => _hasSpeech = available);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (xfile != null) {
      setState(() => _selectedImages.add(xfile.path));
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImages.isEmpty) return;

    final sendText = text;
    final sendImages = List<String>.from(_selectedImages);
    _textController.clear();
    setState(() {
      _selectedImages = [];
      _isSending = true;
    });

    List<String>? imageUris;
    if (sendImages.isNotEmpty) {
      imageUris = [];
      for (final path in sendImages) {
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final base64 = base64Encode(bytes);
          final ext = path.split('.').last;
          imageUris.add('data:image/$ext;base64,$base64');
        }
      }
    }

    try {
      await widget.onSend(sendText, imageUris);
    } catch (_) {}
    if (mounted) {
      setState(() => _isSending = false);
    }
  }

  Future<void> _startListening() async {
    if (!_hasSpeech) return;
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _textController.text = result.recognizedWords;
          });
        }
      },
      localeId: 'zh_CN',
    );
  }

  Future<void> _stopListening() async {
    setState(() => _isListening = false);
    await _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 已选图片预览
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_selectedImages[index]),
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            // 输入行
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 图片按钮
                  IconButton(
                    onPressed: _isSending ? null : _pickImage,
                    icon: Icon(Icons.image_outlined,
                        color: _isSending
                            ? Colors.grey.shade300
                            : RemTheme.iceBlue),
                    splashRadius: 20,
                  ),
                  // 语音按钮
                  if (_hasSpeech)
                    GestureDetector(
                      onLongPressStart: (_) => _startListening(),
                      onLongPressEnd: (_) => _stopListening(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening
                                ? Colors.red
                                : RemTheme.iceBlue.withValues(alpha: 0.3),
                          ),
                          child: Icon(
                            Icons.mic,
                            color:
                                _isListening ? Colors.white : RemTheme.iceBlue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  // 文字输入
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      enabled: !_isSending,
                      maxLines: 5,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: '想对雷姆说什么...',
                        hintStyle: TextStyle(
                            color: Color(0xFFBBBBBB), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  // 发送按钮
                  IconButton(
                    onPressed: widget.enabled && !_isSending ? _send : null,
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: RemTheme.pink),
                          )
                        : Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [RemTheme.iceBlue, RemTheme.pink],
                              ),
                            ),
                            child: const Icon(Icons.send_rounded,
                                color: Colors.white, size: 18),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
