import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:gcargo/services/upgrader_service.dart';
import 'package:gcargo/services/auth_service.dart';

class UpgradeTestWidget extends StatelessWidget {
  const UpgradeTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ทดสอบ Upgrader'), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ทดสอบระบบอัปเดทแอป', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            const Text('การตั้งค่าปัจจุบัน:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            const Text('• แสดงแจ้งเตือนทุก 1 วัน'),
            const Text('• รองรับทั้ง Android และ iOS'),
            const Text('• ข้อความเป็นภาษาไทย'),
            const Text('• มีปุ่ม "ข้าม" และ "ภายหลัง"'),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // แสดง dialog อัปเดทแบบบังคับ
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) => UpgradeAlert(
                        upgrader: Upgrader(
                          debugDisplayAlways: true, // แสดงเสมอเพื่อทดสอบ
                          debugLogging: true,
                          countryCode: 'TH',
                          languageCode: 'th',
                          messages: ThaiUpgraderMessages(),
                        ),
                        child: Container(),
                      ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('ทดสอบแสดง Dialog อัปเดท'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                // ลบข้อมูล SharedPreferences ทั้งหมด
                await AuthService.clearAllData();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('ลบข้อมูลทั้งหมดแล้ว - รีสตาร์ทแอปเพื่อทดสอบ PIN'), backgroundColor: Colors.green));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('ลบข้อมูลทั้งหมด (ทดสอบ)'),
            ),

            const SizedBox(height: 20),

            const Text('หมายเหตุ:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),

            const Text(
              '• ในการใช้งานจริง dialog จะแสดงเมื่อมีเวอร์ชั่นใหม่บน Store\n'
              '• สำหรับ Android: ตรวจสอบจาก Google Play Store\n'
              '• สำหรับ iOS: ตรวจสอบจาก App Store\n'
              '• การทดสอบจะแสดง dialog เสมอ',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚠️ สำคัญ:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                  SizedBox(height: 8),
                  Text(
                    'เพื่อให้ระบบอัปเดททำงานได้:\n'
                    '1. แอปต้องถูกอัปโหลดบน Store (Google Play / App Store)\n'
                    '2. ต้องมีเวอร์ชั่นใหม่บน Store ที่สูงกว่าเวอร์ชั่นปัจจุบัน\n'
                    '3. ผู้ใช้ต้องมีการเชื่อมต่ออินเทอร์เน็ต',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
