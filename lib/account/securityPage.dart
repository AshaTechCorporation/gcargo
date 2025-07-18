import 'package:flutter/material.dart';
import 'package:gcargo/account/changePinPage.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool isPinEnabled = true;
  bool isFaceIDEnabled = false;
  bool isFingerprintEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ความปลอดภัย'), leading: BackButton(color: Colors.black), backgroundColor: Colors.white, elevation: 0),
      body: ListView(
        children: [
          _buildSwitchTile(
            title: 'เข้าสู่ระบบด้วยรหัส PIN',
            subtitle: 'ใช้สำหรับอุปกรณ์นี้เพื่อยืนยันตัวตนก่อนการป้อนรหัสผ่านทุกครั้งที่เข้าสู่ระบบ',
            value: isPinEnabled,
            onChanged: (value) => setState(() => isPinEnabled = value),
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
            onChanged: (value) => setState(() => isFaceIDEnabled = value),
          ),
          _buildSwitchTile(
            title: 'เข้าสู่ระบบด้วย Fingerprint',
            subtitle: 'ใช้สำหรับอุปกรณ์นี้เพื่อยืนยันตัวตนก่อนการป้อนรหัสผ่านทุกครั้งที่เข้าสู่ระบบ',
            value: isFingerprintEnabled,
            onChanged: (value) => setState(() => isFingerprintEnabled = value),
          ),
        ],
      ),
    );
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
