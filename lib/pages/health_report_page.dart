import 'package:flutter/material.dart';
import '../widgets/expandable_text.dart';

class HealthReportPage extends StatelessWidget {
  const HealthReportPage({super.key});

  final String _reportText = '''
ชื่อ: เด็กหญิงวรัชมน
อายุ: 7 ปี
ส่วนสูง: 120 ซม.
น้ำหนัก: 25 กก.
พฤติกรรม: นอนหลับดี, กินผักผลไม้, ชอบเล่นกลางแจ้ง
คำแนะนำ: ควรออกกำลังกายสม่ำเสมอ, ลดขนมหวาน, ตรวจสุขภาพทุก 6 เดือน
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายงานสุขภาพ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ExpandableText(fullText: _reportText, maxLines: 4),
      ),
    );
  }
}