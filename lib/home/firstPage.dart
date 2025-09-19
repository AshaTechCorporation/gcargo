import 'package:flutter/material.dart';
import 'package:gcargo/account/accountPage.dart';
import 'package:gcargo/bill/orderHistoryPage.dart';
import 'package:gcargo/bill/transportCostPage.dart';
import 'package:gcargo/home/homePage.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/parcel/exchangeStatusPage.dart';
import 'package:gcargo/parcel/orderStatusPage.dart';
import 'package:gcargo/parcel/parcelStatusPage.dart';
import 'package:gcargo/parcel/problemPackagePage.dart';
import 'package:get/get.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final PageStorageBucket bucket = PageStorageBucket();
  int _uiSelectedIndex = 0;
  int _pageIndex = 0;
  bool _showStatusPanel = false;
  bool _showBillPanel = false;
  late LanguageController languageController;

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
  }

  final List<Widget> pages = [HomePage(), AccountPage()];

  List<Map<String, dynamic>> get navItems {
    final currentLang = languageController.currentLanguage.value;

    if (currentLang == 'en') {
      return [
        {'icon': 'assets/icons/home-2.png', 'label': 'Home'},
        {'icon': 'assets/icons/box.png', 'label': 'Status'},
        {'icon': 'assets/icons/clipboard-text.png', 'label': 'Bill'},
        {'icon': 'assets/icons/user.png', 'label': 'Account'},
      ];
    } else if (currentLang == 'zh') {
      return [
        {'icon': 'assets/icons/home-2.png', 'label': '首页'},
        {'icon': 'assets/icons/box.png', 'label': '状态'},
        {'icon': 'assets/icons/clipboard-text.png', 'label': '账单'},
        {'icon': 'assets/icons/user.png', 'label': '账户'},
      ];
    } else {
      return [
        {'icon': 'assets/icons/home-2.png', 'label': 'หน้าแรก'},
        {'icon': 'assets/icons/box.png', 'label': 'สถานะ'},
        {'icon': 'assets/icons/clipboard-text.png', 'label': 'บิล'},
        {'icon': 'assets/icons/user.png', 'label': 'บัญชี'},
      ];
    }
  }

  String getStatusTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'order_status': 'ออเดอร์',
        'parcel_status': 'พัสดุ',
        'exchange_status': 'แลกเงิน',
        'problem_package': 'แจ้งเคลม',
        'product_history': 'ประวัติค่าสินค้า',
        'transport_cost': 'ประวัติค่าขนส่ง',
      },
      'en': {
        'order_status': 'Order',
        'parcel_status': 'Parcel',
        'exchange_status': 'Exchange',
        'problem_package': 'Report Issue',
        'product_history': 'Product History',
        'transport_cost': 'Shipping History',
      },
      'zh': {
        'order_status': '订单',
        'parcel_status': '包裹',
        'exchange_status': '换汇',
        'problem_package': '报告问题',
        'product_history': '商品历史',
        'transport_cost': '运费历史',
      },
    };

    return translations[currentLang]?[key] ?? translations['th']?[key] ?? key;
  }

  void onItemSelect(int index) {
    setState(() {
      _uiSelectedIndex = index;
      // ปิด panels เมื่อเปลี่ยนแท็บ
      _showStatusPanel = false;
      _showBillPanel = false;
    });

    if (index == 1) {
      // กดสถานะ
      setState(() {
        _showStatusPanel = !_showStatusPanel;
        _showBillPanel = false;
      });
      return;
    }

    if (index == 2) {
      // กดบิล
      setState(() {
        _showBillPanel = !_showBillPanel;
        _showStatusPanel = false;
      });
      return;
    }

    // กดหน้าอื่น
    if (index == 0 || index == 3) {
      final adjustedPageIndex = index == 3 ? 1 : 0;
      setState(() {
        _pageIndex = adjustedPageIndex;
        _showStatusPanel = false;
        _showBillPanel = false;
      });
    }
  }

  void _hideStatusPanel() {
    setState(() {
      _showStatusPanel = false;
    });
  }

  Widget _statusActionItem({
    required String icon,
    required String label,
    required Color backgroundColor,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: iconBackground),
                child: Center(child: Image.asset(icon, width: 20, height: 20)),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _billActionItem({required String icon, required String label, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onTap();
          _hideStatusPanel();
          setState(() => _showBillPanel = false);
        },
        child: Column(
          children: [
            const SizedBox(height: 4),

            // ปุ่มเต็ม (พื้น + ไอคอน + ข้อความ)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE9F7EF) : const Color(0xFFF0F4FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ไอคอนวงกลม
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: Center(child: Image.asset(icon, width: 20, height: 20)),
                  ),
                  const SizedBox(width: 8),
                  // ข้อความ
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF6BD08B) : Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNavItem(int index) {
    final isSelected = _uiSelectedIndex == index;
    final color = isSelected ? kButtonColor : Colors.grey.shade400;

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemSelect(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(navItems[index]['icon'], width: 24, height: 24, color: color),
            const SizedBox(height: 4),
            if (isSelected) Text(navItems[index]['label'], style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          PageStorage(bucket: bucket, child: pages[_pageIndex]),

          if (_showStatusPanel)
            Positioned(
              left: 0,
              right: 0,
              bottom: 64, // เหนือ BottomNavBar
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statusActionItem(
                        icon: 'assets/icons/task-square.png',
                        label: getStatusTranslation('order_status'),
                        backgroundColor: const Color(0xFFE6F2FF),
                        iconBackground: const Color(0xFFD0E7FF),
                        onTap: () {
                          setState(() {
                            _showStatusPanel = false;
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => OrderStatusPage()));
                        },
                      ),
                      _statusActionItem(
                        icon: 'assets/icons/boxGreen.png',
                        label: getStatusTranslation('parcel_status'),
                        backgroundColor: const Color(0xFFE9F7EF),
                        iconBackground: const Color(0xFFC8E6C9),
                        onTap: () {
                          setState(() {
                            _showStatusPanel = false;
                          });
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => const ParcelPage()));
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ParcelStatusPage()));
                        },
                      ),
                      _statusActionItem(
                        icon: 'assets/icons/bitcoin-convert.png',
                        label: getStatusTranslation('exchange_status'),
                        backgroundColor: const Color(0xFFFFF9E6),
                        iconBackground: const Color(0xFFFFF3CD),
                        onTap: () {
                          setState(() {
                            _showStatusPanel = false;
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ExchangeStatusPage()));
                        },
                      ),
                      _statusActionItem(
                        icon: 'assets/icons/boxRed.png',
                        label: getStatusTranslation('problem_package'),
                        backgroundColor: const Color(0xFFFFEBEE),
                        iconBackground: const Color(0xFFFFCDD2),
                        onTap: () {
                          setState(() {
                            _showStatusPanel = false;
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProblemPackagePage()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_showBillPanel)
            Positioned(
              left: 0,
              right: 0,
              bottom: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _billActionItem(
                        icon: 'assets/icons/task-square.png',
                        label: getStatusTranslation('product_history'),
                        isSelected: false,
                        onTap: () {
                          setState(() {
                            _showBillPanel = false;
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryPage()));
                        },
                      ),
                      _billActionItem(
                        icon: 'assets/icons/menu-board.png',
                        label: getStatusTranslation('transport_cost'),
                        isSelected: true,
                        onTap: () {
                          setState(() {
                            _showBillPanel = false;
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const TransportCostPage()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Row(children: List.generate(4, (index) => buildNavItem(index))),
      ),
    );
  }
}
