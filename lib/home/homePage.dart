import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gcargo/controllers/showImagePickerBottomSheet.dart';
import 'package:gcargo/home/exchangePage.dart';
import 'package:gcargo/home/searchPage.dart';
import 'package:gcargo/home/widgets/ProductCardFromAPI.dart';
import 'package:gcargo/home/widgets/ServiceImageCard.dart';
import 'package:gcargo/home/widgets/service_item_widget.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:gcargo/services/uploadService.dart';
import 'package:get/get.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/home/notificationPage.dart';
import 'package:gcargo/home/packageDepositPage.dart';
import 'package:gcargo/home/productDetailPage.dart';
import 'package:gcargo/home/rewardRedeemPage.dart';
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
    // คอมเม้น Timer สำหรับ auto-slide เพราะใช้แบนเนอร์เดียว

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
    //_timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // ฟังก์ชั่นสำหรับจัดการการค้นหาด้วยรูปภาพ
  Future<void> _handleImageSearch(XFile image) async {
    try {
      // แสดง loading
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

      // 1. อัปโหลดรูปภาพ
      //final _imageUpload = await UoloadService.uploadImage(image);
      File file = File(image.path);
      final _imageUpload = await UoloadService.addImage(file: file!, path: 'uploads/alipay/');

      if (_imageUpload != null) {
        // 2. อัปรูปที่ HomeService
        final _imgcode = await HomeService.uploadImage(imgcode: 'https://cargo-api.dev-asha9.com/${_imageUpload}');

        if (_imgcode != null && _imgcode.isNotEmpty) {
          // 3. ค้นหาด้วยรูปภาพ
          final _searchImage = await HomeService.getItemSearchImg(searchImg: _imgcode, type: homeController.selectedItemType.value);

          if (_searchImage.isNotEmpty) {
            // ปิด loading
            Navigator.pop(context);

            // ไปหน้า SearchPage พร้อมส่งข้อมูล
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage(initialSearchResults: _searchImage, initialSearchQuery: 'ค้นหาด้วยรูปภาพ')),
            );
          } else {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่พบสินค้าจากรูปภาพที่ค้นหา')));
          }
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่สามารถประมวลผลรูปภาพได้')));
        }
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่สามารถอัปโหลดรูปภาพได้')));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')));
    }
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
                            onImagePicked: (XFile image) async {
                              await _handleImageSearch(image);
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
                  Get.snackbar(
                    'แจ้งเตือน',
                    'ฟังก์ชั่นนี้ยังไม่เปิดใช้งาน',
                    backgroundColor: Colors.yellowAccent,
                    colorText: Colors.black,
                    snackPosition: SnackPosition.BOTTOM,
                  );
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
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
                          Get.snackbar(
                            'แจ้งเตือน',
                            'ฟังก์ชั่นนี้ยังไม่เปิดใช้งาน',
                            backgroundColor: Colors.yellowAccent,
                            colorText: Colors.black,
                            snackPosition: SnackPosition.BOTTOM,
                          );
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ServiceItemWidget(iconPath: 'assets/icons/tran1.png', label: 'อัตราค่าขนส่ง'),
                        VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade300),
                        ServiceItemWidget(iconPath: 'assets/icons/monny.png', label: 'อัตราแลกเปลี่ยน'),
                        VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade300),
                        ServiceItemWidget(iconPath: 'assets/icons/cal1.png', label: 'คำนวณค่าบริการ'),
                        VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade300),
                        ServiceItemWidget(iconPath: 'assets/icons/box1.png', label: 'ตามพัสดุของฉัน'),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // 🔹 สินค้าแนะนำ พร้อม dropdown
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('รายการสินค้าแนะนำ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Obx(
                      () => Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: homeController.selectedItemType.value.isEmpty ? itemType.first : homeController.selectedItemType.value,
                            items:
                                itemType.map((item) {
                                  return DropdownMenuItem<String>(value: item, child: Text(item, style: TextStyle(fontSize: 14)));
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                homeController.selectedItemType.value = newValue;
                                homeController.searchItemsFromAPI('Shirt');
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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

                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(num_iid: numIidStr, name: 'Shirt')));
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
}
