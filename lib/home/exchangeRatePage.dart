import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:get/get.dart';

class ExchangeRatePage extends StatelessWidget {
  ExchangeRatePage({super.key, required this.exchangeRate});
  final Map<String, dynamic> exchangeRate;

  String getTranslation(String key) {
    final languageController = Get.find<LanguageController>();
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {'exchange_rate': 'อัตราแลกเปลี่ยน', 'product_order_rate': 'เรทสั่งซื้อสินค้า', 'money_transfer_rate': 'เรทโอนเงิน'},
      'en': {'exchange_rate': 'Exchange Rate', 'product_order_rate': 'Product Order Rate', 'money_transfer_rate': 'Money Transfer Rate'},
      'zh': {'exchange_rate': '汇率', 'product_order_rate': '商品订购汇率', 'money_transfer_rate': '转账汇率'},
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> exchangeRates = [
      {'icon': 'assets/icons/cha2.png', 'title': getTranslation('product_order_rate'), 'price': '${exchangeRate['deposit_order_rate']}'},
      {'icon': 'assets/icons/cha1.png', 'title': getTranslation('money_transfer_rate'), 'price': '${exchangeRate['alipay_topup_rate']}'},
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(getTranslation('exchange_rate'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
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
                  Expanded(
                    child: Text(item['title']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: kTitleTextGridColor)),
                  ),

                  // 🔸 ราคาด้านขวา
                  Text(item['price']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: kTitleTextGridColor)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
