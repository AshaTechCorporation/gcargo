import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  String selectedStatus = 'ทั้งหมด';

  final List<String> statusList = ['ทั้งหมด', 'รอตรวจสอบ', 'รอชำระเงิน', 'รอดำเนินการ', 'สำเร็จ', 'ยกเลิก'];

  final List<Map<String, dynamic>> orders = [
    {'date': '02/07/2025', 'status': 'ยกเลิก', 'code': '00001', 'transport': 'ขนส่งทางเรือ', 'total': 550.0},
    {'date': '01/07/2025', 'status': 'สำเร็จ', 'code': '00001', 'transport': 'ขนส่งทางเรือ', 'total': 550.0},
  ];

  @override
  Widget build(BuildContext context) {
    final groupedOrders = <String, List<Map<String, dynamic>>>{};
    for (var order in orders) {
      if (selectedStatus != 'ทั้งหมด' && order['status'] != selectedStatus) continue;
      groupedOrders.putIfAbsent(order['date'], () => []).add(order);
    }

    final Map<String, int> statusCounts = {
      for (var status in statusList) status: status == 'ทั้งหมด' ? orders.length : orders.where((order) => order['status'] == status).length,
    };

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ออเดอร์', style: TextStyle(color: Colors.black)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Image.asset('assets/icons/calendar_icon.png', width: 18),
                  const SizedBox(width: 6),
                  const Text('1/01/2024 - 01/07/2025', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'ค้นหาเลขที่บิล',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ Status Tabs with proper count and background circle
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: statusList.length,
                itemBuilder: (_, index) {
                  final status = statusList[index];
                  final isSelected = status == selectedStatus;
                  final count = statusCounts[status] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedStatus = status),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Text(
                              status,
                              style: TextStyle(
                                color: isSelected ? Colors.blue : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(color: isSelected ? Colors.blue : Colors.grey.shade300, shape: BoxShape.circle),
                              child: Center(child: Text('$count', style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children:
                    groupedOrders.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          ...entry.value.map((order) => _buildOrderCard(order)).toList(),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isCancelled = order['status'] == 'ยกเลิก';
    final isSuccess = order['status'] == 'สำเร็จ';
    final statusColor =
        isCancelled
            ? Colors.red
            : isSuccess
            ? Colors.green
            : Colors.orange;
    final borderColor =
        isCancelled
            ? Colors.red.shade100
            : isSuccess
            ? Colors.green.shade100
            : Colors.grey.shade300;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/icons/task-square.png', width: 20),
                  const SizedBox(width: 8),
                  Text('เลขบิลสั่งซื้อ ${order['code']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Text(order['status'], style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('การขนส่ง'), Text(order['transport'])]),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text('สรุปราคาสินค้า'), Text('${order['total'].toStringAsFixed(2)}฿')],
          ),
        ],
      ),
    );
  }
}
