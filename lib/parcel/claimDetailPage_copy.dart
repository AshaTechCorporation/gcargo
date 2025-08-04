import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/claim_detail_controller.dart';

class ClaimDetailPage extends StatefulWidget {
  const ClaimDetailPage({super.key, required this.deliveryOrderId});
  final int deliveryOrderId;

  @override
  State<ClaimDetailPage> createState() => _ClaimDetailPageState();
}

class _ClaimDetailPageState extends State<ClaimDetailPage> {
  late ClaimDetailController claimController;

  @override
  void initState() {
    super.initState();
    claimController = Get.put(ClaimDetailController());
    // เรียก API ทันทีเมื่อเข้าหน้า
    claimController.getDeliveryOrderById(widget.deliveryOrderId);
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ข้อมูลออเดอร์', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildInfoRow('รหัสออเดอร์', claimController.orderCode),
          _buildInfoRow('PO Number', claimController.poNumber),
          _buildInfoRow('วันที่', claimController.orderDate),
          _buildInfoRow('สถานะ', claimController.getStatusText(claimController.status)),
          _buildInfoRow('ผู้รับ', claimController.memberName),
          _buildInfoRow('เบอร์โทร', claimController.memberPhone),
          _buildInfoRow('คนขับ', claimController.driverName),
          _buildInfoRow('เบอร์คนขับ', claimController.driverPhone),
          _buildInfoRow('หมายเหตุ', claimController.note),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.black54))),
          const Text(': '),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    final orderLists = claimController.orderLists;

    if (orderLists.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: const Center(child: Text('ไม่มีรายการสินค้า', style: TextStyle(color: Colors.grey, fontSize: 16))),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            orderLists.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Column(children: [if (index > 0) const Divider(), if (index > 0) const SizedBox(height: 16), _buildProductCard(item)]);
            }).toList(),
      ),
    );
  }

  Widget _buildProductCard(dynamic item) {
    // ตรวจสอบว่า item เป็น Deilvery object หรือ Map
    final productName = item is Map ? (item['product_name'] ?? 'ไม่มีชื่อสินค้า') : (item.product_name ?? 'ไม่มีชื่อสินค้า');
    final productQty = item is Map ? (item['product_qty'] ?? 1) : (item.product_qty ?? 1);
    final productShop = item is Map ? (item['product_shop'] ?? 'ไม่ระบุร้านค้า') : (item.product_shop ?? 'ไม่ระบุร้านค้า');
    final productCategory = item is Map ? (item['product_category'] ?? 'ไม่ระบุหมวดหมู่') : (item.product_category ?? 'ไม่ระบุหมวดหมู่');
    final productImage = item is Map ? (item['product_image'] ?? '') : (item.product_image ?? '');
    final options = item is Map ? (item['options'] ?? []) : [];
    final rawPrice = item is Map ? item['product_price'] : item.product_price;
    final parsedPrice = double.tryParse(rawPrice.toString()) ?? 0.0;
    final productPrice = parsedPrice.toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(productShop, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(productCategory, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),

        // Product Info
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  productImage.isNotEmpty
                      ? Image.network(
                        productImage.startsWith('//') ? 'https:$productImage' : productImage,
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${productPrice}฿ x$productQty', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(productName, style: TextStyle(color: kButtonColor)),
                  const SizedBox(height: 6),
                  // Options
                  if (options.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children:
                          options.map<Widget>((option) {
                            final optionName = option is Map ? (option['option_name'] ?? '') : (option.option_name ?? '');
                            return _buildTag(optionName);
                          }).toList(),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('จำนวน', style: TextStyle(fontSize: 12, color: Colors.black54)),
                Text(productQty.toString(), style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),
        const Text('หมายเหตุ', style: TextStyle(color: Colors.black54)),
        Text(item is Map ? (item['product_note'] ?? '-') : '-', style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildPriceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('สรุปราคาสินค้า', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _SummaryRow(label: 'รวมราคาสินค้า', value: '${claimController.totalPrice.toStringAsFixed(2)}฿'),
        _SummaryRow(label: 'ค่าขนส่งจีน', value: '${claimController.chinaShippingFee.toStringAsFixed(2)}฿'),
        _SummaryRow(label: 'ค่ามัดจำ', value: '${claimController.depositFee.toStringAsFixed(2)}฿'),
        _SummaryRow(label: 'อัตราแลกเปลี่ยน', value: '${claimController.exchangeRate.toStringAsFixed(2)}'),
        const SizedBox(height: 16),
        const Divider(),
        const Text('หมายเหตุ', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(claimController.orderNote, style: const TextStyle(color: Colors.black87)),
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
            Expanded(
              child: Obx(
                () => Text(
                  'เลขที่เอกสาร ${claimController.orderCode}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('ยกเลิก', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: Obx(() {
        if (claimController.isLoading.value) {
          return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
        }

        if (claimController.hasError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(claimController.errorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => claimController.refreshData(),
                    style: ElevatedButton.styleFrom(backgroundColor: kButtonColor, foregroundColor: Colors.white),
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ข้อมูลออเดอร์
              _buildOrderInfo(),
              const SizedBox(height: 16),

              const Text('สินค้าทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),

              // แสดงรายการสินค้าจาก API
              _buildProductList(),

              const SizedBox(height: 16),
              const Divider(),
              _buildPriceSummary(),
            ],
          ),
        );
      }),
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
