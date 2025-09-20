import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:get/get.dart';

class RewardSuccessPage extends StatelessWidget {
  const RewardSuccessPage({super.key});

  String getTranslation(String key) {
    final languageController = Get.find<LanguageController>();
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'congratulations': 'ยินดีด้วย! คุณแลกของรางวัลแล้ว',
        'reward_pending': 'คำขอแลกรางวัลกำลังอยู่ระหว่างการอนุมัติ\nระบบจะแจ้งผลให้ทราบทันทีหลังจากขั้นตอนดังกล่าวเสร็จสิ้น\nขอขอบพระคุณที่ใช้บริการ',
        'go_back': 'ย้อนกลับ',
        'success': 'สำเร็จ',
        'processing': 'กำลังดำเนินการ',
        'thank_you': 'ขอบคุณ',
      },
      'en': {
        'congratulations': 'Congratulations! You have redeemed a reward',
        'reward_pending':
            'Your reward redemption request is pending approval.\nWe will notify you immediately after the process is completed.\nThank you for using our service.',
        'go_back': 'Go Back',
        'success': 'Success',
        'processing': 'Processing',
        'thank_you': 'Thank You',
      },
      'zh': {
        'congratulations': '恭喜！您已兑换奖励',
        'reward_pending': '您的奖励兑换请求正在等待批准。\n流程完成后我们会立即通知您。\n感谢您使用我们的服务。',
        'go_back': '返回',
        'success': '成功',
        'processing': '处理中',
        'thank_you': '谢谢',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Obx(
      () => Scaffold(
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
                    Text(getTranslation('congratulations'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  getTranslation('reward_pending'),
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
                    child: Text(getTranslation('go_back'), style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
