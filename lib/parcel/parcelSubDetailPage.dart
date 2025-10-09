import 'package:flutter/material.dart';

class ParcelSubDetailPage extends StatelessWidget {
  final Map<String, dynamic> deliveryOrderItem;
  final String orderCode;
  final Map<String, dynamic> order;

  const ParcelSubDetailPage({super.key, required this.deliveryOrderItem, required this.orderCode, required this.order});

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
        title: Text('เลขขนส่งจีน ${deliveryOrderItem['barcode'] ?? 'N/A'}', style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔹 รายละเอียดรายการ
          const Text('รายละเอียดรายการ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInfoRow('เลขบิลสั่งซื้อ', orderCode),
          _buildInfoRow('ประเภทสินค้า', order['product_type']?['name'] ?? '-'),
          _buildInfoRow('ล็อด', order['packing_list']?['packinglist_no'] ?? '-'),
          const Divider(height: 32),

          // 🔹 ขนาดพัสดุ
          const Text('ขนาดพัสดุ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInfoRow('น้ำหนัก', '${deliveryOrderItem['weight'] ?? '0'} kg'),
          _buildInfoRow(
            'กว้าง*ยาว*สูง',
            '${deliveryOrderItem['width'] ?? '0'} x ${deliveryOrderItem['long'] ?? '0'} x ${deliveryOrderItem['height'] ?? '0'} cm',
          ),
          _buildInfoRow('ปริมาตร', _calculateVolume()),
          _buildInfoRow('จำนวน', '${deliveryOrderItem['qty_box'] ?? '0'}'),
          const Divider(height: 32),

          // 🔹 รูปภาพ
          const Text('รูปภาพอ้างอิง', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildImageGallery(),
        ],
      ),
    );
  }

  // Helper method สำหรับคำนวณปริมาตร
  String _calculateVolume() {
    try {
      final width = double.tryParse(deliveryOrderItem['width']?.toString() ?? '0') ?? 0;
      final length = double.tryParse(deliveryOrderItem['long']?.toString() ?? '0') ?? 0;
      final height = double.tryParse(deliveryOrderItem['height']?.toString() ?? '0') ?? 0;

      final volume = (width * length * height) / 1000000; // แปลงจาก cm³ เป็น m³
      return '${volume.toStringAsFixed(4)} cbm';
    } catch (e) {
      return '0.0000 cbm';
    }
  }

  // Helper method สำหรับแสดงรูปภาพ
  Widget _buildImageGallery() {
    final images = deliveryOrderItem['images'] as List<dynamic>? ?? [];

    if (images.isEmpty) {
      return Container(
        height: 80,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text('ไม่มีรูปภาพ', style: TextStyle(color: Colors.grey))),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            images.map<Widget>((image) {
              final imageUrl = image['image_url'] ?? '';

              // เช็คว่า URL เป็น relative path หรือไม่
              String fullImageUrl = imageUrl;
              if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                fullImageUrl = 'https://g-cargo.dev-asha9.com/public/$imageUrl';
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      fullImageUrl.isNotEmpty
                          ? Image.network(
                            fullImageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              );
                            },
                          )
                          : Container(width: 80, height: 80, color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey)),
                ),
              );
            }).toList(),
      ),
    );
  }
}
