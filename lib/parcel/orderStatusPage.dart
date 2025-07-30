import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/models/orders/ordersPage.dart';
import 'package:gcargo/parcel/POOrderDetailPage.dart';
import 'package:gcargo/parcel/detailOrderPage.dart';
import 'package:gcargo/widgets/RemarkDialog.dart';
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
  String selectedStatus = 'ทั้งหมด';
  TextEditingController _dateController = TextEditingController();

  final List<String> statusList = ['ทั้งหมด', 'รอตรวจสอบ', 'รอชำระเงิน', 'รอดำเนินการ', 'เตรียมจัดส่ง', 'จัดส่งแล้ว', 'ยกเลิก'];

  // Status mapping from API to Thai
  String _getStatusInThai(String? apiStatus) {
    switch (apiStatus) {
      case 'awaiting_summary':
        return 'รอตรวจสอบ';
      case 'awaiting_payment':
        return 'รอชำระเงิน';
      case 'in_progress':
        return 'รอดำเนินการ';
      case 'preparing_shipment':
        return 'เตรียมจัดส่ง';
      case 'shipped':
        return 'จัดส่งแล้ว';
      case 'cancelled':
        return 'ยกเลิก';
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

  // Get shipping type in Thai
  String _getShippingTypeInThai(String? shippingType) {
    switch (shippingType) {
      case 'car':
        return 'ขนส่งทางรถ';
      case 'ship':
        return 'ขนส่งทางเรือ';
      default:
        return shippingType ?? 'ไม่ระบุ';
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = '01/01/2024 - 01/07/2025'; // ค่าเริ่มต้น
    orderController = Get.put(OrderController());
    orderController.getOrders();
    orderController.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading state
      if (orderController.isLoading.value) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
            title: Text('ออเดอร์', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
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
            title: Text('ออเดอร์', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
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
      final displayOrders = <Map<String, dynamic>>[];

      for (var parentOrder in orderController.orders) {
        // Only process parent orders that have nested orders
        if (parentOrder.orders != null && parentOrder.orders!.isNotEmpty) {
          // Add each nested order to display list
          for (var nestedOrder in parentOrder.orders!) {
            displayOrders.add({
              'date': _formatDate(nestedOrder.date),
              'status': _getStatusInThai(nestedOrder.status),
              'code': nestedOrder.code ?? '',
              'transport': _getShippingTypeInThai(nestedOrder.shipping_type),
              'total': double.tryParse(nestedOrder.total_price ?? '0') ?? 0.0,
              'originalOrder': nestedOrder, // Keep reference to original order
              'parentOrder': parentOrder, // Keep reference to parent order
            });
          }
        }
        // Skip parent orders without nested orders - don't show them as cards
      }

      // Group orders by date and filter by status
      final groupedOrders = <String, List<Map<String, dynamic>>>{};
      for (var order in displayOrders) {
        if (selectedStatus != 'ทั้งหมด' && order['status'] != selectedStatus) continue;
        final dateKey = order['date'] as String? ?? '';
        groupedOrders.putIfAbsent(dateKey, () => []).add(order);
      }

      // Calculate status counts
      final Map<String, int> statusCounts = {
        for (var status in statusList)
          status: status == 'ทั้งหมด' ? displayOrders.length : displayOrders.where((order) => order['status'] == status).length,
      };

      // Show empty state if no orders
      if (displayOrders.isEmpty) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
            title: Text('ออเดอร์', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('ยังไม่มีออเดอร์', style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('เมื่อคุณสั่งซื้อสินค้า ออเดอร์จะแสดงที่นี่', style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          ),
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
      );
    }); // Close Obx
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'];
    final isCancelled = status == 'ยกเลิก';
    final isShipped = status == 'จัดส่งแล้ว';
    final isPending = status == 'รอตรวจสอบ';
    final isAwaitingPayment = status == 'รอชำระเงิน';
    final isInProgress = status == 'รอดำเนินการ';
    final isPreparing = status == 'เตรียมจัดส่ง';

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
      onTap: () {
        // Navigate to DetailOrderPage with order data
        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailOrderPage(orderId: order['originalOrder'].id ?? 0)));
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
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     OutlinedButton(
              //       onPressed: () async {
              //         print(55555);
              //         showDialog(
              //           context: context,
              //           builder:
              //               (_) => RemarkDialog(
              //                 initialText: '', // หรือค่าที่มีอยู่
              //                 onSave: (text) {
              //                   print('บันทึกข้อความ: $text');
              //                   // ทำอย่างอื่นต่อ เช่นส่งไปเซิร์ฟเวอร์
              //                 },
              //               ),
              //         );
              //       },
              //       style: OutlinedButton.styleFrom(foregroundColor: Colors.grey),
              //       child: const Text('ยกเลิก'),
              //     ),
              //     SizedBox(width: 8),
              //     ElevatedButton(
              //       onPressed: () {
              //         Navigator.push(context, MaterialPageRoute(builder: (_) => DetailOrderPage(orderId: order['originalOrder'].id ?? 0)));
              //       },
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: const Color(0xFF1E3C72), // ✅ kButtonColor
              //       ),
              //       child: Text('สั่งซื้ออีกครั้ง', style: TextStyle(color: Colors.white, fontSize: 16)),
              //     ),
              //   ],
              // ),
            ],
          ],
        ),
      ),
    );
  }
}
