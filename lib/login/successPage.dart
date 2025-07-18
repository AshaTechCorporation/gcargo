import 'package:flutter/material.dart';
import 'package:gcargo/home/firstPage.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              // ✅ เนื้อหาตรงกลาง
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/icons/iconsuccess.png', width: 24, height: 24),
                      const SizedBox(width: 12),
                      const Flexible(
                        child: Text('ยินดีด้วย! บัญชีของคุณพร้อมใช้งานแล้ว', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'การขนส่งระหว่างประเทศ\nรวดเร็ว ปลอดภัย เริ่มต้นใช้งานกับเรา',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const Spacer(),
              // ✅ ปุ่มด้านล่าง
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const FirstPage()), (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002A5D),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('เริ่มต้นใช้งาน', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
