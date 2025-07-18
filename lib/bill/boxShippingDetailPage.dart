import 'package:flutter/material.dart';

class BoxShippingDetailPage extends StatelessWidget {
  const BoxShippingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: Color(0xFFF3F3F3), shape: BoxShape.circle),
                      child: const Center(child: Icon(Icons.arrow_back_ios_new, size: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('เลขขนส่งจีน 00045', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                ],
              ),
            ),

            // 🔹 Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('รายละเอียดรายการ', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _rowItem('เลขพัสดุอ้างอิง', '167304'),
                    _rowItem('ประเภทสินค้า', 'ทั่วไป'),
                    _rowItem('ล็อต', 'LOT2641-1'),
                    const SizedBox(height: 20),

                    const Text('ขนาดพัสดุ', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _rowItem('น้ำหนัก', '52.00 kg'),
                    _rowItem('กว้าง×ยาว×สูง', '110 x 110 x 55 cm'),
                    _rowItem('ปริมาตร', '0.6655 cbm'),
                    _rowItem('จำนวน', '1'),
                    const SizedBox(height: 20),

                    const Text('รูปภาพพัสดุจริง', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(children: [_buildImage('assets/images/image14.png'), const SizedBox(width: 12), _buildImage('assets/images/image11.png')]),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.grey))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildImage(String assetPath) {
    return ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(assetPath, width: 80, height: 80, fit: BoxFit.cover));
  }
}
