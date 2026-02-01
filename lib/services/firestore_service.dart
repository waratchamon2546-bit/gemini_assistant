import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// -------------------------------
  /// Chat Sessions
  /// -------------------------------

  /// Create a new chat session
  static Future<ChatSession> createSession({
    String title = 'New Chat',
  }) async {
    final docRef = await _db.collection('chat_sessions').add({
      'title': title,
      'createdAt': Timestamp.now(),
    });

    final doc = await docRef.get();

    return ChatSession.fromFirestore(
      doc as DocumentSnapshot<Map<String, dynamic>>,
    );
  }

  /// Get all chat sessions (latest first)
  static Stream<List<ChatSession>> getSessions() {
    return _db
        .collection('chat_sessions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatSession.fromFirestore(doc))
          .toList();
    });
  }

  /// -------------------------------
  /// Messages
  /// -------------------------------

  /// Add a message to a chat session
  static Future<void> addMessage({
    required String sessionId,
    required ChatMessage message,
  }) async {
    await _db
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .add(message.toFirestore());
  }

  /// Get messages of a chat session (oldest first)
  static Stream<List<ChatMessage>> getMessages({
    required String sessionId,
  }) {
    return _db
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    });
  }

  /// Get latest N messages (for Gemini context)
  static Future<List<ChatMessage>> getLatestMessages({
    required String sessionId,
    int limit = 10,
  }) async {
    final snapshot = await _db
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ChatMessage.fromFirestore(doc))
        .toList()
        .reversed
        .toList();
  }
}
