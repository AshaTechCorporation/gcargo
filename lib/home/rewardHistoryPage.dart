import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class RewardHistoryPage extends StatefulWidget {
  const RewardHistoryPage({super.key});

  @override
  State<RewardHistoryPage> createState() => _RewardHistoryPageState();
}

class _RewardHistoryPageState extends State<RewardHistoryPage> {
  int selectedTabIndex = 0;

  final List<Map<String, dynamic>> rewardHistory = [
    {
      'date': '02/07/2025',
      'items': [
        {'title': 'ทองคำแท่ง aurora หนัก 0.2 บาท\nหนัก 0.2 บาท หนัก 0.2  หนัก 0.2', 'points': '100', 'status': 'สำเร็จ'},
        {'title': 'ทองคำแท่ง aurora หนัก 0.2 บาท\nหนัก 0.2 บาท หนัก 0.2  หนัก 0.2', 'points': '100', 'status': 'ยกเลิก'},
      ],
    },
    {
      'date': '03/07/2025',
      'items': [
        {'title': 'ทองคำแท่ง aurora หนัก 1 บาท', 'points': '20000', 'status': 'รอตรวจสอบ'},
      ],
    },
    {
      'date': '04/07/2025',
      'items': [
        {'title': 'ทองคำแท่ง aurora หนัก 0.5 บาท', 'points': '5000', 'status': 'รอดำเนินการ'},
      ],
    },
  ];

  final List<Map<String, dynamic>> filters = [
    {'label': 'ทั้งหมด'},
    {'label': 'รอตรวจสอบ'},
    {'label': 'รอดำเนินการ'},
    {'label': 'สำเร็จ'},
    {'label': 'ยกเลิก'},
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'สำเร็จ':
        return Colors.green;
      case 'ยกเลิก':
        return Colors.red;
      default:
        return kButtonColor;
    }
  }

  Widget _buildFilterTabs() {
    // คำนวณจำนวนของแต่ละสถานะ
    Map<String, int> statusCounts = {
      'ทั้งหมด': rewardHistory.fold(0, (sum, entry) => sum + (entry['items'] as List).length),
      'รอตรวจสอบ': rewardHistory.fold(0, (sum, entry) => sum + (entry['items'] as List).where((i) => i['status'] == 'รอตรวจสอบ').length),
      'รอดำเนินการ': rewardHistory.fold(0, (sum, entry) => sum + (entry['items'] as List).where((i) => i['status'] == 'รอดำเนินการ').length),
      'สำเร็จ': rewardHistory.fold(0, (sum, entry) => sum + (entry['items'] as List).where((i) => i['status'] == 'สำเร็จ').length),
      'ยกเลิก': rewardHistory.fold(0, (sum, entry) => sum + (entry['items'] as List).where((i) => i['status'] == 'ยกเลิก').length),
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = selectedTabIndex == index;
          final label = filters[index]['label'];
          final count = statusCounts[label] ?? 0;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTabIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? kButtonColor : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kButtonColor),
              ),
              child: Row(
                children: [
                  Text(label, style: TextStyle(color: selected ? Colors.white : kButtonColor, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: selected ? Colors.white : kButtonColor, shape: BoxShape.circle),
                    child: Text(
                      count.toString(),
                      style: TextStyle(color: selected ? kButtonColor : Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHistoryList() {
    final filter = filters[selectedTabIndex]['label'];

    List<Map<String, dynamic>> filteredList =
        rewardHistory
            .map((entry) {
              final filteredItems =
                  (entry['items'] as List).where((item) {
                    if (filter == 'ทั้งหมด') return true;
                    return item['status'] == filter;
                  }).toList();

              return {'date': entry['date'], 'items': filteredItems};
            })
            .where((entry) => entry['items'].isNotEmpty)
            .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children:
          filteredList.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry['date'], style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...List.generate(entry['items'].length, (i) {
                  final item = entry['items'][i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/images/g14.png', width: 64, height: 64),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF001C40))),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                child: Text(item['points'], style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(item['status'], style: TextStyle(color: _getStatusColor(item['status']), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
              ],
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
            const Text('ประวัติการแลกของรางวัล', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
      body: Column(children: [const SizedBox(height: 8), _buildFilterTabs(), const Divider(height: 20), Expanded(child: _buildHistoryList())]),
    );
  }
}
