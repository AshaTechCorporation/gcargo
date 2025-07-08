import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  String selectedFilter = 'ทั้งหมด';
  final List<String> filters = ['ทั้งหมด', 'รอชำระ', 'ชำระแล้ว', 'ยกเลิก'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('บิลของฉัน', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list, color: Colors.black))],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedFilter == filter;
                return Container(
                  margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: kButtonColor.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? kButtonColor : Colors.grey.shade600,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(color: isSelected ? kButtonColor : Colors.grey.shade300),
                  ),
                );
              },
            ),
          ),

          // Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kButtonColor, kButtonColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('สรุปยอดเงิน', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('รอชำระ', '1,250', '฿', Colors.orange),
                    _buildSummaryItem('ชำระแล้ว', '8,750', '฿', Colors.green),
                    _buildSummaryItem('ทั้งหมด', '10,000', '฿', Colors.white),
                  ],
                ),
              ],
            ),
          ),

          // Bills List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildBillCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String amount, String currency, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currency, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(amount, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildBillCard(int index) {
    final List<Map<String, dynamic>> bills = [
      {
        'id': 'INV-2024-001',
        'parcelId': 'GC001234567',
        'amount': '120.00',
        'status': 'ชำระแล้ว',
        'statusColor': Colors.green,
        'date': '15 ธ.ค. 2567',
        'dueDate': '20 ธ.ค. 2567',
        'service': 'ส่งพัสดุ Express',
      },
      {
        'id': 'INV-2024-002',
        'parcelId': 'GC001234568',
        'amount': '85.00',
        'status': 'รอชำระ',
        'statusColor': Colors.orange,
        'date': '14 ธ.ค. 2567',
        'dueDate': '19 ธ.ค. 2567',
        'service': 'ส่งพัสดุ Standard',
      },
      {
        'id': 'INV-2024-003',
        'parcelId': 'GC001234569',
        'amount': '200.00',
        'status': 'ชำระแล้ว',
        'statusColor': Colors.green,
        'date': '13 ธ.ค. 2567',
        'dueDate': '18 ธ.ค. 2567',
        'service': 'ส่งพัสดุ Premium',
      },
    ];

    final bill = bills[index % bills.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(bill['id'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: bill['statusColor'].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(bill['status'], style: TextStyle(fontSize: 12, color: bill['statusColor'], fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(bill['service'], style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text('รหัสพัสดุ: ${bill['parcelId']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('วันที่ออกบิล', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  Text(bill['date'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('จำนวนเงิน', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  Text('฿${bill['amount']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kButtonColor)),
                ],
              ),
            ],
          ),
          if (bill['status'] == 'รอชำระ') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kButtonColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('ดูรายละเอียด', style: TextStyle(color: kButtonColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('ชำระเงิน', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kButtonColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('ดูรายละเอียด', style: TextStyle(color: kButtonColor)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
