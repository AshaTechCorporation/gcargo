import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gcargo/home/firstPage.dart';
import 'package:gcargo/models/optionsItem.dart';
import 'package:gcargo/models/orders/serviceTransporterById.dart';
import 'package:gcargo/models/partService.dart';
import 'package:gcargo/models/products.dart';
import 'package:get/get.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/home/couponSelectionPage.dart';
import 'package:gcargo/home/deliveryMethodPage.dart';
import 'package:gcargo/services/cart_service.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:gcargo/utils/helpers.dart';

class PurchaseBillPage extends StatefulWidget {
  final List<Map<String, dynamic>>? productDataList;

  const PurchaseBillPage({super.key, this.productDataList});

  @override
  State<PurchaseBillPage> createState() => _PurchaseBillPageState();
}

class _PurchaseBillPageState extends State<PurchaseBillPage> {
  bool taxChecked = false;
  int? selectedExtraServiceIndex;
  late HomeController homeController;
  List<Map<String, dynamic>> products = [];
  Map<String, dynamic> deliveryOptions = {'id': 1, 'name': 'ขนส่งทางรถ', 'nameEng': 'car'};
  bool isLoadingServices = true;
  bool isOrdering = false; // เพิ่ม loading state สำหรับการสั่งซื้อ
  TextEditingController noteController = TextEditingController();
  ServiceTransporterById? serviceSelected;

