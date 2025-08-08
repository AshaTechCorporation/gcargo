import 'package:flutter/material.dart';
import 'package:gcargo/controllers/product_detail_controller.dart';
import 'package:get/get.dart';

class ProductDescriptionWidget extends StatelessWidget {
  final ProductDetailController productController;

  const ProductDescriptionWidget({
    super.key,
    required this.productController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (productController.isLoading.value) {
        return Column(
          children: [
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 16,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'รายละเอียดสินค้า',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            productController.title,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          if (productController.detailUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'ลิงก์สินค้า: ${productController.detailUrl}',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ],
      );
    });
  }
}
