import 'package:flutter/material.dart';

class ClaimRefundDetailPage extends StatelessWidget {
  const ClaimRefundDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text('เลขขนส่งจีน 00045', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
          bottom: const TabBar(
            indicatorColor: Color(0xFF246BFD),
            labelColor: Color(0xFF246BFD),
            unselectedLabelColor: Colors.black,
            tabs: [Tab(text: 'ข้อมูลพัสดุ'), Tab(text: 'การเคลม')],
          ),
        ),
        body: const TabBarView(children: [_ParcelInfoTab(), _ClaimInfoTab()]),
      ),
    );
  }
}

class _ParcelInfoTab extends StatelessWidget {
  const _ParcelInfoTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ✅ Refund status bar
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFEAF7E9), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Image.asset('assets/icons/iconsuccess.png', width: 20, height: 20),
              const SizedBox(width: 8),
              const Text('คืนเงินค่าสินค้าเป็น wallet', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 🧾 Product card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/unsplash1.png', width: 60, height: 60, fit: BoxFit.cover),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1688', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('500฿ x5\n(100.00฿)', style: TextStyle(fontSize: 12)), Text('2,500฿ (500.00฿)', textAlign: TextAlign.right)],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Chip(label: Text('M'), visualDensity: VisualDensity.compact),
                        SizedBox(width: 6),
                        Chip(label: Text('สีน้ำเงิน'), visualDensity: VisualDensity.compact),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('แจ้งเคลม 1 ชิ้น', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const Text('หมายเหตุ', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('-', style: TextStyle(color: Colors.black87)),

        const SizedBox(height: 16),
        const Text('รูปภาพหลักฐาน', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [_imageBox('assets/images/image14.png'), const SizedBox(width: 8), _imageBox('assets/images/unsplash1.png')]),
      ],
    );
  }

  Widget _imageBox(String path) {
    return ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(path, width: 60, height: 60, fit: BoxFit.cover));
  }
}

class _ClaimInfoTab extends StatelessWidget {
  const _ClaimInfoTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ✅ Refund status bar
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFEAF7E9), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Image.asset('assets/icons/iconsuccess.png', width: 20, height: 20),
              const SizedBox(width: 8),
              const Text('คืนเงินค่าสินค้าเป็น wallet', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 🧾 Product card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/unsplash1.png', width: 60, height: 60, fit: BoxFit.cover),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('1688', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('500฿ x5\n(100.00฿)', style: TextStyle(fontSize: 12)), Text('2,500฿ (500.00฿)', textAlign: TextAlign.right)],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Chip(label: Text('M'), visualDensity: VisualDensity.compact),
                        SizedBox(width: 6),
                        Chip(label: Text('สีน้ำเงิน'), visualDensity: VisualDensity.compact),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('แจ้งเคลม 1 ชิ้น', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 📦 Refund detail section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, size: 18, color: Colors.black87),
                  const SizedBox(width: 8),
                  const Text('การคืนเงิน', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              _buildRefundRow('รวมราคาสินค้า', '500฿'),
              _buildRefundRow('รวมค่าส่งไปจีน', '0.008'),
              _buildRefundRow('รวมค่าส่งไปไทย', '0.008'),
              _buildRefundRow('รวมราคา', '500฿'),
              _buildRefundRow('คืนเงิน', 'wallet'),
              _buildRefundRow('วันที่คืนเงิน', '01/07/2025'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRefundRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(color: Colors.black87)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }
}
