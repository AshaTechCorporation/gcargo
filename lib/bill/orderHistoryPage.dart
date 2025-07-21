import 'package:flutter/material.dart';
import 'package:gcargo/bill/orderDetailPage.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String selectedStatus = 'ทั้งหมด';

  final List<Map<String, dynamic>> allOrders = [
    {'date': '01/07/2025', 'code': '00001', 'status': 'สำเร็จ', 'total': 550.00},
    {'date': '30/06/2025', 'code': '00002', 'status': 'ยกเลิก', 'total': 230.00},
    {'date': '29/06/2025', 'code': '00003', 'status': 'รอดำเนินการ', 'total': 120.00},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredOrders = selectedStatus == 'ทั้งหมด' ? allOrders : allOrders.where((o) => o['status'] == selectedStatus).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ✅ Custom Header
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
                  const Text('ประวัติคำสั่งสินค้า', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Image.asset('assets/icons/calendar_icon.png', height: 18),
                        const SizedBox(width: 6),
                        const Text('1/01/2024 - 01/07/2025', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🔎 Search
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(10)),
                      child: const Row(
                        children: [
                          Icon(Icons.search, size: 20, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('ค้นหาเลขเลขบิลสั่งซื้อ', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🟢 Status filter
              Row(
                children: [
                  _buildStatusChip('ทั้งหมด', 3),
                  const SizedBox(width: 8),
                  _buildStatusChip('สำเร็จ', 1),
                  const SizedBox(width: 8),
                  _buildStatusChip('ยกเลิก', 1),
                ],
              ),
              const SizedBox(height: 16),

              // 🧾 Order List
              Expanded(
                child: ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order['date'], style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderDetailPage())),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE5E5E5)),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset('assets/icons/task-square.png', height: 24),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text('เลขบิลสั่งซื้อ ${order['code']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                      Text(
                                        order['status'],
                                        style: TextStyle(
                                          color:
                                              order['status'] == 'สำเร็จ'
                                                  ? Colors.green
                                                  : order['status'] == 'ยกเลิก'
                                                  ? Colors.red
                                                  : Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('สรุปราคาสินค้า'),
                                      Text('${order['total'].toStringAsFixed(2)}฿', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔘 Status Chip Widget
  Widget _buildStatusChip(String label, int count) {
    final bool isSelected = selectedStatus == label;
    return InkWell(
      onTap: () {
        setState(() {
          selectedStatus = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFFCADDFD) : const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
