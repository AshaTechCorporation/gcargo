import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/models/orders/ordersPage.dart';
import 'package:gcargo/models/orders/productsTrack.dart';
import 'package:intl/intl.dart';

class DetailOrderPage extends StatelessWidget {
  final Map<String, dynamic>? orderData;
  final OrdersPage? originalOrder;

  const DetailOrderPage({super.key, this.orderData, this.originalOrder});

  // Helper methods to get data safely
  String get orderCode => orderData?['code'] ?? originalOrder?.code ?? 'N/A';
  String get orderStatus => orderData?['status'] ?? 'ไม่ทราบสถานะ';
  String get orderDate => orderData?['date'] ?? '';
  String get transportType => orderData?['transport'] ?? 'ไม่ระบุ';
  double get orderTotal => orderData?['total'] ?? 0.0;
  String get memberCode => originalOrder?.member?.code ?? 'N/A';
  String get customerNote => originalOrder?.note ?? '-';
  List<ProductsTrack> get productList => originalOrder?.order_lists ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text('เลขบิลสั่งซื้อ $orderCode', style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildInfoRow('ติดต่อ', '($memberCode)'),
                  _buildInfoRow('รูปแบบการขนส่ง', transportType),
                  _buildInfoRow('หมายเหตุของลูกค้า', customerNote),
                  _buildInfoRow('CS หมายเหตุ', '-'),
                  _buildInfoRow('วันที่สั่งซื้อ', orderDate),
                  _buildInfoRow('สถานะ', orderStatus),
                  _buildInfoRow('ราคารวม', '¥${orderTotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('สินค้าทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // 🔹 การ์ดสินค้า
                  if (productList.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(productList.first.product_store_type ?? '1688', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Text('ไม่ QC | ไม่สั่งไป', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text('ค่าส่งต่อจีน 0.00¥ / 0.00฿', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 12),

                          // 🔻 รายการสินค้าจาก ProductsTrack
                          ...productList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final product = entry.value;
                            return Column(
                              children: [_buildProductItemFromTrack(product), if (index < productList.length - 1) const SizedBox(height: 12)],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ] else ...[
                    // แสดงข้อความเมื่อไม่มีสินค้า
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('ไม่มีรายการสินค้า', style: TextStyle(color: Colors.grey, fontSize: 16))),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // 🔹 สรุปราคา
                  _buildPriceSummary(),
                ],
              ),
            ),

            // 🔻 ปุ่มล่าง
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('ยกเลิก', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kButtonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('สั่งซื้ออีกครั้ง', style: TextStyle(fontSize: 16)),
                    ),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(color: Colors.black))),
          Expanded(flex: 5, child: Text(value, style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildProductItemFromTrack(ProductsTrack product) {
    final productPrice = product.product_price ?? '0';
    final productQty = product.product_qty ?? 1;
    final productName = product.product_name ?? 'ไม่ระบุชื่อสินค้า';
    final productImage = product.product_image;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔺 รูปภาพสินค้า
        _buildProductImage(productImage),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¥$productPrice x$productQty', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('(${_calculateBahtPrice(productPrice)} ฿)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(productName, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              // แสดง options ถ้ามี
              if (product.options != null && product.options!.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children:
                      product.options!.map((option) {
                        return _buildTag(option.option_name ?? '', filled: true);
                      }).toList(),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text('¥$productPrice', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            );
          },
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
  }

  String _calculateBahtPrice(String yuanPrice) {
    try {
      final yuan = double.parse(yuanPrice);
      final baht = yuan * 4.0; // Assuming 1 Yuan = 4 Baht
      return baht.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  Widget _buildTag(String text, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFEDF6FF) : Colors.transparent,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.blue)),
    );
  }

  Widget _buildPriceSummary() {
    final totalProductPrice = _calculateTotalProductPrice();
    final totalBahtPrice = _calculateTotalBahtPrice();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceRow('สรุปราคารวมสินค้า', 'เรทส่งซื้อล่าสุด 4.00'),
          const Divider(),
          _buildPriceRow('รวมราคาสินค้า', '¥${totalProductPrice.toStringAsFixed(2)} (${totalBahtPrice.toStringAsFixed(2)}฿)'),
          _buildPriceRow('รวมค่าส่งในจีน', '0.00฿'),
          _buildPriceRow('ค่าบริการอื่น ๆ', '0.00฿'),
          _buildPriceRow('ส่วนลด', '0.00฿'),
          const Divider(),
          _buildPriceRow('ราคารวม', '¥${totalProductPrice.toStringAsFixed(2)} (${totalBahtPrice.toStringAsFixed(2)}฿)', isBold: true),
        ],
      ),
    );
  }

  double _calculateTotalProductPrice() {
    double total = 0.0;
    for (var product in productList) {
      try {
        final price = double.parse(product.product_price ?? '0');
        final qty = product.product_qty ?? 1;
        total += price * qty;
      } catch (e) {
        // Skip invalid prices
      }
    }
    return total;
  }

  double _calculateTotalBahtPrice() {
    return _calculateTotalProductPrice() * 4.0; // Assuming 1 Yuan = 4 Baht
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
