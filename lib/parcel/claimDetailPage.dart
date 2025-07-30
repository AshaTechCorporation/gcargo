import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class ClaimDetailPage extends StatelessWidget {
  ClaimDetailPage({super.key, required this.status});
  String status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('เลขขนส่งจีน 00045', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            status == 'ยกเลิก'
                ? Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: kTextRedWanningColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Image.asset('assets/icons/info-circle.png', width: 20, height: 20),
                      const SizedBox(width: 8),
                      const Text('คืนเงินค่าสินค้าเป็น wallet', style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
                : SizedBox(),
            const SizedBox(height: 20),
            // 🔹 สินค้า
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📦 รูป
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/images/unsplash1.png', width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),

                  // 📝 รายละเอียด
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('1688', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Text('500฿ x5', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            SizedBox(width: 4),
                            Text('(100.00฿)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('รองเท้า', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            const SizedBox(width: 8),
                            _buildTag('M'),
                            const SizedBox(width: 6),
                            _buildTag('สีน้ำเงิน'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('แจ้งเคลม 1 ชิ้น', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),

                  // 💰 ราคา
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('2,500฿', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('(500.00฿)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔸 หมายเหตุ
            const Text('หมายเหตุ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text('-', style: TextStyle(color: Colors.black87, fontSize: 14)),

            const SizedBox(height: 20),

            // 🔸 รูปภาพหลักฐาน
            const Text('รูปภาพหลักฐาน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(children: [_buildImage('assets/images/image14.png'), const SizedBox(width: 8), _buildImage('assets/images/unsplash1.png')]),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // 🔘 ปุ่มยกเลิก
      bottomNavigationBar:
          status == 'ยกเลิก'
              ? null
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF002A5D)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('ยกเลิก', style: TextStyle(color: Color(0xFF002A5D))),
                  ),
                ),
              ),
    );
  }

  static Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Color(0xFFF1F3F6), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  static Widget _buildImage(String assetPath) {
    return ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(assetPath, width: 80, height: 80, fit: BoxFit.cover));
  }
}
