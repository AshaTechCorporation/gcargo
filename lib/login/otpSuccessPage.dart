import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/login/loginPage.dart';

class OtpSuccessPage extends StatelessWidget {
  const OtpSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // ✅ รูป + ข้อความหลัก จัดแบบ Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/iconsuccess.png', width: 32, height: 32),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('ยินดีด้วย! บัญชีของคุณพร้อมใช้งานแล้ว', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                ],
              ),

              const SizedBox(height: 16),

              // ✅ ข้อความรอง
              const Text(
                'การขนส่งระหว่างประเทศ\nรวดเร็ว ปลอดภัย เริ่มต้นใช้งานกับเรา',
                style: TextStyle(fontSize: 13, color: kHintTextColor),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // ✅ ปุ่ม “เริ่มต้นใช้งาน”
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: นำไปหน้า Home หรือ Login
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kButtonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('เริ่มต้นใช้งาน', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
