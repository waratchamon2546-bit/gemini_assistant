import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../service/gemini_service.dart'; // มั่นใจว่าไฟล์นี้อยู่ในโฟลเดอร์ service

class GeminiPage extends StatefulWidget {
  const GeminiPage({super.key});

  @override
  State<GeminiPage> createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService(); // เรียกใช้ Service ของคุณ
  
  List<Map<String, String>> messages = [];
  bool isLoading = false;
  double _currentAge = 1;
  double _currentTemp = 37.0;

  void _vibrate() => HapticFeedback.lightImpact();

  
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      isLoading = true;
    });

    // เรียกใช้ askGemini จากไฟล์ Service ที่คุณเพิ่งแก้
    final response = await _geminiService.askGemini(text);

    setState(() {
      isLoading = false;
      messages.add({"role": "bot", "text": response});
    });
    
    // หลังจากเพิ่มข้อความ ให้เลื่อนลงล่างสุดอัตโนมัติ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  
  Widget _buildAutoHelper() {
    if (messages.isEmpty || isLoading) return const SizedBox.shrink();
    
    // ดึงข้อความล่าสุดจาก AI มาเช็ค Keyword
    String lastMsg = messages.last['text'] ?? "";

    if (lastMsg.contains("[อายุ]")) return _buildAgeSlider();
    if (lastMsg.contains("[ไข้]")) return _buildTempSlider();
    if (lastMsg.contains("[เพศ]")) return _buildGenderSelector();
    
    return const SizedBox.shrink();
  }

  Widget _buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.all(15), color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(onPressed: () => _sendMessage("น้องเป็นเด็กผู้ชาย"), child: const Text("ชาย 👦")),
          ElevatedButton(onPressed: () => _sendMessage("น้องเป็นเด็กผู้หญิง"), child: const Text("หญิง 👧")),
        ],
      ),
    );
  }

  Widget _buildAgeSlider() {
    return Container(
      padding: const EdgeInsets.all(15), color: Colors.green[50],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("เลือกอายุ: ${_currentAge.toInt()} ปี", style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _currentAge, min: 0, max: 15, divisions: 15,
            onChanged: (val) { _vibrate(); setState(() => _currentAge = val); },
          ),
          ElevatedButton(onPressed: () => _sendMessage("น้องอายุ ${_currentAge.toInt()} ปี"), child: const Text("ยืนยันอายุ")),
        ],
      ),
    );
  }

  Widget _buildTempSlider() {
    Color color = _currentTemp >= 38.5 ? Colors.red : (_currentTemp >= 37.5 ? Colors.orange : Colors.blue);
    return Container(
      padding: const EdgeInsets.all(15), color: color.withOpacity(0.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("อุณหภูมิ: ${_currentTemp.toStringAsFixed(1)} °C", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          Slider(
            value: _currentTemp, min: 35.0, max: 42.0, divisions: 70, activeColor: color,
            onChanged: (val) { _vibrate(); setState(() => _currentTemp = val); },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: () => _sendMessage("น้องมีไข้ ${_currentTemp.toStringAsFixed(1)} องศา"), 
            child: const Text("ส่งค่าอุณหภูมิ", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("คุณหมอเด็ก AI"), backgroundColor: Colors.blueAccent),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, i) {
                bool isUser = messages[i]['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(messages[i]['text']!, style: const TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          if (isLoading) const LinearProgressIndicator(),
          
          
          _buildAutoHelper(), 

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "พิมพ์อาการ..."))),
                IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: () => _sendMessage(_controller.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}