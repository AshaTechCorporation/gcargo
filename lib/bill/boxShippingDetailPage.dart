import 'package:flutter/material.dart';

class BoxShippingDetailPage extends StatelessWidget {
  BoxShippingDetailPage({super.key, required this.transportNo});
  final String transportNo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('เลขขนส่งจีน ${transportNo}', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 🔹 รายละเอียดรายการ
              const Text('รายละเอียดรายการ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              _rowItem('เลขพัสดุอ้างอิง', '167304'),
              _rowItem('ประเภทสินค้า', 'ทั่วไป'),
              _rowItem('ล็อต', 'LOT0001'),

              const SizedBox(height: 20),

              // 🔹 ขนาดพัสดุ
              const Text('ขนาดพัสดุ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              _rowItem('น้ำหนัก', '52.00 kg'),
              _rowItem('กว้าง×ยาว×สูง', '110 x 110 x 55 cm'),
              _rowItem('ปริมาตร', '0.6655 cbm'),
              _rowItem('จำนวน', '1'),

              const SizedBox(height: 20),

              // 🔹 รูปภาพ
              const Text('รูปภาพพัสดุจริง', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              Row(children: [_buildImage('assets/images/image14.png'), const SizedBox(width: 12), _buildImage('assets/images/image11.png')]),

              const SizedBox(height: 24),
            ],
          ),
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
