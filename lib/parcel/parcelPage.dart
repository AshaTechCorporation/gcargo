import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/parcel_controller.dart';
import 'package:gcargo/parcel/claimDetailPage.dart';

class ParcelPage extends StatefulWidget {
  const ParcelPage({super.key});

  @override
  State<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends State<ParcelPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _statusTabController;
  int selectedTopTab = 1; // ✅ เปลี่ยนเป็น 1 (สถานะพัสดุ) เพื่อแสดงข้อมูลจาก API

  // Initialize ParcelController
  final ParcelController parcelController = Get.put(ParcelController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _statusTabController = TabController(length: 3, vsync: this); // เปลี่ยนเป็น 3 tabs: ทั้งหมด, กำลังส่ง, เสร็จสิ้น

    // Listen to tab changes
    _statusTabController.addListener(() {
      if (!_statusTabController.indexIsChanging) {
        parcelController.changeTab(_statusTabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _statusTabController.dispose();
    super.dispose();
  }

  Widget _buildTopTabButton(String label, int index) {
    final bool isSelected = selectedTopTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTopTab = index),
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? kButtonColor : Colors.white,
            border: Border.all(color: kButtonColor),
            borderRadius: BorderRadius.only(
              topLeft: index == 0 ? const Radius.circular(8) : Radius.zero,
              bottomLeft: index == 0 ? const Radius.circular(8) : Radius.zero,
              topRight: index == 2 ? const Radius.circular(8) : Radius.zero,
              bottomRight: index == 2 ? const Radius.circular(8) : Radius.zero,
            ),
          ),
          child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildParcelList(List<String> documentIds, String statusLabel) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: documentIds.length,
      itemBuilder: (context, index) {
        final docId = documentIds[index];
        final statusColor = {'รอดำเนินการ': Colors.orange, 'สำเร็จ': Colors.green, 'ยกเลิก': Colors.red}[statusLabel] ?? Colors.black;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: ListTile(
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const ClaimDetailPage()));
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: kButtonColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Image.asset('assets/icons/document-text.png', width: 24, height: 24, color: kButtonColor),
            ),
            title: Text('เลขที่เอกสาร $docId', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('8516.00฿'),
            trailing: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildParcelListFromAPI() {
    if (parcelController.isLoading.value) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }

    if (parcelController.hasError.value) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(parcelController.errorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => parcelController.refreshData(),
                style: ElevatedButton.styleFrom(backgroundColor: kButtonColor, foregroundColor: Colors.white),
                child: const Text('ลองใหม่'),
              ),
            ],
          ),
        ),
      );
    }

    final currentOrders = parcelController.currentTabOrders;

    if (currentOrders.isEmpty) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(32), child: Text('ไม่มีข้อมูลพัสดุ', style: TextStyle(fontSize: 16, color: Colors.grey))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: currentOrders.length,
      itemBuilder: (context, index) {
        final legalImport = currentOrders[index];
        final deliveryOrders = legalImport.delivery_orders ?? [];

        // แสดงแต่ละ delivery order
        return Column(
          children:
              deliveryOrders.map((order) {
                final statusText = parcelController.getStatusText(order.status);
                final statusColor = _getStatusColor(order.status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: ListTile(
                    onTap: () {
                      // สามารถนำไปหน้ารายละเอียดได้
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ClaimDetailPage(deliveryOrderId: order.id ?? 0)));
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: kButtonColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.local_shipping, color: kButtonColor, size: 24),
                    ),
                    title: Text(order.code ?? 'ไม่มีรหัส', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PO: ${order.po_no ?? 'ไม่มีข้อมูล'}'),
                        Text('วันที่: ${order.date ?? 'ไม่มีข้อมูล'}'),
                        if (order.member?.fname != null && order.member?.lname != null) Text('ผู้รับ: ${order.member!.fname} ${order.member!.lname}'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'arrived_china_warehouse':
        return Colors.blue;
      case 'in_transit':
        return Colors.orange;
      case 'arrived_thailand_warehouse':
        return Colors.green;
      case 'awaiting_payment':
        return Colors.red;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Tabs บนสุด
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [_buildTopTabButton('สถานะออเดอร์', 0), _buildTopTabButton('สถานะพัสดุ', 1), _buildTopTabButton('แจ้งพัสดุมีปัญหา', 2)],
              ),
            ),

            // 🔍 ช่องค้นหา
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Container(
                height: 36,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: const Text('ค้นหาเลขที่เอกสาร', style: TextStyle(color: Colors.grey)),
              ),
            ),

            // 🟦 Tabs สถานะ (แสดงเฉพาะเมื่อเลือก "สถานะพัสดุ")
            if (selectedTopTab == 1)
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _statusTabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  indicatorColor: kButtonColor,
                  indicatorWeight: 2.5,
                  tabs: const [Tab(text: 'ทั้งหมด'), Tab(text: 'กำลังส่ง'), Tab(text: 'เสร็จสิ้น')],
                ),
              ),

            // 📆 วันที่
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(alignment: Alignment.centerLeft, child: Text('02/07/2025', style: TextStyle(color: Colors.black54))),
            ),

            // 🔻 แสดงรายการตามสถานะ
            const SizedBox(height: 8),
            Expanded(
              child:
                  selectedTopTab == 1
                      ? Obx(
                        () => TabBarView(
                          controller: _statusTabController,
                          children: [
                            _buildParcelListFromAPI(), // ทั้งหมด
                            _buildParcelListFromAPI(), // กำลังส่ง
                            _buildParcelListFromAPI(), // เสร็จสิ้น
                          ],
                        ),
                      )
                      : selectedTopTab == 0
                      ? _buildParcelList(['C181211003', 'C181211004'], 'สถานะออเดอร์') // สถานะออเดอร์
                      : _buildParcelList(['C181211005'], 'แจ้งพัสดุมีปัญหา'), // แจ้งพัสดุมีปัญหา
            ),
          ],
        ),
      ),
    );
  }
}
