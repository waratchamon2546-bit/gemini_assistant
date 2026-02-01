import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../constants/app_constants.dart';

class GeminiService {
  GeminiService._();

  static Future<String> sendMessage({
    required List<ChatMessage> messages,
  }) async {
    final prompt = _buildPrompt(messages);

  final response = await http.post(
    Uri.parse(
      '${AppConstants.geminiEndpoint}/${AppConstants.geminiModel}:generateContent'
      '?key=${AppConstants.geminiApiKey}',
      ),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
    }),
  );


    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
        'ขออภัย ไม่สามารถให้คำตอบได้ในขณะนี้';
  }

  static String _buildPrompt(List<ChatMessage> messages) {
    final buffer = StringBuffer();

    buffer.writeln(AppConstants.systemPrompt);
    buffer.writeln('\nบทสนทนาก่อนหน้า:\n');

    for (final message in messages) {
      buffer.writeln(
        message.role == 'user'
            ? 'ผู้ใช้: ${message.text}'
            : 'ผู้ช่วย: ${message.text}',
      );
    }

    buffer.writeln('\nโปรดตอบคำถามล่าสุดอย่างเหมาะสม:');

    return buffer.toString();
  }
}
