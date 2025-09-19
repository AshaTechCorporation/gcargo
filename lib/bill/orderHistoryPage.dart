import 'package:flutter/material.dart';
import 'package:gcargo/bill/orderDetailPage.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late LanguageController languageController;
  String selectedStatus = 'all';
  final TextEditingController _dateController = TextEditingController(text: '1/01/2024 - 01/07/2025');

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'order_history': 'ประวัติคำสั่งสินค้า',
        'all': 'ทั้งหมด',
        'completed': 'สำเร็จ',
        'cancelled': 'ยกเลิก',
        'select_date_range': 'เลือกช่วงวันที่',
        'search_order_number': 'ค้นหาเลขเลขบิลสั่งซื้อ',
        'no_orders_found': 'ไม่พบรายการสั่งซื้อ',
        'no_orders_status': 'ไม่มีรายการในสถานะ',
        'orders_will_show_here': 'เมื่อคุณสั่งซื้อสินค้า รายการจะแสดงที่นี่',
        'order_code': 'รหัสออเดอร์',
        'total_amount': 'ยอดรวม',
        'boxes': 'กล่อง',
        'type': 'ประเภท',
        'general_type': 'แบบทั่วไป',
        'special_type': 'แบบพิเศษ',
        'note': 'หมายเหตุ',
        'no_note': 'ไม่มีหมายเหตุ',
        'view_details': 'ดูรายละเอียด',
        'baht': 'บาท',
        'try_again': 'ลองใหม่',
        'loading': 'กำลังโหลด...',
        'error': 'เกิดข้อผิดพลาด',
      },
      'en': {
        'order_history': 'Order History',
        'all': 'All',
        'completed': 'Completed',
        'cancelled': 'Cancelled',
        'select_date_range': 'Select Date Range',
        'search_order_number': 'Search Order Number',
        'no_orders_found': 'No Orders Found',
        'no_orders_status': 'No orders in status',
        'orders_will_show_here': 'When you place orders, they will appear here',
        'order_code': 'Order Code',
        'total_amount': 'Total Amount',
        'boxes': 'Boxes',
        'type': 'Type',
        'general_type': 'General',
        'special_type': 'Special',
        'note': 'Note',
        'no_note': 'No Note',
        'view_details': 'View Details',
        'baht': 'Baht',
        'try_again': 'Try Again',
        'loading': 'Loading...',
        'error': 'Error Occurred',
      },
      'zh': {
        'order_history': '订单历史',
        'all': '全部',
        'completed': '已完成',
        'cancelled': '已取消',
        'select_date_range': '选择日期范围',
        'search_order_number': '搜索订单号',
        'no_orders_found': '未找到订单',
        'no_orders_status': '该状态下无订单',
        'orders_will_show_here': '下单后订单将显示在这里',
        'order_code': '订单代码',
        'total_amount': '总金额',
        'boxes': '箱数',
        'type': '类型',
        'general_type': '普通',
        'special_type': '特殊',
        'note': '备注',
        'no_note': '无备注',
        'view_details': '查看详情',
        'baht': '泰铢',
        'try_again': '重试',
        'loading': '加载中...',
        'error': '发生错误',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
  }

  String _getTypeTranslation(String type) {
    switch (type) {
      case 'แบบทั่วไป':
        return getTranslation('general_type');
      case 'แบบพิเศษ':
        return getTranslation('special_type');
      default:
        return type;
    }
  }

  String _getNoteTranslation(String note) {
    switch (note) {
      case 'ไม่มีหมายเหตุ':
        return getTranslation('no_note');
      default:
        return note;
    }
  }

  final List<Map<String, dynamic>> allOrders = [
    // {'date': '01/07/2025', 'code': '00001', 'status': 'สำเร็จ', 'total': 550.00, 'box': 2, 'type': 'แบบทั่วไป', 'note': 'ทดสอบระบบ'},
    // {'date': '30/06/2025', 'code': '00002', 'status': 'ยกเลิก', 'total': 230.00, 'box': 1, 'type': 'แบบพิเศษ', 'note': 'ไม่มีหมายเหตุ'},
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filteredOrders = selectedStatus == 'all' ? allOrders : allOrders.where((o) => o['status'] == getTranslation(selectedStatus)).toList();

      return Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(getTranslation('order_history'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
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
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔎 Search
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(getTranslation('search_order_number'), style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 🟢 Status filter
              Row(
                children: [
                  _buildStatusChip(getTranslation('all'), 'all', 0),
                  const SizedBox(width: 8),
                  _buildStatusChip(getTranslation('completed'), 'completed', 0),
                  const SizedBox(width: 8),
                  _buildStatusChip(getTranslation('cancelled'), 'cancelled', 0),
                ],
              ),
              const SizedBox(height: 16),

              // 🧾 Order List
              if (filteredOrders.isEmpty)
                Center(child: Text(getTranslation('no_orders_found'), style: TextStyle(fontSize: 16, color: Colors.grey)))
              else
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
    }); // ปิด Obx
  }

  // 🔘 Status Chip Widget (ดีไซน์เหมือน OrderStatusPage)
  Widget _buildStatusChip(String label, String statusKey, int count) {
    final bool isSelected = selectedStatus == statusKey;
    return InkWell(
      onTap: () => setState(() => selectedStatus = statusKey),
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
                Expanded(child: Text('${getTranslation('order_code')} ${order['code']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        order['status'] == getTranslation('completed')
                            ? const Color(0xFFEAF7E9)
                            : order['status'] == getTranslation('cancelled')
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
                          order['status'] == getTranslation('completed')
                              ? const Color(0xFF219653)
                              : order['status'] == getTranslation('cancelled')
                              ? const Color(0xFFEB5757)
                              : const Color(0xFFFD7E14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🔹 บรรทัด 2: จำนวนกล่อง
            Text('${order['box']} ${getTranslation('boxes')} (${_getTypeTranslation(order['type'])})', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 6),

            // 🔹 บรรทัด 3: หมายเหตุ
            Text('${getTranslation('note')}: ${_getNoteTranslation(order['note'])}', style: const TextStyle(fontSize: 13)),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // 🔹 บรรทัด 4: สรุปราคา
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(getTranslation('total_amount'), style: TextStyle(fontSize: 13)),
                Text('${order['total'].toStringAsFixed(2)} ${getTranslation('baht')}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
