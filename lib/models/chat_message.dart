import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single message in a chat session
/// Can be from user or AI (Gemini)
class ChatMessage {
  final String id;
  final String role; // 'user' or 'ai'
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
  });

  /// Create ChatMessage from Firestore document
  factory ChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return ChatMessage(
      id: doc.id,
      role: data?['role'] ?? 'user',
      text: data?['text'] ?? '',
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  /// Convert ChatMessage to Firestore-friendly map
  Map<String, dynamic> toFirestore() {
    return {
      'role': role,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Helper: create a user message
  factory ChatMessage.user({
    required String text,
  }) {
    return ChatMessage(
      id: '',
      role: 'user',
      text: text,
      createdAt: DateTime.now(),
    );
  }

  /// Helper: create an AI message
  factory ChatMessage.ai({
    required String text,
  }) {
    return ChatMessage(
      id: '',
      role: 'ai',
      text: text,
      createdAt: DateTime.now(),
    );
  }
}
