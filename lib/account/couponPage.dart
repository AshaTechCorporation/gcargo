import 'package:flutter/material.dart';
import 'package:gcargo/controllers/account_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:get/get.dart';

class CouponPage extends StatefulWidget {
  const CouponPage({super.key});

  @override
  State<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  late final AccountController accountController;
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {'coupons': 'คูปองส่วนลด', 'try_again': 'ลองใหม่', 'no_coupons': 'ไม่มีคูปอง'},
      'en': {'coupons': 'Coupons', 'try_again': 'Try Again', 'no_coupons': 'No Coupons'},
      'zh': {'coupons': '优惠券', 'try_again': '重试', 'no_coupons': '暂无优惠券'},
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    accountController = Get.put(AccountController());
    // เรียกฟังก์ชั่น getCoupons เมื่อเข้าหน้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      accountController.getCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(getTranslation('coupons'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: false,
          elevation: 0.5,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        ),
        backgroundColor: Colors.white,
        body: Obx(() {
          if (accountController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (accountController.hasError.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(accountController.errorMessage.value, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => accountController.getCoupons(), child: Text(getTranslation('try_again'))),
                ],
              ),
            );
          }

          final coupons = accountController.coupons;

          if (coupons.isEmpty) {
            return Center(child: Text(getTranslation('no_coupons'), style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coupon['name']?.toString() ?? 'ไม่มีชื่อ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(coupon['description']?.toString() ?? 'ไม่มีเงื่อนไข', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(coupon['code']?.toString() ?? 'ไม่มีรหัส', style: const TextStyle(fontSize: 13, color: Colors.black45)),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
