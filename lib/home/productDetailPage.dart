import 'package:flutter/material.dart';
import 'package:gcargo/utils/helpers.dart';
import 'package:get/get.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/product_detail_controller.dart';
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
  String selectedSize = 'M';
  int selectedImage = 0;
  final TextEditingController searchController = TextEditingController();

  // Initialize ProductDetailController
  late final ProductDetailController productController;

  @override
  void initState() {
    super.initState();
    // สร้าง controller และเรียก API
    productController = Get.put(ProductDetailController(), tag: widget.num_iid);
    productController.getItemDetail(widget.num_iid);
  }

  @override
  void dispose() {
    // ลบ controller เมื่อออกจากหน้า
    Get.delete<ProductDetailController>(tag: widget.num_iid);
    super.dispose();
  }

  List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  List<String> images = ['assets/images/unsplash0.png', 'assets/images/unsplash1.png', 'assets/images/unsplash2.png', 'assets/images/unsplash3.png'];

  Widget buildImageSlider() {
    return Obx(() {
      if (productController.isLoading.value) {
        return Container(
          height: 200,
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      final picUrl = formatImageUrl(productController.picUrl);

      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                picUrl.isNotEmpty
                    ? Image.network(
                      picUrl,
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
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    )
                    : Image.asset(images[selectedImage], width: double.infinity, height: 200, fit: BoxFit.cover),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: selectedImage == index ? Colors.black : Colors.grey.shade300),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget buildSizeSelector() {
    return Wrap(
      spacing: 8,
      children:
          sizes.map((size) {
            final selected = selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => selectedSize = size),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: selected ? kButtonColor : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: selected ? kButtonColor : Colors.white,
                ),
                child: Text(size, style: TextStyle(color: selected ? Colors.white : Colors.black)),
              ),
            );
          }).toList(),
    );
  }

  Widget buildColorOptions() {
    return Column(
      children: List.generate(3, (index) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Image.asset(images[index], width: 40),
          title: Text('ลายดาว'),
          trailing: Text('¥10'),
        );
      }),
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseBillPage()));
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
                        Row(
                          children: [
                            if (productController.promotionPrice != productController.originalPrice) ...[
                              Text(
                                '¥${productController.promotionPrice.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '¥${productController.originalPrice.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough),
                              ),
                            ] else ...[
                              Text('¥${productController.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ],
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

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: List.generate(images.length, (index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                  child: Image.asset(images[index], height: 110, width: double.infinity, fit: BoxFit.cover),
                                ),
                                Positioned(top: 8, right: 8, child: Icon(Icons.favorite_border, color: Colors.grey)),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('เสื้อแขนสั้น', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text(
                                    'เสื้อแขนสั้นลายดาว ¥10',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text('¥10', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
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
