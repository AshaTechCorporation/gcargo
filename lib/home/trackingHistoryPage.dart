import 'package:flutter/material.dart';
import 'package:gcargo/home/trackingDetailPage.dart';

class TrackingHistoryPage extends StatefulWidget {
  const TrackingHistoryPage({super.key});

  @override
  State<TrackingHistoryPage> createState() => _TrackingHistoryPageState();
}

class _TrackingHistoryPageState extends State<TrackingHistoryPage> {
  int selectedTab = 1;

  final Color kButtonColor = const Color(0xFF427D9D);

  Widget _buildTab(String label, int count, int index) {
    final bool isActive = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isActive ? kButtonColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kButtonColor),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: isActive ? Colors.white : kButtonColor, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 10,
              backgroundColor: isActive ? Colors.white : kButtonColor,
              child: Text('$count', style: TextStyle(color: isActive ? kButtonColor : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingDetailPage())),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 🔵 Icon in circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: Color(0xFFE9F4FF), shape: BoxShape.circle),
                  child: Center(child: Image.asset('assets/icons/box-search.png', width: 18, height: 18)),
                ),
                const SizedBox(width: 8),
                const Expanded(child: Text('เลขขนส่งจีน YT7518613489991', style: TextStyle(fontWeight: FontWeight.bold))),
                Text('รอตรวจสอบ', style: TextStyle(fontSize: 12, color: Color(0xFF427D9D), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('รูปภาพอ้างอิง', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/image14.png', width: 80, height: 80, fit: BoxFit.cover),
                ),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/image14.png', width: 80, height: 80, fit: BoxFit.cover),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('ประวัติตามหาเจ้าของ', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🔹 Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [_buildTab('ทั้งหมด', 1, 0), _buildTab('รอตรวจสอบ', 1, 1), _buildTab('สำเร็จ', 0, 2), _buildTab('ยกเลิก', 1, 3)]),
            ),
            const SizedBox(height: 24),

            const Text('02/07/2025', style: TextStyle(fontWeight: FontWeight.bold)),

            _buildCardItem(),
          ],
        ),
      ),
    );
  }
}
