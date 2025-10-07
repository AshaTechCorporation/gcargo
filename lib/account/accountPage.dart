import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcargo/account/WalletPage.dart';
import 'package:gcargo/account/aboutUsPage.dart';
import 'package:gcargo/account/addressListPage.dart';
import 'package:gcargo/account/bankVerifyPage.dart';
import 'package:gcargo/account/changeLanguagePage.dart';
import 'package:gcargo/account/couponPage.dart';
import 'package:gcargo/account/faqPage.dart';
import 'package:gcargo/account/favoritePage.dart';
import 'package:gcargo/account/newsPromotionPage.dart';
import 'package:gcargo/account/profilePage.dart';
import 'package:gcargo/account/securityPage.dart';
import 'package:gcargo/account/userManualPage.dart';
import 'package:gcargo/account/widgets/AccountHeaderWidget.dart';
import 'package:gcargo/account/widgets/showQrDialog.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/home/firstPage.dart';
import 'package:gcargo/login/welcomePage.dart';
import 'package:gcargo/parcel/parcelStatusPage.dart';
import 'package:get/get.dart';
import 'package:gcargo/widgets/LogoutConfirmationDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gcargo/services/accountService.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final HomeController homeController = Get.find<HomeController>();
  final OrderController orderController = Get.put(OrderController());
  late LanguageController languageController;
  String? token;
  bool isGuangzhouSelected = true;
  List<Map<String, dynamic>> storeGcargo = [];
  bool isLoadingStore = false;
  String importer_code = '';

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    // Account translations
    final translations = {
      'th': {
        'Account.title': 'บัญชี',
        'Account.profile': 'ข้อมูลส่วนตัว',
        'Account.wallet': 'กระเป๋าเงิน',
        'Account.address_list': 'ที่อยู่จัดส่ง',
        'Account.bank_verify': 'ยืนยันบัญชีธนาคาร',
        'Account.security': 'ความปลอดภัย',
        'Account.favorite': 'รายการโปรด',
        'Account.coupon': 'คูปองส่วนลด',
        'Account.news_promotion': 'ข่าวสาร & โปรโมชั่น',
        'Account.contact_staff': 'ติดต่อเจ้าหน้าที่',
        'Account.user_manual': 'คู่มือการใช้งาน',
        'Account.faq': 'คำถามที่พบบ่อย',
        'Account.about_us': 'เกี่ยวกับเรา',
        'Account.login': 'เข้าสู่ระบบ',
        'Account.logout': 'ออกจากระบบ',
        'help_section': 'ความช่วยเหลือ',
        'change_language': 'เปลี่ยนภาษา',
        'general_section': 'ทั่วไป',
        'login_required_title': 'จำเป็นต้องเข้าสู่ระบบ',
        'login_required_message': 'กรุณาเข้าสู่ระบบก่อนใช้งานฟีเจอร์นี้',
        'cancel': 'ยกเลิก',
        'user_not_found': 'ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่',
        'profile': 'โปรไฟล์',
        'user_not_logged_in': 'ผู้ใช้ยังไม่เข้าสู่ระบบ',
        'my_parcel': 'พัสดุของฉัน',
        'status': 'สถานะ',
        'transfer_money': 'โอนเงิน',
        'my_wallet': 'Wallet ของฉัน',
        'shipping_address': 'ที่อยู่รับพัสดุ',
        'importer_code': 'รหัสลูกค้า',
        'phone_number': 'เบอร์โทรศัพท์',
      },
      'en': {
        'Account.title': 'Account',
        'Account.profile': 'Profile',
        'Account.wallet': 'Wallet',
        'Account.address_list': 'Shipping Address',
        'Account.bank_verify': 'Bank Account Verification',
        'Account.security': 'Security',
        'Account.favorite': 'Favorites',
        'Account.coupon': 'Coupons',
        'Account.news_promotion': 'News & Promotions',
        'Account.contact_staff': 'Contact Staff',
        'Account.user_manual': 'User Manual',
        'Account.faq': 'FAQ',
        'Account.about_us': 'About Us',
        'Account.login': 'Login',
        'Account.logout': 'Logout',
        'help_section': 'Help',
        'change_language': 'Change Language',
        'general_section': 'General',
        'login_required_title': 'Login Required',
        'login_required_message': 'Please login before using this feature',
        'cancel': 'Cancel',
        'user_not_found': 'User not found. Please login again',
        'profile': 'Profile',
        'user_not_logged_in': 'User not logged in',
        'my_parcel': 'My Parcel',
        'status': 'Status',
        'transfer_money': 'Transfer Money',
        'my_wallet': 'My Wallet',
        'shipping_address': 'Shipping Address',
        'importer_code': 'Importer Code',
        'phone_number': 'Phone Number',
      },
      'zh': {
        'Account.title': '账户',
        'Account.profile': '个人资料',
        'Account.wallet': '钱包',
        'Account.address_list': '收货地址',
        'Account.bank_verify': '银行账户验证',
        'Account.security': '安全',
        'Account.favorite': '收藏夹',
        'Account.coupon': '优惠券',
        'Account.news_promotion': '新闻与促销',
        'Account.contact_staff': '联系客服',
        'Account.user_manual': '使用手册',
        'Account.faq': '常见问题',
        'Account.about_us': '关于我们',
        'Account.login': '登录',
        'Account.logout': '退出登录',
        'help_section': '帮助',
        'change_language': '更改语言',
        'general_section': '常规',
        'login_required_title': '需要登录',
        'login_required_message': '请先登录后使用此功能',
        'cancel': '取消',
        'user_not_found': '未找到用户信息，请重新登录',
        'profile': '个人资料',
        'user_not_logged_in': '用户未登录',
        'my_parcel': '我的包裹',
        'status': '状态',
        'transfer_money': '转账',
        'my_wallet': '我的钱包',
        'shipping_address': '收货地址',
        'importer_code': '进口商代码',
        'phone_number': '电话号码',
      },
    };

    return translations[currentLang]?[key] ?? translations['th']?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fristLoad();
      orderController.getWalletTrans();
      await getStoreData();
    });
  }

  Future<void> fristLoad() async {
    try {
      final user = await homeController.getUserByIdFromAPI();
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('point_balance', user.point_balance ?? '0');
        setState(() {
          importer_code = user.importer_code ?? '';
        });
      }
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('token');

      setState(() {
        token = userToken;
      });
    } catch (e) {
      print('Error in fristLoad: $e');
    }
  }

  Future<void> getStoreData() async {
    try {
      setState(() {
        isLoadingStore = true;
      });
      final stores = await AccountService.getStore();
      setState(() {
        storeGcargo = stores;
        isLoadingStore = false;
      });
    } catch (e) {
      print('Error in getStoreData: $e');
      setState(() {
        isLoadingStore = false;
      });
    }
  }

  Future<void> clearToken() async {
    final _prefs = await SharedPreferences.getInstance();
    SharedPreferences prefs = _prefs;
    prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // เคลียร์ข้อมูลผู้ใช้ใน HomeController
    final homeController = Get.find<HomeController>();
    homeController.currentUser.value = null;
    homeController.update(); // อัปเดต UI
  }

  // ฟังก์ชั่นเช็คสถานะการล็อกอิน
  bool _isLoggedIn() {
    final homeController = Get.find<HomeController>();
    return homeController.currentUser.value != null;
  }

  // ฟังก์ชั่นแสดง dialog เมื่อยังไม่ได้ล็อกอิน
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslation('login_required_title')),
          content: Text(getTranslation('login_required_message')),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(getTranslation('cancel'))),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomePage()));
              },
              child: Text(getTranslation('Account.login')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GetBuilder<LanguageController>(
      builder:
          (controller) => Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu Sections
                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(height: 20),

                        // Header Profile (ชื่อผู้ใช้ + ยอด)
                        GetBuilder<HomeController>(
                          builder:
                              (homeController) => Obx(
                                () => AccountHeaderWidget(
                                  onCreditTap: () {},
                                  onPointTap: () {},
                                  onParcelTap: () {
                                    if (_isLoggedIn()) {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ParcelStatusPage()));
                                    } else {
                                      _showLoginRequiredDialog();
                                    }
                                  },
                                  onWalletTap: () {
                                    if (_isLoggedIn()) {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => WalletPage()));
                                    } else {
                                      _showLoginRequiredDialog();
                                    }
                                  },
                                  onTransferTap: () {},
                                  user: homeController.currentUser.value,
                                  isLoading: homeController.isLoading.value,
                                  walletTrans: orderController.walletTrans,
                                ),
                              ),
                        ),
                        if (_isLoggedIn()) SizedBox(height: 15),
                        if (_isLoggedIn()) // เช็คว่าล็อกอินแล้วหรือไม่
                          // Importer Code Card
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), spreadRadius: 0, blurRadius: 12, offset: Offset(0, 6))],
                            ),
                            child: Column(
                              children: [
                                // Main Importer Code
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                      child: Icon(Icons.badge_outlined, color: Colors.white, size: 24),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getTranslation('importer_code'),
                                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '${importer_code.toUpperCase()}',
                                            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: '${importer_code.toUpperCase()}'));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('คัดลอกรหัสผู้นำเข้าแล้ว'),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                        child: Icon(Icons.copy, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                // Shipping Methods
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Icon(Icons.local_shipping, color: Colors.white, size: 20),
                                            SizedBox(height: 4),
                                            Text(
                                              'ส่งทางรถ',
                                              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'SUN/${importer_code.toUpperCase()}${importcard[0]['Sendbycar']}',
                                              style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Icon(Icons.directions_boat, color: Colors.white, size: 20),
                                            SizedBox(height: 4),
                                            Text(
                                              'ส่งทางเรือ',
                                              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'SUN/${importer_code.toUpperCase()}${importcard[0]['Sendbyboat']}',
                                              style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 16),
                        // Store Address Section
                        (storeGcargo.isEmpty || !_isLoggedIn())
                            ? const SizedBox()
                            : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, color: Color(0xFF4A90E2), size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        getTranslation('shipping_address'),
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Column(
                                    children: List.generate(
                                      storeGcargo.length,
                                      (indexStore) => Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(bottom: 12),
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Color(0xFFE3F2FD)),
                                          boxShadow: [
                                            BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 0, blurRadius: 8, offset: Offset(0, 2)),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF4A90E2).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(Icons.store, color: Color(0xFF4A90E2), size: 16),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        storeGcargo[indexStore]['name'] ?? '',
                                                        style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold, fontSize: 16),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        (storeGcargo[indexStore]['address'] ?? '').replaceAll(RegExp(r'[\r\n]'), ''),
                                                        style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Icon(Icons.phone, color: Color(0xFF27AE60), size: 16),
                                                SizedBox(width: 8),
                                                Text(
                                                  '${getTranslation('phone_number')}: ${storeGcargo[indexStore]['phone'] ?? ''}',
                                                  style: TextStyle(color: Color(0xFF2C3E50), fontSize: 14, fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () {
                                                      Clipboard.setData(ClipboardData(text: storeGcargo[indexStore]['address'] ?? ''));
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('คัดลอกที่อยู่แล้ว'),
                                                          backgroundColor: Colors.green,
                                                          duration: Duration(seconds: 2),
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(Icons.copy, size: 16),
                                                    label: Text('คัดลอกที่อยู่'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Color(0xFF4A90E2),
                                                      foregroundColor: Colors.white,
                                                      padding: EdgeInsets.symmetric(vertical: 8),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                        if (_isLoggedIn()) SizedBox(height: 24),
                        _buildSectionTitle(getTranslation('Account.news_promotion')),
                        _buildMenuItem(
                          getTranslation('Account.news_promotion'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NewsPromotionPage()));
                          },
                        ),
                        _buildMenuItem(
                          getTranslation('Account.coupon'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CouponPage()));
                          },
                        ),
                        _buildMenuItem(
                          getTranslation('Account.favorite'),
                          onTap: () {
                            if (token != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritePage()));
                            } else {
                              // แสดง dialog หรือ snackbar แจ้งว่าไม่มีข้อมูลผู้ใช้
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(getTranslation('user_not_found')), backgroundColor: Colors.orange));
                            }
                          },
                        ),

                        _buildSectionTitle(getTranslation('general_section')),
                        _buildMenuItem(
                          getTranslation('profile'),
                          onTap: () async {
                            final homeController = Get.find<HomeController>();
                            if (homeController.currentUser.value != null) {
                              final _edit = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProfilePage(user: homeController.currentUser.value)),
                              );
                              if (_edit == true) {}
                            } else {
                              // แสดง dialog หรือ snackbar แจ้งว่าไม่มีข้อมูลผู้ใช้
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(getTranslation('user_not_found')), backgroundColor: Colors.orange));
                            }
                          },
                        ),
                        _buildMenuItem(
                          getTranslation('Account.address_list'),
                          onTap: () async {
                            final homeController = Get.find<HomeController>();
                            if (homeController.currentUser.value != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddressListPage()));
                            } else {
                              // แสดง dialog หรือ snackbar แจ้งว่าไม่มีข้อมูลผู้ใช้
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(getTranslation('user_not_found')), backgroundColor: Colors.orange));
                            }
                          },
                        ),
                        _buildMenuItem(
                          getTranslation('Account.bank_verify'),
                          showVerified: true,
                          onTap: () async {
                            final homeController = Get.find<HomeController>();
                            if (homeController.currentUser.value != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => BankVerifyPage()));
                            } else {
                              // แสดง dialog หรือ snackbar แจ้งว่าไม่มีข้อมูลผู้ใช้
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(getTranslation('user_not_found')), backgroundColor: Colors.orange));
                            }
                          },
                        ),
                        _buildMenuItem(
                          getTranslation('Account.security'),
                          onTap: () async {
                            // final homeController = Get.find<HomeController>();
                            // if (homeController.currentUser.value != null) {
                            //   Navigator.push(context, MaterialPageRoute(builder: (context) => SecurityPage()));
                            // } else {
                            //   // แสดง dialog หรือ snackbar แจ้งว่าไม่มีข้อมูลผู้ใช้
                            //   ScaffoldMessenger.of(
                            //     context,
                            //   ).showSnackBar(SnackBar(content: Text(getTranslation('user_not_found')), backgroundColor: Colors.orange));
                            // }

                            Get.snackbar(
                              'แจ้งเตือน',
                              'ฟังก์ชั่นนี้ยังไม่เปิดใช้งาน',
                              backgroundColor: Colors.yellowAccent,
                              colorText: Colors.black,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                        _buildMenuItem(
                          getTranslation('change_language'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeLanguagePage()));
                            // Get.snackbar(
                            //   'แจ้งเตือน',
                            //   'ฟังก์ชั่นนี้ยังไม่เปิดใช้งาน',
                            //   backgroundColor: Colors.yellowAccent,
                            //   colorText: Colors.black,
                            //   snackPosition: SnackPosition.BOTTOM,
                            // );
                          },
                        ),

                        _buildSectionTitle(getTranslation('help_section')),
                        _buildMenuItem(
                          getTranslation('Account.contact_staff'),
                          onTap: () {
                            showQrDialog(
                              context,
                              handle: '@gcargo',
                              //avatarUrl: 'https://i.pravatar.cc/150?img=12', // หรือ avatarAsset: 'assets/images/avatar.png'
                              onDownload: () {
                                // TODO: ทำฟังก์ชันบันทึกรูป/แชร์
                              },
                            );
                          },
                        ),
                        _buildMenuItem(
                          getTranslation('Account.user_manual'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => UserManualPage()));
                          },
                        ),
                        _buildMenuItem(
                          getTranslation('Account.faq'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => FaqPage()));
                          },
                        ),
                        _buildMenuItem(
                          getTranslation('Account.about_us'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsPage()));
                          },
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.white,
                            ),
                            child: TextButton(
                              onPressed: () async {
                                if (token == null) {
                                  // ไปหน้า Login
                                  //Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomePage()));
                                } else {
                                  final confirm = await showDialog(
                                    context: context,
                                    builder:
                                        (context) => LogoutConfirmationDialog(
                                          onConfirm: () {
                                            // TODO: ลบ token ออกจาก SharedPreferences
                                            Navigator.pop(context, true);
                                          },
                                          onCancel: () => Navigator.pop(context, false),
                                        ),
                                  );
                                  if (confirm == true) {
                                    await clearToken();
                                    if (mounted) {
                                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => FirstPage()), (route) => false);
                                    }
                                  }
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                foregroundColor: Color(0xFF4A4A4A),
                                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              child: Text(
                                token == null ? getTranslation('Account.login') : getTranslation('Account.logout'),
                                style: TextStyle(fontFamily: 'SukhumvitSet', fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildMenuItem(String title, {bool showVerified = false, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15)),
                      if (showVerified) ...[const SizedBox(width: 8), const Icon(Icons.verified, color: Colors.grey, size: 18)],
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFE0E0E0)),
      ],
    );
  }
}

Widget _buildInfoRow(BuildContext context, String title, String detail, IconData icon, Color iconColor, String subtitle, void Function()? onTap) {
  final size = MediaQuery.of(context).size; // ใช้ context ที่ส่งเข้ามา

  return Padding(
    padding: EdgeInsets.symmetric(
      vertical: size.height * 0.005, // ปรับขนาด padding ให้สัมพันธ์กับความสูงของหน้าจอ
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(fontSize: 13, color: Color(0xff606060))), //stringsubtitles
            ],
          ),
        ),
        Expanded(flex: 3, child: Text(detail, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              SizedBox(width: size.width * 0.008),
              Text('AccountPage.copy', style: TextStyle(color: iconColor, fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );
}
