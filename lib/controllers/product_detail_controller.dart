import 'dart:developer';
import 'package:get/get.dart';
import 'package:gcargo/services/homeService.dart';

class ProductDetailController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var productDetail = <String, dynamic>{}.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  var numIid = ''.obs;

  @override
  void onInit() {
    super.onInit();
    log('🚀 ProductDetailController onInit called');
  }

  Future<void> getItemDetail(String itemId) async {
    if (itemId.isEmpty) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      numIid.value = itemId;

      // เรียก API จริงโดยใช้ service ที่คุณเขียนไว้
      final data = await HomeService.getItemDetail(
        num_id: itemId,
        type: 'taobao', // หรือ type ที่ต้องการ
      );

      if (data != null && data is Map<String, dynamic>) {
        // สร้างโครงสร้างข้อมูลให้เหมือนกับ API search เพื่อความสอดคล้อง
        final formattedData = {
          "item": {
            "items": {
              "page": "1",
              "real_total_results": "1",
              "total_results": "1",
              "page_size": 1,
              "pagecount": "1",
              "_ddf": "alex",
              "item": [data], // ใส่ข้อมูลที่ได้จาก API
              "item_weight_update": 0,
            },
            "post_url": "",
          },
        };

        productDetail.value = formattedData;
      } else {
        _setError('ไม่สามารถเชื่อมต่อ API หรือไม่พบสินค้าที่ค้นหา');
      }
    } catch (e) {
      log('Error in getItemDetail: $e');
      _setError('ไม่สามารถเชื่อมต่อ API หรือไม่พบสินค้าที่ค้นหา');
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidResponseStructure(dynamic responseBody) {
    try {
      // ตรวจสอบว่ามี structure ตามที่กำหนดหรือไม่
      if (responseBody is! Map<String, dynamic>) return false;

      final item = responseBody['item'];
      if (item is! Map<String, dynamic>) return false;

      final items = item['items'];
      if (items is! Map<String, dynamic>) return false;

      final itemList = items['item'];
      if (itemList is! List) return false;

      // ตรวจสอบว่า item แรกมี field ที่จำเป็นหรือไม่
      if (itemList.isNotEmpty) {
        final firstItem = itemList[0];
        if (firstItem is! Map<String, dynamic>) return false;

        // ตรวจสอบ required fields
        final requiredFields = ['title', 'pic_url', 'price', 'num_iid'];
        for (String field in requiredFields) {
          if (!firstItem.containsKey(field)) return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    productDetail.clear();
  }

  // Helper methods สำหรับดึงข้อมูลจาก productDetail
  Map<String, dynamic>? get itemData {
    if (productDetail.isEmpty) return null;
    final items = productDetail['item']?['items']?['item'];
    if (items is List && items.isNotEmpty) {
      return items[0];
    }
    return null;
  }

  String get title => itemData?['title'] ?? 'ไม่มีชื่อสินค้า';
  String get picUrl => itemData?['pic_url'] ?? '';
  double get price => (itemData?['price'] ?? 0).toDouble();
  double get promotionPrice => (itemData?['promotion_price'] ?? 0).toDouble();
  double get originalPrice => (itemData?['orginal_price'] ?? 0).toDouble();
  String get area => itemData?['area'] ?? '';
  String get detailUrl => itemData?['detail_url'] ?? '';

  // Method สำหรับ refresh ข้อมูล
  Future<void> refreshData() async {
    if (numIid.value.isNotEmpty) {
      await getItemDetail(numIid.value);
    }
  }
}
