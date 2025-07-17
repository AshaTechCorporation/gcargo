import 'package:flutter/material.dart';
import 'package:gcargo/account/accountPage.dart';
import 'package:gcargo/bill/billPage.dart';
import 'package:gcargo/home/homePage.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/parcel/exchangeStatusPage.dart';
import 'package:gcargo/parcel/orderStatusPage.dart';
import 'package:gcargo/parcel/parcelPage.dart';
import 'package:gcargo/parcel/problemPackagePage.dart';

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

  final List<Widget> pages = [HomePage(), BillPage(), AccountPage()];

  final List<Map<String, dynamic>> navItems = [
    {'icon': 'assets/icons/home-2.png', 'label': 'หน้าแรก'},
    {'icon': 'assets/icons/box.png', 'label': 'สถานะ'},
    {'icon': 'assets/icons/clipboard-text.png', 'label': 'บิล'},
    {'icon': 'assets/icons/user.png', 'label': 'บัญชี'},
  ];

  void onItemSelect(int index) {
    setState(() {
      _uiSelectedIndex = index;
    });

    if (index == 1) {
      // Toggle status panel
      setState(() {
        _showStatusPanel = !_showStatusPanel;
      });
      return;
    }

    // ปรับ index เพราะ 'สถานะ' ไม่มีหน้า
    final adjustedPageIndex = index > 1 ? index - 1 : index;

    setState(() {
      _pageIndex = adjustedPageIndex;
      _showStatusPanel = false; // ปิด panel ถ้ากดหน้าอื่น
    });
  }

  void _hideStatusPanel() {
    setState(() {
      _showStatusPanel = false;
    });
  }

  void _showStatusBottomSheet() {
    // ไม่ใช้แล้ว เพราะเราแสดงผ่าน Stack
  }

  Widget _statusActionItem({required String icon, required String label, required Color backgroundColor, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onTap();
          _hideStatusPanel();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
              child: Center(child: Image.asset(icon, width: 24, height: 24)),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
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
              bottom: 70, // เหนือ BottomNavBar
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
                        label: 'เตรียมสั่งซื้อ',
                        backgroundColor: const Color(0xFFE6F2FF),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => OrderStatusPage()));
                        },
                      ),
                      _statusActionItem(
                        icon: 'assets/icons/boxGreen.png',
                        label: 'ดำเนินการแล้ว',
                        backgroundColor: const Color(0xFFE9F7EF),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ParcelPage()));
                        },
                      ),
                      _statusActionItem(
                        icon: 'assets/icons/bitcoin-convert.png',
                        label: 'รอชำระเงิน',
                        backgroundColor: const Color(0xFFFFF9E6),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ExchangeStatusPage()));
                        },
                      ),
                      _statusActionItem(
                        icon: 'assets/icons/boxRed.png',
                        label: 'ยกเลิก',
                        backgroundColor: const Color(0xFFFFEBEE),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProblemPackagePage()));
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
