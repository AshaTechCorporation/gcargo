import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/services/orderService.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalletPaymentPage extends StatefulWidget {
  final double totalPrice;
  final String ref_no;
  final String orderType;

  const WalletPaymentPage({super.key, required this.totalPrice, required this.ref_no, required this.orderType});

  @override
  State<WalletPaymentPage> createState() => _WalletPaymentPageState();
}

class _WalletPaymentPageState extends State<WalletPaymentPage> {
  final OrderController orderController = Get.put(OrderController());

  @override
  void initState() {
    super.initState();
    // Call getWalletTrans when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getWalletTrans();
    });
  }

  // Calculate total wallet balance from API data
  double get walletBalance {
    double balance = 0.0;
    for (var trans in orderController.walletTrans) {
      try {
        final amount = double.parse(trans.amount ?? '0');
        if (trans.type == 'I') {
          balance += amount;
        } else if (trans.type == 'O') {
          balance -= amount;
        }
      } catch (e) {
        // Skip invalid amounts
      }
    }
    return balance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFEFA),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Wallet', style: TextStyle(color: Colors.black)),
      ),
      body: Obx(() {
        // Show loading state
        if (orderController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error state
        if (orderController.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(orderController.errorMessage.value, style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => orderController.getWalletTrans(), child: const Text('ลองใหม่')),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ยอดเงินใน Wallet', style: TextStyle(fontSize: 16, color: Colors.black)),
                Text('${walletBalance.toStringAsFixed(2)}฿', style: const TextStyle(fontSize: 16, color: Colors.black)),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE0E0E0)))),
        child: Row(
          children: [
            Text('${widget.totalPrice.toStringAsFixed(2)}฿', style: const TextStyle(fontSize: 16, color: Colors.black)),
            const Spacer(),
            SizedBox(
              width: 120,
              height: 44,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // Show loading
                    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

                    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
                    await OrderService.paymentOrder(
                      payment_type: 'wallet',
                      ref_no: widget.ref_no,
                      date: formattedDate,
                      total_price: widget.totalPrice,
                      note: '',
                      image: '',
                      order_type: widget.orderType,
                    );

                    // Check if widget is still mounted
                    if (!mounted) return;

                    // Hide loading
                    Get.back();

                    // Show success message
                    Get.snackbar(
                      'สำเร็จ',
                      'ชำระเงินสำเร็จ',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );

                    // Go back to OrderStatusPage and refresh data
                    // Use Get to go back to OrderStatusPage and trigger refresh
                    Get.until((route) => Get.currentRoute == '/orderStatus' || route.isFirst);

                    // Refresh OrderController data
                    final OrderController orderController = Get.find<OrderController>();
                    orderController.refreshData();
                  } catch (e) {
                    // Check if widget is still mounted
                    if (!mounted) return;

                    // Hide loading
                    Get.back();

                    // Show error message
                    Get.snackbar('เกิดข้อผิดพลาด', '$e', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: kButtonColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('ชำระเงิน', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
