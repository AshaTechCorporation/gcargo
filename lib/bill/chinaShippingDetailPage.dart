import 'package:flutter/material.dart';
import 'package:gcargo/bill/boxShippingDetailPage.dart';

class ChinaShippingDetailPage extends StatelessWidget {
  ChinaShippingDetailPage({super.key, required this.transportNo});
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
        title: Text('เลขขนส่งจีน $transportNo', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildCard(
                      icon: 'assets/icons/calendar.png',
                      title: 'กำหนดการ',
                      content: Column(
                        children: const [
                          _DetailRow(label: 'ถึงโกดังจีน', value: '01/07/2025'),
                          _DetailRow(label: 'ออกจากโกดังจีน', value: '03/07/2025'),
                          _DetailRow(label: 'คาดจะถึงไทย', value: '08/07/2025'),
                          _DetailRow(label: 'โกดังไทยรับสินค้า', value: '08/07/2025'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildCard(
                      icon: 'assets/icons/book.png',
                      title: 'รายละเอียดสินค้า',
                      content: Column(
                        children: const [_DetailRow(label: 'ประเภทสินค้า', value: 'ทั่วไป'), _DetailRow(label: 'หมายเหตุของลูกค้า', value: '-')],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildCard(
                      icon: 'assets/icons/box.png',
                      title: 'ค่าใช้จ่าย',
                      content: Column(
                        children: const [
                          _DetailRow(label: 'ค่าขนส่งจีนไทย', value: '660.00฿'),
                          _DetailRow(label: 'ค่าบริการ QC', value: '0฿'),
                          _DetailRow(label: 'ค่าตัดไม้', value: '0฿'),
                          _DetailRow(label: 'รวมราคา', value: '660.00฿'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildCard(
                      icon: 'assets/icons/box.png',
                      title: 'พัสดุทั้งหมด',
                      suffix: const Text('5 ลัง', style: TextStyle(fontWeight: FontWeight.w600)),
                      content: Column(
                        children: [
                          _buildBoxItem(context, '00045-1'),
                          _buildBoxItem(context, '00045-2'),
                          _buildBoxItem(context, '00045-3'),
                          _buildBoxItem(context, '00045-4'),
                          _buildBoxItem(context, '00045-5'),
                        ],
                      ),
                    ),
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

  Widget _buildCard({required String icon, required String title, required Widget content, Widget? suffix}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(color: Color(0xFFF3F3F3), shape: BoxShape.circle),
                child: Center(child: Image.asset(icon, width: 16, height: 16)),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (suffix != null) ...[const Spacer(), suffix],
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildBoxItem(BuildContext context, String label) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => BoxShippingDetailPage(transportNo: label)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.blue)),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(color: Color(0xFFF3F3F3), shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
}
