import 'package:flutter/material.dart';

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
          'trackingNo': 'YT7518613489991',
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
        title: const Text('ตามหาเจ้าของ', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔍 ช่องค้นหา
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: const TextField(decoration: InputDecoration(hintText: 'ค้นหาขนส่งฉัน', border: InputBorder.none)),
          ),
          const SizedBox(height: 16),

          // 🔄 แสดงรายการแบ่งตามวันที่
          ...trackingData.map((section) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section['date'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                          children: const [
                            Icon(Icons.local_shipping, color: Colors.blue),
                            SizedBox(width: 6),
                            Text('เลขขนส่งวัน ', style: TextStyle(fontSize: 14)),
                            // Tracking number ดึงทีหลัง
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 28),
                          child: Text(item['trackingNo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        const SizedBox(height: 8),
                        const Padding(padding: EdgeInsets.only(left: 28), child: Text('รูปภาพข้างของ', style: TextStyle(fontSize: 14))),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 28),
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
