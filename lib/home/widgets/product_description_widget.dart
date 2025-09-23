import 'package:flutter/material.dart';
import 'package:gcargo/controllers/product_detail_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:get/get.dart';

class ProductDescriptionWidget extends StatelessWidget {
  final ProductDetailController productController;
  final String? translatedTitle;

  const ProductDescriptionWidget({super.key, required this.productController, this.translatedTitle});

  String getTranslation(String key) {
    final languageController = Get.find<LanguageController>();
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {'product_details': 'รายละเอียดสินค้า', 'no_description': 'ไม่มีรายละเอียด', 'product_link': 'ลิงก์สินค้า'},
      'en': {'product_details': 'Product Details', 'no_description': 'No Description', 'product_link': 'Product Link'},
      'zh': {'product_details': '商品详情', 'no_description': '无描述', 'product_link': '商品链接'},
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (productController.isLoading.value) {
        return Column(
          children: [
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 4),
            Container(height: 16, width: 200, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(getTranslation('product_details'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          // แสดงชื่อสินค้าต้นฉบับ
          Text(productController.title, style: TextStyle(color: Colors.grey.shade700)),

          // แสดงชื่อสินค้าที่แปลแล้ว (ถ้ามี)
          if (translatedTitle != null && translatedTitle!.isNotEmpty && translatedTitle != productController.title) ...[
            const SizedBox(height: 4),
            Text(translatedTitle!, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500, fontSize: 14)),
          ],
          // if (productController.detailUrl.isNotEmpty) ...[
          //   const SizedBox(height: 8),
          //   Text(
          //     'ลิงก์สินค้า: ${productController.detailUrl}',
          //     style: const TextStyle(
          //       color: Colors.blue,
          //       fontSize: 12,
          //       decoration: TextDecoration.underline,
          //     ),
          //   ),
          // ],
        ],
      );
    });
  }
}
