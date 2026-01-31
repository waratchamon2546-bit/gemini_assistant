import 'package:flutter/material.dart';

class AgeSelectorPage extends StatefulWidget {
  const AgeSelectorPage({super.key});

  @override
  State<AgeSelectorPage> createState() => _AgeSelectorPageState();
}

class _AgeSelectorPageState extends State<AgeSelectorPage> {
  double _age = 5; // ค่าเริ่มต้น

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกอายุเด็ก'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'กรุณาเลือกอายุของเด็ก',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  '${_age.round()} ปี',
                  style: const TextStyle(fontSize: 32, color: Colors.indigo),
                ),
              ),
              Slider(
                value: _age,
                min: 1,
                max: 5,
                divisions: 4,
                label: '${_age.round()}',
                onChanged: (value) {
                  setState(() {
                    _age = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('ยืนยันอายุ'),
                  onPressed: () {
                    Navigator.pop(context, _age.round());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}