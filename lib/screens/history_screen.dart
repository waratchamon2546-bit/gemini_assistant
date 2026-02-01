import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void _openChat(BuildContext context, ChatSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(session: session),
      ),
    );
  }

  void _startNewChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChatScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการสนทนา'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Chat',
            onPressed: () => _startNewChat(context),
          ),
        ],
      ),
      body: StreamBuilder<List<ChatSession>>(
        stream: FirestoreService.getSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'ยังไม่มีประวัติการสนทนา',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final sessions = snapshot.data!;

          return ListView.separated(
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final session = sessions[index];

              return ListTile(
                title: Text(
                  session.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'เริ่มเมื่อ ${session.createdAt.toLocal()}',
                  style: const TextStyle(fontSize: 12),
                ),
                leading: const Icon(Icons.chat_bubble_outline),
                onTap: () => _openChat(context, session),
              );
            },
          );
        },
      ),
    );
  }
}
