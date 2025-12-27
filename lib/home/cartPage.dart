import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/home/purchaseBillPage.dart';
import 'package:gcargo/models/cart_item.dart';
import 'package:gcargo/models/user.dart';
import 'package:gcargo/services/cart_service.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:gcargo/utils/helpers.dart';
import 'package:get/get.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, required this.type});
  final String? type;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isDeleteMode = false;
  List<bool> selectedItems = [];
  List<bool> selectedForPurchase = []; // For normal selection (purchase)
  List<CartItem> cartItems = [];
  bool isLoading = true;
  late HomeController homeController;
  late LanguageController languageController;
  bool isLoadingServices = true;
  double depositOrderRate = 4.0; // Default rate
  User? currentUser;
  List<Map<String, dynamic>> apiCartItems = [];

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'cart': 'ตะกร้าสินค้า',
        'shopping_cart': 'ตะกร้าสินค้า',
        'edit': 'แก้ไข',
        'done': 'เสร็จสิ้น',
        'delete': 'ลบ',
        'select_all': 'เลือกทั้งหมด',
        'deselect_all': 'ยกเลิกการเลือก',
        'empty_cart': 'ตะกร้าสินค้าว่างเปล่า',
        'start_shopping': 'เริ่มช้อปปิ้ง',
        'loading': 'กำลังโหลด...',
        'quantity': 'จำนวน',
        'price': 'ราคา',
        'total': 'รวม',
        'subtotal': 'ยอดรวม',
        'extra_services': 'บริการเสริม',
        'wooden_crate': 'ตีลังไม้',
        'plastic_wrap': 'พันพลาสติก',
        'bubble_wrap': 'พันฟองอากาศ',
        'checkout': 'ชำระเงิน',
        'go_to_checkout': 'ไปหน้าชำระเงิน',
        'remove_selected': 'ลบรายการที่เลือก',
        'confirm_delete': 'ยืนยันการลบ',
        'delete_confirmation': 'คุณต้องการลบสินค้าที่เลือกหรือไม่?',
        'cancel': 'ยกเลิก',
        'confirm': 'ยืนยัน',
        'item_removed': 'ลบสินค้าแล้ว',
        'error_occurred': 'เกิดข้อผิดพลาด',
        'select_items_first': 'กรุณาเลือกสินค้าก่อน',
        'baht': 'บาท',
        'items_selected': 'รายการที่เลือก',
        'no_items_selected': 'ไม่มีรายการที่เลือก',
        'sync_data': 'ซิงค์ข้อมูล',
      },
      'en': {
        'cart': 'Cart',
        'shopping_cart': 'Shopping Cart',
        'edit': 'Edit',
        'done': 'Done',
        'delete': 'Delete',
        'select_all': 'Select All',
        'deselect_all': 'Deselect All',
        'empty_cart': 'Your cart is empty',
        'start_shopping': 'Start Shopping',
        'loading': 'Loading...',
        'quantity': 'Quantity',
        'price': 'Price',
        'total': 'Total',
        'subtotal': 'Subtotal',
        'extra_services': 'Extra Services',
        'wooden_crate': 'Wooden Crate',
        'plastic_wrap': 'Plastic Wrap',
        'bubble_wrap': 'Bubble Wrap',
        'checkout': 'Checkout',
        'go_to_checkout': 'Go to Checkout',
        'remove_selected': 'Remove Selected',
        'confirm_delete': 'Confirm Delete',
        'delete_confirmation': 'Do you want to delete selected items?',
        'cancel': 'Cancel',
        'confirm': 'Confirm',
        'item_removed': 'Item removed',
        'error_occurred': 'An error occurred',
        'select_items_first': 'Please select items first',
        'baht': 'Baht',
        'items_selected': 'Items Selected',
        'no_items_selected': 'No Items Selected',
        'sync_data': 'Sync Data',
      },
      'zh': {
        'cart': '购物车',
        'shopping_cart': '购物车',
        'edit': '编辑',
        'done': '完成',
        'delete': '删除',
        'select_all': '全选',
        'deselect_all': '取消全选',
        'empty_cart': '购物车为空',
        'start_shopping': '开始购物',
        'loading': '加载中...',
        'quantity': '数量',
        'price': '价格',
        'total': '总计',
        'subtotal': '小计',
        'extra_services': '额外服务',
        'wooden_crate': '木箱包装',
        'plastic_wrap': '塑料包装',
        'bubble_wrap': '气泡包装',
        'checkout': '结账',
        'go_to_checkout': '去结账',
        'remove_selected': '删除选中项',
        'confirm_delete': '确认删除',
        'delete_confirmation': '您要删除选中的商品吗？',
        'cancel': '取消',
        'confirm': '确认',
        'item_removed': '商品已删除',
        'error_occurred': '发生错误',
        'select_items_first': '请先选择商品',
        'baht': '泰铢',
        'items_selected': '已选择商品',
        'no_items_selected': '未选择商品',
        'sync_data': '同步数据',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();

    // Get HomeController
    try {
      homeController = Get.find<HomeController>();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    // Get current user
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fristLoad();
    });
    // Fetch extra services
    _loadExtraServices();
    _loadCartItems();
    // หลังจากโหลดข้อมูลสินค้าเสร็จแล้ว ให้แปลไตเติ๊ล
    _loadExchangeRate();
  }

  Future<void> fristLoad() async {
    try {
      final user = await homeController.getUserByIdFromAPI();
      if (user != null) {
        setState(() {
          currentUser = user;
        });
      }
      // เรียก API getCartItems
      await _loadApiCartItems();
    } catch (e) {
      print('Error in fristLoad: $e');
    }
  }

  // โหลดข้อมูลตะกร้าจาก API
  Future<void> _loadApiCartItems() async {
    try {
      final result = await HomeService.getCartItems();
      if (result['success'] == true && result['products'] != null) {
        setState(() {
          apiCartItems = List<Map<String, dynamic>>.from(result['products']);
        });
        //inspect(apiCartItems);

        // เช็คและ sync ข้อมูลจาก API กับ Hive
        await _syncApiCartToHive();
      } else {
        setState(() {
          apiCartItems = [];
        });
      }
    } catch (e) {
      print('Error loading API cart items: $e');
      setState(() {
        apiCartItems = [];
      });
    }
  }

  // sync ข้อมูลจาก API กับ Hive
  Future<void> _syncApiCartToHive() async {
    if (apiCartItems.isEmpty) return;

    // ดึงข้อมูลจาก Hive ก่อน
    final hiveItems = CartService.getCartItems();
    bool hasNewItems = false;

    for (var apiItem in apiCartItems) {
      final productCode = apiItem['product_code']?.toString() ?? '';
      if (productCode.isEmpty) continue;

      // ดึงข้อมูล variants สำหรับ size และ color (API ส่งกลับมาในชื่อ variants)
      String size = '';
      String color = '';
      final variants = apiItem['variants'];
      if (variants != null && variants is List) {
        for (var variant in variants) {
          final optionName = variant['option_name']?.toString() ?? '';
          final optionValue = variant['option_value']?.toString() ?? '';
          if (optionName == 'ไซส์' || optionName.toLowerCase() == 'size') {
            size = optionValue;
          } else if (optionName == 'สี' || optionName.toLowerCase() == 'color') {
            color = optionValue;
          }
        }
      }

      // เช็คว่ามีใน Hive หรือไม่ โดยเทียบจาก hiveItems ที่ดึงมา
      final existingHiveItem = hiveItems.where((item) => item.numIid == productCode).toList();

      if (existingHiveItem.isEmpty) {
        // ถ้าไม่มีใน Hive ให้เพิ่มเข้าไป
        // shop_id - รองรับทั้ง null, String, int แปลงเป็น String เสมอ
        final shopIdValue = apiItem['shop_id'];
        final shopId = shopIdValue == null ? '' : shopIdValue.toString();

        final productData = {
          'num_iid': productCode,
          'title': apiItem['product_name'] ?? '',
          'price': apiItem['product_price'] ?? '0',
          'orginal_price': apiItem['product_real_price'] ?? '0',
          'nick': (apiItem['product_shop']?.toString() ?? '').replaceFirst('_sopid@', ''),
          'detail_url': apiItem['product_url'] ?? '',
          'pic_url': apiItem['product_image'] ?? '',
          'brand': apiItem['product_store_type'] ?? '',
          'quantity': apiItem['product_qty'] ?? 1,
          'selectedSize': size,
          'selectedColor': color,
          'name': apiItem['product_name'] ?? '',
          'id': apiItem['id'] ?? 0,
          'shopId': shopId,
        };

        await CartService.addToCart(productData);
        hasNewItems = true;
      } else {
        // ถ้ามีใน Hive แล้ว ให้อัพเดท id จาก API โดยเช็คจาก numIid (product_code)
        final apiId = apiItem['id'];
        final apiProductCode = apiItem['product_code']?.toString() ?? '';
        if (apiId != null && apiProductCode.isNotEmpty) {
          for (var hiveItem in existingHiveItem) {
            // เช็คว่า numIid ตรงกับ product_code จาก API
            if (hiveItem.numIid == apiProductCode && hiveItem.id != apiId) {
              hiveItem.id = apiId is int ? apiId : int.tryParse(apiId.toString()) ?? 0;
              await hiveItem.save();
              hasNewItems = true;
            }
          }
        }
      }
    }

    // โหลด cart items ใหม่หลังจาก sync ถ้ามี item ใหม่
    if (hasNewItems) {
      await _loadCartItems();
    }
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

  Future<void> _loadExtraServices() async {
    setState(() {
      isLoadingServices = true;
    });

    await homeController.getExtraServicesFromAPI();

    setState(() {
      isLoadingServices = false;
    });
  }

  Future<void> _loadCartItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      cartItems = CartService.getCartItems();
      selectedItems = List.generate(cartItems.length, (index) => false);
      selectedForPurchase = List.generate(cartItems.length, (index) => false);
      inspect(cartItems);
    } catch (e) {
      // Handle error
      cartItems = [];
      selectedItems = [];
      selectedForPurchase = [];
    }

    setState(() {
      isLoading = false;
    });
  }

  // Helper methods for price calculations
  double getExchangeRateValue(Map<String, dynamic> rateData) {
    if (rateData.isNotEmpty && rateData.containsKey('product_payment_rate')) {
      final rate = rateData['product_payment_rate'];
      if (rate is num) {
        return rate.toDouble();
      } else if (rate is String) {
        return double.tryParse(rate) ?? 4.0; // Default fallback rate
      }
    }
    return 4.0; // Default fallback rate
  }

  void toggleDeleteMode() {
    setState(() {
      isDeleteMode = !isDeleteMode;
      if (isDeleteMode) {
        // เข้าโหมดลบ - คัดลอกการเลือกจาก selectedForPurchase
        selectedItems = List.from(selectedForPurchase);
      } else {
        // ออกจากโหมดลบ - รีเซ็ต
        selectedItems = List.filled(cartItems.length, false);
      }
    });
  }

  void toggleItemSelection(int index) {
    setState(() {
      selectedForPurchase[index] = !selectedForPurchase[index];
    });
  }

  bool _isAllSelected() {
    if (cartItems.isEmpty) return false;
    return selectedForPurchase.every((selected) => selected);
  }

  void _toggleSelectAll() {
    setState(() {
      final selectAll = !_isAllSelected();
      for (int i = 0; i < selectedForPurchase.length; i++) {
        selectedForPurchase[i] = selectAll;
      }
    });
  }

  Future<void> removeSelectedItems() async {
    try {
      // Get indices of selected items
      List<int> indicesToRemove = [];
      for (int i = 0; i < selectedItems.length; i++) {
        if (selectedItems[i]) {
          indicesToRemove.add(i);
        }
      }

      if (indicesToRemove.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getTranslation('select_items_first')), backgroundColor: Colors.orange));
        return;
      }

      // Remove from cart service
      await CartService.removeMultipleItems(indicesToRemove);

      // Reload cart items
      await _loadCartItems();

      setState(() {
        isDeleteMode = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getTranslation('item_removed')), backgroundColor: Colors.green));
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${getTranslation('error_occurred')}: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    if (newQuantity <= 0) return;

    try {
      await CartService.updateQuantity(index, newQuantity);
      await _loadCartItems();
    } catch (e) {
      // Handle error silently or show message
    }
  }

  Widget buildCartItem(int index) {
    final item = cartItems[index];
    final isSelected = isDeleteMode ? selectedItems[index] : selectedForPurchase[index];

    return GestureDetector(
      onTap: () {
        if (isDeleteMode) {
          setState(() => selectedItems[index] = !selectedItems[index]);
        } else {
          toggleItemSelection(index);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? kButtonColor : Colors.grey.shade300, width: isSelected ? 2 : 1),
          color: isSelected ? kButtonColor.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDeleteMode)
              Checkbox(
                value: selectedItems[index],
                onChanged: (value) {
                  setState(() => selectedItems[index] = !selectedItems[index]);
                },
                fillColor: WidgetStateProperty.all(kButtonColor),
              ),
            if (!isDeleteMode)
              Checkbox(
                value: selectedForPurchase[index],
                onChanged: (value) {
                  toggleItemSelection(index);
                },
                fillColor: WidgetStateProperty.all(kButtonColor),
              ),
            SizedBox(width: 8),
            _buildProductImage(item.picUrl),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('¥${item.priceAsDouble.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('฿${(item.priceAsDouble * depositOrderRate).toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Spacer(),
                      IconButton(icon: Icon(Icons.add, size: 18), onPressed: () => updateQuantity(index, item.quantity + 1)),
                      Text(item.quantity.toString()),
                      IconButton(icon: Icon(Icons.remove, size: 18), onPressed: () => updateQuantity(index, item.quantity - 1)),
                    ],
                  ),
                  // แสดงชื่อสินค้าต้นฉบับ
                  Text(item.title, style: TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  // แสดงชื่อสินค้าที่แปลแล้ว (ถ้ามี)
                  if (item.translatedTitle != null && item.translatedTitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.translatedTitle!,
                      style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (item.selectedSize.isNotEmpty) buildLabel(item.selectedSize),
                      if (item.selectedColor.isNotEmpty) buildLabel(item.selectedColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    // Check if it's a network image or local asset
    if (imageUrl.startsWith('http') || imageUrl.startsWith('//')) {
      final formattedUrl = formatImageUrl(imageUrl);
      return Image.network(
        formattedUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported, color: Colors.grey));
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported, color: Colors.grey));
        },
      );
    }
  }

  Widget buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.grey.shade200),
      child: Text(text, style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
    );
  }

  String _getTotalText() {
    if (cartItems.isEmpty) return '¥0 (฿ 0.00)';

    // Calculate total for selected items only
    double totalYuan = 0.0;
    for (int i = 0; i < cartItems.length; i++) {
      if (selectedForPurchase[i]) {
        totalYuan += cartItems[i].priceAsDouble * cartItems[i].quantity;
      }
    }

    // ใช้ depositOrderRate ในการคำนวณราคาเงินบาท
    final totalBaht = totalYuan * depositOrderRate;

    return '¥${totalYuan.toStringAsFixed(2)} (฿ ${totalBaht.toStringAsFixed(2)})';
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator(), SizedBox(height: 16), Text(getTranslation('loading'))],
        ),
      );
    }

    if (cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(getTranslation('empty_cart'), style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text(getTranslation('start_shopping'), style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(padding: const EdgeInsets.all(16), itemCount: cartItems.length, itemBuilder: (_, index) => buildCartItem(index));
  }

  Widget buildBottomBar() {
    final hasSelectedItems = selectedForPurchase.any((selected) => selected);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // ปุ่มซิงค์ข้อมูล
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: Colors.grey.shade300)),
              ),
              onPressed: () async {
                // ซิงค์ข้อมูลตะกร้า
                setState(() {
                  isLoading = true;
                });
                try {
                  // จัดรูปแบบข้อมูลสินค้าจาก Hive
                  final List<Map<String, dynamic>> productsForSync =
                      cartItems.map((item) {
                        return {
                          'product_shop': item.nick,
                          'product_code': item.numIid,
                          'product_name': item.title,
                          'product_url': item.detailUrl,
                          'product_image': item.picUrl,
                          'product_category': item.name,
                          'product_store_type': item.brand.isNotEmpty ? item.brand : 'shopgs1',
                          'product_note': '',
                          'product_price': item.priceAsDouble.toStringAsFixed(6),
                          'product_real_price': item.originalPriceAsDouble.toStringAsFixed(6),
                          'product_qty': item.quantity,
                          'note': '',
                          'client_note': '',
                          'shop_id': item.shopId ?? '',
                          'variants': [
                            if (item.selectedSize.isNotEmpty)
                              {"variant_code": "", "variant_name": "", 'option_name': 'ไซส์', 'option_value': item.selectedSize, "price_delta": 0},
                            if (item.selectedColor.isNotEmpty)
                              {"variant_code": "", "variant_name": "", 'option_name': 'สี', 'option_value': item.selectedColor, "price_delta": 0},
                          ],
                        };
                      }).toList();

                  // กรองเฉพาะสินค้าที่ไม่มีใน API
                  // final List<Map<String, dynamic>> productsForSync =
                  //     allProductsFromHive.where((hiveItem) {
                  //       final hiveProductCode = hiveItem['product_code']?.toString() ?? '';
                  //       // เช็คว่ามีใน apiCartItems หรือไม่
                  //       final existsInApi = apiCartItems.any((apiItem) {
                  //         final apiProductCode = apiItem['product_code']?.toString() ?? '';
                  //         return apiProductCode == hiveProductCode;
                  //       });
                  //       // ถ้าไม่มีใน API ให้รวมเข้า productsForSync
                  //       return !existsInApi;
                  //     }).toList();
                  //inspect(productsForSync);

                  // ถ้าไม่มีสินค้าใหม่ที่ต้อง sync
                  // if (productsForSync.isEmpty) {
                  //   setState(() {
                  //     isLoading = false;
                  //   });
                  //   if (mounted) {
                  //     ScaffoldMessenger.of(
                  //       context,
                  //     ).showSnackBar(SnackBar(content: Text(getTranslation('no_new_items_to_sync')), backgroundColor: Colors.orange));
                  //   }
                  //   return;
                  // }

                  // คำนวณราคารวมจาก productsForSync
                  double totalPrice = 0;
                  for (var product in productsForSync) {
                    final price = double.tryParse(product['product_price']?.toString() ?? '0') ?? 0;
                    final qty =
                        product['product_qty'] is int ? product['product_qty'] : (int.tryParse(product['product_qty']?.toString() ?? '0') ?? 0);
                    totalPrice += price * qty;
                  }

                  final result = await HomeService.syncCart(
                    date: DateTime.now(),
                    total_price: totalPrice,
                    shipping_type: 'car',
                    payment_term: '1',
                    note: '',
                    importer_code: currentUser?.importer_code ?? '',
                    member_address_id: '',
                    products: productsForSync,
                  );
                  if (result != null) {
                    setState(() {
                      isLoading = false;
                    });
                    await _loadApiCartItems();
                  }
                } catch (e) {
                  // Handle error silently
                  setState(() {
                    isLoading = false;
                  });
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getTranslation('sync_data')), backgroundColor: Colors.green));
                }
              },
              icon: const Icon(Icons.sync, size: 20),
              label: Text(getTranslation('sync_data')),
            ),
          ),
          const SizedBox(width: 12),
          // ปุ่มหลัก
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDeleteMode ? Colors.white : kButtonColor,
                  foregroundColor: isDeleteMode ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: isDeleteMode ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
                  ),
                ),
                onPressed: () {
                  if (isDeleteMode) {
                    removeSelectedItems();
                  } else if (hasSelectedItems) {
                    // TODO: Navigate to checkout or purchase page
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(getTranslation('go_to_checkout')), backgroundColor: Colors.green));

                    final selectedItemsMapList = <Map<String, dynamic>>[];

                    for (int i = 0; i < selectedForPurchase.length; i++) {
                      if (selectedForPurchase[i]) {
                        final item = cartItems[i];
                        selectedItemsMapList.add({
                          'num_iid': item.numIid,
                          'title': item.title,
                          'translatedTitle': item.translatedTitle,
                          'price': item.price,
                          'orginal_price': item.originalPrice,
                          'nick': item.nick,
                          'detail_url': item.detailUrl,
                          'pic_url': item.picUrl,
                          'brand': item.brand,
                          'quantity': item.quantity,
                          'selectedSize': item.selectedSize,
                          'selectedColor': item.selectedColor,
                          'name': item.name,
                          'id': item.id,
                          'shopId': item.shopId,
                        });
                      }
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PurchaseBillPage(productDataList: selectedItemsMapList, channel: 'nomal', type: widget.type)),
                    );
                  } else {
                    // ถ้าไม่มีสินค้าที่เลือก ให้ pop กลับ
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  isDeleteMode
                      ? getTranslation('remove_selected')
                      : hasSelectedItems
                      ? '${getTranslation('checkout')} ${_getTotalText()}'
                      : getTranslation('select_items_first'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(getTranslation('shopping_cart'), style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
          actions: [
            if (isDeleteMode)
              TextButton(onPressed: toggleDeleteMode, child: Text(getTranslation('cancel'), style: TextStyle(color: Colors.black)))
            else ...[
              TextButton(
                onPressed: _toggleSelectAll,
                child: Text(
                  _isAllSelected() ? getTranslation('deselect_all') : getTranslation('select_all'),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              IconButton(onPressed: toggleDeleteMode, icon: const Icon(Icons.delete_outline, color: Colors.black)),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        body: Column(children: [Expanded(child: _buildBody()), buildBottomBar()]),
      ),
    );
  }
}
