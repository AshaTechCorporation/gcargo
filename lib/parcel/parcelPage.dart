import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/parcel/claimDetailPage.dart';

class ParcelPage extends StatefulWidget {
  const ParcelPage({super.key});

  @override
  State<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends State<ParcelPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _statusTabController;
  int selectedTopTab = 2; // ✅ default: แจ้งพัสดุมีปัญหา

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _statusTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _statusTabController.dispose();
    super.dispose();
  }

  Widget _buildTopTabButton(String label, int index) {
    final bool isSelected = selectedTopTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTopTab = index),
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? kButtonColor : Colors.white,
            border: Border.all(color: kButtonColor),
            borderRadius: BorderRadius.only(
              topLeft: index == 0 ? const Radius.circular(8) : Radius.zero,
              bottomLeft: index == 0 ? const Radius.circular(8) : Radius.zero,
              topRight: index == 2 ? const Radius.circular(8) : Radius.zero,
              bottomRight: index == 2 ? const Radius.circular(8) : Radius.zero,
            ),
          ),
          child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Tabs บนสุด (แก้ให้เรียงกระจายเหมือนในภาพ)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [_buildTopTabButton('สถานะออเดอร์', 0), _buildTopTabButton('สถานะพัสดุ', 1), _buildTopTabButton('แจ้งพัสดุมีปัญหา', 2)],
              ),
            ),

            // ช่องค้นหา
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Container(
                height: 36,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: const Text('ค้นหาเลขที่เอกสาร', style: TextStyle(color: Colors.grey)),
              ),
            ),

            // Tabs สถานะ
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _statusTabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                indicatorColor: kButtonColor,
                indicatorWeight: 2.5,
                tabs: const [Tab(text: 'ทั้งหมด(4)'), Tab(text: 'รอดำเนินการ(1)'), Tab(text: 'สำเร็จ(1)'), Tab(text: 'ยกเลิก(1)')],
              ),
            ),

            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(alignment: Alignment.centerLeft, child: Text('02/07/2025', style: TextStyle(color: Colors.black54))),
            ),

            const SizedBox(height: 12),

            // รายการพัสดุ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ClaimDetailPage()));
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: kButtonColor.withOpacity(0.1), shape: BoxShape.circle),
                    child: Image.asset('assets/icons/document-text.png', width: 24, height: 24, color: kButtonColor),
                  ),
                  title: const Text('เลขที่เอกสาร C181211003', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('8516.00฿'),
                  trailing: const Text('ยกเลิก', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
