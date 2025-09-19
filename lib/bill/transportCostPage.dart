import 'package:flutter/material.dart';
import 'package:gcargo/bill/documentDetailPage.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
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
  late LanguageController languageController;
  String selectedStatus = 'all';
  final OrderController orderController = Get.put(OrderController());
  final TextEditingController _dateController = TextEditingController();

  // Date filter variables
  DateTime? startDate;
  DateTime? endDate;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'transport_cost': 'ค่าขนส่ง',
        'all': 'ทั้งหมด',
        'processing': 'รอดำเนินการ',
        'completed': 'สำเร็จ',
        'select_date_range': 'เลือกช่วงวันที่',
        'search_document': 'ค้นหาเลขที่เอกสาร',
        'no_documents_found': 'ไม่พบเอกสาร',
        'no_documents_status': 'ไม่มีเอกสารในสถานะ',
        'documents_will_show_here': 'เมื่อมีเอกสาร จะแสดงที่นี่',
        'document_number': 'เลขที่เอกสาร',
        'amount': 'จำนวนเงิน',
        'status': 'สถานะ',
        'view_details': 'ดูรายละเอียด',
        'baht': 'บาท',
        'try_again': 'ลองใหม่',
        'loading': 'กำลังโหลด...',
        'error': 'เกิดข้อผิดพลาด',
        'total_amount': 'ยอดรวม',
        'date': 'วันที่',
        'china_thailand_transport': 'รวมค่าขนส่งจีนไทย',
      },
      'en': {
        'transport_cost': 'Transport Cost',
        'all': 'All',
        'processing': 'Processing',
        'completed': 'Completed',
        'select_date_range': 'Select Date Range',
        'search_document': 'Search Document Number',
        'no_documents_found': 'No Documents Found',
        'no_documents_status': 'No documents in status',
        'documents_will_show_here': 'When there are documents, they will appear here',
        'document_number': 'Document Number',
        'amount': 'Amount',
        'status': 'Status',
        'view_details': 'View Details',
        'baht': 'Baht',
        'try_again': 'Try Again',
        'loading': 'Loading...',
        'error': 'Error Occurred',
        'total_amount': 'Total Amount',
        'date': 'Date',
        'china_thailand_transport': 'China-Thailand Transport Cost',
      },
      'zh': {
        'transport_cost': '运输费用',
        'all': '全部',
        'processing': '处理中',
        'completed': '已完成',
        'select_date_range': '选择日期范围',
        'search_document': '搜索文档编号',
        'no_documents_found': '未找到文档',
        'no_documents_status': '该状态下无文档',
        'documents_will_show_here': '有文档时将显示在这里',
        'document_number': '文档编号',
        'amount': '金额',
        'status': '状态',
        'view_details': '查看详情',
        'baht': '泰铢',
        'try_again': '重试',
        'loading': '加载中...',
        'error': '发生错误',
        'total_amount': '总金额',
        'date': '日期',
        'china_thailand_transport': '中泰运输费用',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    _dateController.text = getTranslation('select_date_range');
    // Call getBills when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getBills();
    });
  }

  // Status mapping from API to translated text
  String _getStatusText(String? apiStatus) {
    switch (apiStatus) {
      case 'pending':
      case 'processing':
      case 'awaiting_payment':
      case 'in_transit':
      case 'arrived_china_warehouse':
      case 'arrived_thailand_warehouse':
        return getTranslation('processing');
      case 'completed':
      case 'delivered':
      case 'paid':
        return getTranslation('completed');
      default:
        return getTranslation('processing');
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
            title: Text(getTranslation('transport_cost'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(), SizedBox(height: 16), Text(getTranslation('loading'))],
            ),
          ),
        );
      }

      // ใช้ API data จาก OrderController
      final displayOrders = <Map<String, dynamic>>[];
      for (var bill in orderController.billing) {
        displayOrders.add({
          'id': bill.id ?? 0, // เพิ่ม id สำหรับส่งไป detail page
          'date': _formatDate(bill.in_thai_date ?? bill.created_at?.toString()),
          'docNo': bill.code ?? '',
          'status': _getStatusText(bill.status),
          'amount': double.tryParse(bill.total_amount ?? '0') ?? 0.0,
        });
      }

      // ✅ กรองตามสถานะและวันที่
      var filteredData = selectedStatus == 'all' ? displayOrders : displayOrders.where((e) => e['status'] == getTranslation(selectedStatus)).toList();

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
      final int pendingCount = displayOrders.where((e) => e['status'] == getTranslation('processing')).length;
      final int successCount = displayOrders.where((e) => e['status'] == getTranslation('completed')).length;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(getTranslation('transport_cost'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
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
                    hintText: getTranslation('select_date_range'),
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
                          hintText: getTranslation('search_document'),
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
                            _buildChip(getTranslation('all'), 'all', count: totalCount),
                            _buildChip(getTranslation('processing'), 'processing', count: pendingCount),
                            _buildChip(getTranslation('completed'), 'completed', count: successCount),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 🔹 Group by date
                      if (filteredData.isEmpty)
                        Center(child: Text(getTranslation('no_documents_found'), style: TextStyle(fontSize: 16, color: Colors.grey)))
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

  Widget _buildChip(String label, String statusKey, {int? count}) {
    final bool selected = selectedStatus == statusKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = statusKey;
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
        status == getTranslation('completed')
            ? 'green'
            : status == getTranslation('cancelled')
            ? 'red'
            : status == getTranslation('processing')
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
                Expanded(
                  child: Text(
                    '${getTranslation('document_number')} ${item['docNo']}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
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
                Text(getTranslation('china_thailand_transport'), style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('${item['amount'].toStringAsFixed(2)} ${getTranslation('baht')}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
