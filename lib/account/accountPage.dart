import 'package:flutter/material.dart';
import 'package:gcargo/account/WalletPage.dart';
import 'package:gcargo/account/aboutUsPage.dart';
import 'package:gcargo/account/addressListPage.dart';
import 'package:gcargo/account/bankVerifyPage.dart';
import 'package:gcargo/account/couponPage.dart';
import 'package:gcargo/account/faqPage.dart';
import 'package:gcargo/account/favoritePage.dart';
import 'package:gcargo/account/newsPromotionPage.dart';
import 'package:gcargo/account/profilePage.dart';
import 'package:gcargo/account/securityPage.dart';
import 'package:gcargo/account/userManualPage.dart';
import 'package:gcargo/account/widgets/AccountHeaderWidget.dart';
import 'package:gcargo/account/widgets/showQrDialog.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/home/firstPage.dart';
import 'package:gcargo/login/welcomePage.dart';
import 'package:gcargo/parcel/parcelStatusPage.dart';
import 'package:get/get.dart';
import 'package:gcargo/widgets/LogoutConfirmationDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final HomeController homeController = Get.find<HomeController>();
  final OrderController orderController = Get.put(OrderController());
  String? token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fristLoad();
      orderController.getWalletTrans();
    });
  }

  Future<void> fristLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('token');

      setState(() {
        token = userToken;
      });
    } catch (e) {
      print('Error in fristLoad: $e');
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
          title: const Text('จำเป็นต้องเข้าสู่ระบบ'),
          content: const Text('กรุณาเข้าสู่ระบบก่อนใช้งานฟีเจอร์นี้'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('ยกเลิก')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomePage()));
              },
              child: const Text('เข้าสู่ระบบ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  SizedBox(height: 24),
                  _buildSectionTitle('โปรโมชั่น'),
                  _buildMenuItem(
                    'ข่าวสาร & โปรโมชั่น',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NewsPromotionPage()));
                    },
                  ),
                  _buildMenuItem(
                    'คูปองส่วนลด',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CouponPage()));
                    },
                  ),
                  _buildMenuItem(
                    'รายการโปรด',
                    onTap: () {
                      if (token != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritePage()));
                      } else {
                        // แสดง dialog หรือ snackbar แจ้งว่าไม่มีข้อมูลผู้ใช้
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่'), backgroundColor: Colors.orange));
                      }
                    },
                  ),

                  _buildSectionTitle('ทั่วไป'),
                  _buildMenuItem(
                    'โปรไฟล์',
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
                        ).showSnackBar(const SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่'), backgroundColor: Colors.orange));
                      }
                    },
                  ),
                  _buildMenuItem(
                    'ที่อยู่ของฉัน',
                    onTap: () async {
                      final homeController = Get.find<HomeController>();
                      if (homeController.currentUser.value != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddressListPage()));
                      } else {
                        // แสดง dialog หรือ snackbar แจ้งว่าไม่มีข้อมูลผู้ใช้
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่'), backgroundColor: Colors.orange));
                      }
                    },
                  ),
                  _buildMenuItem(
                    'ยืนยันบัญชีธนาคาร',
                    showVerified: true,
                    onTap: () async {
                      final homeController = Get.find<HomeController>();
                      if (homeController.currentUser.value != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BankVerifyPage()));
                      } else {
                        // แสดง dialog หรือ snackbar แจ้งว่าไม่มีข้อมูลผู้ใช้
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่'), backgroundColor: Colors.orange));
                      }

                      // Get.snackbar(
                      //   'แจ้งเตือน',
                      //   'ฟังก์ชั่นนี้ยังไม่เปิดใช้งาน',
                      //   backgroundColor: Colors.yellowAccent,
                      //   colorText: Colors.black,
                      //   snackPosition: SnackPosition.BOTTOM,
                      // );
                    },
                  ),
                  _buildMenuItem(
                    'ความปลอดภัย',
                    onTap: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => SecurityPage()));
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
                    'เปลี่ยนภาษา',
                    onTap: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeLanguagePage()));
                      Get.snackbar(
                        'แจ้งเตือน',
                        'ฟังก์ชั่นนี้ยังไม่เปิดใช้งาน',
                        backgroundColor: Colors.yellowAccent,
                        colorText: Colors.black,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),

                  _buildSectionTitle('ความช่วยเหลือ'),
                  _buildMenuItem(
                    'ติดต่อเจ้าหน้าที่',
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
                    'คู่มือการใช้งาน',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UserManualPage()));
                    },
                  ),
                  _buildMenuItem(
                    'คำถามที่พบบ่อย',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FaqPage()));
                    },
                  ),
                  _buildMenuItem(
                    'เกี่ยวกับเรา',
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
                          token == null ? 'เข้าสู่ระบบ' : 'ออกจากระบบ',
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
