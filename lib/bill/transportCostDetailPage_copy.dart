import 'package:flutter/material.dart';
import 'package:gcargo/bill/chinaShippingDetailPage.dart';

class TransportCostDetailPage extends StatelessWidget {
  TransportCostDetailPage({super.key, required this.paper_number});
  String paper_number;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('เลขที่เอกสาร $paper_number', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: Color(0xFFF3F3F3), shape: BoxShape.circle),
              child: Center(child: Image.asset('assets/icons/print-icon.png', width: 20)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Section: ข้อมูลรวม
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _rowItem('รวมค่าขนส่งจีนไทย', '1,060.00฿'),
                    _rowItem('ค่าบริการ QC', '0฿'),
                    _rowItem('ค่าตัดไม้', '0฿'),
                    _rowItem('ค่าบริการ', '50฿'),
                    _rowItem('ค่าขนส่งในไทย', '0฿'),
                    _rowItem('ส่วนลด', '0฿'),
                    const Divider(height: 24),
                    _rowItem('รวมราคาทั้งสิ้น', '1,110.00฿', bold: true),
                    _rowItem('การชำระเงิน', 'QR พร้อมเพย์'),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Text('หักภาษี ณ ที่จ่าย 1%', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              Image.asset('assets/icons/green-success.png', width: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
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

  Widget _rowItem(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
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
