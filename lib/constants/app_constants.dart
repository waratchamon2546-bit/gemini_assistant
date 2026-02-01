class AppConstants {
  // ===============================
  // App
  // ===============================
  static const String appName = 'Gemini Child Health Assistant';

  // ===============================
  // Gemini
  // ===============================
  static const String geminiApiKey = 'AIzaSyCa28K5GaSqCiQC2bv2113UNf8efUmlVK4';
  static const String geminiModel = 'gemini-2.5-flash';
  static const String geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1/models';

    

  // ===============================
  // Prompt
  // ===============================
  static const String systemPrompt =
      'คุณคือผู้ช่วยด้านสุขภาพสำหรับเด็ก '
      'ช่วยอธิบายอาการเบื้องต้นอย่างสุภาพ เข้าใจง่าย '
      'โดยไม่วินิจฉัยโรค และแนะนำให้พบแพทย์เมื่อจำเป็น';
}
