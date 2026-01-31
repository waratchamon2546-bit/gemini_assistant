import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  //
  static const String _baseUrl = 'http://10.0.2.2:5000/analyze'; 

  Future<String> askGemini(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? "ไม่มีข้อความตอบกลับ";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "ติดต่อเซิร์ฟเวอร์ไม่ได้: $e";
    }
  }
}