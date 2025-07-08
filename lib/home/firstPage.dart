import 'package:flutter/material.dart';
import 'package:gcargo/account/accountPage.dart';
import 'package:gcargo/bill/billPage.dart';
import 'package:gcargo/home/homePage.dart';
import 'package:gcargo/parcel/parcelPage.dart';
import 'package:gcargo/constants.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final PageStorageBucket bucket = PageStorageBucket();
  int _selectedIndex = 0;

  final List<Widget> pages = [HomePage(), ParcelPage(), BillPage(), AccountPage()];

  final List<Map<String, dynamic>> navItems = [
    {'icon': 'assets/icons/home-2.png', 'label': 'หน้าแรก'},
    {'icon': 'assets/icons/box.png', 'label': 'พัสดุของฉัน'},
    {'icon': 'assets/icons/clipboard-text.png', 'label': 'บิล'},
    {'icon': 'assets/icons/user.png', 'label': 'บัญชี'},
  ];

  void onItemSelect(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget buildNavItem(int index) {
    final isSelected = _selectedIndex == index;
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
      body: PageStorage(bucket: bucket, child: pages[_selectedIndex]),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Row(children: List.generate(4, (index) => buildNavItem(index))),
      ),
    );
  }
}
