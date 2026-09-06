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
  var translatedPropsOptions = <String, Map<String, String>>{}.obs; // เก็บข้อมูลแปลภาษาของ props_list
  var selectedOptionsByCategory = <String, String>{}.obs; // เก็บ option ที่เลือกแต่ละ category เช่น {"0": "0:0", "1": "1:2"}

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

        // แปลภาษา props_list
        await translatePropsOptions();

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
  double get price {
    // Force reactive by accessing selectedOptionKey.value
    selectedOptionKey.value;
    return getCurrentPrice();
  }

  double get promotionPrice => _safeToDouble(itemData?['promotion_price']);
  double get originalPrice {
    // Force reactive by accessing selectedOptionKey.value
    selectedOptionKey.value;
    return getCurrentPrice();
  }

  double _safeToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Method สำหรับหาราคาจาก SKU ตาม selectedOptionKey
  double getCurrentPrice() {
    // ถ้าไม่มีการเลือก option ให้ใช้ราคาเดิม
    if (selectedOptionsByCategory.isEmpty) {
      return _safeToDouble(itemData?['price']);
    }

    // หาราคาจาก SKU ที่ตรงกับ selectedOptionKey
    final skus = itemData?['skus'];
    if (skus != null && skus['sku'] is List) {
      final skuList = skus['sku'] as List;

      // ตรวจสอบทุก SKU เพื่อหาที่ตรงกับ selected options
      for (var sku in skuList) {
        final skuProperties = sku['properties'] as String?;
        if (skuProperties == null) continue;

        // แยก properties ของ SKU
        final skuParts = skuProperties.split(';');
        bool isMatch = true;

        // ตรวจสอบว่า selected options ทุกตัวตรงกับ SKU นี้หรือไม่
        for (final selectedOption in selectedOptionsByCategory.values) {
          if (selectedOption.isEmpty) continue;

          bool foundInSku = false;
          for (final skuPart in skuParts) {
            if (skuPart == selectedOption) {
              foundInSku = true;
              break;
            }
          }

          if (!foundInSku) {
            isMatch = false;
            break;
          }
        }

        if (isMatch && selectedOptionsByCategory.isNotEmpty) {
          final skuPrice = _safeToDouble(sku['price']);
          log('Found matching SKU: $skuProperties with price: $skuPrice');
          log('Selected options: ${selectedOptionsByCategory.values.toList()}');

          // ถ้าราคาใน SKU เป็น 0 หรือไม่มี ให้ใช้ราคาเดิม
          if (skuPrice > 0) {
            return skuPrice;
          }
        }
      }
    }

    // ถ้าไม่เจอ SKU หรือราคาเป็น 0 ให้ใช้ราคาเดิม
    return _safeToDouble(itemData?['price']);
  }

  // สร้าง combination key จาก selected options
  String _buildCombinationKey() {
    if (selectedOptionsByCategory.isEmpty) return '';

    // หาทุก category ที่มีใน SKU properties และเรียงลำดับ
    final skus = itemData?['skus'];
    if (skus == null || skus['sku'] is! List) return '';

    final skuList = skus['sku'] as List;
    if (skuList.isEmpty) return '';

    // ใช้ SKU แรกเป็นตัวอย่างเพื่อหาลำดับ category
    final firstSkuProperties = skuList.first['properties'] as String?;
    if (firstSkuProperties == null) return '';

    final categoryOrder = <String>[];
    final propertyParts = firstSkuProperties.split(';');
    for (final part in propertyParts) {
      final keyParts = part.split(':');
      if (keyParts.isNotEmpty) {
        final category = keyParts[0];
        if (!categoryOrder.contains(category)) {
          categoryOrder.add(category);
        }
      }
    }

    // สร้าง combination key ตามลำดับที่พบใน SKU
    final selectedOptions = <String>[];
    for (final category in categoryOrder) {
      final selectedOption = selectedOptionsByCategory[category];
      if (selectedOption != null && selectedOption.isNotEmpty) {
        selectedOptions.add(selectedOption);
      }
    }

    final result = selectedOptions.join(';');
    log('Building combination key from SKU order $categoryOrder: $result');
    log('Selected options by category: $selectedOptionsByCategory');
    return result;
  }

  String get area => itemData?['area'] ?? '';
  String get detailUrl => itemData?['detail_url'] ?? '';
  String get nick => itemData?['nick'] ?? '';
  String get brand => itemData?['brand'] ?? '';
  String get numIidValue => itemData?['num_iid']?.toString() ?? '';

  // shop_id - รองรับทั้ง null, String, int แปลงเป็น String เสมอ
  String get shopId {
    final value = itemData?['shop_id'];
    if (value == null) return '';
    return value.toString();
  }

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

    // อัพเดท selectedOptionsByCategory
    final parts = optionKey.split(':');
    if (parts.length >= 2) {
      final categoryId = parts[0];
      selectedOptionsByCategory[categoryId] = optionKey;
      log('Updated selectedOptionsByCategory: $selectedOptionsByCategory');
    }

    // Force update price by triggering reactive update
    update();
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
      if (value.toString().contains('颜色:') || value.toString().contains('颜色分类:')) {
        final valueParts = value.toString().split(':');
        if (valueParts.length >= 2) {
          final originalColor = valueParts.sublist(1).join(':'); // รองรับ "颜色:白色" และ "颜色分类:黑色 速干款"
          final translatedColor = translateToThai(originalColor);
          mapping[translatedColor] = key; // เช่น "ขาว长款" -> "0:0" หรือ "1627207:28341"
        }
      }
    });
    return mapping;
  }

  // Create mapping between translated sizes and their keys
  Map<String, String> get sizeToKeyMapping {
    Map<String, String> mapping = {};
    propsList.forEach((key, value) {
      if (value.toString().contains('尺码:')) {
        final valueParts = value.toString().split(':');
        if (valueParts.length >= 2) {
          final originalSize = valueParts.sublist(1).join(':'); // เช่น "S", "M", "L"
          final translatedSize = translateToThai(originalSize);
          mapping[translatedSize] = key; // เช่น "S" -> "20509:28314"
        }
      }
    });

    // APIs can use one generic category (for example "-1" / 商品规格)
    // instead of a dedicated size category. Preserve its real option keys so
    // the existing SKU and price-selection logic continues to work.
    if (mapping.isEmpty && _singleGenericOptionGroup != null) {
      final groupId = _singleGenericOptionGroup!['id']?.toString();
      final items = groupId == null ? null : _optionsByCategory[groupId];
      for (final item in items ?? const <Map<String, String>>[]) {
        final value = item['value'];
        final key = item['key'];
        if (value != null && key != null) {
          mapping[translateToThai(value)] = key;
        }
      }
    }

    return mapping;
  }

  // Get props_list data
  Map<String, dynamic> get propsList {
    final props = itemData?['props_list'];

    // Keep the original API shape untouched when props_list is already a map.
    if (props is Map<String, dynamic>) {
      return props;
    }
    if (props is Map) {
      return Map<String, dynamic>.fromEntries(props.entries.map((entry) => MapEntry(entry.key.toString(), entry.value)));
    }

    // Some product-detail responses return the same options as a list. Convert
    // the common list shapes to the map shape consumed by the existing option,
    // SKU, image and translation logic.
    if (props is List) {
      final normalized = <String, dynamic>{};
      final categoryIds = <String, String>{};

      String categoryIdFor(String label) {
        final normalizedLabel = label.trim();
        return categoryIds.putIfAbsent(normalizedLabel, () => categoryIds.length.toString());
      }

      for (var index = 0; index < props.length; index++) {
        final option = props[index];

        if (option is String && option.trim().isNotEmpty) {
          final parts = option.split(':');
          final label = parts.length > 1 ? parts.first.trim() : '';
          final categoryId = categoryIdFor(label);
          normalized['$categoryId:$index'] = option;
          continue;
        }

        if (option is! Map) continue;

        final entry = Map<String, dynamic>.fromEntries(option.entries.map((entry) => MapEntry(entry.key.toString(), entry.value)));

        // Shape: [{"1627207:28341": "颜色分类:黑色"}, ...]
        if (entry.length == 1 && entry.keys.first.contains(':')) {
          normalized[entry.keys.first] = entry.values.first;
          continue;
        }

        // Shape: [{"key": "1627207:28341", "value": "颜色分类:黑色"}, ...]
        final explicitKey = entry['key'] ?? entry['properties'] ?? entry['property'] ?? entry['prop_key'];
        final label = entry['label'] ?? entry['name'] ?? entry['prop_name'] ?? entry['property_name'] ?? '';
        final value = entry['value'] ?? entry['option'] ?? entry['prop_value'] ?? entry['property_value'];

        if (value == null) continue;

        final key =
            explicitKey != null && explicitKey.toString().contains(':') ? explicitKey.toString() : '${categoryIdFor(label.toString())}:$index';
        final valueText = value.toString();
        normalized[key] = label.toString().trim().isNotEmpty && !valueText.contains(':') ? '${label.toString().trim()}:$valueText' : valueText;
      }

      return normalized;
    }

    return {};
  }

  // ------------------------- FLEX PARSER (ไม่สร้างคลาส) -------------------------

  /// แยก props_list เป็นกลุ่มตามด้านซ้ายของ key (เช่น "0", "1" หรือ "1627207", "122216343")
  /// คืนค่าเป็น Map<categoryId, List<Map<String,String>>> โดยรายการเก็บ {'key','value','raw'}
  Map<String, List<Map<String, String>>> get _optionsByCategory {
    final Map<String, List<Map<String, String>>> bucket = {};

    propsList.forEach((k, v) {
      if (v is! String || !k.contains(':')) return;
      final kp = k.split(':');
      if (kp.length != 2) return;
      final catId = kp[0].trim(); // "0", "1", "1627207", "122216343", ...
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
    if (_hasAny(['商品规格', '商品規格', 'product specification'])) return 'ตัวเลือกสินค้า';

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

  Map<String, dynamic>? get _singleGenericOptionGroup {
    final groups = optionGroups;
    if (groups.length != 1) return null;

    final label = groups.first['label'];
    if (label == 'สี' || label == 'ขนาด/ไซส์') return null;
    return groups.first;
  }

  String get sizeOptionLabel => _singleGenericOptionGroup?['label']?.toString() ?? 'ขนาด/ไซส์';

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
    if (one != null) return List<String>.from(one['options'] ?? const []);

    final genericGroup = _singleGenericOptionGroup;
    return genericGroup != null ? List<String>.from(genericGroup['options'] ?? const []) : <String>[];
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

  // ฟังก์ชันสำหรับแปลภาษา props_list
  Future<void> translatePropsOptions() async {
    try {
      final props = propsList;
      if (props.isEmpty) return;

      log('Props list to translate: ${props.length} items');

      // สร้าง list ของ options สำหรับแปล
      List<Map<String, dynamic>> optionsToTranslate = [];
      props.forEach((key, value) {
        if (value is String) {
          // แยกชื่อและค่าจาก value เช่น "颜色:罗森绿" -> name: "颜色", value: "罗森绿"
          final parts = value.split(':');
          if (parts.length >= 2) {
            optionsToTranslate.add({'key': key, 'name': parts[0], 'value': parts.sublist(1).join(':'), 'original': value});
          } else {
            // กรณีที่ไม่มี : ให้ใช้ value ทั้งหมด
            optionsToTranslate.add({'key': key, 'name': '', 'value': value, 'original': value});
          }
        }
      });

      log('Options to translate: ${optionsToTranslate.length} items');

      if (optionsToTranslate.isNotEmpty) {
        // ใช้ฟังก์ชัน extractTitlesToTranslatePops เพื่อสร้างข้อความสำหรับแปล
        final textToTranslate = extractTitlesToTranslatePops(optionsToTranslate);

        log('Text to translate: $textToTranslate');

        if (textToTranslate.isNotEmpty) {
          // เรียก translate API
          final translated = await HomeService.translate(text: textToTranslate, from: 'zh-CN', to: 'th');

          log('Translated result: $translated');

          if (translated != null && translated.isNotEmpty) {
            // ประมวลผลข้อมูลที่แปลแล้ว
            final translatedOptions = applyTranslatedTitlesToItemsPops(optionsToTranslate, translated);

            log('Translated options: ${translatedOptions.length} items');

            // เก็บข้อมูลแปลภาษา
            Map<String, Map<String, String>> translatedMap = {};
            for (var option in translatedOptions) {
              final key = option['key'] as String;
              translatedMap[key] = {
                'original': option['original'] ?? '',
                'translated_name': option['name'] ?? '',
                'translated_value': option['value'] ?? '',
                'translated_full': '${option['name'] ?? ''}:${option['value'] ?? ''}',
              };
            }

            translatedPropsOptions.value = translatedMap;
            log('Final translated map: ${translatedMap.length} items');
          }
        }
      }
    } catch (e) {
      log('Error translating props options: $e');
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
