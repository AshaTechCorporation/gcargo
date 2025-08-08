import 'package:flutter/material.dart';
import 'package:gcargo/bill/documentDetailPage.dart';
import 'package:gcargo/bill/transportCostDetailPage.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransportCostPage extends StatefulWidget {
  const TransportCostPage({super.key});

  @override
  State<TransportCostPage> createState() => _TransportCostPageState();
}

class _TransportCostPageState extends State<TransportCostPage> {
  String selectedStatus = 'ทั้งหมด';
  final OrderController orderController = Get.put(OrderController());

  // Mock data สำหรับแสดงผล
  final List<Map<String, dynamic>> mockTransportData = [
    {'date': '2025-01-31', 'docNo': 'TC001', 'status': 'สำเร็จ', 'amount': 1250.00},
    {'date': '2025-01-31', 'docNo': 'TC002', 'status': 'กำลังตรวจสอบ', 'amount': 890.50},
    {'date': '2025-01-30', 'docNo': 'TC003', 'status': 'ยกเลิก', 'amount': 0.00},
    {'date': '2025-01-30', 'docNo': 'TC004', 'status': 'สำเร็จ', 'amount': 2100.75},
    {'date': '2025-01-29', 'docNo': 'TC005', 'status': 'กำลังตรวจสอบ', 'amount': 675.25},
    {'date': '2025-01-29', 'docNo': 'TC006', 'status': 'สำเร็จ', 'amount': 1450.00},
    {'date': '2025-01-28', 'docNo': 'TC007', 'status': 'กำลังตรวจสอบ', 'amount': 980.00},
    {'date': '2025-01-28', 'docNo': 'TC008', 'status': 'ยกเลิก', 'amount': 0.00},
    {'date': '2025-01-27', 'docNo': 'TC009', 'status': 'สำเร็จ', 'amount': 1800.50},
    {'date': '2025-01-27', 'docNo': 'TC010', 'status': 'กำลังตรวจสอบ', 'amount': 1125.75},
  ];

  @override
  void initState() {
    super.initState();
    // Call getDeliveryOrders when page loads
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   orderController.getDeliveryOrders();
    // });
  }

  // Status mapping from API to Thai
  String _getStatusInThai(String? apiStatus) {
    switch (apiStatus) {
      case 'arrived_china_warehouse':
        return 'ถึงคลังจีน';
      case 'in_transit':
        return 'กำลังขนส่ง';
      case 'arrived_thailand_warehouse':
        return 'ถึงคลังไทย';
      case 'awaiting_payment':
        return 'รอชำระเงิน';
      case 'delivered':
        return 'สำเร็จ';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  // Format date from API
  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ mock data แทน API data (ยังคงฟังก์ชัน API ไว้)
    final displayOrders = List<Map<String, dynamic>>.from(mockTransportData);

    // TODO: ใช้ API data แทน mock data
    // final displayOrders = <Map<String, dynamic>>[];
    // for (var legalImport in orderController.deilveryOrders) {
    //   if (legalImport.delivery_orders != null && legalImport.delivery_orders!.isNotEmpty) {
    //     for (var deliveryOrder in legalImport.delivery_orders!) {
    //       displayOrders.add({
    //         'date': _formatDate(deliveryOrder.date),
    //         'docNo': deliveryOrder.code ?? '',
    //         'status': _getStatusInThai(deliveryOrder.status),
    //         'amount': 0.0,
    //       });
    //     }
    //   }
    // }

    // ✅ กรองตามสถานะ
    final filteredData = selectedStatus == 'ทั้งหมด' ? displayOrders : displayOrders.where((e) => e['status'] == selectedStatus).toList();

    // ✅ นับแต่ละสถานะ
    final int totalCount = displayOrders.length;
    final int pendingCount = displayOrders.where((e) => e['status'] == 'กำลังตรวจสอบ').length;
    final int successCount = displayOrders.where((e) => e['status'] == 'สำเร็จ').length;
    final int cancelledCount = displayOrders.where((e) => e['status'] == 'ยกเลิก').length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Header Row: ค่าขนส่ง + ช่องเลือกวันที่
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // 🔙 ปุ่มกลับ
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                    ),
                  ),
                  const Expanded(child: Text('ค่าขนส่ง', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  GestureDetector(
                    onTap: () {
                      // TODO: Add date range picker
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentDetailPage()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/icons/calendar_icon.png', width: 18, height: 18),
                          const SizedBox(width: 8),
                          const Text('01/01/2024 - 01/07/2025', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Search Field
                    TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: 'ค้นหาเลขที่เอกสาร',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔹 Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChip('ทั้งหมด', count: totalCount),
                          _buildChip('กำลังตรวจสอบ', count: pendingCount),
                          _buildChip('สำเร็จ', count: successCount),
                          _buildChip('ยกเลิก', count: cancelledCount),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 🔹 Group by date
                    ..._buildGroupedList(filteredData),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, {int? count}) {
    final bool selected = selectedStatus == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: selected ? kBackgroundTextColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? kBackgroundTextColor : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(color: selected ? kBackgroundTextColor : Colors.black, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(color: selected ? kCicleColor : Colors.grey.shade300, shape: BoxShape.circle),
                child: Center(child: Text('$count', style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.black))),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 🔹 Group by date
  List<Widget> _buildGroupedList(List<Map<String, dynamic>> data) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (var item in data) {
      grouped.putIfAbsent(item['date'], () => []).add(item);
    }

    return grouped.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...entry.value.map((e) => _buildDocumentCard(e)),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Widget _buildDocumentCard(Map<String, dynamic> item) {
    final String status = item['status'];
    final String statusColor =
        status == 'สำเร็จ'
            ? 'green'
            : status == 'ยกเลิก'
            ? 'red'
            : status == 'กำลังตรวจสอบ'
            ? 'orange'
            : 'black';

    return InkWell(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (_) => TransportCostDetailPage(paper_number: item['docNo'])));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/icons/menu-board-blue.png', width: 24, height: 24),
                const SizedBox(width: 8),
                Expanded(child: Text('เลขที่เอกสาร ${item['docNo']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                Text(
                  item['status'],
                  style: TextStyle(
                    color:
                        statusColor == 'green'
                            ? Colors.green
                            : statusColor == 'red'
                            ? Colors.red
                            : statusColor == 'orange'
                            ? Colors.orange
                            : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('รวมค่าขนส่งจีนไทย', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('${item['amount'].toStringAsFixed(2)} ฿', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
