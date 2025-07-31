import 'package:flutter/material.dart';
import 'package:gcargo/bill/orderDetailPage.dart';
import 'package:gcargo/constants.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String selectedStatus = 'ทั้งหมด';
  final TextEditingController _dateController = TextEditingController(text: '1/01/2024 - 01/07/2025');

  final List<Map<String, dynamic>> allOrders = [
    {'date': '01/07/2025', 'code': '00001', 'status': 'สำเร็จ', 'total': 550.00, 'box': 2, 'type': 'แบบทั่วไป', 'note': 'ทดสอบระบบ'},
    {'date': '30/06/2025', 'code': '00002', 'status': 'ยกเลิก', 'total': 230.00, 'box': 1, 'type': 'แบบพิเศษ', 'note': 'ไม่มีหมายเหตุ'},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredOrders = selectedStatus == 'ทั้งหมด' ? allOrders : allOrders.where((o) => o['status'] == selectedStatus).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ประวัติคำสั่งสินค้า', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(width: 20),
            Expanded(
              child: TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () async {
                  DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2030),
                    initialDateRange: DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2025, 7, 1)),
                  );
                  if (picked != null) {
                    String formatted = '${DateFormat('dd/MM/yyyy').format(picked.start)} - ${DateFormat('dd/MM/yyyy').format(picked.end)}';
                    setState(() {
                      _dateController.text = formatted;
                    });
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: Padding(padding: const EdgeInsets.all(12.0), child: Image.asset('assets/icons/calendar_icon.png', width: 18)),
                  hintText: 'เลือกช่วงวันที่',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔎 Search
            Container(
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
            const SizedBox(height: 12),

            // 🟢 Status filter
            Row(
              children: [
                _buildStatusChip('ทั้งหมด', 2),
                const SizedBox(width: 8),
                _buildStatusChip('สำเร็จ', 1),
                const SizedBox(width: 8),
                _buildStatusChip('ยกเลิก', 1),
              ],
            ),
            const SizedBox(height: 16),

            // 🧾 Order List
            ...filteredOrders.map((order) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order['date'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildOrderCard(order),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // 🔘 Status Chip Widget (ดีไซน์เหมือน OrderStatusPage)
  Widget _buildStatusChip(String label, int count) {
    final bool isSelected = selectedStatus == label;
    return InkWell(
      onTap: () => setState(() => selectedStatus = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? kBackgroundTextColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? kBackgroundTextColor : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(color: isSelected ? kBackgroundTextColor : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
            const SizedBox(width: 6),
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(color: isSelected ? kCicleColor : Colors.grey.shade300, shape: BoxShape.circle),
              child: Center(child: Text('$count', style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailPage(status: order['status']))),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E5E5))),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 บรรทัด 1: ไอคอน + เลขบิล + สถานะ
            Row(
              children: [
                Image.asset('assets/icons/task-square.png', height: 24),
                const SizedBox(width: 10),
                Expanded(child: Text('เลขบิลสั่งซื้อ ${order['code']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        order['status'] == 'สำเร็จ'
                            ? const Color(0xFFEAF7E9)
                            : order['status'] == 'ยกเลิก'
                            ? const Color(0xFFFFEDED)
                            : const Color(0xFFFFF4DB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          order['status'] == 'สำเร็จ'
                              ? const Color(0xFF219653)
                              : order['status'] == 'ยกเลิก'
                              ? const Color(0xFFEB5757)
                              : const Color(0xFFFD7E14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🔹 บรรทัด 2: จำนวนกล่อง
            Text('${order['box']} กล่อง (${order['type']})', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 6),

            // 🔹 บรรทัด 3: หมายเหตุ
            Text('หมายเหตุ: ${order['note']}', style: const TextStyle(fontSize: 13)),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // 🔹 บรรทัด 4: สรุปราคา
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('สรุปราคาสินค้า', style: TextStyle(fontSize: 13)),
                Text('${order['total'].toStringAsFixed(2)}฿', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
