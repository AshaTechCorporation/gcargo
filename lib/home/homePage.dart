import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gcargo/home/cartPage.dart';
import 'package:gcargo/home/exchangePage.dart';

import 'package:gcargo/home/widgets/ProductCardFromAPI.dart';
import 'package:gcargo/home/widgets/ServiceImageCard.dart';
import 'package:gcargo/home/widgets/service_item_widget.dart';
import 'package:gcargo/services/search_service.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:get/get.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/home/notificationPage.dart';
import 'package:gcargo/home/packageDepositPage.dart';
import 'package:gcargo/home/productDetailPage.dart';
import 'package:gcargo/home/rewardRedeemPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController searchLinkController = TextEditingController();

  // Initialize HomeController
  final HomeController homeController = Get.put(HomeController());
  late LanguageController languageController;

  // Loading state สำหรับช่องค้นหา
  bool isSearchLoading = false;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'Home.search_placeholder': 'ค้นหาสินค้า',
        'Home.notifications': 'แจ้งเตือน',
        'Home.package_deposit': 'ฝากพัสดุ',
        'Home.reward_redeem': 'แลกของรางวัล',
        'Home.services.shipping_rate': 'อัตราค่าขนส่ง',
        'Home.services.exchange_rate': 'อัตราแลกเปลี่ยน',
        'Home.services.calculate_service': 'คำนวณค่าบริการ',
        'Home.services.track_parcel': 'ตามพัสดุของฉัน',
        'alert_title': 'แจ้งเตือน',
        'ok': 'ตกลง',
        'no_banner': 'ไม่มีรูปภาพแบนเนอร์',
        'recommended_products': 'รายการสินค้าแนะนำ',
        'try_again': 'ลองใหม่',
        'no_products': 'ไม่พบสินค้า',
        'paste_link_here': 'วางลิ้งก์ของคุณที่นี่',
      },
      'en': {
        'Home.search_placeholder': 'Search products',
        'Home.notifications': 'Notifications',
        'Home.package_deposit': 'Package Deposit',
        'Home.reward_redeem': 'Redeem Rewards',
        'Home.services.shipping_rate': 'Shipping Rate',
        'Home.services.exchange_rate': 'Exchange Rate',
        'Home.services.calculate_service': 'Calculate Service',
        'Home.services.track_parcel': 'Track My Parcel',
        'alert_title': 'Alert',
        'ok': 'OK',
        'no_banner': 'No banner image',
        'recommended_products': 'Recommended Products',
        'try_again': 'Try Again',
        'no_products': 'No products found',
        'paste_link_here': 'Paste your link here',
      },
      'zh': {
        'Home.search_placeholder': '搜索商品',
        'Home.notifications': '通知',
        'Home.package_deposit': '包裹寄存',
        'Home.reward_redeem': '兑换奖励',
        'Home.services.shipping_rate': '运费价格',
        'Home.services.exchange_rate': '汇率',
        'Home.services.calculate_service': '计算服务费',
        'Home.services.track_parcel': '追踪我的包裹',
        'alert_title': '提醒',
        'ok': '确定',
        'no_banner': '没有横幅图片',
        'recommended_products': '推荐商品',
        'try_again': '重试',
        'no_products': '未找到商品',
        'paste_link_here': '在此粘贴您的链接',
      },
    };

    return translations[currentLang]?[key] ?? translations['th']?[key] ?? key;
  }

  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    homeController.searchItemsFromAPI('');

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

  // ฟังก์ชั่นสำหรับเรียก API searchLink
  Future<void> extractIdFromUrl(String url) async {
    // เริ่ม loading
    setState(() {
      isSearchLoading = true;
    });

    try {
      print('🔍 เริ่มเรียก API searchLink: $url');

      // เรียก API searchLink จาก HomeService
      final response = await HomeService.searchLink(textLink: url);

      if (response != null) {
        final productId = response['productId']?.toString();
        final platform = response['platform']?.toString();

        print('🔍 API Response - productId: $productId, platform: $platform');

        if (productId != null && productId.isNotEmpty) {
          // กำหนด type ตาม platform จาก API หรือ selectedItemType
          String type;
          if (platform != null && platform.isNotEmpty) {
            type = platform.toLowerCase() == 'taobao' ? 'taobao' : '1688';
          } else {
            type = homeController.selectedItemType.value == 'shopgs1' ? 'taobao' : '1688';
          }

          print('🔍 ไปหน้า ProductDetailPage - ID: $productId, type: $type');
          Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(num_iid: productId, name: 'Shirt', type: type)));
        } else {
          _showAlert('ไม่พบ Product ID จาก API');
        }
      } else {
        _showAlert('ไม่สามารถเรียก API ได้\nกรุณาตรวจสอบ URL ที่กรอก');
      }
    } catch (e) {
      print('❌ Error calling searchLink API: $e');
      _showAlert('เกิดข้อผิดพลาดในการเรียก API');
    } finally {
      // หยุด loading
      if (mounted) {
        setState(() {
          isSearchLoading = false;
        });
      }
    }
  }

  // ฟังก์ชั่นสำหรับแสดง Alert Dialog
  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslation('alert_title')),
          content: Text(message),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(getTranslation('ok')))],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder:
          (controller) => Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Obx(
                      () => Text(
                        homeController.currentUser.value?.code ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kSubTitleTextGridColor),
                      ),
                    ),
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
                                  hintText: getTranslation('Home.search_placeholder'),
                                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(color: Colors.black),
                                onFieldSubmitted: (value) {
                                  SearchService.handleTextSearch(context: context, query: value, selectedType: homeController.selectedItemType.value);
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                SearchService.showImagePickerBottomSheet(context: context, selectedType: homeController.selectedItemType.value);
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
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
                    // Image.asset('assets/images/slidpic.png', width: double.infinity, height: 140, fit: BoxFit.cover),
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
                              child: Center(child: Text(getTranslation('no_banner'), style: TextStyle(color: Colors.grey))),
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

                        // 🔸 ช่องกรอกค้นหา
                        Positioned(
                          left: 32,
                          right: 32,
                          top: 16,
                          child: Container(
                            height: 42,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: TextField(
                                        controller: searchLinkController,
                                        decoration: InputDecoration(
                                          hintText: getTranslation('Home.search_placeholder'),
                                          hintStyle: TextStyle(color: Colors.grey),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        style: TextStyle(fontSize: 14),
                                        textInputAction: TextInputAction.search,
                                        onSubmitted:
                                            isSearchLoading
                                                ? null
                                                : (value) {
                                                  // เมื่อกด Enter หรือ Submit
                                                  final inputUrl = value.trim();
                                                  if (inputUrl.isEmpty) {
                                                    _showAlert('กรุณากรอก URL ที่ต้องการค้นหา');
                                                    return;
                                                  }
                                                  extractIdFromUrl(inputUrl);
                                                },
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap:
                                        isSearchLoading
                                            ? null
                                            : () {
                                              // เช็คว่ามีการกรอกข้อมูลหรือไม่
                                              final inputUrl = searchLinkController.text.trim();
                                              print('🔍 Input URL: $inputUrl');
                                              print('🔍 Selected Type: ${homeController.selectedItemType.value}');

                                              if (inputUrl.isEmpty) {
                                                _showAlert('กรุณากรอก URL ที่ต้องการค้นหา');
                                                return;
                                              }

                                              // ส่ง URL ที่กรอกไปยังฟังก์ชั่นตัด ID
                                              extractIdFromUrl(inputUrl);
                                            },
                                    child: Icon(Icons.send, color: Colors.grey.shade600, size: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 🔸 ข้อความทับบนรูป (ใต้ช่องค้นหา)
                        Positioned(
                          left: 28,
                          top: 66,
                          child: Text(
                            getTranslation('paste_link_here'),
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
                              ServiceItemWidget(
                                iconPath: 'assets/icons/tran1.png',
                                label: getTranslation('Home.services.shipping_rate'),
                                serviceKey: 'shipping_rate',
                              ),
                              VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade300),
                              ServiceItemWidget(
                                iconPath: 'assets/icons/monny.png',
                                label: getTranslation('Home.services.exchange_rate'),
                                serviceKey: 'exchange_rate',
                              ),
                              VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade300),
                              ServiceItemWidget(
                                iconPath: 'assets/icons/cal1.png',
                                label: getTranslation('Home.services.calculate_service'),
                                serviceKey: 'calculate_service',
                              ),
                              VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade300),
                              ServiceItemWidget(
                                iconPath: 'assets/icons/box1.png',
                                label: getTranslation('Home.services.track_parcel'),
                                serviceKey: 'track_package',
                              ),
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
                          Text(getTranslation('recommended_products'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                                  child: Text(getTranslation('try_again')),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (homeController.searchItems.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text(getTranslation('no_products'), style: TextStyle(fontSize: 16, color: Colors.grey))),
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

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ProductDetailPage(
                                          num_iid: numIidStr,
                                          name: 'Shirt',
                                          type: homeController.selectedItemType.value == 'shopgs1' ? 'taobao' : '1688',
                                        ),
                                  ),
                                );
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
          ),
    );
  }
}
