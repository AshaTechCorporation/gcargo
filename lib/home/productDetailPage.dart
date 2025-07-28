import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gcargo/utils/helpers.dart';
import 'package:get/get.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/product_detail_controller.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/showImagePickerBottomSheet.dart';
import 'package:gcargo/home/cartPage.dart';
import 'package:gcargo/home/purchaseBillPage.dart';
import 'package:image_picker/image_picker.dart';

class ProductDetailPage extends StatefulWidget {
  ProductDetailPage({super.key, required this.num_iid});
  String num_iid;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  String selectedSize = '';
  String selectedColor = '';
  int selectedImage = 0;
  final TextEditingController searchController = TextEditingController();
  late PageController _pageController;
  Timer? _autoSlideTimer;

  // Initialize ProductDetailController
  late final ProductDetailController productController;

  // Initialize HomeController to get search items
  late final HomeController homeController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // สร้าง controller และเรียก API
    productController = Get.put(ProductDetailController(), tag: widget.num_iid);
    productController.getItemDetail(widget.num_iid);

    // Get existing HomeController or create new one
    try {
      homeController = Get.find<HomeController>();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    // ลบ controller เมื่อออกจากหน้า
    Get.delete<ProductDetailController>(tag: widget.num_iid);
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final allImages = productController.allImages;
        final imagesToShow = allImages.isNotEmpty ? allImages : images;

        if (imagesToShow.length > 1) {
          final nextPage = (selectedImage + 1) % imagesToShow.length;
          _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      }
    });
  }

  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
  }

  void _restartAutoSlide() {
    _stopAutoSlide();
    _startAutoSlide();
  }

  List<String> images = ['assets/images/unsplash0.png', 'assets/images/unsplash1.png', 'assets/images/unsplash2.png', 'assets/images/unsplash3.png'];

  Widget buildImageSlider() {
    return Obx(() {
      if (productController.isLoading.value) {
        return Container(
          height: 200,
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      // Get all images from API (main pic_url + desc_img)
      final allImages = productController.allImages;

      // If no images from API, use fallback images
      final imagesToShow = allImages.isNotEmpty ? allImages : images;
      final isUsingApiImages = allImages.isNotEmpty;

      return Column(
        children: [
          // Image Slider
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  imagesToShow.length == 1
                      ? _buildSingleImage(imagesToShow[0], isUsingApiImages)
                      : GestureDetector(
                        onPanDown: (_) => _stopAutoSlide(),
                        onPanEnd: (_) => _restartAutoSlide(),
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              selectedImage = index;
                            });
                          },
                          itemCount: imagesToShow.length,
                          itemBuilder: (context, index) {
                            final imageUrl = imagesToShow[index];
                            return _buildSingleImage(imageUrl, isUsingApiImages);
                          },
                        ),
                      ),
            ),
          ),

          // Page Indicators
          if (imagesToShow.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imagesToShow.length,
                (index) => GestureDetector(
                  onTap: () {
                    _stopAutoSlide();
                    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    _restartAutoSlide();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: selectedImage == index ? Colors.black : Colors.grey.shade300),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildSingleImage(String imageUrl, bool isUsingApiImages) {
    if (isUsingApiImages) {
      // Display API images
      final formattedUrl = formatImageUrl(imageUrl);
      return Image.network(
        formattedUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey.shade200,
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(width: double.infinity, height: 200, color: Colors.grey.shade200, child: const Center(child: CircularProgressIndicator()));
        },
      );
    } else {
      // Display fallback asset images
      return Image.asset(imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover);
    }
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
      onTap: () {
        if (numIid.isNotEmpty) {
          // Navigate to product detail page
          productController.getItemDetail(numIid);
        }
      },
      child: Container(
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
                              fit: BoxFit.cover,
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
            onPressed: () {
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
              };

              Navigator.push(context, MaterialPageRoute(builder: (_) => PurchaseBillPage(productDataList: [productData])));
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
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
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
          title: Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: searchController, // 👈 เพิ่ม controller ตามที่คุณกำหนดไว้
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'ค้นหาสินค้า',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          showImagePickerBottomSheet(
                            context: context,
                            onImagePicked: (XFile image) {
                              print('📸 ได้รูป: ${image.path}');
                              // คุณสามารถใช้งาน image.path ได้ตามต้องการ เช่นส่ง API หรือแสดง preview
                            },
                          );
                        },
                        child: Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.delete_outline, color: Colors.black),
              SizedBox(width: 12),
              Icon(Icons.notifications_none, color: Colors.black),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  buildImageSlider(),
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
                  Obx(() {
                    if (productController.isLoading.value) {
                      return Column(
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                          ),
                          SizedBox(height: 4),
                          Container(
                            height: 16,
                            width: 200,
                            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('รายละเอียดสินค้า', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 8),
                        Text(productController.title, style: TextStyle(color: Colors.grey.shade700)),
                        if (productController.detailUrl.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Text(
                            'ลิงก์สินค้า: ${productController.detailUrl}',
                            style: TextStyle(color: Colors.blue, fontSize: 12, decoration: TextDecoration.underline),
                          ),
                        ],
                      ],
                    );
                  }),

                  // 🔽 ส่วนนี้แทรกไว้ "ก่อน" หัวข้อ 'สิ่งที่คุณอาจสนใจ'
                  Column(
                    children: [
                      Divider(),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: แสดงเนื้อหาเพิ่มเติม
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('แสดงเพิ่มเติม', style: TextStyle(color: Colors.grey)),
                              SizedBox(width: 4),
                              Icon(Icons.expand_more, color: Colors.grey, size: 18),
                            ],
                          ),
                        ),
                      ),
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
