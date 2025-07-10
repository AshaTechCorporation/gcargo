import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class ClaimDetailPage extends StatelessWidget {
  const ClaimDetailPage({super.key});

  Widget _buildClaimCard({
    required String shopCode,
    required String note,
    required String image,
    required String name,
    required String price,
    required String size,
    required String color,
    required int qty,
    required List<String> previewImages,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(shopCode, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(note, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),

        // 🔹 Row with Image + Info + Qty
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(image, width: 80, height: 80, fit: BoxFit.cover)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$price x1', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(name, style: TextStyle(color: kButtonColor)),
                  const SizedBox(height: 6),
                  Row(children: [_buildTag(size), const SizedBox(width: 8), _buildTag(color)]),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('จำนวนที่เคลม', style: TextStyle(fontSize: 12, color: Colors.black54)),
                Text(qty.toString(), style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),
        const Text('หมายเหตุ', style: TextStyle(color: Colors.black54)),
        const Text('-', style: TextStyle(fontSize: 14)),

        const SizedBox(height: 12),
        const Text('รูปภาพหลักฐานการเคลม', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),

        // 🔹 รูปภาพ Preview
        Row(
          children:
              previewImages
                  .map(
                    (img) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.asset(img, width: 80, height: 80, fit: BoxFit.cover)),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
    );
  }

  Widget _buildPriceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('สรุปราคาสินค้า', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        _SummaryRow(label: 'รวมราคาสินค้า', value: '550฿'),
        _SummaryRow(label: 'รวมค่าขนส่งเงิน', value: '0฿'),
        _SummaryRow(label: 'ส่วนลด', value: '0฿'),
        _SummaryRow(label: 'รวมราคา', value: '550฿'),
        SizedBox(height: 16),
        Divider(),
        Text('หมายเหตุ', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('-', style: TextStyle(color: Colors.black87)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
            const Expanded(child: Text('เลขที่เอกสาร C181211003', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16))),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('ยกเลิก', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('สินค้าทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),

            // 🔹 ✅ ครอบสินค้าทั้งหมดในกล่องเดียว
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClaimCard(
                    shopCode: '1688',
                    note: 'ไม่ QC  |  ไม่ตัดไม้',
                    image: 'assets/images/unsplash0.png',
                    name: 'เสื้อแขนสั้น',
                    price: '50฿',
                    size: 'M',
                    color: 'สีดำ',
                    qty: 1,
                    previewImages: const ['assets/images/unsplash0.png', 'assets/images/unsplash0.png'],
                  ),
                  const SizedBox(height: 16),
                  Divider(),
                  _buildClaimCard(
                    shopCode: '1688',
                    note: 'ไม่ QC  |  ไม่ตัดไม้',
                    image: 'assets/images/unsplash1.png',
                    name: 'รองเท้าผ้าใบ',
                    price: '500฿',
                    size: 'M',
                    color: 'สีดำ',
                    qty: 1,
                    previewImages: const ['assets/images/unsplash1.png', 'assets/images/unsplash1.png'],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Divider(),
            _buildPriceSummary(),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(color: Colors.black87)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }
}
