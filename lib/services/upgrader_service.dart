import 'package:upgrader/upgrader.dart';

class UpgraderService {
  static Upgrader createUpgrader() {
    return Upgrader(
      // กำหนดค่าต่างๆ สำหรับ upgrader
      durationUntilAlertAgain: const Duration(days: 1), // แสดงแจ้งเตือนทุก 1 วัน
      debugDisplayAlways: false, // ตั้งเป็น true เพื่อทดสอบ
      debugDisplayOnce: false, // ตั้งเป็น true เพื่อทดสอบ
      debugLogging: true, // แสดง log สำหรับ debug
      countryCode: 'TH', // รหัสประเทศไทย
      languageCode: 'th', // ภาษาไทย
      // กำหนดข้อความเป็นภาษาไทย
      messages: ThaiUpgraderMessages(),
    );
  }
}

class ThaiUpgraderMessages extends UpgraderMessages {
  @override
  String get buttonTitleIgnore => 'ข้าม';

  @override
  String get buttonTitleLater => 'ภายหลัง';

  @override
  String get buttonTitleUpdate => 'อัปเดท';

  @override
  String get prompt => 'มีเวอร์ชั่นใหม่ของแอป {{appName}} พร้อมให้ใช้งานแล้ว';

  @override
  String get title => 'อัปเดทแอป';

  @override
  String get body => 'เวอร์ชั่นใหม่ {{currentAppStoreVersion}} พร้อมให้ใช้งานแล้ว คุณกำลังใช้เวอร์ชั่น {{currentInstalledVersion}}';

  @override
  String get releaseNotes => 'รายละเอียดการอัปเดท:';

  @override
  String get updateAvailable => 'มีการอัปเดทใหม่';

  @override
  String get wouldYouLikeToUpdate => 'คุณต้องการอัปเดทหรือไม่?';
}
