import 'package:flutter/material.dart';
import 'package:gcargo/bill/chinaShippingDetailPage.dart';

class TransportCostDetailPage extends StatelessWidget {
  TransportCostDetailPage({super.key, required this.paper_number});
  String paper_number;

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
                  Expanded(child: Text('เลขที่เอกสาร ${paper_number}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: Center(child: Image.asset('assets/icons/print-icon.png', width: 20)),
                  ),
                ],
              ),
            ),

            // 🔹 Section: ข้อมูลรวม
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _rowItem('รวมค่าขนส่งจีนไทย', '1,060.00฿'),
                    _rowItem('การชำระเงิน', 'QR พร้อมเพย์'),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text('หักภาษี ณ ที่จ่าย 1%', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              Image.asset('assets/icons/green-success.png', width: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _rowItem('บริษัทขนส่งในไทย', '-'),
                    _rowItem('หมายเลขขนส่งในประเทศไทย', '-'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Section: รายการขนส่งจีน
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text('เลขขนส่งจีน', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const Divider(height: 1),
                    ..._buildChinaRows(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  List<Widget> _buildChinaRows(BuildContext context) {
    final data = [
      {'code': '00035', 'price': '660.00฿'},
      {'code': '00034', 'price': '100.00฿'},
      {'code': '00033', 'price': '100.00฿'},
      {'code': '00032', 'price': '100.00฿'},
      {'code': '00031', 'price': '100.00฿'},
    ];

    return data.map((item) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChinaShippingDetailPage(transportNo: item['code']!))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['code']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(item['price']!, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
        ],
      );
    }).toList();
  }
}
