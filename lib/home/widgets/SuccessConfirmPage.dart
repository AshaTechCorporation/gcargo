import 'package:flutter/material.dart';

class SuccessConfirmPage extends StatelessWidget {
  const SuccessConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/iconsuccess.png', width: 48, height: 48),
                const SizedBox(height: 16),
                const Text('แจ้งยืนยันความเป็นเจ้าของแล้ว', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text(
                  'คำร้องของท่านอยู่ระหว่างดำเนินการ\nระบบจะแจ้งผลให้ทราบ\nทันทีหลังจากขั้นตอนดังกล่าวเสร็จสิ้น\nขอขอบพระคุณที่ใช้บริการ',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                ..pop()
                ..pop()
                ..pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E3C72), // ✅ kButtonColor
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('ยืนยัน', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
