import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  double _currentAge = 1;
  double _currentTemp = 37.0;

  void _vibrate() => HapticFeedback.lightImpact();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      messages.add({"role": "user", "text": text});
      isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/analyze'), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          messages.add({"role": "bot", "text": data['reply']});
        });
      }
    } catch (e) {
      setState(() {
        messages.add({"role": "bot", "text": "เชื่อมต่อเซิร์ฟเวอร์ไม่ได้"});
      });
    } finally {
      setState(() => isLoading = false);
      _controller.clear();
      _scrollToBottom();
    }
  }

  // --- ส่วนตัดสินใจเลือก Widget (Smart UI) ---
  Widget _buildAutoHelper() {
    if (messages.isEmpty || isLoading) return SizedBox(key: UniqueKey());
    String lastMsg = messages.last['text'] ?? "";

    if (lastMsg.contains("[เพศ]")) {
      return _buildGenderSelector();
    } 
    if (lastMsg.contains("[อายุ]")) {
      return _buildAgeSlider();
    } 
    if (lastMsg.contains("[ไข้]")) {
      return _buildTempSlider();
    }
    return SizedBox(key: UniqueKey());
  }

  Widget _buildGenderSelector() {
    return Container(
      key: UniqueKey(),
      padding: EdgeInsets.all(15),
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(onPressed: () => _sendMessage("น้องเป็นเด็กผู้ชาย"), child: Text("ชาย 👦")),
          ElevatedButton(onPressed: () => _sendMessage("น้องเป็นเด็กผู้หญิง"), child: Text("หญิง 👧")),
        ],
      ),
    );
  }

  Widget _buildAgeSlider() {
    return Container(
      key: UniqueKey(),
      padding: EdgeInsets.all(15),
      color: Colors.green[50],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("เลื่อนเพื่อเลือกอายุ: ${_currentAge.toInt()} ปี", style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _currentAge, min: 0, max: 15, divisions: 15,
            onChanged: (val) { _vibrate(); setState(() => _currentAge = val); },
          ),
          ElevatedButton(onPressed: () => _sendMessage("น้องอายุ ${_currentAge.toInt()} ปี"), child: Text("ยืนยันอายุ")),
        ],
      ),
    );
  }

  Widget _buildTempSlider() {
    Color color = _currentTemp >= 38.5 ? Colors.red : (_currentTemp >= 37.5 ? Colors.orange : Colors.blue);
    return Container(
      key: UniqueKey(),
      padding: EdgeInsets.all(15),
      color: color.withOpacity(0.1),
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
            child: Text("ส่งค่าอุณหภูมิ", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("คุณหมอเด็ก AI"), backgroundColor: Colors.blueAccent),
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
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(messages[i]['text']!, style: TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          if (isLoading) LinearProgressIndicator(),
          
          // ส่วนของ Smart UI (Slider/Buttons)
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _buildAutoHelper(),
          ),

          // ช่องพิมพ์ข้อความ
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: "พิมพ์อาการ..."))),
                IconButton(icon: Icon(Icons.send, color: Colors.blue), onPressed: () => _sendMessage(_controller.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}