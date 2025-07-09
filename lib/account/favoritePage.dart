import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart'; // ✅ ต้องมี kButtonColor

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = [
      {'image': 'assets/images/unsplash0.png', 'title': 'เสื้อแขนสั้น', 'desc': 'เสื้อแขนสั้นไว้ใส่ไปเดินเล่นลายกราฟิก สำหรับผู้ชาย', 'price': '฿10'},
      {
        'image': 'assets/images/unsplash1.png',
        'title': 'รองเท้าบาส',
        'desc': 'รองเท้าบาสไว้ใส่เล่นกีฬาบาสเก็ตบอลเหมะสำหรับพื้นไม้ปาเก้',
        'price': '฿100',
      },
      {'image': 'assets/images/unsplash3.png', 'title': 'นาฬิกาข้อมือ', 'desc': 'นาฬิกาแฟชั่น ดีไซน์ล้ำ ทันสมัย เท่ทุกมุมมอง', 'price': '฿999'},
      {
        'image': 'assets/images/unsplash2.png',
        'title': 'เสื้อคลุม',
        'desc': 'เสื้อฮู้ดฟรีไซน์มีหลายโทนสีสามารถใส่ได้ทั้งชาย และหญิง กันลม กันฝน ใส่เดินเที่ยวก็เท่',
        'price': '฿499',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('รายการโปรด', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: GridView.builder(
          itemCount: favorites.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            final item = favorites[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Image + heart
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.asset(item['image']!, height: 120, width: double.infinity, fit: BoxFit.cover),
                      ),
                      Positioned(top: 8, right: 8, child: Icon(Icons.favorite, color: kButtonColor, size: 20)),
                    ],
                  ),
                  // 🔹 Details
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 6),
                        Text(
                          item['desc']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        Text(item['price']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
