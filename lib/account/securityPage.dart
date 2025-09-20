import 'package:flutter/material.dart';
import 'package:gcargo/account/changePinPage.dart';
import 'package:gcargo/auth/pinAuthPage.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/services/auth_service.dart';
import 'package:gcargo/services/biometric_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool isPinEnabled = true;
  bool isFaceIDEnabled = false;
  bool isFingerprintEnabled = true;
  bool isLoading = true;
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {'security': 'ความปลอดภัย'},
      'en': {'security': 'Security'},
      'zh': {'security': '安全'},
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    _loadSecuritySettings();
  }

  // โหลดการตั้งค่าความปลอดภัยจาก SharedPreferences
  Future<void> _loadSecuritySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        isPinEnabled = prefs.getBool('security_pin_enabled') ?? true;
        isFaceIDEnabled = prefs.getBool('security_faceid_enabled') ?? false;
        isFingerprintEnabled = prefs.getBool('security_fingerprint_enabled') ?? true;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading security settings: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // บันทึกการตั้งค่า PIN
  Future<void> _savePinSetting(bool value) async {
    try {
      if (value) {
        // ถ้าเปิดใช้งาน PIN ให้ตรวจสอบว่ามี PIN ตั้งไว้หรือไม่
        final hasPin = await AuthService.hasPinSet();
        if (!hasPin) {
          // ถ้าไม่มี PIN ให้ไปตั้ง PIN ก่อน
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PinAuthPage(
                    onSuccess: () {
                      Navigator.pop(context, true);
                    },
                    isSetup: true,
                  ),
            ),
          );

          if (result != true) {
            // ถ้าไม่ได้ตั้ง PIN ให้ยกเลิก
            return;
          }
        }
      }

      final success = await AuthService.saveSecuritySetting('pin', value);
      if (success) {
        setState(() {
          isPinEnabled = value;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(value ? 'เปิดใช้งานรหัส PIN แล้ว' : 'ปิดใช้งานรหัส PIN แล้ว'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่สามารถบันทึกการตั้งค่าได้'), backgroundColor: Colors.red));
      }
    } catch (e) {
      print('Error saving PIN setting: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่สามารถบันทึกการตั้งค่าได้'), backgroundColor: Colors.red));
    }
  }

  // บันทึกการตั้งค่า Face ID
  Future<void> _saveFaceIDSetting(bool value) async {
    try {
      if (value) {
        // ตรวจสอบว่าอุปกรณ์รองรับ Face ID หรือไม่
        final hasFaceID = await BiometricService.hasFaceID();
        if (!hasFaceID) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('อุปกรณ์ไม่รองรับ Face ID'), backgroundColor: Colors.red));
          return;
        }

        // ทดสอบ Face ID
        final result = await BiometricService.authenticateWithFaceID();
        if (!result.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.errorMessage ?? 'ไม่สามารถใช้ Face ID ได้'), backgroundColor: Colors.red));
          return;
        }
      }

      final success = await AuthService.saveSecuritySetting('faceid', value);
      if (success) {
        setState(() {
          isFaceIDEnabled = value;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(value ? 'เปิดใช้งาน Face ID แล้ว' : 'ปิดใช้งาน Face ID แล้ว'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่สามารถบันทึกการตั้งค่าได้'), backgroundColor: Colors.red));
      }
    } catch (e) {
      print('Error saving Face ID setting: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่สามารถบันทึกการตั้งค่าได้'), backgroundColor: Colors.red));
    }
  }

  // บันทึกการตั้งค่า Fingerprint
  Future<void> _saveFingerprintSetting(bool value) async {
    try {
      if (value) {
        // ตรวจสอบว่าอุปกรณ์รองรับ Fingerprint หรือไม่
        final hasFingerprint = await BiometricService.hasFingerprint();
        if (!hasFingerprint) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('อุปกรณ์ไม่รองรับลายนิ้วมือ'), backgroundColor: Colors.red));
          return;
        }

        // ทดสอบ Fingerprint
        final result = await BiometricService.authenticateWithFingerprint();
        if (!result.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.errorMessage ?? 'ไม่สามารถใช้ลายนิ้วมือได้'), backgroundColor: Colors.red));
          return;
        }
      }

      final success = await AuthService.saveSecuritySetting('fingerprint', value);
      if (success) {
        setState(() {
          isFingerprintEnabled = value;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(value ? 'เปิดใช้งาน Fingerprint แล้ว' : 'ปิดใช้งาน Fingerprint แล้ว'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่สามารถบันทึกการตั้งค่าได้'), backgroundColor: Colors.red));
      }
    } catch (e) {
      print('Error saving Fingerprint setting: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่สามารถบันทึกการตั้งค่าได้'), backgroundColor: Colors.red));
    }
  }

  // Static method สำหรับอ่านการตั้งค่าความปลอดภัยจากที่อื่น
  static Future<Map<String, bool>> getSecuritySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'pin_enabled': prefs.getBool('security_pin_enabled') ?? true,
        'faceid_enabled': prefs.getBool('security_faceid_enabled') ?? false,
        'fingerprint_enabled': prefs.getBool('security_fingerprint_enabled') ?? true,
      };
    } catch (e) {
      print('Error getting security settings: $e');
      return {'pin_enabled': true, 'faceid_enabled': false, 'fingerprint_enabled': true};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading) {
        return Scaffold(
          appBar: AppBar(
            title: Text(getTranslation('security')),
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: Text(getTranslation('security')),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          children: [
            _buildSwitchTile(
              title: 'เข้าสู่ระบบด้วยรหัส PIN',
              subtitle: 'ใช้สำหรับอุปกรณ์นี้เพื่อยืนยันตัวตนก่อนการป้อนรหัสผ่านทุกครั้งที่เข้าสู่ระบบ',
              value: isPinEnabled,
              onChanged: _savePinSetting,
            ),
            _buildArrowTile(
              title: 'เปลี่ยนรหัส PIN',
              onTap: () {
                // TODO: ไปหน้าเปลี่ยน PIN
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePinPage()));
              },
            ),
            _buildSwitchTile(
              title: 'เข้าสู่ระบบด้วย Face ID',
              subtitle: 'ใช้สำหรับอุปกรณ์นี้เพื่อยืนยันตัวตนก่อนการป้อนรหัสผ่านทุกครั้งที่เข้าสู่ระบบ',
              value: isFaceIDEnabled,
              onChanged: _saveFaceIDSetting,
            ),
            _buildSwitchTile(
              title: 'เข้าสู่ระบบด้วย Fingerprint',
              subtitle: 'ใช้สำหรับอุปกรณ์นี้เพื่อยืนยันตัวตนก่อนการป้อนรหัสผ่านทุกครั้งที่เข้าสู่ระบบ',
              value: isFingerprintEnabled,
              onChanged: _saveFingerprintSetting,
            ),
          ],
        ),
      );
    }); // ปิด Obx
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(title, style: const TextStyle(fontSize: 15)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          trailing: Switch(value: value, onChanged: onChanged, activeColor: Colors.white, activeTrackColor: Colors.blue),
        ),
        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFE0E0E0)),
      ],
    );
  }

  Widget _buildArrowTile({required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(title, style: const TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFE0E0E0)),
      ],
    );
  }
}
