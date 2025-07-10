import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/home/cartPage.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  String selectedSize = 'M';
  int selectedImage = 0;

  List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  List<String> images = ['assets/images/unsplash0.png', 'assets/images/unsplash1.png', 'assets/images/unsplash2.png', 'assets/images/unsplash3.png'];

  Widget buildImageSlider() {
    return Column(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(images[selectedImage], width: double.infinity, fit: BoxFit.cover)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: selectedImage == index ? Colors.black : Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          title: const Text('ลายดาว'),
          trailing: const Text('¥10'),
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
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6), // ✅ ขอบมนเล็กน้อย
              ),
            ),
            onPressed: () {},
            child: const Text('สั่งซื้อสินค้า', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kButtonColor,
              side: BorderSide(color: kButtonColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6), // ✅ ขอบมนเล็กน้อย
              ),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
            },
            child: const Text('เพิ่มลงตะกร้า', style: TextStyle(color: Colors.white, fontSize: 16)),
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
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Expanded(child: Text('ค้นหาสินค้า', style: TextStyle(color: Colors.grey))),
                      Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.delete_outline, color: Colors.black),
              const SizedBox(width: 12),
              const Icon(Icons.notifications_none, color: Colors.black),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  buildImageSlider(),
                  const SizedBox(height: 16),

                  const Text('เสื้อแขนสั้น', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('¥10', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Text('จำนวน'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed:
                            () => setState(() {
                              if (quantity > 1) quantity--;
                            }),
                      ),
                      Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
                      IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => quantity++)),
                    ],
                  ),
                  const Divider(height: 32),

                  const Text('ไซต์', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  buildSizeSelector(),

                  const SizedBox(height: 20),
                  const Text('สี', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  buildColorOptions(),

                  const SizedBox(height: 20),
                  const Text('เสื้อแขนสั้นใช้ใส่ไปเดินเล่นสบายๆ...', style: TextStyle(color: Colors.grey)),

                  // 🔽 ส่วนนี้แทรกไว้ "ก่อน" หัวข้อ 'สิ่งที่คุณอาจสนใจ'
                  Column(
                    children: [
                      const Divider(),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: แสดงเนื้อหาเพิ่มเติม
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('แสดงเพิ่มเติม', style: TextStyle(color: Colors.grey)),
                              SizedBox(width: 4),
                              Icon(Icons.expand_more, color: Colors.grey, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text('สิ่งที่คุณอาจสนใจ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                  child: Image.asset(images[index], height: 110, width: double.infinity, fit: BoxFit.cover),
                                ),
                                const Positioned(top: 8, right: 8, child: Icon(Icons.favorite_border, color: Colors.grey)),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
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
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: buildBottomBar()),
          ],
        ),
      ),
    );
  }
}
