import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gcargo/home/firstPage.dart';
import 'package:gcargo/home/notificationPage.dart';
import 'package:gcargo/utils/helpers.dart';
import 'package:get/get.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/product_detail_controller.dart';
import 'package:gcargo/controllers/home_controller.dart';
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
  ProductDetailPage({super.key, required this.num_iid, required this.name, required this.type});
  String num_iid;
  String name;
  String type;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  String selectedSize = '';
  String selectedColor = '';
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingRecommendedItem = false;

  // Initialize ProductDetailController
  late final ProductDetailController productController;

  // Initialize HomeController to get search items
  late final HomeController homeController;

  @override
  void initState() {
    super.initState();
    // สร้าง controller และเรียก API
    productController = Get.put(ProductDetailController(), tag: widget.num_iid);
    productController.getItemDetail(widget.num_iid, widget.type);

    // Get existing HomeController or create new one
    try {
      homeController = Get.find<HomeController>();
    } catch (e) {
      homeController = Get.put(HomeController());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // ลบ controller เมื่อออกจากหน้า
    Get.delete<ProductDetailController>(tag: widget.num_iid);
    super.dispose();
  }

  // เช็ค userID ว่าเข้าสู่ระบบแล้วหรือไม่
  Future<bool> _checkUserLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');

    if (userID == null) {
      // แสดงแจ้งเตือนให้เข้าสู่ระบบ
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('ยังไม่ได้เข้าสู่ระบบ'),
              content: const Text('กรุณาเข้าสู่ระบบก่อนสั่งซื้อสินค้า'),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ตกลง'))],
            );
          },
        );
      }
      return false;
    }

    return true;
  }

  Widget buildSizeSelector() {
    return Obx(() {
      final availableSizes = productController.availableSizes;

      if (availableSizes.isEmpty) {
        return const Text('ไม่มีข้อมูลไซส์', style: TextStyle(color: Colors.grey));
      }

      return Wrap(
        spacing: 8,
        children:
            availableSizes.map((size) {
              final translatedSize = productController.translateToThai(size);
              final selected = selectedSize == size;
              return GestureDetector(
                onTap: () => setState(() => selectedSize = size),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: selected ? kButtonColor : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: selected ? kButtonColor : Colors.white,
                  ),
                  child: Text(translatedSize, style: TextStyle(color: selected ? Colors.white : Colors.black)),
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
        return const Text('ไม่มีข้อมูลสี', style: TextStyle(color: Colors.grey));
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            availableColors.map((color) {
              final translatedColor = productController.translateToThai(color);
              final selected = selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => selectedColor = color),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: selected ? kButtonColor : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: selected ? kButtonColor : Colors.white,
                  ),
                  child: Text(translatedColor, style: TextStyle(color: selected ? Colors.white : Colors.black)),
                ),
              );
            }).toList(),
      );
    });
  }

  Widget _buildRecommendedItem(Map<String, dynamic> item) {
    final title = item['title'] ?? 'ไม่มีชื่อสินค้า';
    final picUrl = formatImageUrl(item['pic_url'] ?? '');
    final price = item['price']?.toString() ?? '0';
    final promotionPrice = item['promotion_price']?.toString() ?? '';
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
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (promotionPrice.isNotEmpty && promotionPrice != '0') ...[
                              Text('¥$promotionPrice', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 12)),
                              Text('¥$price', style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                            ] else ...[
                              Text('¥$price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ],
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
                'price': productController.price,
                'orginal_price': productController.originalPrice,
                'nick': productController.nick,
                'detail_url': productController.detailUrl,
                'pic_url': productController.picUrl,
                'brand': productController.brand,
                'quantity': quantity,
                'selectedSize': selectedSize,
                'selectedColor': selectedColor,
                'name': widget.name,
              };

              if (mounted) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PurchaseBillPage(productDataList: [productData])));
              }
            },
            child: Text('สั่งซื้อสินค้า', style: TextStyle(fontSize: 16, color: Colors.white)),
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
                'price': productController.price,
                'orginal_price': productController.originalPrice,
                'nick': productController.nick,
                'detail_url': productController.detailUrl,
                'pic_url': productController.picUrl,
                'brand': productController.brand,
                'quantity': quantity,
                'selectedSize': selectedSize,
                'selectedColor': selectedColor,
                'name': widget.name,
              };

              try {
                // Add to cart
                await CartService.addToCart(productData);

                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    const SnackBar(content: Text('เพิ่มสินค้าลงตะกร้าเรียบร้อยแล้ว'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
                  );

                  // Navigate to cart page
                  Navigator.push(currentContext, MaterialPageRoute(builder: (_) => const CartPage()));
                }
              } catch (e) {
                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(
                    currentContext,
                  ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 2)));
                }
              }
            },
            child: Text('เพิ่มลงตะกร้า', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onFieldSubmitted: (query) {
              SearchService.handleTextSearch(context: context, query: query, selectedType: widget.type);
            },
            onImagePicked: (XFile image) {
              SearchService.handleImageSearch(context: context, image: image, selectedType: widget.type);
            },
            onBagTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
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
                        Text(productController.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text(
                          '¥${productController.originalPrice.toStringAsFixed(0)}',
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
                      Text('จำนวน'),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed:
                            () => setState(() {
                              if (quantity > 1) quantity--;
                            }),
                      ),
                      Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
                      IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => quantity++)),
                    ],
                  ),
                  Divider(height: 32),

                  Text('ไซต์', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  buildSizeSelector(),

                  SizedBox(height: 20),
                  Text('สี', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  buildColorOptions(),

                  SizedBox(height: 20),

                  // แสดงคำอธิบายสินค้า
                  ProductDescriptionWidget(productController: productController),

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
                  Text('สิ่งที่คุณอาจสนใจ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 12),

                  // แสดงข้อมูลจาก homeController.searchItems
                  Obx(() {
                    if (homeController.isLoading.value) {
                      return Container(height: 200, child: Center(child: CircularProgressIndicator()));
                    }

                    if (homeController.hasError.value) {
                      return Container(
                        height: 100,
                        child: Center(child: Text('ไม่สามารถโหลดสินค้าที่แนะนำได้', style: TextStyle(color: Colors.grey))),
                      );
                    }

                    final searchItems = homeController.searchItems;
                    if (searchItems.isEmpty) {
                      return Container(height: 100, child: Center(child: Text('ไม่มีสินค้าที่แนะนำ', style: TextStyle(color: Colors.grey))));
                    }

                    // แสดงสินค้าสูงสุด 6 รายการ
                    final itemsToShow = searchItems.take(6).toList();

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
    );
  }
}
