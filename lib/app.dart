// This Flutter app is a chat-based smart assistant.
// It uses Firestore to store chat sessions and messages.
// Each chat session has many messages.
// Gemini API is called directly from Flutter.
// Clean architecture: models, services, screens, widgets.
import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gemini Assistant',
      home: const ChatScreen(),
    );
  }
}

