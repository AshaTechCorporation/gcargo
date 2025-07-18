import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gcargo/controllers/showImagePickerBottomSheet.dart';
import 'package:gcargo/home/widgets/ProductCardFromAPI.dart';
import 'package:gcargo/home/widgets/ServiceImageCard.dart';
import 'package:get/get.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/home/exchangeRatePage.dart';
import 'package:gcargo/home/notificationPage.dart';
import 'package:gcargo/home/packageDepositPage.dart';
import 'package:gcargo/home/productDetailPage.dart';
import 'package:gcargo/home/rewardRedeemPage.dart';
import 'package:gcargo/home/shippingRatePage.dart';
import 'package:gcargo/home/trackingOwnerPage.dart';
import 'package:gcargo/home/transportCalculatePage.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();

  // Initialize HomeController
  final HomeController homeController = Get.put(HomeController());

  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<String> _images = [
    'assets/images/slidpic.png',
    'assets/images/slidpic.png',
    'assets/images/slidpic.png',
    'assets/images/slidpic.png',
    'assets/images/slidpic.png',
  ];

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _images.length;
        _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Text('A100', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
              SizedBox(width: 12),
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
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
                },
                child: Icon(Icons.notifications_none, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Slide Image
              // 🔹 Image Slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 140,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.asset(_images[index], fit: BoxFit.cover, width: double.infinity);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 🔹 Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_images.length, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(color: isActive ? Colors.blue.shade900 : Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                  );
                }),
              ),
              SizedBox(height: 16),

              // 🔹 Stack รูป + ช่องค้นหา + ข้อความ
              Stack(
                children: [
                  // 🔸 รูป
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset('assets/images/pichome.png', width: double.infinity, height: 140, fit: BoxFit.cover),
                    ),
                  ),

                  // 🔸 ช่องค้นหาแบบ overlay
                  Positioned(
                    left: 32,
                    right: 32,
                    top: 16,
                    child: Container(
                      height: 36,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Expanded(child: Text('ค้นหาสินค้าจากคลัง', style: TextStyle(color: Colors.grey))),
                          Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600, size: 20),
                        ],
                      ),
                    ),
                  ),

                  // 🔸 ข้อความทับบนรูป (ใต้ช่องค้นหา)
                  Positioned(
                    left: 32,
                    top: 64,
                    child: Text(
                      'วางสิ่งที่ของคุณที่นี่',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: Offset(1, 1))],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ServiceImageCard(
                      imagePath: 'assets/images/sand.png',
                      onTap: () {
                        // 👉 ไปหน้าบริการฝากส่ง
                        //Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryPage()));
                      },
                    ),
                    const SizedBox(width: 12),
                    ServiceImageCard(
                      imagePath: 'assets/images/bay.png',
                      onTap: () {
                        // 👉 ไปหน้าแลกเปลี่ยนเงิน
                        //Navigator.push(context, MaterialPageRoute(builder: (_) => const ExchangePage()));
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      // 🔹 ฝั่งซ้าย: กล่องรูปใหญ่เต็ม 50%
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PackageDepositPage()));
                            },
                            child: Image.asset('assets/images/ex1.png', fit: BoxFit.cover),
                          ),
                        ),
                      ),

                      // 🔸 เส้นแบ่งกลาง
                      Container(width: 1, height: 100, margin: const EdgeInsets.symmetric(horizontal: 12), color: Colors.grey.shade300),

                      // 🔹 ฝั่งขวา: การ์ดแต้มของขวัญ
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RewardRedeemPage()));
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    // ข้อความ
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('100', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF9800))),
                                          SizedBox(height: 2),
                                          Text('แต้มของขวัญ', style: TextStyle(fontSize: 13, color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                    // รูปของขวัญด้านขวา
                                    Image.asset('assets/icons/gif.png', width: 30, height: 30),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text('นำไปแลกของรางวัล', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // 🔹 เมนูบริการ
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildServiceItem(context, 'assets/icons/tran1.png', 'อัตราค่าขนส่ง'),
                    _buildServiceItem(context, 'assets/icons/monny.png', 'อัตราแลกเปลี่ยน'),
                    _buildServiceItem(context, 'assets/icons/cal1.png', 'คำนวณค่าบริการ'),
                    _buildServiceItem(context, 'assets/icons/box1.png', 'ตามพัสดุของฉัน'),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // 🔹 สินค้าแนะนำ
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('รายการสินค้าแนะนำ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 12),

              // ใช้ Obx เพื่อ listen การเปลี่ยนแปลงข้อมูล
              Obx(() {
                if (homeController.isLoading.value) {
                  return Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
                }

                if (homeController.hasError.value) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600, size: 48),
                          SizedBox(height: 12),
                          Text(
                            homeController.errorMessage.value,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => homeController.refreshData(),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
                            child: Text('ลองใหม่'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (homeController.searchItems.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('ไม่พบสินค้า', style: TextStyle(fontSize: 16, color: Colors.grey))),
                  );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: homeController.searchItems.length,
                    itemBuilder: (context, index) {
                      final item = homeController.searchItems[index];

                      return ProductCardFromAPI(
                        imageUrl: item['pic_url'] ?? '',
                        title: item['title'] ?? 'ไม่มีชื่อสินค้า',
                        seller: item['seller_nick'] ?? 'ไม่มีข้อมูลร้านค้า',
                        price: '฿${item['price'] ?? 0}',
                        detailUrl: item['detail_url'] ?? '',
                        onTap: () {
                          final rawNumIid = item['num_iid'];
                          final String numIidStr = (rawNumIid is int || rawNumIid is String) ? rawNumIid.toString() : '0';

                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(num_iid: numIidStr)));
                        },
                      );
                    },
                  ),
                );
              }),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, String iconPath, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'อัตราค่าขนส่ง') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ShippingRatePage()));
        } else if (label == 'อัตราแลกเปลี่ยน') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ExchangeRatePage(exchangeRate: homeController.exchangeRate)));
        } else if (label == 'คำนวณค่าบริการ') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TransportCalculatePage()));
        } else if (label == 'ตามพัสดุของฉัน') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingOwnerPage()));
        }
      },
      child: Column(
        children: [
          Image.asset(iconPath, width: 36, height: 36),
          const SizedBox(height: 6),
          SizedBox(width: 64, child: Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
