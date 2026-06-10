import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/parcel/detailOrderPage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late LanguageController languageController;
  late final OrderController orderController;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String searchQuery = '';

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
        'by_sea': 'ทางเรือ',
        'by_land': 'ทางรถ',
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
        'by_sea': 'By Sea',
        'by_land': 'By Land',
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
        'by_sea': '海运',
        'by_land': '陆运',
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
    orderController = Get.isRegistered<OrderController>() ? Get.find<OrderController>() : Get.put(OrderController());
    _dateController.text = getTranslation('select_date_range');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getOrders();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getNoteTranslation(String note) {
    switch (note) {
      case 'ไม่มีหมายเหตุ':
        return getTranslation('no_note');
      default:
        return note;
    }
  }

  bool _isCompletedStatus(String? status) {
    return ['shipped', 'completed', 'delivered', 'success', 'paid'].contains(status);
  }

  String _getShippingTypeText(String? shippingType) {
    switch (shippingType) {
      case 'car':
        return getTranslation('by_land');
      case 'ship':
        return getTranslation('by_sea');
      default:
        return shippingType ?? '-';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        return DateFormat('dd/MM/yyyy').parse(dateString);
      } catch (e2) {
        return null;
      }
    }
  }

  int _getBoxCount(dynamic order) {
    final deliveryLists = order.delivery_order_lists;
    if (deliveryLists != null && deliveryLists.isNotEmpty) {
      return deliveryLists.length;
    }
    final orderLists = order.order_lists;
    if (orderLists != null && orderLists.isNotEmpty) return orderLists.length;
    return 0;
  }

  List<Map<String, dynamic>> _buildCompletedOrders() {
    final displayOrders = <Map<String, dynamic>>[];

    for (final parentOrder in orderController.orders) {
      final nestedOrders = parentOrder.orders;
      if (nestedOrders == null || nestedOrders.isEmpty) continue;

      for (final nestedOrder in nestedOrders) {
        if (!_isCompletedStatus(nestedOrder.status)) continue;

        displayOrders.add({
          'date': _formatDate(nestedOrder.date),
          'rawDate': nestedOrder.date ?? '',
          'status': getTranslation('completed'),
          'code': nestedOrder.code ?? '',
          'total': double.tryParse(nestedOrder.total_price ?? '0') ?? 0.0,
          'box': _getBoxCount(nestedOrder),
          'type': _getShippingTypeText(nestedOrder.shipping_type),
          'note': (nestedOrder.note?.trim().isNotEmpty ?? false) ? nestedOrder.note! : getTranslation('no_note'),
          'orderId': nestedOrder.id ?? 0,
        });
      }
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      displayOrders.removeWhere((order) => !(order['code']?.toString().toLowerCase().contains(query) ?? false));
    }

    if (startDate != null && endDate != null) {
      displayOrders.removeWhere((order) {
        final orderDate = _parseDate(order['rawDate']?.toString());
        if (orderDate == null) return true;
        final startOfDay = DateTime(startDate!.year, startDate!.month, startDate!.day);
        final endOfDay = DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59);
        return !(orderDate.isAfter(startOfDay.subtract(const Duration(days: 1))) && orderDate.isBefore(endOfDay.add(const Duration(days: 1))));
      });
    }

    displayOrders.sort((a, b) {
      final aDate = _parseDate(a['rawDate']?.toString()) ?? DateTime(1900);
      final bDate = _parseDate(b['rawDate']?.toString()) ?? DateTime(1900);
      return bDate.compareTo(aDate);
    });

    return displayOrders;
  }

  Map<String, List<Map<String, dynamic>>> _groupOrdersByDate(List<Map<String, dynamic>> orders) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final order in orders) {
      grouped.putIfAbsent(order['date']?.toString() ?? '', () => []).add(order);
    }
    return grouped;
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: startDate != null && endDate != null ? DateTimeRange(start: startDate!, end: endDate!) : null,
    );

    if (picked == null) return;

    setState(() {
      startDate = picked.start;
      endDate = picked.end;
      _dateController.text = '${DateFormat('dd/MM/yyyy').format(picked.start)} - ${DateFormat('dd/MM/yyyy').format(picked.end)}';
    });
  }

  void _performSearch() {
    setState(() {
      searchQuery = _searchController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (orderController.isLoading.value) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(getTranslation('order_history'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      if (orderController.hasError.value) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(getTranslation('order_history'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(orderController.errorMessage.value, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: orderController.getOrders, child: Text(getTranslation('try_again'))),
              ],
            ),
          ),
        );
      }

      final filteredOrders = _buildCompletedOrders();
      final groupedOrders = _groupOrdersByDate(filteredOrders);

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
                  onTap: _selectDateRange,
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
              TextField(
                controller: _searchController,
                onSubmitted: (_) => _performSearch(),
                decoration: InputDecoration(
                  hintText: getTranslation('search_order_number'),
                  filled: true,
                  fillColor: const Color(0xFFF2F2F2),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(icon: Icon(Icons.search, color: kButtonColor), onPressed: _performSearch),
                ),
              ),
              const SizedBox(height: 12),

              // 🟢 Status filter
              // Row(
              //   children: [
              //     _buildStatusChip(getTranslation('completed'), 'completed', filteredOrders.length),
              //   ],
              // ),
              // const SizedBox(height: 16),

              // 🧾 Order List
              if (filteredOrders.isEmpty)
                Center(child: Text(getTranslation('no_orders_found'), style: TextStyle(fontSize: 16, color: Colors.grey)))
              else
                Expanded(
                  child: ListView(
                    children:
                        groupedOrders.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...entry.value.map(_buildOrderCard),
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
    }); // ปิด Obx
  }

  // 🔘 Status Chip Widget (ดีไซน์เหมือน OrderStatusPage)
  // ignore: unused_element
  Widget _buildStatusChip(String label, int count) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: kBackgroundTextColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBackgroundTextColor),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: kBackgroundTextColor, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Container(
              width: 25,
              height: 25,
              decoration: const BoxDecoration(color: kCicleColor, shape: BoxShape.circle),
              child: Center(child: Text('$count', style: const TextStyle(fontSize: 12, color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return GestureDetector(
      onTap: () {
        final orderId = order['orderId'] as int? ?? 0;
        if (orderId <= 0) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailOrderPage(orderId: orderId)));
      },
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
            Text('${order['box']} ${getTranslation('boxes')} (${order['type']})', style: const TextStyle(fontSize: 13)),
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
