import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('บัญชีของฉัน', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings, color: Colors.black))],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: kButtonColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, size: 40, color: kButtonColor),
                  ),
                  const SizedBox(height: 16),
                  const Text('สมชาย ใจดี', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('somchai@email.com', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text('โทร: 081-234-5678', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('แก้ไขโปรไฟล์', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),

            // Quick Stats
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard(icon: Icons.local_shipping, title: 'พัสดุทั้งหมด', value: '24', color: Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(icon: Icons.receipt_long, title: 'บิลทั้งหมด', value: '18', color: Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(icon: Icons.star, title: 'คะแนน', value: '4.8', color: Colors.orange)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  _buildMenuItem(icon: Icons.location_on, title: 'ที่อยู่ของฉัน', subtitle: 'จัดการที่อยู่สำหรับส่งพัสดุ', onTap: () {}),
                  _buildMenuItem(icon: Icons.payment, title: 'วิธีการชำระเงิน', subtitle: 'จัดการบัตรเครดิตและวิธีชำระเงิน', onTap: () {}),
                  _buildMenuItem(icon: Icons.history, title: 'ประวัติการใช้งาน', subtitle: 'ดูประวัติการส่งพัสดุทั้งหมด', onTap: () {}),
                  _buildMenuItem(icon: Icons.notifications, title: 'การแจ้งเตือน', subtitle: 'ตั้งค่าการแจ้งเตือน', onTap: () {}),
                  _buildMenuItem(icon: Icons.help_outline, title: 'ช่วยเหลือ', subtitle: 'คำถามที่พบบ่อยและการติดต่อ', onTap: () {}),
                  _buildMenuItem(icon: Icons.info_outline, title: 'เกี่ยวกับเรา', subtitle: 'ข้อมูลเกี่ยวกับ G-Cargo', onTap: () {}),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'ออกจากระบบ',
                    subtitle: 'ออกจากบัญชีผู้ใช้',
                    onTap: () {},
                    isLast: true,
                    textColor: Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // App Version
            Text('G-Cargo v1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1))),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: (textColor ?? kButtonColor).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: textColor ?? kButtonColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor ?? Colors.black87)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
