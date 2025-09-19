import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/parcel/detailOrderPage.dart';
import 'package:gcargo/parcel/paymentMethodMulti.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  // Initialize OrderController
  late final OrderController orderController;
  late LanguageController languageController;
  String selectedStatus = 'all';
  TextEditingController _dateController = TextEditingController();
  TextEditingController _searchController = TextEditingController();

  List<String> get statusList => [
    getTranslation('all'),
    getTranslation('pending_review'),
    getTranslation('pending_payment'),
    getTranslation('processing'),
    getTranslation('preparing_shipment'),
    getTranslation('completed'),
    getTranslation('cancelled'),
  ];

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'order_status': 'ออเดอร์',
        'all': 'ทั้งหมด',
        'pending_review': 'รอตรวจสอบ',
        'pending_payment': 'รอชำระเงิน',
        'processing': 'รอดำเนินการ',
        'preparing_shipment': 'เตรียมจัดส่ง',
        'completed': 'สำเร็จ',
        'cancelled': 'ยกเลิก',
        'search_orders': 'ค้นหาออเดอร์',
        'select_date_range': 'เลือกช่วงวันที่',
        'select_all': 'เลือกทั้งหมด',
        'need_vat_receipt': 'ต้องการใบกำกับภาษี (VAT 7%)',
        'total_amount': 'ยอดรวม',
        'payment': 'ชำระเงิน',
        'no_orders': 'ไม่มีออเดอร์',
        'loading': 'กำลังโหลด...',
        'error': 'เกิดข้อผิดพลาด',
        'try_again': 'ลองใหม่',
        'unknown': 'ไม่ทราบสถานะ',
        'select_date_range_text': 'เลือกช่วงวันที่',
        'search_bill_number': 'ค้นหาเลขที่บิล',
        'no_orders_found': 'ไม่พบออเดอร์',
        'no_orders_search': 'ไม่พบออเดอร์ที่ตรงกับการค้นหา',
        'no_orders_status': 'ไม่มีออเดอร์ในสถานะ',
        'orders_will_show_here': 'เมื่อคุณสั่งซื้อสินค้า ออเดอร์จะแสดงที่นี่',
        'vat_confirm_message': 'หากต้องการใบกำกับภาษีกรุณายืนยันก่อนชำระเงิน',
        'order_number': 'เลขบิลสั่งซื้อ',
        'transport': 'การขนส่ง',
        'by_sea': 'ทางเรือ',
        'by_land': 'ทางรถ',
        'total_price_summary': 'สรุปราคาสินค้า',
      },
      'en': {
        'order_status': 'Order Status',
        'all': 'All',
        'pending_review': 'Pending Review',
        'pending_payment': 'Pending Payment',
        'processing': 'Processing',
        'preparing_shipment': 'Preparing Shipment',
        'completed': 'Completed',
        'cancelled': 'Cancelled',
        'search_orders': 'Search Orders',
        'select_date_range': 'Select Date Range',
        'select_all': 'Select All',
        'need_vat_receipt': 'Need VAT Receipt (VAT 7%)',
        'total_amount': 'Total Amount',
        'payment': 'Payment',
        'no_orders': 'No Orders',
        'loading': 'Loading...',
        'error': 'Error Occurred',
        'try_again': 'Try Again',
        'unknown': 'Unknown Status',
        'select_date_range_text': 'Select Date Range',
        'search_bill_number': 'Search Bill Number',
        'no_orders_found': 'No Orders Found',
        'no_orders_search': 'No orders found matching search',
        'no_orders_status': 'No orders in status',
        'orders_will_show_here': 'When you place an order, it will appear here',
        'vat_confirm_message': 'Please confirm before payment if you need VAT receipt',
        'order_number': 'Order Number',
        'transport': 'Transport',
        'by_sea': 'By Sea',
        'by_land': 'By Land',
        'total_price_summary': 'Total Price Summary',
      },
      'zh': {
        'order_status': '订单状态',
        'all': '全部',
        'pending_review': '待审核',
        'pending_payment': '待付款',
        'processing': '处理中',
        'preparing_shipment': '准备发货',
        'completed': '已完成',
        'cancelled': '已取消',
        'search_orders': '搜索订单',
        'select_date_range': '选择日期范围',
        'select_all': '全选',
        'need_vat_receipt': '需要增值税发票 (VAT 7%)',
        'total_amount': '总金额',
        'payment': '付款',
        'no_orders': '无订单',
        'loading': '加载中...',
        'error': '发生错误',
        'try_again': '重试',
        'unknown': '未知状态',
        'select_date_range_text': '选择日期范围',
        'search_bill_number': '搜索账单号',
        'no_orders_found': '未找到订单',
        'no_orders_search': '未找到匹配搜索的订单',
        'no_orders_status': '该状态下无订单',
        'orders_will_show_here': '下单后订单将显示在这里',
        'vat_confirm_message': '如需增值税发票请在付款前确认',
        'order_number': '订单号',
        'transport': '运输方式',
        'by_sea': '海运',
        'by_land': '陆运',
        'total_price_summary': '商品价格汇总',
      },
    };

    return translations[currentLang]?[key] ?? translations['th']?[key] ?? key;
  }

  // State variables
  bool needVatReceipt = false;
  bool selectAll = false;
  Set<String> selectedOrders = {};

  // Search variables
  DateTime? startDate;
  DateTime? endDate;
  String searchQuery = '';

  // Status mapping from API to key
  String _getStatusKey(String? apiStatus) {
    switch (apiStatus) {
      case 'awaiting_summary':
        return 'pending_review';
      case 'awaiting_payment':
        return 'pending_payment';
      case 'in_progress':
        return 'processing';
      case 'preparing_shipment':
        return 'preparing_shipment';
      case 'shipped':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return 'unknown';
    }
  }

  // Get translated status text
  String _getStatusText(String? apiStatus) {
    final key = _getStatusKey(apiStatus);
    return getTranslation(key);
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

  // Parse date string to DateTime for filtering
  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Try different date formats
      try {
        // Try dd/MM/yyyy format
        return DateFormat('dd/MM/yyyy').parse(dateString);
      } catch (e2) {
        try {
          // Try yyyy-MM-dd format
          return DateFormat('yyyy-MM-dd').parse(dateString);
        } catch (e3) {
          print('Cannot parse date: $dateString');
          return null;
        }
      }
    }
  }

  // Get shipping type translated
  String _getShippingTypeText(String? shippingType) {
    switch (shippingType) {
      case 'car':
        return getTranslation('by_land');
      case 'ship':
        return getTranslation('by_sea');
      default:
        return shippingType ?? getTranslation('unknown');
    }
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    _dateController.text = getTranslation('select_date_range_text'); // ไม่ตั้งค่าเริ่มต้น

    // ไม่ตั้งค่าวันที่เริ่มต้น - ให้ผู้ใช้เลือกเอง
    startDate = null;
    endDate = null;

    orderController = Get.put(OrderController());
    orderController.getOrders();
    orderController.refreshData();
  }

  // ฟังก์ชั่นสำหรับค้นหาและฟิลเตอร์ออเดอร์
  List<Map<String, dynamic>> _getFilteredOrders() {
    List<Map<String, dynamic>> filteredOrders = List.from(orderController.orders);

    // ฟิลเตอร์ตามช่วงวันที่
    if (startDate != null && endDate != null) {
      filteredOrders =
          filteredOrders.where((order) {
            final orderDateStr = order['created_at'] as String?;
            if (orderDateStr == null) return false;

            try {
              final orderDate = DateTime.parse(orderDateStr);
              return orderDate.isAfter(startDate!.subtract(const Duration(days: 1))) && orderDate.isBefore(endDate!.add(const Duration(days: 1)));
            } catch (e) {
              return false;
            }
          }).toList();
    }

    // ฟิลเตอร์ตามเลขบิล
    if (searchQuery.isNotEmpty) {
      filteredOrders =
          filteredOrders.where((order) {
            final billNumber = order['bill_number']?.toString().toLowerCase() ?? '';
            final orderNumber = order['order_number']?.toString().toLowerCase() ?? '';
            final query = searchQuery.toLowerCase();

            return billNumber.contains(query) || orderNumber.contains(query);
          }).toList();
    }

    // ฟิลเตอร์ตามสถานะ
    if (selectedStatus != 'all') {
      final targetStatus = getTranslation(selectedStatus);
      filteredOrders =
          filteredOrders.where((order) {
            final orderStatus = order['status'];
            return orderStatus == targetStatus;
          }).toList();
    }

    return filteredOrders;
  }

  // ฟังก์ชั่นสำหรับการค้นหา
  void _performSearch() {
    setState(() {
      searchQuery = _searchController.text.trim();
    });
  }

  // ฟังก์ชั่นสำหรับเลือกช่วงวันที่
  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: startDate != null && endDate != null ? DateTimeRange(start: startDate!, end: endDate!) : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: kButtonColor, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        _dateController.text = '${DateFormat('dd/MM/yyyy').format(picked.start)} - ${DateFormat('dd/MM/yyyy').format(picked.end)}';

        // Debug: แสดงวันที่ที่เลือก
        print('🗓️ เลือกช่วงวันที่: ${startDate} ถึง ${endDate}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder:
          (controller) => Obx(() {
            // Show loading state
            if (orderController.isLoading.value) {
              return Scaffold(
                backgroundColor: Colors.grey.shade100,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
                  title: Text(getTranslation('order_status'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            // Show error state
            if (orderController.hasError.value) {
              return Scaffold(
                backgroundColor: Colors.grey.shade100,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
                  title: Text(getTranslation('order_status'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(orderController.errorMessage.value, style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                      SizedBox(height: 16),
                      ElevatedButton(onPressed: () => orderController.refreshData(), child: Text('ลองใหม่')),
                    ],
                  ),
                ),
              );
            }

            // Convert API data to display format - extract nested orders only
            final allDisplayOrders = <Map<String, dynamic>>[];

            for (var parentOrder in orderController.orders) {
              // Only process parent orders that have nested orders
              if (parentOrder.orders != null && parentOrder.orders!.isNotEmpty) {
                // Add each nested order to display list
                for (var nestedOrder in parentOrder.orders!) {
                  allDisplayOrders.add({
                    'date': _formatDate(nestedOrder.date),
                    'status': _getStatusText(nestedOrder.status),
                    'code': nestedOrder.code ?? '',
                    'transport': _getShippingTypeText(nestedOrder.shipping_type),
                    'total': double.tryParse(nestedOrder.total_price ?? '0') ?? 0.0,
                    'originalOrder': nestedOrder, // Keep reference to original order
                    'parentOrder': parentOrder, // Keep reference to parent order
                    'bill_number': nestedOrder.code ?? '', // สำหรับการค้นหา
                    'order_number': nestedOrder.id?.toString() ?? '', // สำหรับการค้นหา
                    'created_at': nestedOrder.date ?? '', // สำหรับการฟิลเตอร์วันที่
                    'raw_date': nestedOrder.date, // เก็บข้อมูลวันที่ดิบไว้ debug
                  });
                }
              }
              // Skip parent orders without nested orders - don't show them as cards
            }

            // Apply filters using the _getFilteredOrders function
            // First, set the orders for filtering
            final tempOrders = allDisplayOrders;

            // Apply filters
            List<Map<String, dynamic>> filteredOrders = List.from(tempOrders);

            // ฟิลเตอร์ตามช่วงวันที่
            if (startDate != null && endDate != null) {
              print('🔍 กำลังฟิลเตอร์ตามวันที่: $startDate ถึง $endDate');
              print('📊 จำนวนออเดอร์ก่อนฟิลเตอร์: ${filteredOrders.length}');

              filteredOrders =
                  filteredOrders.where((order) {
                    final orderDateStr = order['created_at'] as String?;
                    final rawDate = order['raw_date'];

                    print('📅 ตรวจสอบออเดอร์: created_at="$orderDateStr", raw_date="$rawDate"');

                    if (orderDateStr == null || orderDateStr.isEmpty) {
                      print('❌ ไม่มีวันที่');
                      return false;
                    }

                    final orderDate = _parseDate(orderDateStr);
                    if (orderDate == null) {
                      print('❌ ไม่สามารถแปลงวันที่: $orderDateStr');
                      return false;
                    }

                    // ตรวจสอบว่าวันที่ออเดอร์อยู่ในช่วงที่เลือก
                    final startOfDay = DateTime(startDate!.year, startDate!.month, startDate!.day);
                    final endOfDay = DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59);

                    final isInRange =
                        orderDate.isAfter(startOfDay.subtract(const Duration(days: 1))) && orderDate.isBefore(endOfDay.add(const Duration(days: 1)));

                    print('✅ วันที่ออเดอร์: $orderDate, อยู่ในช่วง: $isInRange');

                    return isInRange;
                  }).toList();

              print('📊 จำนวนออเดอร์หลังฟิลเตอร์: ${filteredOrders.length}');
            } else {
              print('📅 ไม่ได้เลือกช่วงวันที่ - แสดงออเดอร์ทั้งหมด');
            }

            // ฟิลเตอร์ตามเลขบิล
            if (searchQuery.isNotEmpty) {
              filteredOrders =
                  filteredOrders.where((order) {
                    final billNumber = order['bill_number']?.toString().toLowerCase() ?? '';
                    final orderNumber = order['order_number']?.toString().toLowerCase() ?? '';
                    final code = order['code']?.toString().toLowerCase() ?? '';
                    final query = searchQuery.toLowerCase();

                    return billNumber.contains(query) || orderNumber.contains(query) || code.contains(query);
                  }).toList();
            }

            // ฟิลเตอร์ตามสถานะ
            if (selectedStatus != 'all') {
              final targetStatus = getTranslation(selectedStatus);
              filteredOrders =
                  filteredOrders.where((order) {
                    final orderStatus = order['status'];
                    return orderStatus == targetStatus;
                  }).toList();
            }

            final displayOrders = filteredOrders;

            // Group orders by date
            final groupedOrders = <String, List<Map<String, dynamic>>>{};
            for (var order in displayOrders) {
              final dateKey = order['date'] as String? ?? '';
              groupedOrders.putIfAbsent(dateKey, () => []).add(order);
            }

            // Calculate status counts (ใช้ข้อมูลทั้งหมดไม่ใช่ข้อมูลที่ถูกฟิลเตอร์)
            final Map<String, int> statusCounts = {
              getTranslation('all'): allDisplayOrders.length,
              getTranslation('pending_review'): allDisplayOrders.where((order) => order['status'] == getTranslation('pending_review')).length,
              getTranslation('pending_payment'): allDisplayOrders.where((order) => order['status'] == getTranslation('pending_payment')).length,
              getTranslation('processing'): allDisplayOrders.where((order) => order['status'] == getTranslation('processing')).length,
              getTranslation('preparing_shipment'): allDisplayOrders.where((order) => order['status'] == getTranslation('preparing_shipment')).length,
              getTranslation('completed'): allDisplayOrders.where((order) => order['status'] == getTranslation('completed')).length,
              getTranslation('cancelled'): allDisplayOrders.where((order) => order['status'] == getTranslation('cancelled')).length,
            };

            // Build the main UI structure
            Widget buildMainContent() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: getTranslation('search_bill_number'),
                            filled: true,
                            hintStyle: TextStyle(fontSize: 14),
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            suffixIcon: IconButton(icon: Icon(Icons.search, color: kButtonColor), onPressed: _performSearch),
                          ),
                          onSubmitted: (_) => _performSearch(),
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
                        final statusKey =
                            ['all', 'pending_review', 'pending_payment', 'processing', 'preparing_shipment', 'completed', 'cancelled'][index];
                        final isSelected = statusKey == selectedStatus;
                        final count = statusCounts[status] ?? 0;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
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
                                    status,
                                    style: TextStyle(
                                      color: isSelected ? kBackgroundTextColor : Colors.black,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(color: isSelected ? kCicleColor : Colors.grey.shade300, shape: BoxShape.circle),
                                    child: Center(
                                      child: Text('$count', style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // Show empty state if no orders, but keep the search and status tabs
                  if (displayOrders.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(getTranslation('no_orders_found'), style: TextStyle(fontSize: 18, color: Colors.grey)),
                            SizedBox(height: 8),
                            Text(
                              searchQuery.isNotEmpty
                                  ? '${getTranslation('no_orders_search')} "$searchQuery"'
                                  : selectedStatus != 'all'
                                  ? '${getTranslation('no_orders_status')} "${getTranslation(selectedStatus)}"'
                                  : getTranslation('orders_will_show_here'),
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }

            return Scaffold(
              backgroundColor: Colors.grey.shade100,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getTranslation('order_status'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
                    SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _selectDateRange,
                        decoration: InputDecoration(
                          prefixIcon: Padding(padding: const EdgeInsets.all(12.0), child: Image.asset('assets/icons/calendar_icon.png', width: 18)),
                          hintText: getTranslation('select_date_range_text'),
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
                child:
                    displayOrders.isEmpty
                        ? buildMainContent()
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: getTranslation('search_bill_number'),
                                      filled: true,
                                      hintStyle: TextStyle(fontSize: 14),
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                      suffixIcon: IconButton(icon: Icon(Icons.search, color: kButtonColor), onPressed: _performSearch),
                                    ),
                                    onSubmitted: (_) => _performSearch(),
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
                                  final statusKey =
                                      [
                                        'all',
                                        'pending_review',
                                        'pending_payment',
                                        'processing',
                                        'preparing_shipment',
                                        'completed',
                                        'cancelled',
                                      ][index];
                                  final isSelected = statusKey == selectedStatus;
                                  final count = statusCounts[status] ?? 0;

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
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
                                              status,
                                              style: TextStyle(
                                                color: isSelected ? kBackgroundTextColor : Colors.black,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: isSelected ? kCicleColor : Colors.grey.shade300,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$count',
                                                  style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black),
                                                ),
                                              ),
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
                                          ...entry.value.map((order) => _buildOrderCard(order)),
                                          const SizedBox(height: 16),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
              ),
              bottomNavigationBar: selectedStatus == 'pending_payment' ? _buildBottomBar() : null,
            );
          }), // Close Obx
    ); // Close GetBuilder
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE0E0E0)))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔸 บรรทัด VAT
          GestureDetector(
            onTap: () {
              setState(() {
                needVatReceipt = !needVatReceipt;
              });
            },
            child: Row(
              children: [
                Icon(
                  needVatReceipt ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 20,
                  color: needVatReceipt ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(getTranslation('need_vat_receipt')),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: 28),
            child: Text(getTranslation('vat_confirm_message'), style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
          const SizedBox(height: 12),

          // 🔸 แถวล่างสุด
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: selectAll,
                    onChanged: (value) {
                      setState(() {
                        selectAll = value ?? false;
                        if (selectAll) {
                          // เลือกทั้งหมด - เพิ่ม order IDs ที่มีสถานะ "รอชำระเงิน"
                          selectedOrders.clear(); // เคลียร์ก่อน

                          // หา orders ที่มีสถานะ "รอชำระเงิน" จาก orderController
                          for (var parentOrder in orderController.orders) {
                            if (parentOrder.orders != null) {
                              for (var nestedOrder in parentOrder.orders!) {
                                if (_getStatusKey(nestedOrder.status) == 'pending_payment') {
                                  final orderId = nestedOrder.id?.toString() ?? '';
                                  if (orderId.isNotEmpty) {
                                    selectedOrders.add(orderId);
                                  }
                                }
                              }
                            }
                          }
                        } else {
                          // ยกเลิกเลือกทั้งหมด
                          selectedOrders.clear();
                        }
                      });
                    },
                  ),
                  Text(getTranslation('select_all'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  // นำ selectedOrders ไปยังหน้าชำระเงิน
                  if (selectedOrders.isNotEmpty) {
                    // จัดฟอร์แมตข้อมูลตามที่ต้องการ
                    final paymentData = _preparePaymentData();
                    inspect(paymentData);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PaymentMethodMulti(
                              vat: paymentData['vat'],
                              orderType: paymentData['order_type'],
                              totalPrice: paymentData['total_price'],
                              items: paymentData['items'],
                            ),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFF1E3C72), borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text('${selectedOrders.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(getTranslation('total_amount'), style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 12),
                      Text('${_calculateTotalPrice()}฿', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateTotalPrice() {
    double total = 0.0;

    // วนลูปหาออเดอร์ที่เลือกและรวมราคา
    for (String selectedOrderId in selectedOrders) {
      // หาออเดอร์จาก orderController.orders
      for (var parentOrder in orderController.orders) {
        if (parentOrder.orders != null) {
          for (var nestedOrder in parentOrder.orders!) {
            if (nestedOrder.id?.toString() == selectedOrderId) {
              // เพิ่มราคาของออเดอร์นี้
              double orderPrice = double.tryParse(nestedOrder.total_price ?? '0') ?? 0.0;
              total += orderPrice;
              break;
            }
          }
        }
      }
    }

    // เพิ่ม VAT 7% ถ้าเลือก
    if (needVatReceipt) {
      total = total * 1.07;
    }

    return total.toStringAsFixed(2);
  }

  // จัดเตรียมข้อมูลสำหรับส่งไปหน้า PaymentMethodMulti
  Map<String, dynamic> _preparePaymentData() {
    double totalPrice = 0.0;
    List<Map<String, dynamic>> items = [];

    // วนลูปหาออเดอร์ที่เลือกและสร้าง items
    for (String selectedOrderId in selectedOrders) {
      for (var parentOrder in orderController.orders) {
        if (parentOrder.orders != null) {
          for (var nestedOrder in parentOrder.orders!) {
            if (nestedOrder.id?.toString() == selectedOrderId) {
              double orderPrice = double.tryParse(nestedOrder.total_price ?? '0') ?? 0.0;
              totalPrice += orderPrice;

              // สร้าง item สำหรับออเดอร์นี้
              items.add({
                'ref_no': nestedOrder.code ?? '',
                'date': nestedOrder.date ?? '',
                'total_price': orderPrice,
                'note': nestedOrder.note ?? '',
                'image': '', // ถ้ามีรูปภาพสามารถเพิ่มได้
              });
              break;
            }
          }
        }
      }
    }

    // เพิ่ม VAT 7% ถ้าเลือก
    if (needVatReceipt) {
      totalPrice = totalPrice * 1.07;
    }

    return {'vat': needVatReceipt, 'order_type': 'order', 'total_price': totalPrice, 'items': items};
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'];
    final isCancelled = status == getTranslation('cancelled');
    final isShipped = status == getTranslation('completed');
    final isPending = status == getTranslation('pending_review');
    final isAwaitingPayment = status == getTranslation('pending_payment');
    final isInProgress = status == getTranslation('processing');
    final isPreparing = status == getTranslation('preparing_shipment');

    final statusColor =
        isCancelled
            ? Colors.red
            : isShipped
            ? Colors.green
            : isPreparing
            ? Colors.blue
            : isInProgress
            ? Colors.orange
            : isAwaitingPayment
            ? Colors.purple
            : isPending
            ? Colors.amber
            : Colors.grey;

    final borderColor =
        isCancelled
            ? Colors.red.shade100
            : isShipped
            ? Colors.green.shade100
            : isPreparing
            ? Colors.blue.shade100
            : isInProgress
            ? Colors.orange.shade100
            : isAwaitingPayment
            ? Colors.purple.shade100
            : isPending
            ? Colors.amber.shade100
            : Colors.grey.shade300;

    return GestureDetector(
      onTap: () async {
        // Navigate to DetailOrderPage with order data
        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailOrderPage(orderId: order['originalOrder'].id ?? 0)));

        // ถ้ายกเลิกออเดอร์สำเร็จ ให้รีเฟรชข้อมูล
        if (result == true) {
          print('🔄 ยกเลิกออเดอร์สำเร็จ รีเฟรชข้อมูล OrderStatusPage');
          setState(() {
            orderController.getOrders();
          });
        }
      },
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
                    Text('${getTranslation('order_number')} ${order['code']}', style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
                  ],
                ),
                Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Divider(),

            // 🔹 ปกติ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(getTranslation('transport'), style: TextStyle(fontSize: 16)), Text(order['transport'], style: TextStyle(fontSize: 16))],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(getTranslation('total_price_summary'), style: TextStyle(fontSize: 16)),
                Text('${order['total'].toStringAsFixed(2)}฿', style: TextStyle(fontSize: 16)),
              ],
            ),

            // 🔹 Checkbox สำหรับสถานะรอชำระเงิน
            if (isAwaitingPayment) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: selectedOrders.contains(order['originalOrder']?.id?.toString() ?? ''),
                    onChanged: (value) {
                      setState(() {
                        final orderId = order['originalOrder']?.id?.toString() ?? '';
                        if (value == true) {
                          selectedOrders.add(orderId);
                        } else {
                          selectedOrders.remove(orderId);
                        }

                        // อัปเดต selectAll checkbox ตามจำนวนที่เลือก
                        int totalAwaitingPaymentOrders = 0;
                        for (var parentOrder in orderController.orders) {
                          if (parentOrder.orders != null) {
                            for (var nestedOrder in parentOrder.orders!) {
                              if (_getStatusKey(nestedOrder.status) == 'pending_payment') {
                                totalAwaitingPaymentOrders++;
                              }
                            }
                          }
                        }
                        selectAll = selectedOrders.length == totalAwaitingPaymentOrders && totalAwaitingPaymentOrders > 0;
                      });
                    },
                  ),
                  const Text('เลือกรายการนี้', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
