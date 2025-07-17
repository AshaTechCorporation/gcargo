import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class ExchangeRatePage extends StatelessWidget {
  ExchangeRatePage({super.key, required this.exchangeRate});
  Map<String, dynamic> exchangeRate;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> exchangeRates = [
      {'icon': 'assets/icons/cha2.png', 'title': 'เรทสั่งซื้อสินค้า', 'price': '${exchangeRate['product_payment_rate']}'},
      {'icon': 'assets/icons/cha1.png', 'title': 'เรทโอนเงิน', 'price': '${exchangeRate['alipay_topup_rate']}'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('อัตราแลกเปลี่ยน', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: exchangeRates.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = exchangeRates[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            decoration: BoxDecoration(color: const Color(0xFFF5F8FF), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                // 🔹 รูปไอคอน
                Image.asset(item['icon']!, width: 50, height: 50),
                const SizedBox(width: 12),

                // 🔸 ข้อความด้านซ้าย
                Expanded(child: Text(item['title']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: kTitleTextGridColor))),

                // 🔸 ราคาด้านขวา
                Text(item['price']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: kTitleTextGridColor)),
              ],
            ),
          );
        },
      ),
    );
  }
}
