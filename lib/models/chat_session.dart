import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  /// Create ChatSession from Firestore document
  factory ChatSession.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return ChatSession(
      id: doc.id,
      title: data?['title'] ?? 'New Chat',
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  /// Convert ChatSession to Firestore-friendly map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Helper: create a brand new chat session
  factory ChatSession.newSession() {
    return ChatSession(
      id: '',
      title: 'New Chat',
      createdAt: DateTime.now(),
    );
  }
}
