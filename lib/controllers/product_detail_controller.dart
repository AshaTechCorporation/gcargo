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
  var selectedOptionKey = ''.obs; // สำหรับเก็บ option key ที่เลือก เช่น "0:0"

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

        // Debug: Log all available fields
        log('🔍 All product data fields: ${data.keys.toList()}');
        log('🖼️ desc_img data: ${data['desc_img']}');
        log('📋 props_list data: ${data['props_list']}');
        log('📝 description data: ${data['description']}');
        log('📄 detail data: ${data['detail']}');
        log('📄 content data: ${data['content']}');
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

  String extractTitlesToTranslate(List<Map<String, dynamic>> items, {String separator = '|||'}) {
    return items.map((item) => item['title'] ?? '').join(separator);
  }

  List<Map<String, dynamic>> applyTranslatedTitlesToItems(
    List<Map<String, dynamic>> originalItems,
    String translatedText, {
    String separator = '|||',
  }) {
    final translatedTitles = translatedText.split(separator);

    return List.generate(originalItems.length, (i) {
      final newItem = Map<String, dynamic>.from(originalItems[i]);
      if (i < translatedTitles.length) {
        newItem['title'] = translatedTitles[i].trim();
      }
      return newItem;
    });
  }

  String extractTitlesToTranslatePops(List<Map<String, dynamic>> items, {String separator = '|||'}) {
    return items.map((item) => '${item['name'] ?? ''}:${item['value'] ?? ''}').join(separator);
  }

  List<Map<String, dynamic>> applyTranslatedTitlesToItemsPops(
    List<Map<String, dynamic>> originalItems,
    String translatedText, {
    String separator = '|||',
  }) {
    final translatedTitles = translatedText.split(separator);

    return List.generate(originalItems.length, (i) {
      final newItem = Map<String, dynamic>.from(originalItems[i]);
      if (i < translatedTitles.length) {
        final data = translatedTitles[i].split(': ');
        if (data.length >= 2) {
          newItem['name'] = data[0].trim();
          newItem['value'] = data[1].trim();
        } else if (data.length == 1) {
          newItem['name'] = data[0].trim();
          newItem['value'] = originalItems[i]['value'] ?? '';
        }
      }
      return newItem;
    });
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

  // Get prop_imgs data
  Map<String, dynamic> get propImgs {
    final propImgs = itemData?['prop_imgs'];
    if (propImgs is Map<String, dynamic>) {
      return propImgs;
    }
    return {};
  }

  // Get prop_img list
  List<Map<String, dynamic>> get propImgList {
    final propImg = propImgs['prop_img'];
    if (propImg is List) {
      return propImg.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Get image URL for specific option key
  String getImageForOption(String optionKey) {
    for (var propImg in propImgList) {
      if (propImg['properties'] == optionKey) {
        return propImg['url'] ?? '';
      }
    }
    return '';
  }

  // Get all available images (prop_imgs only, fallback to main pic_url)
  List<String> get allImages {
    // Force reactive by accessing selectedOptionKey.value
    final currentSelection = selectedOptionKey.value;
    List<String> images = [];

    // Always show all prop_img images in original order
    if (propImgList.isNotEmpty) {
      for (var propImg in propImgList) {
        final url = propImg['url'];
        if (url != null && url.isNotEmpty && !images.contains(url)) {
          images.add(url);
        }
      }
      return images;
    }

    // Fallback: if no prop_imgs, show only main product image
    if (picUrl.isNotEmpty) {
      images.add(picUrl);
    }

    return images;
  }

  // Method to update selected option and trigger image change
  void updateSelectedOption(String optionKey) {
    selectedOptionKey.value = optionKey;
  }

  // Get current selected image URL (for cart/order)
  String get currentSelectedImageUrl {
    // If option is selected, use option image
    if (selectedOptionKey.value.isNotEmpty) {
      final optionImage = getImageForOption(selectedOptionKey.value);
      if (optionImage.isNotEmpty) {
        return optionImage;
      }
    }
    // If no option selected, use main pic_url
    return picUrl;
  }

  // Create mapping between translated colors and their keys
  Map<String, String> get colorToKeyMapping {
    Map<String, String> mapping = {};
    propsList.forEach((key, value) {
      if (value.toString().contains('颜色:')) {
        final originalColor = value.toString().split(':')[1]; // เช่น "白色长款"
        final translatedColor = translateToThai(originalColor); // เช่น "ขาว长款"
        mapping[translatedColor] = key; // "ขาว长款" -> "0:0"
      }
    });
    return mapping;
  }

  // Create mapping between translated sizes and their keys
  Map<String, String> get sizeToKeyMapping {
    Map<String, String> mapping = {};
    propsList.forEach((key, value) {
      if (value.toString().contains('尺码:')) {
        final originalSize = value.toString().split(':')[1]; // เช่น "XS"
        final translatedSize = translateToThai(originalSize); // เช่น "XS"
        mapping[translatedSize] = key; // "XS" -> "1:0"
      }
    });
    return mapping;
  }

  // Get props_list data
  Map<String, dynamic> get propsList {
    final props = itemData?['props_list'];
    if (props is Map<String, dynamic>) {
      return props;
    }
    return {};
  }

  // ------------------------- FLEX PARSER (ไม่สร้างคลาส) -------------------------

  /// แยก props_list เป็นกลุ่มตามด้านซ้ายของ key (เช่น "0", "1")
  /// คืนค่าเป็น Map<categoryId, List<Map<String,String>>> โดยรายการเก็บ {'key','value','raw'}
  Map<String, List<Map<String, String>>> get _optionsByCategory {
    final Map<String, List<Map<String, String>>> bucket = {};

    propsList.forEach((k, v) {
      if (v is! String || !k.contains(':')) return;
      final kp = k.split(':');
      if (kp.length != 2) return;
      final catId = kp[0].trim(); // "0", "1", ...
      // value เช่น "颜色:S23外置笔黑色【16+1T】" -> เก็บเฉพาะส่วนหลังเป็น value
      final vp = v.split(':');
      final cleaned = (vp.length >= 2 ? vp.sublist(1).join(':') : v).trim();

      final item = {'key': k, 'value': cleaned, 'raw': v};
      final list = bucket[catId] ?? <Map<String, String>>[];
      // กันซ้ำด้วย value
      final exists = list.any((e) => e['value'] == cleaned);
      if (!exists) list.add(item);
      bucket[catId] = list;
    });

    // sort catId ตามตัวเลขถ้าทำได้
    final sortedKeys =
        bucket.keys.toList()..sort((a, b) {
          final ai = int.tryParse(a);
          final bi = int.tryParse(b);
          if (ai == null || bi == null) return a.compareTo(b);
          return ai.compareTo(bi);
        });

    final Map<String, List<Map<String, String>>> out = {};
    for (final k in sortedKeys) {
      out[k] = bucket[k]!;
    }
    return out;
  }

  /// เดาชื่อกลุ่มจากข้อมูลภายใน (ยืดหยุ่น ไม่ฟิก)
  String _inferCategoryLabel(String categoryId, List<Map<String, String>> items) {
    final combined =
        (items.map((e) => e['raw']).whereType<String>().join(' | ') + ' ' + items.map((e) => e['value']).whereType<String>().join(' | '))
            .toLowerCase();

    bool _hasAny(List<String> hints) => hints.any((h) => combined.contains(h.toLowerCase()));

    // hints
    const colorHints = [
      '颜色',
      '顏色',
      'color',
      'สี',
      'black',
      'white',
      'red',
      'blue',
      'green',
      'yellow',
      'pink',
      'purple',
      'orange',
      'brown',
      'gray',
      'grey',
      '金色',
      '银色',
      '咖啡',
      '米色',
      '深蓝',
      '浅蓝',
      '深灰',
      '浅灰',
    ];
    const sizeHints = ['尺码', '尺寸', 'size', 'ไซส์', 'ขนาด', 'xs', 's', 'm', 'l', 'xl', 'xxl', 'xxxl', '均码', 'free size', 'one size'];
    const capacityHints = ['容量', '内存', '存储', 'storage', 'memory', 'ram', 'rom', 'gb', 'tb'];

    if (_hasAny(colorHints)) return 'สี';
    if (_hasAny(sizeHints)) return 'ขนาด/ไซส์';
    if (_hasAny(capacityHints)) return 'ความจุ/สเปก';

    // fallback: ตั้งชื่อทั่วไป + running number
    final idx = int.tryParse(categoryId);
    return 'ตัวเลือก ${idx != null ? (idx + 1) : categoryId}';
  }

  /// กลุ่มตัวเลือกทั้งหมด แบบพร้อมแปลไทย (ใช้เรนเดอร์ UI ได้เลย)
  /// โครงสร้าง: [{'id': '0', 'label': 'สี', 'options': ['ดำ','ขาว',...]}]
  List<Map<String, dynamic>> get optionGroups {
    final List<Map<String, dynamic>> out = [];
    _optionsByCategory.forEach((catId, items) {
      out.add({'id': catId, 'label': _inferCategoryLabel(catId, items), 'options': items.map((e) => translateToThai(e['value'] ?? '')).toList()});
    });
    return out;
  }

  /// หา key จริง ("0:0", "1:2", ...) จาก (categoryId, optionValue ที่ผู้ใช้เลือก)
  String? getOptionKeyByCategoryAndValue(String categoryId, String optionValue) {
    final items = _optionsByCategory[categoryId];
    if (items == null) return null;
    String norm(String s) => s.trim();
    final picked = norm(optionValue);
    for (final it in items) {
      final rawVal = norm(it['value'] ?? '');
      final thVal = norm(translateToThai(it['value'] ?? ''));
      if (picked == rawVal || picked == thVal) return it['key'];
    }
    return null;
  }

  // ----------------- Helper: availableSizes / availableColors (แบบยืดหยุ่น) -----------------

  /// ถ้าเจอกลุ่ม label == 'สี' ก็ใช้เลย, ไม่งั้นลองเดาจาก catId '0'
  List<String> get availableColors {
    // หา label == 'สี'
    final matchLabel = optionGroups.firstWhereOrNull((g) => g['label'] == 'สี');
    if (matchLabel != null) return List<String>.from(matchLabel['options'] ?? const []);

    // fallback: ลอง catId '0'
    final zero = optionGroups.firstWhereOrNull((g) => g['id'] == '0');
    return zero != null ? List<String>.from(zero['options'] ?? const []) : <String>[];
  }

  /// ถ้าเจอกลุ่ม label == 'ขนาด/ไซส์' ก็ใช้เลย, ไม่งั้นลองเดาจาก catId '1'
  List<String> get availableSizes {
    final matchLabel = optionGroups.firstWhereOrNull((g) => g['label'] == 'ขนาด/ไซส์');
    if (matchLabel != null) return List<String>.from(matchLabel['options'] ?? const []);

    final one = optionGroups.firstWhereOrNull((g) => g['id'] == '1');
    return one != null ? List<String>.from(one['options'] ?? const []) : <String>[];
  }

  // ------------------------- แปลข้อความ (จีน/อังกฤษ -> ไทย) -------------------------

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

      // Colors (EN)
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
