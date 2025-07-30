import 'package:flutter/material.dart';

class ParcelSubDetailPage extends StatelessWidget {
  const ParcelSubDetailPage({super.key});

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Expanded(child: Text(label)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('เลขขนส่งจีน 00045', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔹 รายละเอียดรายการ
          const Text('รายละเอียดรายการ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInfoRow('เลขบิลสั่งซื้อ', '167304'),
          _buildInfoRow('ประเภทสินค้า', 'ทั่วไป'),
          _buildInfoRow('ล็อด', 'รอตรวจสอบ'),
          const Divider(height: 32),

          // 🔹 ขนาดพัสดุ
          const Text('ขนาดพัสดุ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInfoRow('น้ำหนัก', '52.00 kg'),
          _buildInfoRow('กว้าง*ยาว*สูง', '110 x 110 x 55 cm'),
          _buildInfoRow('ปริมาตร', '0.6655 cbm'),
          _buildInfoRow('จำนวน', '1'),
          const Divider(height: 32),

          // 🔹 รูปภาพ
          const Text('รูปภาพอ้างอิง', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/images/image14.png', width: 80, height: 80, fit: BoxFit.cover),
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/images/image14.png', width: 80, height: 80, fit: BoxFit.cover),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
