import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/firestore_service.dart';
import '../services/gemini_api.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  final ChatSession? session;

  const ChatScreen({super.key, this.session});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatSession? _session;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  /// 🔹 Handle sending user message
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      // 1️⃣ สร้าง session ใหม่ถ้ายังไม่มี
      _session ??= await FirestoreService.createSession(
        title: text.length > 20 ? text.substring(0, 20) : text,
      );

      final sessionId = _session!.id;

      // 2️⃣ บันทึกข้อความ user
      final userMessage = ChatMessage.user(text: text);
      await FirestoreService.addMessage(
        sessionId: sessionId,
        message: userMessage,
      );

      // 3️⃣ เรียก Gemini ผ่าน Cloud Function
      final aiReply = await GeminiApi.ask(text);

      // 4️⃣ บันทึกข้อความ AI
      final aiMessage = ChatMessage.ai(text: aiReply);
      await FirestoreService.addMessage(
        sessionId: sessionId,
        message: aiMessage,
      );
    } catch (e) {
      debugPrint('Error sending message: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionId = _session?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Chat',
            onPressed: () {
              setState(() {
                _session = null;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Messages area
          Expanded(
            child: sessionId == null
                ? const Center(
                    child: Text(
                      'เริ่มพิมพ์เพื่อเริ่มการสนทนา',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : StreamBuilder<List<ChatMessage>>(
                    stream:
                        FirestoreService.getMessages(sessionId: sessionId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final messages = snapshot.data!;

                      if (messages.isEmpty) {
                        return const Center(
                          child: Text(
                            'ยังไม่มีข้อความ',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return ChatBubble(message: message);
                        },
                      );
                    },
                  ),
          ),

          // 🔹 Input area
          MessageInput(
            isSending: _isSending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
