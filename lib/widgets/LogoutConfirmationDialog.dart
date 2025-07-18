import 'package:flutter/material.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const LogoutConfirmationDialog({super.key, required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔶 ไอคอนแจ้งเตือน
            Image.asset('assets/icons/wanningLogout.png', width: 48),
            const SizedBox(height: 20),

            // 🔸 ข้อความ
            const Text('คุณต้องการออกจากระบบหรือไม่', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            // 🔘 ปุ่ม
            Row(
              children: [
                // ปุ่มยกเลิก
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('ยกเลิก', style: TextStyle(color: Color(0xFF4A4A4A))),
                  ),
                ),
                const SizedBox(width: 12),

                // ปุ่มยืนยัน
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFC107), // ✅ สีเหลือง
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
