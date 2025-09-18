import 'package:flutter/material.dart';
import 'package:gcargo/bill/documentDetailPage.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/parcel/widgets/date_range_picker_widget.dart';
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
  final TextEditingController _dateController = TextEditingController();

  // Date filter variables
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _dateController.text = 'เลือกช่วงวันที่';
    // Call getBills when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getBills();
    });
  }

  // Status mapping from API to Thai (เหลือ 3 สถานะ)
  String _getStatusInThai(String? apiStatus) {
    switch (apiStatus) {
      case 'pending':
      case 'processing':
      case 'awaiting_payment':
      case 'in_transit':
      case 'arrived_china_warehouse':
      case 'arrived_thailand_warehouse':
        return 'รอดำเนินการ';
      case 'completed':
      case 'delivered':
      case 'paid':
        return 'สำเร็จ';
      default:
        return 'รอดำเนินการ';
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
    return Obx(() {
      // แสดง loading
      if (orderController.isLoading.value) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.grey.shade50,
            title: const Text('ค่าขนส่ง', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      // ใช้ API data จาก OrderController
      final displayOrders = <Map<String, dynamic>>[];
      for (var bill in orderController.billing) {
        displayOrders.add({
          'id': bill.id ?? 0, // เพิ่ม id สำหรับส่งไป detail page
          'date': _formatDate(bill.in_thai_date ?? bill.created_at?.toString()),
          'docNo': bill.code ?? '',
          'status': _getStatusInThai(bill.status),
          'amount': double.tryParse(bill.total_amount ?? '0') ?? 0.0,
        });
      }

      // ✅ กรองตามสถานะและวันที่
      var filteredData = selectedStatus == 'ทั้งหมด' ? displayOrders : displayOrders.where((e) => e['status'] == selectedStatus).toList();

      // กรองตามช่วงวันที่
      if (startDate != null && endDate != null) {
        filteredData =
            filteredData.where((item) {
              final itemDateStr = item['date'] as String;
              if (itemDateStr.isEmpty) return false;

              try {
                final itemDate = DateFormat('dd/MM/yyyy').parse(itemDateStr);
                final startOfDay = DateTime(startDate!.year, startDate!.month, startDate!.day);
                final endOfDay = DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59);

                return itemDate.isAfter(startOfDay.subtract(const Duration(days: 1))) && itemDate.isBefore(endOfDay.add(const Duration(days: 1)));
              } catch (e) {
                return false;
              }
            }).toList();
      }

      // ✅ นับแต่ละสถานะ (เหลือ 3 สถานะ)
      final int totalCount = displayOrders.length;
      final int pendingCount = displayOrders.where((e) => e['status'] == 'รอดำเนินการ').length;
      final int successCount = displayOrders.where((e) => e['status'] == 'สำเร็จ').length;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ค่าขนส่ง', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
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
        body: SafeArea(
          child: Column(
            children: [
              // 🔹 Header Row: ค่าขนส่ง + ช่องเลือกวันที่
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              //   child: Row(
              //     children: [
              //       // 🔙 ปุ่มกลับ
              //       GestureDetector(
              //         onTap: () => Navigator.pop(context),
              //         child: Container(
              //           width: 36,
              //           height: 36,
              //           decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              //           child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
              //         ),
              //       ),
              //       Expanded(
              //         child: GestureDetector(
              //           onTap: () {
              //             // TODO: Add date range picker
              //             Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentDetailPage()));
              //           },
              //           child: Text('ค่าขนส่ง', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              //         ),
              //       ),
              //       DateRangePickerWidget(
              //         controller: _dateController,
              //         hintText: 'เลือกช่วงวันที่',
              //         onDateRangeSelected: (DateTimeRange? picked) {
              //           if (picked != null) {
              //             setState(() {
              //               startDate = picked.start;
              //               endDate = picked.end;
              //             });
              //           }
              //         },
              //       ),
              //     ],
              //   ),
              // ),

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
                            _buildChip('รอดำเนินการ', count: pendingCount),
                            _buildChip('สำเร็จ', count: successCount),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 🔹 Group by date
                      if (filteredData.isEmpty)
                        const Center(child: Text('ไม่พบข้อมูล', style: TextStyle(fontSize: 16, color: Colors.grey)))
                      else
                        ..._buildGroupedList(filteredData),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }); // ปิด Obx
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
        //Navigator.push(context, MaterialPageRoute(builder: (_) => TransportCostDetailPage(paper_number: item['docNo'], billId: item['id'])));
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
