import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiApi {
  static Future<String> ask(String message) async {
    final response = await http.post(
      Uri.parse(
        'http://127.0.0.1:5001/apppppppp-159fd/us-central1/askGemini',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['reply'];
  }
}
