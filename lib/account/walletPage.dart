import 'package:flutter/material.dart';
import 'package:gcargo/account/topUpPage.dart';
import 'package:gcargo/controllers/account_controller.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final OrderController orderController = Get.put(OrderController());
  final AccountController accountController = Get.put(AccountController());

  @override
  void initState() {
    super.initState();
    // เรียก API เมื่อโหลดหน้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getWalletTrans();
      accountController.getListWalletTrans();
    });
  }

  // คำนวณยอดเงินรวมจาก OrderController (เดิม)
  double _calculateTotalBalance() {
    double total = 0.0;
    for (var trans in orderController.walletTrans) {
      final amount = double.tryParse(trans.amount ?? '0') ?? 0.0;
      if (trans.type == 'I') {
        total += amount; // เงินเข้า
      } else if (trans.type == 'O') {
        total -= amount; // เงินออก
      }
    }
    return total;
  }

  // จัดฟอร์แมทตัวเลข
  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Wallet', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        elevation: 0,
      ),
      body: Obx(() {
        // แสดง loading
        if (orderController.isLoading.value || accountController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // แสดง error
        if (orderController.hasError.value || accountController.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(orderController.hasError.value ? orderController.errorMessage.value : accountController.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    orderController.getWalletTrans();
                    accountController.getListWalletTrans();
                  },
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        }

        final totalBalance = _calculateTotalBalance();

        return Column(
          children: [
            // 🔷 Top Section: ยอดเงิน + ปุ่ม
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ ฝั่งซ้าย: ข้อความ + จำนวนเงิน + ข้อความยืนยัน
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('ยอดเงินใน Wallet', style: TextStyle(fontSize: 14, color: Colors.black87)),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatAmount(totalBalance)}฿',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('ยืนยันบัญชีผู้รับการชำระเงิน', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ✅ ฝั่งขวา: เติมเงิน + ถอนเงิน
                  Row(
                    children: [
                      // เติมเงิน
                      GestureDetector(
                        onTap: () {
                          // TODO: ไปหน้า WalletPaymentPage
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TopUpPage()));
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(color: Color(0xFFEDF6FF), shape: BoxShape.circle),
                              padding: const EdgeInsets.all(8),
                              child: Image.asset('assets/icons/money-recive.png', fit: BoxFit.contain),
                            ),
                            const SizedBox(height: 4),
                            const Text('เติมเงิน', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // ถอนเงิน
                      Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(color: Color(0xFFEDF6FF), shape: BoxShape.circle),
                            padding: const EdgeInsets.all(8),
                            child: Image.asset('assets/icons/money-send.png', fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 4),
                          const Text('ถอนเงิน', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            // 🧾 รายการ Wallet
            Expanded(
              child:
                  accountController.listWalletTrans.isEmpty
                      ? const Center(child: Text('ไม่มีรายการธุรกรรม', style: TextStyle(color: Colors.grey, fontSize: 16)))
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: accountController.listWalletTrans.length,
                        itemBuilder: (context, index) {
                          // เรียงวันที่ล่าสุดก่อน
                          final sortedList =
                              accountController.listWalletTrans.toList()
                                ..sort((a, b) => (b.created_at ?? DateTime.now()).compareTo(a.created_at ?? DateTime.now()));

                          final trans = sortedList[index];
                          final amount = double.tryParse(trans.amount ?? '0') ?? 0.0;
                          final finalAmount = trans.type == 'O' ? -amount : amount;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index == 0 || _shouldShowDateHeader(index, sortedList)) _dateHeader(_formatTransactionDate(trans.created_at)),
                              _walletTransaction(trans.detail ?? 'ไม่มีรายละเอียด', finalAmount),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
            ),
          ],
        );
      }), // ปิด Obx
    );
  }

  // Helper methods
  bool _shouldShowDateHeader(int index, [List<dynamic>? sortedList]) {
    if (index == 0) return true;
    final list = sortedList ?? accountController.listWalletTrans;
    final currentDate = _formatTransactionDate(list[index].created_at);
    final previousDate = _formatTransactionDate(list[index - 1].created_at);
    return currentDate != previousDate;
  }

  String _formatTransactionDate(DateTime? date) {
    if (date == null) return 'ไม่ทราบวันที่';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // 📌 วันที่หัวกลุ่มรายการ
  Widget _dateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(date, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
    );
  }

  // 📌 รายการแต่ละบรรทัด
  Widget _walletTransaction(String description, double amount) {
    final isPositive = amount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(description, style: const TextStyle(fontSize: 14))),
          Text(
            '${isPositive ? '+' : '-'} ${_formatAmount(amount.abs())}฿',
            style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
