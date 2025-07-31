import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class OrderDetailPage extends StatelessWidget {
  OrderDetailPage({super.key, required this.status});
  String status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('เลขบิลสั่งซื้อ 00001', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: Image.asset('assets/icons/print-icon.png', height: 20),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔸 กล่องเตือน
            status == 'สำเร็จ'
                ? Container(
                  width: double.infinity,
                  color: const Color(0xFFFFF7D8),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC107)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'เอกสารจะจัดส่งให้ทางไลน์ภายใน 24 ชั่วโมง\nหลังจากชำระเงินสำเร็จ',
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                )
                : Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: kTextRedWanningColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Image.asset('assets/icons/info-circle.png', width: 20, height: 20),
                      const SizedBox(width: 8),
                      const Text('ร้านค้าไม่มีสีตามที่สั่งซื้อจึงต้องยกเลิกรายการสินค้านี้', style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),

            const Divider(height: 1),

            // 🔹 รายละเอียดจัดส่ง
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('ติดต่อ', '(TB22499)'),
                  _infoRow('รูปแบบการขนส่ง', 'ขนส่งด่วนจี๋'),
                  _infoRow('หมายเหตุ', '-'),
                  _infoRow('CS หมายเหตุ', '-'),
                ],
              ),
            ),

            const Divider(thickness: 1),

            // 🔹 รายการสินค้า
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('สินค้าทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    // 🔸 การ์ดรวมสินค้า + Header ร้าน
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 Header ร้าน + Options
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ร้าน 1688', style: TextStyle(fontWeight: FontWeight.bold)),
                              Row(
                                children: const [
                                  Text('ไม่ QC', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                  SizedBox(width: 12),
                                  Text('ไม่ใส่ถุงใบ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 🔹 สินค้า 1
                          _buildProductItem(
                            image: 'assets/images/unsplash0.png',
                            name: 'เสื้อแฟชั่น',
                            price: 50,
                            qty: 1,
                            size: 'M',
                            color: 'สีดำ',
                            shipping: 'ค่าส่งไปจีนร้าน 08',
                          ),

                          const Divider(height: 24),

                          // 🔹 สินค้า 2
                          _buildProductItem(
                            image: 'assets/images/unsplash1.png',
                            name: 'รองเท้าผ้าใบ',
                            price: 500,
                            qty: 1,
                            size: 'M',
                            color: 'สีดำ',
                            shipping: 'ค่าส่งไปจีนร้าน 08',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(thickness: 1),

                    // 🔹 สรุปราคา
                    _buildSummaryRow('สรุปราคาสินค้า', 'เรทค่าสั่งซื้อสินค้า 5.00', isNote: true),
                    _buildSummaryRow('รวมราคาสินค้า', '550.00฿'),
                    _buildSummaryRow('รวมค่าขนส่งไปจีน', '0.00฿'),
                    _buildSummaryRow('ส่วนลด', '0.00฿'),
                    _buildSummaryRow('รวมราคา', '550.00฿', bold: true),
                    status == 'สำเร็จ' ? _buildSummaryRow('การชำระเงิน', 'QR พร้อมเพย์', showIcon: true) : SizedBox(),
                    status == 'สำเร็จ' ? _buildSummaryRow('ใบกำกับภาษี (VAT 7%)', '', showCheck: true) : SizedBox(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: Colors.black54))),
          Expanded(child: Text(value, style: TextStyle(color: Colors.black), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildProductItem({
    required String image,
    required String name,
    required double price,
    required int qty,
    required String size,
    required String color,
    required String shipping,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.asset(image, height: 60, width: 60, fit: BoxFit.cover)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${price.toStringAsFixed(0)}฿ x$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(name, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Row(children: [_labelBox(size), const SizedBox(width: 4), _labelBox(color)]),
              const SizedBox(height: 4),
              Text(shipping, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Text('${(price * qty).toStringAsFixed(0)}฿', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  static Widget _labelBox(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isNote = false, bool bold = false, bool showIcon = false, bool showCheck = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: isNote ? Colors.blue : Colors.black87, fontSize: 14))),
          if (showIcon) const Icon(Icons.qr_code, size: 18, color: Colors.green),
          if (showCheck) const Icon(Icons.check_circle, size: 18, color: Colors.green),
          if (!showIcon && !showCheck) Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
