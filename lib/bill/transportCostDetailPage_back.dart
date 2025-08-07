import 'package:flutter/material.dart';
import 'package:gcargo/bill/chinaShippingDetailPage.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:get/get.dart';

class TransportCostDetailPage extends StatefulWidget {
  final String paper_number;
  final int billId;

  const TransportCostDetailPage({super.key, required this.paper_number, required this.billId});

  @override
  State<TransportCostDetailPage> createState() => _TransportCostDetailPageState();
}

class _TransportCostDetailPageState extends State<TransportCostDetailPage> {
  final OrderController orderController = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
    // เรียก API เมื่อโหลดหน้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getBillById(widget.billId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('เลขที่เอกสาร ${widget.paper_number}', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
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
      body: Obx(() {
        // แสดง loading
        if (orderController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // แสดง error
        if (orderController.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(orderController.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => orderController.getBillById(widget.billId), child: const Text('ลองใหม่')),
              ],
            ),
          );
        }

        final bill = orderController.billingById.value;
        if (bill == null) {
          return const Center(child: Text('ไม่พบข้อมูล'));
        }

        return SafeArea(
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
                      _rowItem('รวมค่าขนส่งจีนไทย', '${_formatAmount(bill.total_amount)}฿'),
                      _rowItem('ค่าบริการ QC', '0฿'),
                      _rowItem('ค่าตัดไม้', '0฿'),
                      _rowItem('ค่าบริการ', '0฿'),
                      _rowItem('ค่าขนส่งในไทย', '0฿'),
                      _rowItem('ส่วนลด', '0฿'),
                      const Divider(height: 24),
                      _rowItem('รวมราคาทั้งสิ้น', '${_formatAmount(bill.total_amount)}฿', bold: true),
                      _rowItem('การชำระเงิน', _getPaymentMethod(bill.status)),
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
        );
      }), // ปิด Obx
    );
  }

  // Helper methods
  String _formatAmount(String? amount) {
    if (amount == null || amount.isEmpty) return '0.00';
    final double value = double.tryParse(amount) ?? 0.0;
    return value.toStringAsFixed(2);
  }

  String _getPaymentMethod(String? status) {
    switch (status) {
      case 'paid':
        return 'ชำระแล้ว';
      case 'pending':
        return 'รอชำระเงิน';
      default:
        return 'QR พร้อมเพย์';
    }
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
    final bill = orderController.billingById.value;
    if (bill?.bill_lists_grouped == null || bill!.bill_lists_grouped!.isEmpty) {
      return [const Padding(padding: EdgeInsets.all(16), child: Text('ไม่มีข้อมูลรายการขนส่ง', style: TextStyle(color: Colors.grey)))];
    }

    return bill.bill_lists_grouped!.map((item) {
      final code = item.code ?? 'N/A';
      final price = '${_formatAmount(item.weight)}฿'; // ใช้ weight เป็นราคาชั่วคราว
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChinaShippingDetailPage(transportNo: code))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(code, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(price, style: const TextStyle(fontSize: 14)),
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
