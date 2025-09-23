import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/home/purchaseBillPage.dart';
import 'package:gcargo/models/cart_item.dart';
import 'package:gcargo/services/cart_service.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:gcargo/utils/helpers.dart';
import 'package:get/get.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

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

    // Fetch extra services
    _loadExtraServices();
    _loadCartItems();
    // หลังจากโหลดข้อมูลสินค้าเสร็จแล้ว ให้แปลไตเติ๊ล
    _loadExchangeRate();
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
                  Row(
                    children: [
                      if (item.selectedSize.isNotEmpty) buildLabel(item.selectedSize),
                      if (item.selectedSize.isNotEmpty && item.selectedColor.isNotEmpty) const SizedBox(width: 6),
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
      child: Text(text, style: const TextStyle(fontSize: 12)),
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
      child: SizedBox(
        height: 48,
        width: double.infinity,
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getTranslation('go_to_checkout')), backgroundColor: Colors.green));

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
                  });
                }
              }

              if (selectedItemsMapList.isEmpty) return; // ป้องกันกรณีไม่มีอะไรถูกเลือก

              Navigator.push(context, MaterialPageRoute(builder: (_) => PurchaseBillPage(productDataList: selectedItemsMapList)));
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
