import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final bool isSending;
  final ValueChanged<String> onSend;

  const MessageInput({
    super.key,
    required this.isSending,
    required this.onSend,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;

    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                decoration: const InputDecoration(
                  hintText: 'พิมพ์ข้อความ...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            widget.isSending
                ? const CircularProgressIndicator()
                : IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _handleSend,
                  ),
          ],
        ),
      ),
    );
  }
}