  @override
  void initState() {
    super.initState();

    // Get HomeController
    try {
      homeController = Get.find<HomeController>();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    // Initialize products list
    if (widget.productDataList != null && widget.productDataList!.isNotEmpty) {
      products = List.from(widget.productDataList!);
    } else {}

    // Fetch extra services
    _loadExtraServices();
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

  double calculateProductTotal(Map<String, dynamic> product) {
    final price = (product['price'] ?? 0).toDouble();
    final quantity = (product['quantity'] ?? 1).toInt();
    return price * quantity;
  }

  double calculateTotalYuan() {
    return products.fold(0.0, (sum, product) => sum + calculateProductTotal(product));
  }

  double calculateTotalBaht() {
    return calculateTotalYuan() * getExchangeRateValue(homeController.exchangeRate);
  }

  void updateProductQuantity(int index, int newQuantity) {
    setState(() {
      products[index]['quantity'] = newQuantity > 0 ? newQuantity : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final exchangeRateData = homeController.exchangeRate;
    final exchangeRate = getExchangeRateValue(exchangeRateData);
    final totalYuan = calculateTotalYuan();
    final totalBaht = totalYuan * exchangeRate;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back_ios_new, color: Colors.black)),
        title: Text('บิลสั่งซื้อสินค้า', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final selectedOption = await Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryMethodPage()));
                    if (selectedOption != null) {
                      setState(() {
                        deliveryOptions = selectedOption;
                      });
                    }
                  },
                  child: Text('รูปแบบการขนส่ง', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                Text('${deliveryOptions['name']}', style: TextStyle(color: Colors.grey)),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('สินค้าทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${products.fold(0, (sum, product) => sum + (product['quantity'] ?? 1) as int)} ชิ้น',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProductSection(),
                const SizedBox(height: 24),
                const Divider(height: 24, color: Colors.orange),
                const Text('หมายเหตุ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'กรอกหมายเหตุเพิ่มเติม...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 24),

                const Divider(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CouponSelectionPage()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('คูปองส่วนลด', style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
                    ],
                  ),
                ),
                const Divider(height: 24),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // ✅ ด้านล่างสุด สรุปยอดสินค้า ตามภาพจริง
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 แถบอัตราแลกเปลี่ยน
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                alignment: Alignment.centerLeft,
                color: Colors.white,
                child: Text(
                  'อัตราแลกเปลี่ยน  1 ¥ = ${exchangeRate.toStringAsFixed(4)} หยวนต่อบาท',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                ),
              ),

              // 🔻 ด้านล่างสุด ตามภาพเป๊ะ
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: GestureDetector(
                  onTap:
                      isOrdering
                          ? null
                          : () async {
                            // ป้องกันการกดซ้ำ
                            if (isOrdering) return;

                            setState(() {
                              isOrdering = true;
                            });

                            // Store context before async operations
                            final currentContext = context;

                            try {
                              List<OptionsItem> optionsItems = [];
                              List<PartService> addOnServices = [];
                              List<Products> orderProducts = [];

                              // Create options for each product
                              if (products.isNotEmpty) {
                                for (var i = 0; i < products.length; i++) {
                                  final product = products[i];

                                  // Add selectedSize if available
                                  if (product['selectedSize'] != null && product['selectedSize'].toString().isNotEmpty) {
                                    final sizeOption = OptionsItem(product['selectedSize'], '', 'size');
                                    optionsItems.add(sizeOption);
                                  }

                                  // Add selectedColor if available
                                  if (product['selectedColor'] != null && product['selectedColor'].toString().isNotEmpty) {
                                    final colorOption = OptionsItem(product['selectedColor'], '', 'color');
                                    optionsItems.add(colorOption);
                                  }
                                }
                              }

                              // Add selected extra service
                              if (serviceSelected != null) {
                                final addOnService = PartService(serviceSelected!.id, serviceSelected!.standard_price);
                                addOnServices.add(addOnService);
                              }

                              // Create products for order
                              for (var i = 0; i < products.length; i++) {
                                final product = products[i];
                                final orderProduct = Products(
                                  product['nick'] ?? '', // product_shop
                                  product['num_iid'] ?? '', // product_code
                                  product['title'] ?? '', // product_name
                                  product['detail_url'] ?? '', // product_url
                                  product['pic_url'] ?? '', // product_image
                                  product['name'] ?? '', // product_category
                                  'taobao', // product_store_type
                                  noteController.text, // product_note
                                  product['price']?.toString() ?? '0', // product_price
                                  product['quantity']?.toString() ?? '1', // product_qty
                                  addOnServices, // add_on_services
                                  optionsItems, // options
                                );
                                orderProducts.add(orderProduct);
                              }
                              inspect(orderProducts);

                              // Calculate total price
                              final totalYuan = calculateTotalYuan();

                              // Get selected shipping address ID
                              final selectedAddressId = homeController.select_ship_address?.id;
                              print(selectedAddressId);

                              //Create order via API
                              final result = await HomeService.createOrder(
                                date: DateTime.now().toIso8601String(),
                                total_price: totalYuan,
                                shipping_type: deliveryOptions['nameEng'] ?? 'car',
                                payment_term: 'prepaid',
                                note: noteController.text,
                                importer_code: '',
                                member_address_id: selectedAddressId,
                                products: orderProducts,
                              );

                              log('✅ Order created successfully: $result');

                              // Remove ordered items from cart
                              await _removeOrderedItemsFromCart();

                              // Show success message
                              if (mounted) {
                                ScaffoldMessenger.of(
                                  currentContext,
                                ).showSnackBar(const SnackBar(content: Text('สร้างออเดอร์สำเร็จ!'), backgroundColor: Colors.green));

                                // Navigate back or to order confirmation page
                                Navigator.pushAndRemoveUntil(currentContext, MaterialPageRoute(builder: (context) => FirstPage()), (route) => false);
                              }
                            } catch (e) {
                              log('❌ Error creating order: $e');

                              if (mounted) {
                                ScaffoldMessenger.of(
                                  currentContext,
                                ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red));
                              }
                            } finally {
                              // รีเซ็ต loading state
                              if (mounted) {
                                setState(() {
                                  isOrdering = false;
                                });
                              }
                            }
                          },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: isOrdering ? Colors.grey : kButtonColor, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        // 🔵 วงกลมมีเลข หรือ loading spinner
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isOrdering ? Colors.grey.shade600 : Color(0xFF2E73B9), // ฟ้าอ่อน
                            shape: BoxShape.circle,
                          ),
                          child:
                              isOrdering
                                  ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                  )
                                  : Text(
                                    '${widget.productDataList!.length}',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isOrdering ? 'กำลังสั่งซื้อ...' : 'สินค้าทั้งหมด',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Spacer(),
                        if (!isOrdering)
                          Text(
                            '¥${totalYuan.toStringAsFixed(2)} (฿ ${totalBaht.toStringAsFixed(2)})',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // 🔹 แถบสีขาวบาง ๆ ด้านล่างสุด (ไม่กินพื้นที่)
              Container(height: 8, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ บริการเสริม (Row เดียวกับตัวเลือก)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('บริการเสริม', style: TextStyle(fontWeight: FontWeight.bold)), Spacer(), Expanded(child: _buildExtraServicesSection())],
          ),
          const SizedBox(height: 12),

          // 🔻 สินค้าแต่ละรายการ
          ...products.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;

            return Column(
              children: [
                if (index > 0) const SizedBox(height: 16),
                _buildProductItem(
                  index: index,
                  image: product['pic_url'] ?? 'assets/images/unsplash1.png',
                  name: product['title'] ?? 'ไม่มีชื่อสินค้า',
                  price: (product['price'] ?? 0).toDouble(),
                  originalPrice: product['orginal_price']?.toDouble(),
                  qty: (product['quantity'] ?? 1).toInt(),
                  selectedSize: product['selectedSize'] ?? '',
                  selectedColor: product['selectedColor'] ?? '',
                  onAdd: () => updateProductQuantity(index, (product['quantity'] ?? 1) + 1),
                  onRemove: () => updateProductQuantity(index, (product['quantity'] ?? 1) - 1),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductItem({
    required int index,
    required String image,
    required String name,
    required double price,
    required int qty,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    double? originalPrice,
    String selectedSize = '',
    String selectedColor = '',
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildProductImage(image)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      final exchangeRateData = homeController.exchangeRate;
                      final exchangeRate = getExchangeRateValue(exchangeRateData);
                      final totalPrice = price * qty;
                      final totalBaht = totalPrice * exchangeRate;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [Text('¥${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))],
                          ),
                          Text('฿${totalBaht.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      );
                    }),

                    // 🔸 ปุ่มเพิ่ม-ลด
                    Row(
                      children: [
                        _buildQtyButton(icon: Icons.remove, onPressed: onRemove),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text('$qty', style: const TextStyle(fontSize: 16))),
                        _buildQtyButton(icon: Icons.add, onPressed: onAdd),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(name, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (selectedSize.isNotEmpty) ...[_buildTag(selectedSize), const SizedBox(width: 6)],
                    if (selectedColor.isNotEmpty) ...[_buildTag(selectedColor, filled: true)],
                    if (selectedSize.isEmpty && selectedColor.isEmpty) ...[_buildTag('ไม่ได้เลือก', filled: false)],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(14), color: Colors.white),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }

  Widget _buildTag(String text, {bool filled = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? kButtondiableColor : Colors.transparent,
        border: Border.all(color: kButtonColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: kButtonColor), overflow: TextOverflow.ellipsis),
    );
  }

  // Helper method to build product image with URL formatting
  Widget _buildProductImage(String imageUrl) {
    // Use the formatImageUrl helper to handle // URLs
    final formattedUrl = formatImageUrl(imageUrl);

    // Check if it's a network image or local asset
    if (formattedUrl.startsWith('http')) {
      return Image.network(
        formattedUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(width: 60, height: 60, color: Colors.grey.shade200, child: Icon(Icons.image_not_supported, color: Colors.grey));
        },
      );
    } else {
      return Image.asset(imageUrl, width: 60, height: 60, fit: BoxFit.cover);
    }
  }

  // Method to build extra services section
  Widget _buildExtraServicesSection() {
    if (isLoadingServices) {
      return const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (homeController.extraServices.isEmpty) {
      return const Text('ไม่มีบริการ', style: TextStyle(fontSize: 12, color: Colors.grey));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            homeController.extraServices.asMap().entries.map((entry) {
              final index = entry.key;
              final service = entry.value;
              final isSelected = selectedExtraServiceIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedExtraServiceIndex = isSelected ? null : index;
                    serviceSelected = service;
                  });
                  inspect(serviceSelected);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.blue : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.name ?? '',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.blue : Colors.black),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // Method to remove ordered items from cart
  Future<void> _removeOrderedItemsFromCart() async {
    try {
      // Get all cart items
      final cartItems = CartService.getCartItems();

      // No cart items, nothing to remove
      if (cartItems.isEmpty) return;

      // Indices of cart items to remove
      List<int> indicesToRemove = [];

      // Check each product in the order
      for (var orderProduct in products) {
        final orderNumId = orderProduct['num_iid']?.toString() ?? '';

        // Skip if no valid num_iid
        if (orderNumId.isEmpty) continue;

        // Find matching items in cart
        for (int i = 0; i < cartItems.length; i++) {
          final cartItem = cartItems[i];

          // Check if cart item matches order item
          if (cartItem.numIid == orderNumId) {
            // If sizes match (or both empty)
            final orderSize = orderProduct['selectedSize']?.toString() ?? '';
            final cartSize = cartItem.selectedSize;

            // If colors match (or both empty)
            final orderColor = orderProduct['selectedColor']?.toString() ?? '';
            final cartColor = cartItem.selectedColor;

            // If both size and color match (or both empty)
            if ((orderSize == cartSize) && (orderColor == cartColor)) {
              indicesToRemove.add(i);
              break; // Found a match, move to next order product
            }
          }
        }
      }

      // Remove matched items from cart
      if (indicesToRemove.isNotEmpty) {
        await CartService.removeMultipleItems(indicesToRemove);
        log('✅ Removed ${indicesToRemove.length} items from cart after successful order');
      }
    } catch (e) {
      // Log error but don't interrupt the flow
      log('❌ Error removing items from cart: $e');
    }
  }
}
