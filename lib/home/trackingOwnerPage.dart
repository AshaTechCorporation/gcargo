import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class TrackingOwnerPage extends StatelessWidget {
  const TrackingOwnerPage({super.key});

  final List<Map<String, dynamic>> trackingData = const [
    {
      'date': '02/07/2025',
      'items': [
        {
          'trackingNo': 'YT7518613489991',
          'images': ['assets/images/image11.png', 'assets/images/image14.png'],
        },
      ],
    },
    {
      'date': '01/07/2025',
      'items': [
        {
          'trackingNo': 'YT7518613489992',
          'images': ['assets/images/image11.png', 'assets/images/image14.png'],
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black), onPressed: () => Navigator.pop(context)),
            const Text('ตามหาเจ้าของ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const Spacer(),
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(child: Text('ประวัติ', style: TextStyle(color: kButtonColor, fontSize: 16, fontWeight: FontWeight.w500))),
            ),
          ],
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 4),

          // 🔍 ช่องค้นหา
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(25)),
            child: const Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: 'ค้นหาเลขขนส่งฉัน', hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 🔴 แจ้งเตือน
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: const Text(
              'บริษัทจะจัดเก็บสินค้าที่ไม่มีผู้แสดงความเป็นเจ้าของไว้ไม่เกิน 30 วัน หากพ้นกำหนดโดยไม่มีการยืนยัน บริษัทขอสงวนสิทธิ์ในการดำเนินการตามดุลยพินิจ\nและไม่รับผิดชอบต่อความเสียหายที่อาจเกิดขึ้น',
              style: TextStyle(color: Colors.red),
            ),
          ),

          // 📦 รายการตามวัน
          ...trackingData.map((section) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section['date'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...List.generate(section['items'].length, (index) {
                  final item = section['items'][index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/icons/box-search.png', width: 24, height: 24),
                            const SizedBox(width: 8),
                            const Text('เลขขนส่งวัน', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(item['trackingNo'], style: const TextStyle(fontSize: 14, color: kButtonColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Padding(padding: EdgeInsets.only(left: 32), child: Text('รูปภาพอ้างอิง', style: TextStyle(fontSize: 14))),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Row(
                            children:
                                (item['images'] as List<String>).map((imgPath) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.asset(imgPath, width: 60, height: 60, fit: BoxFit.cover),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
