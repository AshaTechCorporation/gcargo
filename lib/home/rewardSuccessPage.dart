import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class RewardSuccessPage extends StatelessWidget {
  const RewardSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/iconsuccess.png', width: 36, height: 36),
                  SizedBox(width: 12),
                  Text('ยินดีด้วย! คุณแลกของรางวัลแล้ว', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'คำขอแลกรางวัลกำลังอยู่ระหว่างการอนุมัติ\nระบบจะแจ้งผลให้ทราบทันทีหลังจากขั้นตอนดังกล่าวเสร็จสิ้น\nขอขอบพระคุณที่ใช้บริการ',
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kButtonColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('ย้อนกลับ', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
