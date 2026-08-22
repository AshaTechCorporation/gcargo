import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcargo/home/firstPage.dart';
import 'package:gcargo/home/notificationPage.dart';
import 'package:gcargo/login/loginPage.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:gcargo/utils/helpers.dart';
import 'package:get/get.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/product_detail_controller.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/controllers/showImagePickerBottomSheet.dart' as controller;
import 'package:gcargo/home/cartPage.dart';
import 'package:gcargo/home/purchaseBillPage.dart';
import 'package:gcargo/home/widgets/product_description_widget.dart';
import 'package:gcargo/home/widgets/product_image_slider_widget.dart';
import 'package:gcargo/home/widgets/search_header_widget.dart';
import 'package:gcargo/services/cart_service.dart';
import 'package:gcargo/services/search_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatefulWidget {
  ProductDetailPage({super.key, required this.num_iid, required this.name, required this.type, required this.channel});
  String num_iid;
  String name;
  String type;
  String channel;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _quantityFocusNode = FocusNode();
  String selectedSize = '';
  String selectedColor = '';
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingRecommendedItem = false;
  double depositOrderRate = 4.0; // Default rate

  // Initialize ProductDetailController
  late final ProductDetailController productController;

  // Initialize HomeController to get search items
  late final HomeController homeController;

  // Initialize LanguageController
  late LanguageController languageController;

  // สำหรับเก็บไตเติ๊ลที่แปลแล้ว
  String translatedTitle = '';
  bool isTranslatingTitle = false;

  // สำหรับเก็บไตเติ๊ลที่แปลแล้วของ recommended items
  Map<String, String> translatedRecommendedTitles = {};
  bool isTranslatingRecommendedTitles = false;
  List<String> lastTranslatedItemIds = []; // เก็บ ID ของ items ที่แปลไปแล้ว

  // จำนวนสินค้าในตะกร้า
  int cartItemCount = 0;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'product_details': 'รายละเอียดสินค้า',
        'quantity': 'จำนวน',
        'size': 'ขนาด',
        'color': 'สี',
        'add_to_cart': 'เพิ่มลงตะกร้า',
        'buy_now': 'ซื้อเลย',
        'description': 'รายละเอียด',
        'specifications': 'ข้อมูลจำเพาะ',
        'reviews': 'รีวิว',
        'recommended': 'สินค้าแนะนำ',
        'price': 'ราคา',
        'original_price': 'ราคาเดิม',
        'discount': 'ส่วนลด',
        'in_stock': 'มีสินค้า',
        'out_of_stock': 'สินค้าหมด',
        'select_size': 'เลือกขนาด',
        'select_color': 'เลือกสี',
        'added_to_cart': 'เพิ่มลงตะกร้าแล้ว',
        'error_occurred': 'เกิดข้อผิดพลาด',
        'loading': 'กำลังโหลด...',
        'no_description': 'ไม่มีรายละเอียด',
        'share': 'แชร์',
        'favorite': 'รายการโปรด',
        'search_hint': 'ค้นหาสินค้า...',
        'related_products': 'สินค้าที่เกี่ยวข้อง',
        'product_images': 'รูปภาพสินค้า',
        'zoom_image': 'ขยายรูป',
        'select_options': 'เลือกตัวเลือก',
        'total_price': 'ราคารวม',
        'shipping_info': 'ข้อมูลการจัดส่ง',
        'return_policy': 'นโยบายการคืนสินค้า',
        'seller_info': 'ข้อมูลผู้ขาย',
        'customer_reviews': 'รีวิวลูกค้า',
        'rating': 'คะแนน',
        'view_all_reviews': 'ดูรีวิวทั้งหมด',
        'not_logged_in': 'ยังไม่ได้เข้าสู่ระบบ',
        'please_login_first': 'กรุณาเข้าสู่ระบบก่อนสั่งซื้อสินค้า',
        'ok': 'ตกลง',
        'cancel': 'ยกเลิก',
        'order_now': 'สั่งซื้อสินค้า',
        'you_might_like': 'สิ่งที่คุณอาจสนใจ',
        'search_products': 'ค้นหาสินค้า',
      },
      'en': {
        'product_details': 'Product Details',
        'quantity': 'Quantity',
        'size': 'Size',
        'color': 'Color',
        'add_to_cart': 'Add to Cart',
        'buy_now': 'Buy Now',
        'description': 'Description',
        'specifications': 'Specifications',
        'reviews': 'Reviews',
        'recommended': 'Recommended',
        'price': 'Price',
        'original_price': 'Original Price',
        'discount': 'Discount',
        'in_stock': 'In Stock',
        'out_of_stock': 'Out of Stock',
        'select_size': 'Select Size',
        'select_color': 'Select Color',
        'added_to_cart': 'Added to Cart',
        'error_occurred': 'An Error Occurred',
        'loading': 'Loading...',
        'no_description': 'No Description',
        'share': 'Share',
        'favorite': 'Favorite',
        'search_hint': 'Search products...',
        'related_products': 'Related Products',
        'product_images': 'Product Images',
        'zoom_image': 'Zoom Image',
        'select_options': 'Select Options',
        'total_price': 'Total Price',
        'shipping_info': 'Shipping Info',
        'return_policy': 'Return Policy',
        'seller_info': 'Seller Info',
        'customer_reviews': 'Customer Reviews',
        'rating': 'Rating',
        'view_all_reviews': 'View All Reviews',
        'not_logged_in': 'Not Logged In',
        'please_login_first': 'Please log in before placing an order',
        'ok': 'OK',
        'cancel': 'Cancel',
        'order_now': 'Order Now',
        'you_might_like': 'You Might Like',
        'search_products': 'Search products',
      },
      'zh': {
        'product_details': '商品详情',
        'quantity': '数量',
        'size': '尺寸',
        'color': '颜色',
        'add_to_cart': '加入购物车',
        'buy_now': '立即购买',
        'description': '描述',
        'specifications': '规格',
        'reviews': '评价',
        'recommended': '推荐',
        'price': '价格',
        'original_price': '原价',
        'discount': '折扣',
        'in_stock': '有库存',
        'out_of_stock': '缺货',
        'select_size': '选择尺寸',
        'select_color': '选择颜色',
        'added_to_cart': '已加入购物车',
        'error_occurred': '发生错误',
        'loading': '加载中...',
        'no_description': '无描述',
        'share': '分享',
        'favorite': '收藏',
        'search_hint': '搜索商品...',
        'related_products': '相关商品',
        'product_images': '商品图片',
        'zoom_image': '放大图片',
        'select_options': '选择选项',
        'total_price': '总价',
        'shipping_info': '配送信息',
        'return_policy': '退货政策',
        'seller_info': '卖家信息',
        'customer_reviews': '客户评价',
        'rating': '评分',
        'view_all_reviews': '查看所有评价',
        'not_logged_in': '未登录',
        'please_login_first': '请先登录再下单',
        'ok': '确定',
        'cancel': '取消',
        'order_now': '立即下单',
        'you_might_like': '您可能喜欢',
        'search_products': '搜索商品',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _quantityController.text = quantity.toString();
    _quantityFocusNode.addListener(() {
      if (!_quantityFocusNode.hasFocus) {
        _validateQuantity();
      }
    });
    languageController = Get.find<LanguageController>();

    // สร้าง controller และเรียก API
    productController = Get.put(ProductDetailController(), tag: widget.num_iid);
    productController.getItemDetail(widget.num_iid, widget.type).then((_) {
      // หลังจากโหลดข้อมูลสินค้าเสร็จแล้ว ให้แปลไตเติ๊ล
      _translateTitle();
    });

    // Get existing HomeController or create new one
    try {
      homeController = Get.find<HomeController>();
    } catch (e) {
      homeController = Get.put(HomeController());
    }
    //_loadExchangeRate();

    // โหลดจำนวนสินค้าในตะกร้า
    _loadCartItemCount();
  }

  // โหลดจำนวนสินค้าในตะกร้า
  void _loadCartItemCount() {
    try {
      setState(() {
        cartItemCount = CartService.getCartItemsCount();
      });
    } catch (e) {
      setState(() {
        cartItemCount = 0;
      });
    }
  }

  // ฟังก์ชันสำหรับแปลไตเติ๊ล
  Future<void> _translateTitle() async {
    if (productController.title.isEmpty || isTranslatingTitle || translatedTitle.isNotEmpty) return;

    setState(() {
      isTranslatingTitle = true;
    });

    try {
      // ใช้ฟังก์ชัน extractTitlesToTranslate เพื่อดึงไตเติ๊ล
      final titleToTranslate = productController.extractTitlesToTranslate([
        {'title': productController.title},
      ]);

      if (titleToTranslate.isNotEmpty) {
        // เรียก translate API
        final translated = await HomeService.translate(text: titleToTranslate, from: 'zh-CN', to: 'th');

        if (translated != null && translated.isNotEmpty) {
          setState(() {
            translatedTitle = translated;
          });
        }
      }
    } catch (e) {
      print('Error translating title: $e');
    } finally {
      setState(() {
        isTranslatingTitle = false;
      });
    }
  }

  // ฟังก์ชันสำหรับแปลไตเติ๊ลของ recommended items
  Future<void> _translateRecommendedTitles(List<Map<String, dynamic>> items) async {
    if (items.isEmpty || isTranslatingRecommendedTitles) return;
    // บันทึก item IDs ที่กำลังจะแปล
    lastTranslatedItemIds = items.map((item) => item['num_iid']?.toString() ?? '').toList();

    setState(() {
      isTranslatingRecommendedTitles = true;
    });

    try {
      // รวบรวมไตเติ๊ลทั้งหมดเพื่อส่งแปลครั้งเดียว
      final List<String> originalTitles = [];

      for (int i = 0; i < items.length; i++) {
        final originalTitle = items[i]['title']?.toString() ?? '';
        if (originalTitle.isNotEmpty) {
          originalTitles.add(originalTitle);
        }
      }

      if (originalTitles.isNotEmpty) {
        final Map<String, String> titleMap = {};

        // ครั้งที่ 1: ส่งแปลทั้งหมด
        await _translateRecommendedTitlesRound(originalTitles, titleMap, 1);

        // เช็คว่าได้แปลครบหรือไม่
        final List<String> missingTitles = originalTitles.where((title) => !titleMap.containsKey(title)).toList();

        if (missingTitles.isNotEmpty) {
          print('🔄 Round 2: Translating ${missingTitles.length} missing recommended titles');
          await _translateRecommendedTitlesRound(missingTitles, titleMap, 2);
        }

        if (mounted) {
          setState(() {
            translatedRecommendedTitles = titleMap;
          });
        }

        print('🎉 Recommended titles translation completed. Total translated: ${titleMap.length}/${originalTitles.length}');
      }

      // ถ้าการแปลไม่สำเร็จ ให้ reset เพื่อให้ลองใหม่ได้
      if (mounted && translatedRecommendedTitles.isEmpty) {
        lastTranslatedItemIds = [];
      }
    } catch (e) {
      print('Error translating recommended titles: $e');
      // Reset เมื่อเกิด error
      if (mounted) {
        lastTranslatedItemIds = [];
      }
    } finally {
      if (mounted) {
        setState(() {
          isTranslatingRecommendedTitles = false;
        });
      }
    }
  }

  // ฟังก์ชันช่วยสำหรับแปลแต่ละรอบของ recommended titles
  Future<void> _translateRecommendedTitlesRound(List<String> titlesToTranslate, Map<String, String> titleMap, int round) async {
    try {
      // รวมไตเติ๊ลด้วย separator
      final String combinedText = titlesToTranslate.join('|||');
      print('📝 Round $round - Combined recommended titles to translate: ${combinedText.length} characters');

      // ส่งแปลครั้งเดียว
      final String? translatedText = await HomeService.translate(text: combinedText, from: 'zh-CN', to: 'th');

      if (translatedText != null && translatedText.isNotEmpty) {
        // แยกผลลัพธ์ที่แปลแล้ว
        final List<String> translatedTitles = translatedText.split('|||');

        // จับคู่ไตเติ๊ลต้นฉบับกับที่แปลแล้ว
        for (int i = 0; i < titlesToTranslate.length && i < translatedTitles.length; i++) {
          final original = titlesToTranslate[i];
          final translated = translatedTitles[i].trim();
          if (translated.isNotEmpty) {
            titleMap[original] = translated;
            print('✅ Round $round - Recommended translated: "$original" -> "$translated"');
          }
        }
      }
    } catch (e) {
      print('❌ Error in recommended translation round $round: $e');
    }
  }

  // ฟังก์ชันเปรียบเทียบ list
  bool _listEquals(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  void _validateQuantity() {
    int? val = int.tryParse(_quantityController.text);
    if (val == null || val <= 0) {
      setState(() {
        quantity = 1;
        _quantityController.text = '1';
      });
    } else {
      setState(() {
        quantity = val;
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    _scrollController.dispose();
    // ลบ controller เมื่อออกจากหน้า
    Get.delete<ProductDetailController>(tag: widget.num_iid);
    super.dispose();
  }

  // Load exchange rate from API
  Future<void> _loadExchangeRate() async {
    try {
      final exchangeData = await HomeService.getExchageRate();
      if (exchangeData != null && exchangeData['deposit_order_rate'] != null) {
        setState(() {
          depositOrderRate = double.tryParse(exchangeData['deposit_order_rate'].toString()) ?? 4.0;
        });
      }
    } catch (e) {
      print('Error loading exchange rate: $e');
      // Keep default rate if API fails
    }
  }

  // เช็ค userID ว่าเข้าสู่ระบบแล้วหรือไม่
  Future<bool> _checkUserLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');

    if (userID == null) {
      // แสดงแจ้งเตือนให้เข้าสู่ระบบ
      if (mounted) {
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // ป้องกันการปิดโดยการแตะข้างนอก
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(getTranslation('not_logged_in')),
              content: Text(getTranslation('please_login_first')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false), // ยกเลิก
                  child: Text(getTranslation('cancel')),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true); // ตกลง
                    // ไปหน้าล็อกอินแบบ removeUntil
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
                  },
                  child: Text(getTranslation('ok')),
                ),
              ],
            );
          },
        );

        // ถ้าผู้ใช้กดตกลง จะไปหน้าล็อกอินแล้ว ไม่ต้อง return อะไร
        // ถ้าผู้ใช้กดยกเลิก ให้ return false
        return false;
      }
      return false;
    }

    return true;
  }

  Widget buildSizeSelector() {
    return Obx(() {
      final availableSizes = productController.availableSizes;

      if (availableSizes.isEmpty) {
        return Text(getTranslation('select_size'), style: TextStyle(color: Colors.grey));
      }

      return Wrap(
        spacing: 8,
        children:
            availableSizes.map((size) {
              final translatedSize = productController.translateToThai(size);
              final selected = selectedSize == size;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedSize = size);

                  // Use mapping to find key
                  final sizeMapping = productController.sizeToKeyMapping;
                  final optionKey = sizeMapping[size];

                  print('📏 Size: $size -> Key: $optionKey');

                  if (optionKey != null) {
                    productController.updateSelectedOption(optionKey);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: selected ? kButtonColor : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: selected ? kButtonColor : Colors.white,
                  ),
                  child: Obx(() {
                    final sizeMapping = productController.sizeToKeyMapping;
                    final mappedKey = sizeMapping[size];
                    final translatedData = mappedKey != null ? productController.translatedPropsOptions[mappedKey] : null;
                    final originalText = translatedData?['original'] ?? size;
                    final translatedText = translatedData?['translated_value'] ?? translatedSize;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          originalText.split(':').length > 1 ? originalText.split(':')[1] : originalText,
                          style: TextStyle(color: selected ? Colors.white : Colors.black, fontSize: 10),
                        ),
                        if (translatedText != originalText && translatedText.isNotEmpty) ...[
                          SizedBox(height: 2),
                          Text(translatedText, style: TextStyle(color: selected ? Colors.white70 : Colors.grey, fontSize: 10)),
                        ],
                      ],
                    );
                  }),
                ),
              );
            }).toList(),
      );
    });
  }

  Widget buildColorOptions() {
    return Obx(() {
      final availableColors = productController.availableColors;

      if (availableColors.isEmpty) {
        return Text(getTranslation('select_color'), style: TextStyle(color: Colors.grey));
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            availableColors.map((color) {
              final translatedColor = productController.translateToThai(color);
              final selected = selectedColor == color;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedColor = color);

                  // Use mapping to find key
                  final colorMapping = productController.colorToKeyMapping;
                  final optionKey = colorMapping[translatedColor];

                  print('🎨 Color: $translatedColor -> Key: $optionKey');

                  if (optionKey != null) {
                    productController.updateSelectedOption(optionKey);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: selected ? kButtonColor : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: selected ? kButtonColor : Colors.white,
                  ),
                  child: Obx(() {
                    final colorMapping = productController.colorToKeyMapping;
                    final mappedKey = colorMapping[translatedColor];
                    final translatedData = mappedKey != null ? productController.translatedPropsOptions[mappedKey] : null;
                    final originalText = translatedData?['original'] ?? translatedColor;
                    final translatedText = translatedData?['translated_value'] ?? translatedColor;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          originalText.split(':').length > 1 ? originalText.split(':')[1] : originalText,
                          style: TextStyle(color: selected ? Colors.white : Colors.black, fontSize: 10),
                        ),
                        if (translatedText != originalText && translatedText.isNotEmpty) ...[
                          SizedBox(height: 2),
                          Text(translatedText, style: TextStyle(color: selected ? Colors.white70 : Colors.grey, fontSize: 10)),
                        ],
                      ],
                    );
                  }),
                ),
              );
            }).toList(),
      );
    });
  }

  Widget _buildRecommendedItem(Map<String, dynamic> item) {
    final originalTitle = item['title'] ?? 'ไม่มีชื่อสินค้า';
    final itemTranslatedTitle = translatedRecommendedTitles[originalTitle] ?? originalTitle;
    final picUrl = formatImageUrl(item['pic_url'] ?? '');
    final price = item['price']?.toString() ?? '0';
    final numIid = item['num_iid']?.toString() ?? '';

    return GestureDetector(
      onTap: () async {
        // ป้องกันการกดซ้ำระหว่างโหลด
        if (_isLoadingRecommendedItem || numIid.isEmpty) return;

        setState(() {
          _isLoadingRecommendedItem = true;
        });

        try {
          // เรียก API เพื่อดึงข้อมูลสินค้าใหม่
          await productController.getItemDetail(numIid, widget.type);

          // รีเซ็ตการแปลและแปลใหม่
          setState(() {
            translatedTitle = '';
            translatedRecommendedTitles.clear();
            lastTranslatedItemIds.clear();
          });

          // แปลไตเติ๊ลหลักใหม่
          _translateTitle();

          // เลื่อนขึ้นด้านบนหลังจาก API เสร็จ
          if (_scrollController.hasClients) {
            _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
          }
        } catch (e) {
          print('Error loading recommended item: $e');
        } finally {
          if (mounted) {
            setState(() {
              _isLoadingRecommendedItem = false;
            });
          }
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                        child:
                            picUrl.isNotEmpty
                                ? Image.network(
                                  picUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.fill,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: Colors.grey.shade200,
                                      child: const Center(child: CircularProgressIndicator()),
                                    );
                                  },
                                )
                                : Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image, color: Colors.grey),
                                ),
                      ),
                      const Positioned(top: 8, right: 8, child: Icon(Icons.favorite_border, color: Colors.grey)),
                    ],
                  ),
                ),

                // Product Info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ไตเติ๊ลต้นฉบับ
                            Text(
                              originalTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // ไตเติ๊ลที่แปลแล้ว (ถ้ามี)
                            if (itemTranslatedTitle != originalTitle) ...[
                              const SizedBox(height: 2),
                              Text(
                                itemTranslatedTitle,
                                style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w500),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text('¥$price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoadingRecommendedItem)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 3)),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildBottomBar() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kSubButtonColor,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6), // ✅ ขอบมนเล็กน้อย
              ),
            ),
            onPressed: () async {
              // เช็ค userID ก่อนสั่งซื้อ
              final isLoggedIn = await _checkUserLogin();
              if (!isLoggedIn) return;

              // Prepare product data to send to PurchaseBillPage
              final productData = {
                'num_iid': productController.numIidValue,
                'title': productController.title,
                'translatedTitle': translatedTitle.isNotEmpty ? translatedTitle : null,
                'price': productController.price,
                'orginal_price': productController.originalPrice,
                'nick': productController.nick,
                'detail_url': productController.detailUrl,
                'pic_url': productController.currentSelectedImageUrl,
                'brand': productController.brand,
                'quantity': quantity,
                'selectedSize': selectedSize,
                'selectedColor': selectedColor,
                'name': widget.name,
                'shop_id': productController.shopId,
              };

              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PurchaseBillPage(productDataList: [productData], channel: widget.channel, type: widget.type)),
                );
              }
            },
            child: Text(getTranslation('order_now'), style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kButtonColor,
              side: BorderSide(color: kButtonColor),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6), // ✅ ขอบมนเล็กน้อย
              ),
            ),
            onPressed: () async {
              // เช็ค userID ก่อนเพิ่มลงตะกร้า
              final isLoggedIn = await _checkUserLogin();
              if (!isLoggedIn) return;

              // Store context before async operations
              final currentContext = context;

              // Create product data
              final productData = {
                'num_iid': productController.numIidValue,
                'title': productController.title,
                'translatedTitle': translatedTitle.isNotEmpty ? translatedTitle : null,
                'price': productController.price,
                'orginal_price': productController.originalPrice,
                'nick': productController.nick,
                'detail_url': productController.detailUrl,
                'pic_url': productController.currentSelectedImageUrl,
                'brand': productController.brand,
                'quantity': quantity,
                'selectedSize': selectedSize,
                'selectedColor': selectedColor,
                'name': widget.name,
                'id': 0,
                'shop_id': productController.shopId,
              };

              try {
                // Add to cart
                await CartService.addToCart(productData);

                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    SnackBar(content: Text(getTranslation('added_to_cart')), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
                  );
                  _loadCartItemCount();

                  // Navigate to cart page
                  Navigator.push(currentContext, MaterialPageRoute(builder: (_) => CartPage(type: widget.type)));
                }
              } catch (e) {
                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    SnackBar(
                      content: Text('${getTranslation('error_occurred')}: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: Text(getTranslation('add_to_cart'), style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,

          // ✅ AppBar ที่เหมือนหน้า Home
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => FirstPage()), (route) => false),
              ),
              title: SearchHeaderWidget(
                searchController: searchController,
                cartItemCount: cartItemCount,
                onFieldSubmitted: (query) {
                  SearchService.handleTextSearch(context: context, query: query, selectedType: widget.type);
                },
                onImagePicked: (XFile image) {
                  SearchService.handleImageSearch(context: context, image: image, selectedType: widget.type);
                },
                onBagTap: () async {
                  // เช็ค userID ก่อนไปหน้าตะกร้า
                  final isLoggedIn = await _checkUserLogin();
                  if (!isLoggedIn) return;
                  if (mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage(type: widget.type)));
                  }
                },
                onNotificationTap: () {
                  // TODO: ไปหน้า notification
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
                },
              ),
            ),
          ),

          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      Stack(
                        children: [
                          ProductImageSliderWidget(productController: productController),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Obx(
                              () => GestureDetector(
                                onTap: () async {
                                  await productController.toggleFavorite();
                                },
                                child: Icon(
                                  productController.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                                  color: productController.isFavorite.value ? kButtonColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // แสดงข้อมูลสินค้าจาก API
                      Obx(() {
                        if (productController.isLoading.value) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 20,
                                width: 200,
                                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                              ),
                              SizedBox(height: 8),
                              Container(
                                height: 24,
                                width: 100,
                                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                              ),
                            ],
                          );
                        }

                        if (productController.hasError.value) {
                          return Column(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 48),
                              SizedBox(height: 8),
                              Text(productController.errorMessage.value, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
                              SizedBox(height: 8),
                              ElevatedButton(onPressed: () => productController.refreshData(), child: Text('ลองใหม่')),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ไตเติ๊ลต้นฉบับ
                            Text(productController.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                            // ไตเติ๊ลที่แปลแล้ว
                            if (isTranslatingTitle) ...[
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                                  SizedBox(width: 8),
                                  Text('กำลังแปล...', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ] else if (translatedTitle.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Text(translatedTitle, style: TextStyle(fontSize: 16, color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
                            ],

                            SizedBox(height: 6),
                            Text(
                              '¥${productController.originalPrice}',
                              style: TextStyle(fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                            if (productController.area.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Text('จาก: ${productController.area}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                            ],
                          ],
                        );
                      }),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          Text(getTranslation('quantity')),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (quantity > 1) {
                                  quantity--;
                                  _quantityController.text = quantity.toString();
                                }
                              });
                            },
                          ),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: _quantityController,
                              focusNode: _quantityFocusNode,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                int? val = int.tryParse(value);
                                if (val != null && val > 0) {
                                  quantity = val;
                                }
                              },
                              onSubmitted: (value) {
                                _validateQuantity();
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                quantity++;
                                _quantityController.text = quantity.toString();
                              });
                            },
                          ),
                        ],
                      ),
                      Divider(height: 32),

                      Text(getTranslation('size'), style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      buildSizeSelector(),

                      SizedBox(height: 20),
                      Text(getTranslation('color'), style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      buildColorOptions(),

                      SizedBox(height: 20),

                      // แสดงคำอธิบายสินค้า
                      ProductDescriptionWidget(
                        productController: productController,
                        translatedTitle: translatedTitle.isNotEmpty ? translatedTitle : null,
                      ),

                      // 🔽 ส่วนนี้แทรกไว้ "ก่อน" หัวข้อ 'สิ่งที่คุณอาจสนใจ'
                      Column(
                        children: [
                          // Divider(),
                          // Center(
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       // TODO: แสดงเนื้อหาเพิ่มเติม
                          //     },
                          //     child: Row(
                          //       mainAxisSize: MainAxisSize.min,
                          //       children: [
                          //         Text('แสดงเพิ่มเติม', style: TextStyle(color: Colors.grey)),
                          //         SizedBox(width: 4),
                          //         Icon(Icons.expand_more, color: Colors.grey, size: 18),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          Divider(),
                          SizedBox(height: 16),
                        ],
                      ),

                      SizedBox(height: 24),
                      Text(getTranslation('you_might_like'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 12),

                      // แสดงข้อมูลจาก homeController.searchItems
                      Obx(() {
                        if (homeController.isLoading.value) {
                          return Container(height: 200, child: Center(child: CircularProgressIndicator()));
                        }

                        if (homeController.hasError.value) {
                          return Container(
                            height: 100,
                            child: Center(child: Text(getTranslation('error_occurred'), style: TextStyle(color: Colors.grey))),
                          );
                        }

                        final searchItems = homeController.searchItems;
                        if (searchItems.isEmpty) {
                          return Container(
                            height: 100,
                            child: Center(child: Text(getTranslation('recommended'), style: TextStyle(color: Colors.grey))),
                          );
                        }

                        // แสดงสินค้าสูงสุด 6 รายการ
                        final itemsToShow = searchItems.take(6).toList();

                        // สร้าง list ของ item IDs สำหรับเปรียบเทียบ
                        final currentItemIds = itemsToShow.map((item) => item['num_iid']?.toString() ?? '').toList();

                        // แปลไตเติ๊ลของ recommended items ถ้ายังไม่ได้แปลหรือ items เปลี่ยน
                        final itemsChanged = !_listEquals(currentItemIds, lastTranslatedItemIds);

                        // ถ้าการแปลล้มเหลว (ไม่มีผลลัพธ์) ให้ลองใหม่
                        final shouldRetry = translatedRecommendedTitles.isEmpty && lastTranslatedItemIds.isNotEmpty;

                        if (!isTranslatingRecommendedTitles && (itemsChanged || shouldRetry)) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _translateRecommendedTitles(itemsToShow);
                          });
                        }

                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.75,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children:
                              itemsToShow.map((item) {
                                return _buildRecommendedItem(item);
                              }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 16), child: buildBottomBar()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
