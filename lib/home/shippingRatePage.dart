import 'package:flutter/material.dart';

class ShippingRatePage extends StatefulWidget {
  const ShippingRatePage({super.key});

  @override
  State<ShippingRatePage> createState() => _ShippingRatePageState();
}

class _ShippingRatePageState extends State<ShippingRatePage> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('อัตราค่าขนส่ง', style: TextStyle(color: Colors.black)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          tabs: const [Tab(text: 'การรถ'), Tab(text: 'การเรือ')],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [_buildTabContent(_mockCarData), _buildTabContent(_mockBoatData)]),
    );
  }

  Widget _buildTabContent(List<Map<String, dynamic>> data) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final section = data[index];
        final title = section['title'] as String;
        final rows = section['rows'] as List<Map<String, String>>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 ชื่อหัวข้อ
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),

            // 🔸 หัวตาราง
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0)))),
              child: Row(
                children: const [
                  Expanded(flex: 2, child: Text('ประเภทสินค้า', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  Expanded(flex: 1, child: Center(child: Text('กิโลกรัม', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('เปรียบเทียบ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),

            // 🔸 รายการข้อมูล
            ...rows.map((row) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0)))),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(row['type'] ?? '', style: const TextStyle(fontSize: 14))),
                    Expanded(flex: 1, child: Center(child: Text(row['kg'] ?? '', style: const TextStyle(fontSize: 14)))),
                    Expanded(
                      flex: 1,
                      child: Align(alignment: Alignment.centerRight, child: Text(row['price'] ?? '', style: const TextStyle(fontSize: 14))),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  final List<Map<String, dynamic>> _mockCarData = [
    {
      'title': 'ฟรีออเดอร์',
      'rows': [
        {'type': 'ทั่วไป', 'kg': '55', 'price': '7,900'},
        {'type': 'มอก', 'kg': '55', 'price': '8,000'},
        {'type': 'อย', 'kg': '45', 'price': '8,800'},
        {'type': 'ของหนัก', 'kg': '35', 'price': '-'},
      ],
    },
    {
      'title': 'แบบออเดอร์เดียว',
      'rows': [
        {'type': 'ทั่วไป', 'kg': '55', 'price': '7,900'},
        {'type': 'มอก', 'kg': '65', 'price': '8,000'},
        {'type': 'อย', 'kg': '45', 'price': '8,800'},
        {'type': 'ของหนัก', 'kg': '35', 'price': '-'},
      ],
    },
  ];

  final List<Map<String, dynamic>> _mockBoatData = [
    {
      'title': 'ฟรีออเดอร์',
      'rows': [
        {'type': 'ทั่วไป', 'kg': '38', 'price': '5,200'},
        {'type': 'มอก', 'kg': '50', 'price': '5,800'},
        {'type': 'อย', 'kg': '45', 'price': '8,800'},
        {'type': 'ของหนัก', 'kg': '25', 'price': '-'},
      ],
    },
    {
      'title': 'แบบออเดอร์เดียว',
      'rows': [
        {'type': 'ทั่วไป', 'kg': '38', 'price': '5,200'},
        {'type': 'มอก', 'kg': '50', 'price': '5,800'},
        {'type': 'อย', 'kg': '45', 'price': '8,800'},
        {'type': 'ของหนัก', 'kg': '25', 'price': '-'},
      ],
    },
  ];
}
