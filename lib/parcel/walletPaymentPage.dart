import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class WalletPaymentPage extends StatelessWidget {
  const WalletPaymentPage({super.key});

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('ยอดเงินใน Wallet', style: TextStyle(fontSize: 16, color: Colors.black)),
              Text('00.00฿', style: TextStyle(fontSize: 16, color: Colors.black)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE0E0E0)))),
        child: Row(
          children: [
            const Text('00.00฿', style: TextStyle(fontSize: 16, color: Colors.black)),
            const Spacer(),
            SizedBox(
              width: 120,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: ดำเนินการชำระเงิน
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
