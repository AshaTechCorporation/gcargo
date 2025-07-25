import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gcargo/controllers/showImagePickerBottomSheet.dart';
import 'package:gcargo/home/exchangePage.dart';
import 'package:gcargo/home/searchPage.dart';
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

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && homeController.imgBanners.isNotEmpty) {
        int nextPage = (_currentPage + 1) % homeController.imgBanners.length;
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

  // Method to handle search
  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณากรอกคำค้นหา')));
      }
      return;
    }

    // Show loading indicator
    if (mounted) {
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    }

    try {
      // Call API to search
      await homeController.searchItemsFromAPI(query);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Check if we have results
      if (homeController.hasError.value) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(homeController.errorMessage.value)));
        }
      } else if (homeController.searchItems.isEmpty) {
        // Show no results message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่พบสินค้าที่ค้นหา')));
        }
      } else {
        // Navigate to SearchPage with results
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage(initialSearchResults: homeController.searchItems, initialSearchQuery: query)),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Text('A100', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kSubTitleTextGridColor)),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 36,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: kBackTextFiledColor, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: searchController, // 👈 เพิ่ม controller ตามที่คุณกำหนดไว้
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'ค้นหาสินค้า',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.black),
                          onFieldSubmitted: (value) {
                            _handleSearch(value);
                          },
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
              GestureDetector(
                onTap: () {
                  ////go action
                },
                child: Image.asset('assets/icons/bag.png', width: 20, height: 20, fit: BoxFit.fill),
              ),
              SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
                },
                child: Image.asset('assets/icons/notification.png', width: 20, height: 20, fit: BoxFit.fill),
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
              // 🔹 Image Slider
              Obx(() {
                if (homeController.isLoading.value) {
                  return Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
                }

                if (homeController.imgBanners.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 140,
                        color: Colors.grey.shade200,
                        child: Center(child: Text('ไม่มีรูปภาพแบนเนอร์', style: TextStyle(color: Colors.grey))),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 140,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: homeController.imgBanners.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final banner = homeController.imgBanners[index];
                          return Image.network(
                            banner.image ?? 'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              }),

              SizedBox(height: 16),
              // 🔹 Indicator
              Obx(() {
                if (homeController.imgBanners.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(homeController.imgBanners.length, (index) {
                    final isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.blue.shade900 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                );
              }),
              SizedBox(height: 16),

              // 🔹 Stack รูป + ช่องค้นหา + ข้อความ
              Stack(
                children: [
                  // 🔸 รูป
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
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
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to SearchPage for search
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
                        },
                        child: Row(
                          children: [
                            Expanded(child: Text('ค้นหาสินค้าจากคลัง', style: TextStyle(color: Colors.grey))),
                            Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🔸 ข้อความทับบนรูป (ใต้ช่องค้นหา)
                  Positioned(
                    left: 28,
                    top: 64,
                    child: Text(
                      'วางลิ้งก์์ของคุณที่นี่',
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
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PackageDepositPage()));
                      },
                    ),
                    SizedBox(width: 12),
                    ServiceImageCard(
                      imagePath: 'assets/images/bay.png',
                      onTap: () {
                        // 👉 ไปหน้าแลกเปลี่ยนเงิน
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ExchangePage()));
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RewardRedeemPage()));
                  },
                  child: Image.asset('assets/images/point1.png', fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20),

              // 🔹 เมนูบริการ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildServiceItem(context, 'assets/icons/tran1.png', 'อัตราค่าขนส่ง'),
                      VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade300),
                      _buildServiceItem(context, 'assets/icons/monny.png', 'อัตราแลกเปลี่ยน'),
                      VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade300),
                      _buildServiceItem(context, 'assets/icons/cal1.png', 'คำนวณค่าบริการ'),
                      VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade300),
                      _buildServiceItem(context, 'assets/icons/box1.png', 'ตามพัสดุของฉัน'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // 🔹 สินค้าแนะนำ
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('รายการสินค้าแนะนำ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                        price: '¥${item['price'] ?? 0}',
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Image.asset(iconPath, width: 36, height: 36),
          ),
          const SizedBox(height: 6),
          SizedBox(width: 64, child: Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
