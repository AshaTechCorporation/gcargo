import 'dart:developer';
import 'package:get/get.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:hive/hive.dart';

class ProductDetailController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var productDetail = <String, dynamic>{}.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  var numIid = ''.obs;
  var type = ''.obs;
  var isFavorite = false.obs; // สำหรับเช็คว่าอยู่ในรายการโปรดหรือไม่

  @override
  void onInit() {
    super.onInit();
    log('🚀 ProductDetailController onInit called');
  }

  Future<void> getItemDetail(String itemId, String type) async {
    if (itemId.isEmpty) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      numIid.value = itemId;
      this.type.value = type;

      // เรียก API จริงโดยใช้ service ที่คุณเขียนไว้
      final data = await HomeService.getItemDetail(
        num_id: itemId,
        type: type, // หรือ type ที่ต้องการ
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

        // เช็คว่าอยู่ในรายการโปรดหรือไม่
        await checkIfFavorite();

        // Debug: Log desc_img and props_list data
        log('🖼️ desc_img data: ${data['desc_img']}');
        log('📋 props_list data: ${data['props_list']}');
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
  double get price => _safeToDouble(itemData?['price']);
  double get promotionPrice => _safeToDouble(itemData?['promotion_price']);
  double get originalPrice => _safeToDouble(itemData?['orginal_price']);

  double _safeToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String get area => itemData?['area'] ?? '';
  String get detailUrl => itemData?['detail_url'] ?? '';
  String get nick => itemData?['nick'] ?? '';
  String get brand => itemData?['brand'] ?? '';
  String get numIidValue => itemData?['num_iid']?.toString() ?? '';

  // Get desc_img as a list of image URLs
  List<String> get descImages {
    final descImg = itemData?['desc_img'];
    if (descImg is String && descImg.isNotEmpty) {
      // If desc_img is a string with multiple URLs separated by commas or semicolons
      return descImg.split(RegExp(r'[,;]')).map((url) => url.trim()).where((url) => url.isNotEmpty).toList();
    } else if (descImg is List) {
      // If desc_img is already a list
      return descImg.map((url) => url.toString().trim()).where((url) => url.isNotEmpty).toList();
    }
    return [];
  }

  // Get all available images (main pic_url + desc_img)
  List<String> get allImages {
    List<String> images = [];

    // Add main product image first
    if (picUrl.isNotEmpty) {
      images.add(picUrl);
    }

    // Add description images
    images.addAll(descImages);

    return images;
  }

  // Get props_list data
  Map<String, dynamic> get propsList {
    final props = itemData?['props_list'];
    if (props is Map<String, dynamic>) {
      return props;
    }
    return {};
  }

  // Get sizes from props_list
  List<String> get availableSizes {
    List<String> sizes = [];

    propsList.forEach((key, value) {
      if (value is String) {
        // Check if this property is related to size (尺码)
        if (value.contains('尺码:')) {
          final sizeName = value.split(':').last.trim();
          if (sizeName.isNotEmpty && !sizes.contains(sizeName)) {
            sizes.add(sizeName);
          }
        }
      }
    });

    return sizes;
  }

  // Get colors from props_list
  List<String> get availableColors {
    List<String> colors = [];

    propsList.forEach((key, value) {
      if (value is String) {
        // Check if this property is related to color (颜色)
        if (value.contains('颜色:')) {
          final colorName = value.split(':').last.trim();
          if (colorName.isNotEmpty && !colors.contains(colorName)) {
            colors.add(colorName);
          }
        }
      }
    });

    return colors;
  }

  // Helper method to translate complex color descriptions
  String _translateComplexColorDescription(String text) {
    // Handle complex patterns like "绿色衬衫+黑色短裤【两件套】"
    String result = text;

    // Replace common Chinese terms
    final complexTranslations = {
      '衬衫': 'เสื้อเชิ้ต',
      '短裤': 'กางเกงขาสั้น',
      '长裤': 'กางเกงขายาว',
      '两件套': 'ชุด 2 ชิ้น',
      '三件套': 'ชุด 3 ชิ้น',
      '套装': 'ชุดเซ็ต',
      '【': ' (',
      '】': ')',
      '+': ' + ',
    };

    complexTranslations.forEach((chinese, thai) {
      result = result.replaceAll(chinese, thai);
    });

    return result;
  }

  // Translate Chinese/English to Thai
  String translateToThai(String text) {
    // Handle complex color descriptions first
    String translatedText = _translateComplexColorDescription(text);

    final translations = {
      // Sizes
      'XS': 'XS',
      'S': 'S',
      'M': 'M',
      'L': 'L',
      'XL': 'XL',
      '2XL': '2XL',
      '3XL': '3XL',
      '4XL': '4XL',
      '5XL': '5XL',
      'XXL': 'XXL',
      'XXXL': 'XXXL',
      '均码': 'ไซส์เดียว',
      '均': 'ไซส์เดียว',
      'Free Size': 'ไซส์เดียว',
      'One Size': 'ไซส์เดียว',

      // Colors
      'black': 'ดำ',
      'white': 'ขาว',
      'red': 'แดง',
      'blue': 'น้ำเงิน',
      'green': 'เขียว',
      'yellow': 'เหลือง',
      'pink': 'ชมพู',
      'purple': 'ม่วง',
      'orange': 'ส้ม',
      'brown': 'น้ำตาล',
      'gray': 'เทา',
      'grey': 'เทา',

      // Chinese colors
      '黑色': 'ดำ',
      '白色': 'ขาว',
      '红色': 'แดง',
      '蓝色': 'น้ำเงิน',
      '绿色': 'เขียว',
      '黄色': 'เหลือง',
      '粉色': 'ชมพู',
      '紫色': 'ม่วง',
      '橙色': 'ส้ม',
      '棕色': 'น้ำตาล',
      '灰色': 'เทา',
      '黑': 'ดำ',
      '白': 'ขาว',
      '红': 'แดง',
      '蓝': 'น้ำเงิน',
      '绿': 'เขียว',
      '黄': 'เหลือง',
      '粉': 'ชมพู',
      '紫': 'ม่วง',
      '橙': 'ส้ม',
      '棕': 'น้ำตาล',
      '灰': 'เทา',
      '金色': 'ทอง',
      '银色': 'เงิน',
      '咖啡色': 'น้ำตาลเข้ม',
      '咖啡': 'น้ำตาล',
      '米色': 'ครีม',
      '卡其色': 'กากี',
      '深蓝': 'น้ำเงินเข้ม',
      '浅蓝': 'น้ำเงินอ่อน',
      '深灰': 'เทาเข้ม',
      '浅灰': 'เทาอ่อน',
      '玫瑰红': 'แดงกุหลาบ',
      '天蓝': 'ฟ้า',
      '草绿': 'เขียวอ่อน',
      '深绿': 'เขียวเข้ม',
    };

    // Apply simple translations to the complex translated text
    String finalResult = translatedText;
    translations.forEach((original, translated) {
      finalResult = finalResult.replaceAll(original, translated);
    });

    return finalResult;
  }

  // Method สำหรับ refresh ข้อมูล
  Future<void> refreshData() async {
    if (numIid.value.isNotEmpty) {
      await getItemDetail(numIid.value, type.value);
    }
  }

  // ฟังก์ชั่นสำหรับจัดการรายการโปรด
  Future<void> checkIfFavorite() async {
    try {
      final box = await Hive.openBox('favorites');
      final favoriteKey = '${numIid.value}_favorite';
      isFavorite.value = box.containsKey(favoriteKey);
    } catch (e) {
      log('Error checking favorite: $e');
    }
  }

  Future<void> toggleFavorite() async {
    try {
      final box = await Hive.openBox('favorites');
      final favoriteKey = '${numIid.value}_favorite';

      if (isFavorite.value) {
        // ลบออกจากรายการโปรด
        await box.delete(favoriteKey);
        isFavorite.value = false;
        log('Removed from favorites: $favoriteKey');
      } else {
        // เพิ่มเข้ารายการโปรด
        final favoriteItem = {
          'num_iid': numIidValue,
          'title': title,
          'price': price,
          'orginal_price': originalPrice,
          'nick': nick,
          'detail_url': detailUrl,
          'pic_url': picUrl,
          'brand': brand,
          'quantity': 1, // ค่าเริ่มต้น
          'selectedSize': '', // ค่าเริ่มต้น
          'selectedColor': '', // ค่าเริ่มต้น
          'name': title, // ใช้ title เป็น name
          'added_at': DateTime.now().toIso8601String(),
        };

        await box.put(favoriteKey, favoriteItem);
        isFavorite.value = true;
        log('Added to favorites: $favoriteKey');
      }
    } catch (e) {
      log('Error toggling favorite: $e');
    }
  }
}
