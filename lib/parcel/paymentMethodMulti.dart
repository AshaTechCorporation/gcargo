import 'package:flutter/material.dart';
import 'package:gcargo/parcel/QRPaymentMulti.dart';
import 'package:gcargo/parcel/QRPaymentPage.dart';
import 'package:gcargo/parcel/walletPaymentMulti.dart';
import 'package:gcargo/parcel/walletPaymentPage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class PaymentMethodMulti extends StatelessWidget {
  PaymentMethodMulti({super.key, required this.totalPrice, required this.orderType, required this.items, required this.vat});
  double totalPrice;
  String orderType;
  List<Map<String, dynamic>> items;
  bool vat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFEFA),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('ชำระเงิน (${totalPrice.toStringAsFixed(2)}฿)', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WalletPaymentMulti(totalPrice: totalPrice, orderType: orderType, items: items, vat: vat)),
                );
              },
              child: _buildPaymentOption('Wallet (${totalPrice.toStringAsFixed(2)}฿)'),
            ),
            SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QRPaymentMulti(totalPrice: totalPrice, orderType: orderType, items: items, vat: vat)),
                );
              },
              child: _buildPaymentOption('QR พร้อมเพย์ / โอน'),
            ),
            SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Get.snackbar(
                  'แจ้งเตือน',
                  'ฟังก์ชั่นนี้ยังไม่เปิดใช้งาน',
                  backgroundColor: Colors.yellowAccent,
                  colorText: Colors.black,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: _buildPaymentOption('เครดิต'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black)),
    );
  }
}
