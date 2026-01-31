import 'package:flutter/material.dart';
import 'health_report_page.dart';
import 'gemini_page.dart';
import 'age_selector_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เมนูหลัก')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.health_and_safety),
            title: const Text('รายงานสุขภาพ'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HealthReportPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.child_care),
            title: const Text('เลือกอายุเด็ก'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AgeSelectorPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('ถาม Gemini'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GeminiPage()),
            ),
          ),
        ],
      ),
    );
  }
}