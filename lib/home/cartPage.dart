import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/home/purchaseBillPage.dart';
import 'package:gcargo/models/cart_item.dart';
import 'package:gcargo/services/cart_service.dart';
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
  bool isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    // Get HomeController
    try {
      homeController = Get.find<HomeController>();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    // Fetch extra services
    _loadExtraServices();
    _loadCartItems();
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
      selectedItems = List.filled(cartItems.length, false);
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

      // Remove from cart service
      await CartService.removeMultipleItems(indicesToRemove);

      // Reload cart items
      await _loadCartItems();

      setState(() {
        isDeleteMode = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ลบสินค้าออกจากตะกร้าเรียบร้อยแล้ว'), backgroundColor: Colors.green));
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red));
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
                      Text('¥${item.priceAsDouble.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      IconButton(icon: Icon(Icons.add, size: 18), onPressed: () => updateQuantity(index, item.quantity + 1)),
                      Text(item.quantity.toString()),
                      IconButton(icon: Icon(Icons.remove, size: 18), onPressed: () => updateQuantity(index, item.quantity - 1)),
                    ],
                  ),
                  Text(item.title, style: TextStyle(color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
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

    // You can add exchange rate calculation here if needed
    final exchangeRateData = homeController.exchangeRate;
    final exchangeRate = getExchangeRateValue(exchangeRateData);
    final totalBaht = totalYuan * exchangeRate; // Assuming 1 Yuan = 4 Baht

    return '¥${totalYuan.toStringAsFixed(2)} (฿ ${totalBaht.toStringAsFixed(2)})';
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cartItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('ตะกร้าสินค้าว่างเปล่า', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('เพิ่มสินค้าลงตะกร้าเพื่อเริ่มต้นการสั่งซื้อ', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไปหน้าชำระเงิน'), backgroundColor: Colors.green));

              final selectedItemsMapList = <Map<String, dynamic>>[];

              for (int i = 0; i < selectedForPurchase.length; i++) {
                if (selectedForPurchase[i]) {
                  final item = cartItems[i];
                  selectedItemsMapList.add({
                    'num_iid': item.numIid,
                    'title': item.title,
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
                ? 'ลบสินค้า'
                : hasSelectedItems
                ? 'สั่งซื้อ ${_getTotalText()}'
                : 'เลือกสินค้าที่ต้องการสั่งซื้อ',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตะกร้าสินค้า', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          if (isDeleteMode)
            TextButton(onPressed: toggleDeleteMode, child: const Text('ยกเลิก', style: TextStyle(color: Colors.black)))
          else ...[
            TextButton(
              onPressed: _toggleSelectAll,
              child: Text(_isAllSelected() ? 'ยกเลิกทั้งหมด' : 'เลือกทั้งหมด', style: const TextStyle(color: Colors.black)),
            ),
            IconButton(onPressed: toggleDeleteMode, icon: const Icon(Icons.delete_outline, color: Colors.black)),
          ],
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(children: [Expanded(child: _buildBody()), buildBottomBar()]),
    );
  }
}
