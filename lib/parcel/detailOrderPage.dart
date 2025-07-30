import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/models/orders/productsTrack.dart';
import 'package:gcargo/parcel/paymentMethodPage.dart';
import 'package:gcargo/utils/helpers.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DetailOrderPage extends StatefulWidget {
  final int orderId;

  const DetailOrderPage({super.key, required this.orderId});

  @override
  State<DetailOrderPage> createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  final OrderController orderController = Get.put(OrderController());

  @override
  void initState() {
    super.initState();
    // Call getOrderById when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getOrderById(widget.orderId);
    });
  }

  // Helper methods to get data safely from API response
  String get orderCode => orderController.order.value?.code ?? 'N/A';
  String get orderStatus => _getStatusInThai(orderController.order.value?.status);
  String get orderDate => _formatDate(orderController.order.value?.date);
  String get transportType => orderController.order.value?.shipping_type ?? 'ไม่ระบุ';
  double get orderTotal => double.tryParse(orderController.order.value?.total_price ?? '0') ?? 0.0;
  String get memberCode => orderController.order.value?.member?.code ?? 'N/A';
  String get customerNote => orderController.order.value?.note ?? '-';
  List<ProductsTrack> get productList => orderController.order.value?.order_lists ?? [];

  // Status mapping from API to Thai
  String _getStatusInThai(String? apiStatus) {
    switch (apiStatus) {
      case 'awaiting_summary':
        return 'รอตรวจสอบ';
      case 'awaiting_payment':
        return 'รอชำระเงิน';
      case 'in_progress':
        return 'รอดำเนินการ';
      case 'preparing_shipment':
        return 'เตรียมจัดส่ง';
      case 'shipped':
        return 'จัดส่งแล้ว';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  // Format date from API
  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Obx(() => Text('เลขบิลสั่งซื้อ $orderCode', style: const TextStyle(color: Colors.black, fontSize: 24))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20)),
      ),
      body: Obx(() {
        // Show loading state
        if (orderController.isLoading.value) {
          return const SafeArea(child: Center(child: CircularProgressIndicator()));
        }

        // Show error state
        if (orderController.hasError.value) {
          return SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(orderController.errorMessage.value, style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => orderController.getOrderById(widget.orderId), child: const Text('ลองใหม่')),
                ],
              ),
            ),
          );
        }

        // Show empty state if no order data
        if (orderController.order.value == null) {
          return const SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('ไม่พบข้อมูลออเดอร์', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return SafeArea(
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
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 12),
                    Text('สินค้าทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: kTextTitleHeadColor)),
                    SizedBox(height: 12),

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
                                Text(
                                  productList.first.product_store_type ?? '1688',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextTitleHeadColor),
                                ),
                                const Text('ไม่ QC | ไม่สั่งไป', style: TextStyle(fontSize: 14, color: kTextgreyColor)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [const Text('ค่าส่งต่อจีน 0.00¥ / 0.00฿', style: TextStyle(fontSize: 14, color: kTextgreyColor))],
                            ),
                            const SizedBox(height: 12),

                            // 🔻 รายการสินค้าจาก ProductsTrack
                            ...productList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final product = entry.value;
                              return Column(
                                children: [_buildProductItemFromTrack(product), if (index < productList.length - 1) const SizedBox(height: 12)],
                              );
                            }),
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

              // 🔻 ปุ่มล่าง - แสดงตามสถานะ
              _buildBottomButtons(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(color: kHintTextColor, fontSize: 14))),
          Expanded(flex: 5, child: Text(value, style: const TextStyle(color: Colors.black, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildProductItemFromTrack(ProductsTrack product) {
    final productPrice = product.product_price ?? '0';
    final productQty = product.product_qty ?? 1;
    final productName = product.product_name ?? 'ไม่ระบุชื่อสินค้า';
    //final productImage = product.product_image;
    final productImage = formatImageUrl(product.product_image ?? '');

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
              Text('¥$productPrice x$productQty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text('(${_calculateBahtPrice(productPrice)} ฿)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
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
        //const SizedBox(width: 8),
        //Text('¥$productPrice', style: const TextStyle(fontWeight: FontWeight.bold)),
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
        color: filled ? kCicleSelectedColor : Colors.transparent,
        border: Border.all(color: kCicleSelectedColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black)),
    );
  }

  Widget _buildPriceSummary() {
    final order = orderController.order.value;
    final totalProductPrice = _calculateTotalProductPrice();
    final totalBahtPrice = _calculateTotalBahtPrice();

    // Get data from API
    final exchangeRate = double.tryParse(order?.exchange_rate ?? '4.00') ?? 4.00;
    final chinaShippingFee = double.tryParse(order?.china_shipping_fee ?? '0') ?? 0.0;
    final depositFee = double.tryParse(order?.deposit_fee ?? '0') ?? 0.0;
    final totalPriceFromAPI = double.tryParse(order?.total_price ?? '0') ?? 0.0;

    // Calculate additional fees
    final chinaShippingBaht = chinaShippingFee * exchangeRate;
    final depositBaht = depositFee * exchangeRate;
    final serviceFee = totalBahtPrice * 0.03; // 3% service fee
    final totalWithFees = totalBahtPrice + chinaShippingBaht + depositBaht + serviceFee;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceRow('สรุปราคารวมสินค้า', 'เรทแลกเปลี่ยน ${exchangeRate.toStringAsFixed(2)}'),
          const Divider(),

          // Product details
          _buildPriceRow('รวมราคาสินค้า', '¥${totalProductPrice.toStringAsFixed(2)} (${totalBahtPrice.toStringAsFixed(2)}฿)'),

          // China shipping fee
          if (chinaShippingFee > 0)
            _buildPriceRow('ค่าส่งในจีน', '¥${chinaShippingFee.toStringAsFixed(2)} (${chinaShippingBaht.toStringAsFixed(2)}฿)')
          else
            _buildPriceRow('ค่าส่งในจีน', '0.00฿'),

          // Deposit fee
          if (depositFee > 0)
            _buildPriceRow('ค่ามัดจำ', '¥${depositFee.toStringAsFixed(2)} (${depositBaht.toStringAsFixed(2)}฿)')
          else
            _buildPriceRow('ค่ามัดจำ', '0.00฿'),

          // Service fee
          _buildPriceRow('ค่าบริการ (3%)', '${serviceFee.toStringAsFixed(2)}฿'),

          // Payment term
          if (order?.payment_term != null && order!.payment_term!.isNotEmpty) _buildPriceRow('เงื่อนไขการชำระ', order.payment_term!),

          const Divider(),

          // Total from API vs calculated
          if (totalPriceFromAPI > 0)
            _buildPriceRow(
              'ราคารวม (จาก API)',
              '¥${totalPriceFromAPI.toStringAsFixed(2)} (${(totalPriceFromAPI * exchangeRate).toStringAsFixed(2)}฿)',
              isBold: true,
            )
          else
            _buildPriceRow('ราคารวม (คำนวณ)', '${totalWithFees.toStringAsFixed(2)}฿', isBold: true),

          // Order info
          const SizedBox(height: 8),
          _buildInfoSection(),
        ],
      ),
    );
  }

  // Additional info section
  Widget _buildInfoSection() {
    final order = orderController.order.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('ข้อมูลเพิ่มเติม', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (order?.shipping_type != null) _buildPriceRow('ประเภทการขนส่ง', order!.shipping_type!),

        if (order?.created_at != null) _buildPriceRow('วันที่สร้างออเดอร์', _formatDate(order!.created_at.toString())),

        _buildPriceRow('จำนวนสินค้า', '${productList.length} รายการ'),

        if (order?.member?.code != null) _buildPriceRow('รหัสสมาชิก', order!.member!.code!),
      ],
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
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
        ],
      ),
    );
  }

  // Build bottom buttons based on order status
  Widget _buildBottomButtons() {
    final status = orderController.order.value?.status;

    // Only show buttons for specific statuses
    if (status == 'shipped' || status == 'awaiting_payment') {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Cancel button (smaller size)
            Expanded(
              flex: 2, // Smaller flex ratio
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implement cancel order
                  Navigator.pop(context);
                },
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
            // Second button depends on status (larger size)
            Expanded(
              flex: 3, // Larger flex ratio
              child: _buildSecondButton(status),
            ),
          ],
        ),
      );
    }

    // No buttons for other statuses
    return const SizedBox.shrink();
  }

  // Build second button based on status
  Widget _buildSecondButton(String? status) {
    if (status == 'shipped') {
      // For "รอตรวจสอบ" - show "ซื้ออีกครั้ง" button
      return ElevatedButton(
        onPressed: () {
          // แสดงข้อความว่าฟังก์ชันยังไม่พร้อมใช้งาน
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ฟังก์ชันนี้ยังไม่พร้อมใช้งาน'), backgroundColor: Colors.orange));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kButtonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('ซื้ออีกครั้ง', style: TextStyle(fontSize: 16)),
      );
    } else if (status == 'awaiting_payment') {
      // For "รอชำระเงิน" - show price button with API total
      final order = orderController.order.value;
      final exchangeRate = double.tryParse(order?.exchange_rate ?? '4.00') ?? 4.00;
      final totalPriceFromAPI = double.tryParse(order?.total_price ?? '0') ?? 0.0;

      // Use API total if available, otherwise use calculated total
      final displayPrice = totalPriceFromAPI > 0 ? totalPriceFromAPI * exchangeRate : _calculateTotalBahtPrice();

      return ElevatedButton(
        onPressed: () {
          // TODO: Navigate to payment page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PaymentMethodPage(totalPrice: totalPriceFromAPI, ref_no: orderCode, orderType: 'order')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kButtonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ราคารวม', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            SizedBox(width: 5),
            if (totalPriceFromAPI > 0)
              Text('${totalPriceFromAPI.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          ],
        ),
      );
    }

    // Default fallback (shouldn't reach here)
    return const SizedBox.shrink();
  }
}
