import 'package:flutter/material.dart';
import 'package:gcargo/parcel/POOrderDetailPage.dart';
import 'package:gcargo/widgets/RemarkDialog.dart';
import 'package:intl/intl.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  String selectedStatus = 'ทั้งหมด';
  TextEditingController _dateController = TextEditingController();

  final List<String> statusList = ['ทั้งหมด', 'รอตรวจสอบ', 'รอชำระเงิน', 'รอดำเนินการ', 'สำเร็จ', 'ยกเลิก'];

  final List<Map<String, dynamic>> orders = [
    {'date': '02/07/2025', 'status': 'ยกเลิก', 'code': '00001', 'transport': 'ขนส่งทางเรือ', 'total': 550.0},
    {'date': '01/07/2025', 'status': 'สำเร็จ', 'code': '00002', 'transport': 'ขนส่งทางเรือ', 'total': 550.0},
    {'date': '01/07/2025', 'status': 'รอตรวจสอบ', 'code': '00003', 'transport': 'ขนส่งทางเรือ', 'total': 550.0},
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = '01/01/2024 - 01/07/2025'; // ค่าเริ่มต้น
  }

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
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ออเดอร์', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'ค้นหาเลขที่บิล',
                      filled: true,
                      hintStyle: TextStyle(fontSize: 14),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

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
    final status = order['status'];
    final isCancelled = status == 'ยกเลิก';
    final isSuccess = status == 'สำเร็จ';
    final isPending = status == 'รอตรวจสอบ';

    final statusColor =
        isCancelled
            ? Colors.red
            : isSuccess
            ? Colors.green
            : isPending
            ? Colors.orange
            : Colors.grey;

    final borderColor =
        isCancelled
            ? Colors.red.shade100
            : isSuccess
            ? Colors.green.shade100
            : isPending
            ? Colors.orange.shade100
            : Colors.grey.shade300;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const POOrderDetailPage())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('assets/icons/task-square.png', width: 20),
                    const SizedBox(width: 8),
                    Text('เลขบิลสั่งซื้อ ${order['code']}', style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
                  ],
                ),
                Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),

            // 🔸 รอตรวจสอบจะมีแถวเพิ่ม
            if (isPending) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('การสั่งซื้อ', style: TextStyle(fontSize: 16)), Text('คำสั่งซื้อของเชล', style: TextStyle(fontSize: 16))],
              ),
              SizedBox(height: 4),
            ],

            // 🔹 ปกติ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('การขนส่ง', style: TextStyle(fontSize: 16)), Text(order['transport'], style: TextStyle(fontSize: 16))],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('สรุปราคาสินค้า', style: TextStyle(fontSize: 16)),
                Text('${order['total'].toStringAsFixed(2)}฿', style: TextStyle(fontSize: 16)),
              ],
            ),

            // 🔹 ปุ่มเฉพาะสถานะรอตรวจสอบ
            if (isPending) ...[
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      print(55555);
                      showDialog(
                        context: context,
                        builder:
                            (_) => RemarkDialog(
                              initialText: '', // หรือค่าที่มีอยู่
                              onSave: (text) {
                                print('บันทึกข้อความ: $text');
                                // ทำอย่างอื่นต่อ เช่นส่งไปเซิร์ฟเวอร์
                              },
                            ),
                      );
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.grey),
                    child: const Text('ยกเลิก'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3C72), // ✅ kButtonColor
                    ),
                    child: Text('สั่งซื้ออีกครั้ง', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
