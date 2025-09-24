import 'package:flutter/material.dart';
import 'package:gcargo/parcel/QRPaymentPage.dart';
import 'package:gcargo/parcel/walletPaymentPage.dart';

class PaymentMethodPage extends StatelessWidget {
  PaymentMethodPage({super.key, required this.totalPrice, required this.ref_no, required this.orderType});
  double totalPrice;
  String ref_no;
  String orderType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFEFA),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('ชำระเงิน', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WalletPaymentPage(totalPrice: totalPrice, ref_no: ref_no, orderType: orderType)),
                );
              },
              child: _buildPaymentOption('Wallet (${totalPrice.toStringAsFixed(2)}฿)'),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QRPaymentPage(totalPrice: totalPrice, ref_no: ref_no, orderType: orderType)),
                );
              },
              child: _buildPaymentOption('QR พร้อมเพย์ / โอน'),
            ),
            const SizedBox(height: 12),
            _buildPaymentOption('เครดิต'),
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
