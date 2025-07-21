import 'package:flutter/material.dart';

class POOrderDetailPage extends StatelessWidget {
  const POOrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 AppBar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
                  const Text('เลขบิลสั่งซื้อ PO-00001', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const Divider(height: 1),

            // 🔹 รายละเอียดบิล
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _infoRow('ติดต่อสื่อสาร', '(TB22499)'),
                  _infoRow('วิธีการชำระเงิน', 'แต้มเชล 30/70'),
                  _infoRow('รูปแบบการขนส่ง', 'ขนส่งทางเรือ'),
                  const SizedBox(height: 12),

                  // 🔸 ไฟล์รายการสั่งซื้อ
                  Row(
                    children: [
                      Container(
                        height: 78,
                        width: 64,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        child: Image.asset('assets/images/Simple-Red.png', fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 8),
                      const Text('ไฟล์ออเดอร์'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(thickness: 1),

            // 🔹 สรุปราคา
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _summaryRow('สรุปราคาสินค้า', 'เรทค่าสั่งซื้อสินค้า 5.00', isNote: true),
                  _summaryRow('รวมราคาสินค้า', '550.00฿'),
                  _summaryRow('รวมค่าขนส่งไปจีน', '0.00฿'),
                  _summaryRow('รวมราคา', '550.00฿', bold: true),
                ],
              ),
            ),

            const Spacer(),

            // 🔻 ปุ่มยกเลิก
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.black, side: const BorderSide(color: Colors.grey)),
                  child: const Text('ยกเลิก'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: Colors.black54, fontSize: 14))),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Colors.black, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool isNote = false, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: isNote ? Colors.blue : Colors.black87, fontSize: 14))),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
