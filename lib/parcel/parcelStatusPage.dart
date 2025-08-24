import 'package:flutter/material.dart';
import 'package:gcargo/account/couponPage.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/models/legalimport.dart';
import 'package:gcargo/models/orders/ordersPageNew.dart';
import 'package:gcargo/parcel/claimPackagePage.dart';
import 'package:gcargo/parcel/parcelDetailPage.dart';
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
  final List<String> statuses = ['ทั้งหมด', 'รอส่งไปโกดังจีน', 'ถึงโกดังจีน', 'ปิดตู้', 'ถึงโกดังไทย', 'กำลังตรวจสอบ', 'รอจัดส่ง', 'สำเร็จ'];
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

  @override
  void initState() {
    super.initState();
    //_dateController.text = '01/01/2024 - 01/07/2025'; // ค่าเริ่มต้น

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

    counts['ทั้งหมด'] = totalCount;
    return counts;
  }

  // ฟังก์ชั่นสำหรับแปลงสถานะจาก API เป็นสถานะที่แสดง
  String _mapApiStatusToDisplayStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'pending_send_to_china':
      case 'รอส่งไปโกดังจีน':
        return 'รอส่งไปโกดังจีน';
      case 'arrived_china_warehouse':
      case 'ถึงโกดังจีน':
        return 'ถึงโกดังจีน';
      case 'in_transit':
      case 'ปิดตู้':
        return 'ปิดตู้';
      case 'arrived_thailand_warehouse':
      case 'ถึงโกดังไทย':
        return 'ถึงโกดังไทย';
      case 'awaiting_payment':
      case 'กำลังตรวจสอบ':
        return 'กำลังตรวจสอบ';
      case 'delivered':
      case 'รอจัดส่ง':
        return 'รอจัดส่ง';
      case 'completed':
      case 'สำเร็จ':
        return 'สำเร็จ';
      default:
        return 'รอส่งไปโกดังจีน'; // default status
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
          if (orderStatus == 'ถึงโกดังไทย') {
            allThailandParcels.add(order.code ?? '');
          }
        }
      }
    }

    if (isSelectAll) {
      // เลือกทั้งหมด
      selectedParcels.addAll(allThailandParcels);
    } else {
      // ยกเลิกการเลือกทั้งหมด
      selectedParcels.removeAll(allThailandParcels);
    }
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
                Expanded(child: Text('เลขขนส่งจีน $parcelNo', style: const TextStyle(fontWeight: FontWeight.bold))),
                //Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF427D9D))),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('เลขบิลสั่งซื้อ'), Text(orderCode, style: const TextStyle(fontWeight: FontWeight.bold))],
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('เลขบิลหน้าโกดัง'),
                status == 'รอส่งไปโกดังจีน' ? SizedBox() : Text(warehouseCode, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            status == 'กำลังตรวจสอบ' || status == 'รอจัดส่ง'
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('เลขที่เอกสาร'), const Text(' X2504290002', style: TextStyle(fontWeight: FontWeight.bold))],
                )
                : SizedBox(),

            // เพิ่ม checkbox เฉพาะสถานะ "ถึงโกดังไทย"
            Row(
              children: [
                if (status == 'ถึงโกดังไทย') ...[
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
                children: [const Text('เลขที่เอกสาร'), const Text('X2504290002', style: TextStyle(fontWeight: FontWeight.bold))],
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const Text('บริษัทขนส่งในไทย'), const Text('-', style: TextStyle(fontWeight: FontWeight.bold))],
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const Text('หมายเลขขนส่งในไทย'), const Text('-', style: TextStyle(fontWeight: FontWeight.bold))],
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
                    child: const Text('แจ้งพัสดุมีปัญหา'),
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
          if (status != 'ทั้งหมด' && orderStatus != status) continue;

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
            showActionButton: orderStatus == 'สำเร็จ',
            orderId: order.id ?? 0,
            orderCode: order.order?.code ?? 'N/A',
            warehouseCode: order.code ?? 'N/A',
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
              Text('สถานะพัสดุ', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(width: 20),
              DateRangePickerWidget(
                controller: _dateController,
                hintText: 'เลือกช่วงวันที่',
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
                ElevatedButton(onPressed: () => orderController.getDeliveryOrders(), child: Text('ลองใหม่')),
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
                  hintText: 'ค้นหาเลขที่ออเดอร์/เลขขนส่งจีน',
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
              Expanded(child: ListView(children: _getCardsForStatus(statuses[selectedStatusIndex]))),
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
          GestureDetector(
            onTap: () {
              // ไปหน้าคูปองส่วนลด
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CouponPage()));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('คูปองส่วนลด', style: TextStyle(fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF999999)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 🚚 ขนส่ง
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ขนส่งไทย  รถเหมาบริษัท', style: TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  // ไปหน้าเลือกขนส่ง
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ShippingMethodPage()));
                },
                child: Row(
                  children: const [
                    Text('50฿', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF999999)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ⚠️ แจ้งเตือนภาษี
          GestureDetector(
            onTap: () {
              setState(() {
                isRequestTaxCertificate = !isRequestTaxCertificate;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ขอใบรับรองภาษีหัก ณ ที่จ่าย 1%', style: TextStyle(fontSize: 13)),
                      Text('หากต้องการหัก ณ ที่จ่าย กรุณายืนยันก่อนชำระเงิน', style: TextStyle(fontSize: 12, color: Colors.red)),
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
                child: const Text('เลือกทั้งหมด'),
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
              onPressed: () {},
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
                      const Text('สินค้าทั้งหมด', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                  const Text('8,566.00฿', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
