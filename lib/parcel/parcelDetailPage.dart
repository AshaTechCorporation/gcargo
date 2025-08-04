import 'package:flutter/material.dart';
import 'package:gcargo/parcel/parcelSubDetailPage.dart';

class ParcelDetailPage extends StatelessWidget {
  final String status;

  const ParcelDetailPage({super.key, required this.status});

  Widget _buildSectionTitle(String iconPath, String title) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: Color(0xFFE9F4FF), shape: BoxShape.circle),
          child: Center(child: Image.asset(iconPath, width: 18, height: 18)),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBox({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: child,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🔹 กล่อง: กำหนดการ
            _buildBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('assets/icons/calendar.png', 'กำหนดการ'),
                  const SizedBox(height: 12),
                  _buildInfoRow('ถึงโกดังจีน', '-'),
                  _buildInfoRow('ออกจากโกดังจีน', '-'),
                  _buildInfoRow('คาดจะถึงไทย', '-'),
                  _buildInfoRow('โกดังไทยรับสินค้า', '-'),
                ],
              ),
            ),

            // 🔹 กล่อง: รายละเอียดสินค้า
            _buildBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('assets/icons/book.png', 'รายละเอียดสินค้า'),
                  const SizedBox(height: 12),
                  _buildInfoRow('เลขบิลสั่งซื้อ', '167304'),
                  _buildInfoRow('เลขบิลหน้าโกดัง', '000000'),
                  _buildInfoRow('ประเภทสินค้า', 'ทั่วไป'),
                  _buildInfoRow('หมายเหตุของลูกค้า', '.'),
                ],
              ),
            ),

            // 🔹 กล่อง: ค่าใช้จ่าย (ซ่อนถ้าสถานะเป็น รอส่งไปโกดังจีน หรือ ถึงโกดังจีน)
            if (status != 'รอส่งไปโกดังจีน' && status != 'ถึงโกดังจีน')
              _buildBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('assets/icons/dollar-circle.png', 'ค่าใช้จ่าย'),
                    const SizedBox(height: 12),
                    _buildInfoRow('ค่าขนส่งจีนไทย', ' 8516.00฿'),
                    _buildInfoRow('ค่าบริการ QC', ' 0฿'),
                    _buildInfoRow('ค่าตีลังไม้', ' 0฿'),
                    _buildInfoRow('รวมราคา', ' 8516.00฿'),
                  ],
                ),
              ),

            // 🔹 กล่อง: การชำระเงิน (ซ่อนถ้าสถานะเป็น รอส่งไปโกดังจีน หรือ ถึงโกดังจีน)
            if (status != 'รอส่งไปโกดังจีน' && status != 'ถึงโกดังจีน')
              _buildBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('assets/icons/menu-board-blue.png', 'การชำระเงิน'),
                    const SizedBox(height: 12),
                    _buildInfoRow('การชำระเงิน', 'QR พร้อมเพย์'),
                    _buildInfoRow('เลขที่เอกสาร  X2504290002', '.'),
                  ],
                ),
              ),

            // 🔹 กล่อง: พัสดุทั้งหมด
            _buildBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildSectionTitle('assets/icons/box.png', 'พัสดุทั้งหมด'),
                      const Spacer(),
                      const Text('5 ชิ้น', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final parcelCode = '00045-${index + 1}';
                      return Container(
                        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          title: Text(parcelCode),
                          trailing: const Icon(Icons.chevron_right),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcelSubDetailPage())),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Expanded(child: Text(label)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }
}
