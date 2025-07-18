import 'package:flutter/material.dart';
import 'package:gcargo/login/successPage.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool useFaceID = false;
  bool useFingerprint = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.arrow_back_ios, size: 20),
              const SizedBox(height: 16),
              const Text('ความปลอดภัย', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('สมัครใช้งานง่าย ส่งของจากจีนถึงไทยสบายใจทุกขั้นตอน', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 32),
              _buildSwitchTile(title: 'เข้าสู่ระบบด้วย Face ID', value: useFaceID, onChanged: (val) => setState(() => useFaceID = val)),
              const Divider(height: 1),
              _buildSwitchTile(title: 'เข้าสู่ระบบด้วย Fingerprint', value: useFingerprint, onChanged: (val) => setState(() => useFingerprint = val)),
              const Divider(height: 1),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // กด "ยืนยัน" แล้วทำอะไรต่อ
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SuccessPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002A5D),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('ยืนยัน', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text(
                  'ใช้สำหรับอุปกรณ์นี้เพื่อหลีกเลี่ยงการป้อนรหัสผ่านทุกครั้งที่เข้าสู่ระบบ',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
