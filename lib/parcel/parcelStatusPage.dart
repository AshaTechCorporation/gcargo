import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gcargo/account/couponPage.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/models/legalimport.dart';
import 'package:gcargo/models/orders/ordersPageNew.dart';
import 'package:gcargo/parcel/claimPackagePage.dart';
import 'package:gcargo/parcel/parcelDetailPage.dart';
import 'package:gcargo/parcel/paymentMethodMulti.dart';
import 'package:gcargo/parcel/shippingMethodPage.dart';
import 'package:gcargo/parcel/widgets/date_range_picker_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ParcelStatusPage extends StatefulWidget {
  const ParcelStatusPage({super.key});

  @override
  State<ParcelStatusPage> createState() => _ParcelStatusPageState();
}

class _ParcelStatusPageState extends State<ParcelStatusPage> {
  late LanguageController languageController;
  final TextEditingController _dateController = TextEditingController();

  // Date filter variables
  DateTime? startDate;
  DateTime? endDate;

  // เพิ่ม state สำหรับ checkbox ของสถานะ "ถึงโกดังไทย"
  Set<String> selectedParcels = {};

  // เพิ่ม OrderController
  late final OrderController orderController;

  int selectedStatusIndex = 0;
  bool isRequestTaxCertificate = false; // สำหรับ radio button ขอใบรับรองภาษี
  bool isSelectAll = false; // สำหรับ checkbox เลือกทั้งหมด

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'parcel_status': 'สถานะพัสดุ',
        'all': 'ทั้งหมด',
        'pending_send_china': 'รอส่งไปโกดังจีน',
        'arrived_china': 'ถึงโกดังจีน',
        'container_closed': 'ปิดตู้',
        'arrived_thailand': 'ถึงโกดังไทย',
        'under_inspection': 'กำลังตรวจสอบ',
        'ready_delivery': 'รอจัดส่ง',
        'completed': 'สำเร็จ',
        'select_date_range': 'เลือกช่วงวันที่',
        'search_tracking': 'ค้นหาหมายเลขแทรคกิ้ง',
        'no_parcels_found': 'ไม่พบพัสดุ',
        'no_parcels_status': 'ไม่มีพัสดุในสถานะ',
        'parcels_will_show_here': 'เมื่อคุณมีพัสดุ จะแสดงที่นี่',
        'tracking_number': 'หมายเลขแทรคกิ้ง',
        'weight': 'น้ำหนัก',
        'kg': 'กก.',
        'select_all': 'เลือกทั้งหมด',
        'request_tax_certificate': 'ขอใบรับรองภาษี',
        'confirm_delivery': 'ยืนยันการจัดส่ง',
        'claim_package': 'เคลมพัสดุ',
        'shipping_method': 'วิธีการจัดส่ง',
        'view_details': 'ดูรายละเอียด',
        'coupon_discount': 'คูปองส่วนลด',
        'shipping_thailand': 'ขนส่งไทย รถเหมาบริษัท',
        'tax_warning': 'หากต้องการหัก ณ ที่จ่าย กรุณายืนยันก่อนชำระเงิน',
        'order_bill_number': 'เลขบิลสั่งซื้อ',
        'warehouse_bill_number': 'เลขบิลหน้าโกดัง',
        'document_number': 'เลขที่เอกสาร',
        'thailand_shipping_company': 'บริษัทขนส่งในไทย',
        'thailand_tracking_number': 'หมายเลขขนส่งในไทย',
        'report_problem': 'แจ้งพัสดุมีปัญหา',
        'try_again': 'ลองใหม่',
      },
      'en': {
        'parcel_status': 'Parcel Status',
        'all': 'All',
        'pending_send_china': 'Pending Send to China',
        'arrived_china': 'Arrived China Warehouse',
        'container_closed': 'Container Closed',
        'arrived_thailand': 'Arrived Thailand Warehouse',
        'under_inspection': 'Under Inspection',
        'ready_delivery': 'Ready for Delivery',
        'completed': 'Completed',
        'select_date_range': 'Select Date Range',
        'search_tracking': 'Search Tracking Number',
        'no_parcels_found': 'No Parcels Found',
        'no_parcels_status': 'No parcels in status',
        'parcels_will_show_here': 'When you have parcels, they will appear here',
        'tracking_number': 'Tracking Number',
        'weight': 'Weight',
        'kg': 'kg',
        'select_all': 'Select All',
        'request_tax_certificate': 'Request Tax Certificate',
        'confirm_delivery': 'Confirm Delivery',
        'claim_package': 'Claim Package',
        'shipping_method': 'Shipping Method',
        'view_details': 'View Details',
        'coupon_discount': 'Coupon Discount',
        'shipping_thailand': 'Thailand Shipping - Company Truck',
        'tax_warning': 'Please confirm before payment if you need tax withholding',
        'order_bill_number': 'Order Bill Number',
        'warehouse_bill_number': 'Warehouse Bill Number',
        'document_number': 'Document Number',
        'thailand_shipping_company': 'Thailand Shipping Company',
        'thailand_tracking_number': 'Thailand Tracking Number',
        'report_problem': 'Report Problem',
        'try_again': 'Try Again',
      },
      'zh': {
        'parcel_status': '包裹状态',
        'all': '全部',
        'pending_send_china': '等待发往中国仓库',
        'arrived_china': '到达中国仓库',
        'container_closed': '封柜',
        'arrived_thailand': '到达泰国仓库',
        'under_inspection': '正在检查',
        'ready_delivery': '等待配送',
        'completed': '已完成',
        'select_date_range': '选择日期范围',
        'search_tracking': '搜索跟踪号',
        'no_parcels_found': '未找到包裹',
        'no_parcels_status': '该状态下无包裹',
        'parcels_will_show_here': '有包裹时将显示在这里',
        'tracking_number': '跟踪号',
        'weight': '重量',
        'kg': '公斤',
        'select_all': '全选',
        'request_tax_certificate': '申请税务证明',
        'confirm_delivery': '确认配送',
        'claim_package': '申请理赔',
        'shipping_method': '配送方式',
        'view_details': '查看详情',
        'coupon_discount': '优惠券折扣',
        'shipping_thailand': '泰国运输 - 公司卡车',
        'tax_warning': '如需代扣税款请在付款前确认',
        'order_bill_number': '订单账单号',
        'warehouse_bill_number': '仓库账单号',
        'document_number': '文件编号',
        'thailand_shipping_company': '泰国运输公司',
        'thailand_tracking_number': '泰国跟踪号',
        'report_problem': '报告问题',
        'try_again': '重试',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  List<String> get statuses => [
    getTranslation('all'),
    getTranslation('pending_send_china'),
    getTranslation('arrived_china'),
    getTranslation('container_closed'),
    getTranslation('arrived_thailand'),
    getTranslation('under_inspection'),
    getTranslation('ready_delivery'),
    getTranslation('completed'),
  ];

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    _dateController.text = getTranslation('select_date_range');

    // Initialize OrderController และเรียก API
    orderController = Get.put(OrderController());
    orderController.getDeliveryOrders();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // ฟังก์ชั่นสำหรับคำนวณจำนวนตามสถานะ
  Map<String, int> _calculateStatusCounts() {
    final counts = <String, int>{};

    // Initialize all statuses with 0
    for (String status in statuses) {
      counts[status] = 0;
    }

    // Count from API data
    int totalCount = 0;
    for (LegalImport legalImport in orderController.deilveryOrders) {
      if (legalImport.delivery_orders != null) {
        for (OrdersPageNew order in legalImport.delivery_orders!) {
          totalCount++;
          final status = _mapApiStatusToDisplayStatus(order.status ?? '');
          if (counts.containsKey(status)) {
            counts[status] = (counts[status] ?? 0) + 1;
          }
        }
      }
    }

    counts[getTranslation('all')] = totalCount;
    return counts;
  }

  // ฟังก์ชั่นสำหรับแปลงสถานะจาก API เป็นสถานะที่แสดง
  String _mapApiStatusToDisplayStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'pending_send_to_china':
      case 'รอส่งไปโกดังจีน':
        return getTranslation('pending_send_china');
      case 'arrived_china_warehouse':
      case 'ถึงโกดังจีน':
        return getTranslation('arrived_china');
      case 'in_transit':
      case 'ปิดตู้':
        return getTranslation('container_closed');
      case 'arrived_thailand_warehouse':
      case 'ถึงโกดังไทย':
        return getTranslation('arrived_thailand');
      case 'awaiting_payment':
      case 'กำลังตรวจสอบ':
        return getTranslation('under_inspection');
      case 'delivered':
      case 'รอจัดส่ง':
        return getTranslation('ready_delivery');
      case 'completed':
      case 'สำเร็จ':
        return getTranslation('completed');
      default:
        return getTranslation('pending_send_china'); // default status
    }
  }

  // Method สำหรับอัปเดต selection ของพัสดุทั้งหมดในสถานะ "ถึงโกดังไทย"
  void _updateAllParcelsSelection() {
    // รายการพัสดุทั้งหมดในสถานะ "ถึงโกดังไทย" จาก API
    List<String> allThailandParcels = [];

    for (LegalImport legalImport in orderController.deilveryOrders) {
      if (legalImport.delivery_orders != null) {
        for (OrdersPageNew order in legalImport.delivery_orders!) {
          final orderStatus = _mapApiStatusToDisplayStatus(order.status ?? '');
          if (orderStatus == getTranslation('arrived_thailand')) {
            allThailandParcels.add(order.po_no ?? '');
          }
        }
      }
    }

    setState(() {
      if (isSelectAll) {
        // เลือกทั้งหมด
        selectedParcels.addAll(allThailandParcels);
      } else {
        // ยกเลิกการเลือกทั้งหมด
        selectedParcels.removeAll(allThailandParcels);
      }
    });
  }

  // Method สำหรับอัปเดตสถานะ "เลือกทั้งหมด" ตามการเลือกของแต่ละการ์ด
  void _updateSelectAllState() {
    final allThailandParcels = ['00044', '00051', '00052'];

    // ถ้าเลือกครบทุกตัว ให้ติ๊ก "เลือกทั้งหมด"
    // ถ้าไม่เลือกครบ ให้ยกเลิกการติ๊ก "เลือกทั้งหมด"
    isSelectAll = allThailandParcels.every((parcel) => selectedParcels.contains(parcel));
  }

  Widget _buildStatusChip(String label, int count, bool isActive, int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedStatusIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF427D9D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF427D9D)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isActive ? Colors.white : const Color(0xFF427D9D))),
            if (count > 0) ...[
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 10,
                backgroundColor: isActive ? Colors.white : kCicleColor,
                child: Text(
                  '$count',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF427D9D) : Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParcelCard({
    required String parcelNo,
    required String status,
    required bool showActionButton,
    required int orderId,
    required String orderCode,
    required String warehouseCode,
    required String totalPrice,
  }) {
    return GestureDetector(
      onTap: () {
        // ไปหน้า parcel detail พร้อมส่ง ID
        Navigator.push(context, MaterialPageRoute(builder: (_) => ParcelDetailPage(status: status, id: orderId)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: Color(0xFFE9F4FF), shape: BoxShape.circle),
                  child: Center(child: Image.asset('assets/icons/box.png', width: 18, height: 18)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('${getTranslation('tracking_number')} $parcelNo', style: const TextStyle(fontWeight: FontWeight.bold))),
                //Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF427D9D))),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(getTranslation('order_bill_number')), Text(orderCode, style: const TextStyle(fontWeight: FontWeight.bold))],
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(getTranslation('warehouse_bill_number')),
                status == getTranslation('pending_send_china') ? SizedBox() : Text(warehouseCode, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            status == getTranslation('under_inspection') || status == getTranslation('ready_delivery')
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(getTranslation('document_number')), const Text(' X2504290002', style: TextStyle(fontWeight: FontWeight.bold))],
                )
                : SizedBox(),

            // เพิ่ม checkbox เฉพาะสถานะ "ถึงโกดังไทย"
            Row(
              children: [
                if (status == getTranslation('arrived_thailand')) ...[
                  Checkbox(
                    value: selectedParcels.contains(parcelNo),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedParcels.add(parcelNo);
                        } else {
                          selectedParcels.remove(parcelNo);
                        }
                        _updateSelectAllState();
                      });
                    },
                    activeColor: const Color(0xFF427D9D),
                  ),
                  const SizedBox(width: 8),
                  Text('$totalPrice฿'),
                ],
              ],
            ),

            if (showActionButton) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(getTranslation('document_number')), const Text('X2504290002', style: TextStyle(fontWeight: FontWeight.bold))],
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(getTranslation('thailand_shipping_company')), const Text('-', style: TextStyle(fontWeight: FontWeight.bold))],
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(getTranslation('thailand_tracking_number')), const Text('-', style: TextStyle(fontWeight: FontWeight.bold))],
              ),

              const SizedBox(height: 12),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ClaimPackagePage()));
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF427D9D)),
                      foregroundColor: const Color(0xFF427D9D),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(getTranslation('report_problem')),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateGroup(String date, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(date, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...cards, const SizedBox(height: 16)],
    );
  }

  // สร้างข้อมูลการ์ดตามสถานะ
  List<Widget> _getCardsForStatus(String status) {
    // Get filtered orders from API
    List<OrdersPageNew> filteredOrders = [];

    for (LegalImport legalImport in orderController.deilveryOrders) {
      if (legalImport.delivery_orders != null) {
        for (OrdersPageNew order in legalImport.delivery_orders!) {
          final orderStatus = _mapApiStatusToDisplayStatus(order.status ?? '');

          // Filter by status
          if (status != getTranslation('all') && orderStatus != status) continue;

          // Filter by date range
          if (startDate != null && endDate != null && order.created_at != null) {
            final orderDate = order.created_at!;
            final startOfDay = DateTime(startDate!.year, startDate!.month, startDate!.day);
            final endOfDay = DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59);

            if (orderDate.isBefore(startOfDay) || orderDate.isAfter(endOfDay)) continue;
          }

          filteredOrders.add(order);
        }
      }
    }

    // Group orders by date
    Map<String, List<OrdersPageNew>> groupedOrders = {};
    for (OrdersPageNew order in filteredOrders) {
      String dateKey = _formatDate(order.created_at);
      if (!groupedOrders.containsKey(dateKey)) {
        groupedOrders[dateKey] = [];
      }
      groupedOrders[dateKey]!.add(order);
    }

    // Convert to widgets
    List<Widget> widgets = [];
    List<String> sortedDates = groupedOrders.keys.toList()..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)

    for (String date in sortedDates) {
      List<Widget> cards = [];
      for (OrdersPageNew order in groupedOrders[date]!) {
        final orderStatus = _mapApiStatusToDisplayStatus(order.status ?? '');
        cards.add(
          _buildParcelCard(
            parcelNo: order.po_no ?? 'N/A',
            status: orderStatus,
            showActionButton: orderStatus == getTranslation('completed'),
            orderId: order.id ?? 0,
            orderCode: order.order?.code ?? 'N/A',
            warehouseCode: order.receipt_no_wh ?? 'N/A',
            totalPrice: order.order?.total_price ?? '0.00',
          ),
        );
      }
      widgets.add(_buildDateGroup(date, cards));
    }

    return widgets;
  }

  // ฟังก์ชั่นสำหรับ format วันที่
  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return DateFormat('dd/MM/yyyy').format(DateTime.now());
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(getTranslation('parcel_status'), style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(width: 20),
              DateRangePickerWidget(
                controller: _dateController,
                hintText: getTranslation('select_date_range'),
                onDateRangeSelected: (DateTimeRange? picked) {
                  if (picked != null) {
                    setState(() {
                      startDate = picked.start;
                      endDate = picked.end;
                    });
                  }
                },
              ),
            ],
          ),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),

          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
      body: Obx(() {
        if (orderController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orderController.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(orderController.errorMessage.value, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 16),
                ElevatedButton(onPressed: () => orderController.getDeliveryOrders(), child: Text(getTranslation('try_again'))),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // 🔍 Search Box
              TextFormField(
                decoration: InputDecoration(
                  hintText: getTranslation('search_tracking'),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // 🔄 Scrollable Chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: statuses.length,
                  padding: const EdgeInsets.only(right: 4),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final label = statuses[index];
                    final statusCounts = _calculateStatusCounts();
                    final count = statusCounts[label] ?? 0;
                    return _buildStatusChip(label, count, index == selectedStatusIndex, index);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 📦 Parcel List
              Expanded(
                child: () {
                  final cards = _getCardsForStatus(statuses[selectedStatusIndex]);
                  if (cards.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(getTranslation('no_parcels_found'), style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return ListView(children: cards);
                }(),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: selectedStatusIndex == statuses.indexOf('ถึงโกดังไทย') ? _buildBottomPanel() : null,
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE0E0E0)))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎟 คูปองส่วนลด
          // GestureDetector(
          //   onTap: () {
          //     // ไปหน้าคูปองส่วนลด
          //     Navigator.push(context, MaterialPageRoute(builder: (_) => const CouponPage()));
          //   },
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(getTranslation('coupon_discount'), style: TextStyle(fontWeight: FontWeight.bold)),
          //       Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF999999)),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 12),

          // 🚚 ขนส่ง
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(getTranslation('shipping_thailand'), style: TextStyle(fontWeight: FontWeight.bold)),
          //     GestureDetector(
          //       onTap: () {
          //         // ไปหน้าเลือกขนส่ง
          //         Navigator.push(context, MaterialPageRoute(builder: (_) => const ShippingMethodPage()));
          //       },
          //       child: Row(
          //         children: const [
          //           Text('50฿', style: TextStyle(fontWeight: FontWeight.bold)),
          //           SizedBox(width: 4),
          //           Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF999999)),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 16),
          // ☑️ Checkbox สำหรับขอใบเสร็จ
          GestureDetector(
            onTap: () {
              setState(() {
                isRequestTaxCertificate = !isRequestTaxCertificate;
              });
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF427D9D), width: 2),
                    color: isRequestTaxCertificate ? const Color(0xFF427D9D) : Colors.transparent,
                  ),
                  child: isRequestTaxCertificate ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getTranslation('request_tax_certificate'), style: TextStyle(fontSize: 13)),
                      Text(getTranslation('tax_warning'), style: TextStyle(fontSize: 12, color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ☑️ Checkbox + ปุ่มเลือกทั้งหมด
          Row(
            children: [
              Checkbox(
                value: isSelectAll,
                onChanged: (val) {
                  setState(() {
                    isSelectAll = val ?? false;
                    _updateAllParcelsSelection();
                  });
                },
                activeColor: const Color(0xFF427D9D),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelectAll = !isSelectAll;
                    _updateAllParcelsSelection();
                  });
                },
                child: Text(getTranslation('select_all')),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 🛒 ปุ่มสินค้าทั้งหมด
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002A5D),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (selectedParcels.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('โปรดเลือกรายการที่จะชำระ'), backgroundColor: Colors.red));
                  return;
                }

                final formattedData = _formatSelectedItemsData();
                inspect(formattedData);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PaymentMethodMulti(
                          vat: formattedData['vat'],
                          orderType: formattedData['order_type'],
                          totalPrice: formattedData['total_price'],
                          items: formattedData['items'],
                        ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '${selectedParcels.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF002A5D)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(getTranslation('confirm_delivery'), style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                  Text(
                    '${_calculateTotalPrice().toStringAsFixed(2)}฿',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method สำหรับคำนวณราคารวม
  double _calculateTotalPrice() {
    double totalPrice = 0.0;

    // คำนวณราคาจากพัสดุที่เลือก
    for (LegalImport legalImport in orderController.deilveryOrders) {
      if (legalImport.delivery_orders != null) {
        for (OrdersPageNew order in legalImport.delivery_orders!) {
          if (selectedParcels.contains(order.po_no)) {
            // ใช้ราคาจาก order.order?.total_price
            double price = double.tryParse(order.order?.total_price ?? '0') ?? 0.0;
            totalPrice += price;
          }
        }
      }
    }

    // ถ้าเลือกขอใบเสร็จ ให้บวก 7%
    if (isRequestTaxCertificate) {
      totalPrice = totalPrice * 1.07;
    }

    return totalPrice;
  }

  // Method สำหรับจัดฟอร์แมตข้อมูลที่เลือก
  Map<String, dynamic> _formatSelectedItemsData() {
    List<Map<String, dynamic>> items = [];
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    double totalPrice = 0.0;

    for (LegalImport legalImport in orderController.deilveryOrders) {
      if (legalImport.delivery_orders != null) {
        for (OrdersPageNew order in legalImport.delivery_orders!) {
          if (selectedParcels.contains(order.po_no)) {
            double itemPrice = double.tryParse(order.order?.total_price ?? '0') ?? 0.0;
            totalPrice += itemPrice;

            items.add({
              "ref_no": order.code?.isNotEmpty == true ? order.code : "",
              "date": currentDate,
              "total_price": itemPrice,
              "note": order.note ?? "",
              "image": "",
            });
          }
        }
      }
    }

    // เพิ่ม VAT 7% ถ้าเลือก
    if (isRequestTaxCertificate) {
      totalPrice = totalPrice * 1.07;
    }

    return {'vat': isRequestTaxCertificate, 'order_type': 'transport_thai', 'total_price': totalPrice, 'items': items};
  }
}
