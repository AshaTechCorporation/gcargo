import 'package:flutter/material.dart';

class ExchangeRatePage extends StatelessWidget {
  const ExchangeRatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> exchangeRates = [
      {'title': 'กรมศุลกากร', 'price': '4.80'},
      {'title': 'กรมสรรพสามิต', 'price': '4.78'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('อัตราแลกเปลี่ยน', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // 🔹 หัวตาราง
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('อัตราแลกเปลี่ยน', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                Expanded(
                  flex: 1,
                  child: Align(alignment: Alignment.centerRight, child: Text('ราคา', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),

          // 🔹 ข้อมูลรายการ
          ...exchangeRates.map(
            (item) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(item['title']!, style: const TextStyle(fontSize: 14))),
                      Expanded(
                        flex: 1,
                        child: Align(alignment: Alignment.centerRight, child: Text(item['price']!, style: const TextStyle(fontSize: 14))),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
