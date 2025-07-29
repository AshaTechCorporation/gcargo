import 'package:flutter/material.dart';
import 'package:gcargo/parcel/walletPaymentPage.dart';

class PaymentMethodPage extends StatelessWidget {
  const PaymentMethodPage({super.key});

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
                Navigator.push(context, MaterialPageRoute(builder: (_) => WalletPaymentPage()));
              },
              child: _buildPaymentOption('Wallet (00.00฿)'),
            ),
            const SizedBox(height: 12),
            _buildPaymentOption('QR พร้อมเพย์'),
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
