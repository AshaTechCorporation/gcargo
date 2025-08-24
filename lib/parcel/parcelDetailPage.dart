import 'package:flutter/material.dart';
import 'package:gcargo/parcel/parcelSubDetailPage.dart';
import 'package:gcargo/services/orderService.dart';

class ParcelDetailPage extends StatefulWidget {
  final String status;
  final int id;

  const ParcelDetailPage({super.key, required this.status, required this.id});

  @override
  State<ParcelDetailPage> createState() => _ParcelDetailPageState();
}

class _ParcelDetailPageState extends State<ParcelDetailPage> {
  Map<String, dynamic>? orderData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await OrderService.getDeliveryOrderById(id: widget.id);

      setState(() {
        orderData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildSectionTitle(String iconPath, String title) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: Color(0xFFE9F4FF), shape: BoxShape.circle),
          child: Center(child: Image.asset(iconPath, width: 18, height: 18)),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBox({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('เลขขนส่งจีน ${orderData?['po_no'] ?? '...'}', style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(errorMessage!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadOrderData, child: const Text('ลองใหม่')),
          ],
        ),
      );
    }

    if (orderData == null) {
      return const Center(child: Text('ไม่พบข้อมูล'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // 🔹 กล่อง: กำหนดการ
          _buildBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('assets/icons/calendar.png', 'กำหนดการ'),
                const SizedBox(height: 12),
                _buildInfoRow('ถึงโกดังจีน', '-'),
                _buildInfoRow('ออกจากโกดังจีน', '-'),
                _buildInfoRow('คาดจะถึงไทย', '-'),
                _buildInfoRow('โกดังไทยรับสินค้า', '-'),
              ],
            ),
          ),

          // 🔹 กล่อง: รายละเอียดสินค้า
          _buildBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('assets/icons/book.png', 'รายละเอียดสินค้า'),
                const SizedBox(height: 12),
                _buildInfoRow('เลขบิลสั่งซื้อ', orderData?['code'] ?? '-'),
                _buildInfoRow('เลขบิลหน้าโกดัง', orderData?['po_no'] ?? '-'),
                _buildInfoRow('ประเภทสินค้า', orderData?['store']?['name'] ?? '-'),
                _buildInfoRow('หมายเหตุของลูกค้า', orderData?['note'] ?? '-'),
              ],
            ),
          ),

          // 🔹 กล่อง: ค่าใช้จ่าย (ซ่อนถ้าสถานะเป็น รอส่งไปโกดังจีน หรือ ถึงโกดังจีน)
          if (widget.status != 'รอส่งไปโกดังจีน' && widget.status != 'ถึงโกดังจีน')
            _buildBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('assets/icons/dollar-circle.png', 'ค่าใช้จ่าย'),
                  const SizedBox(height: 12),
                  _buildInfoRow('ค่าขนส่งจีนไทย', ' 8516.00฿'),
                  _buildInfoRow('ค่าบริการ QC', ' 0฿'),
                  _buildInfoRow('ค่าตีลังไม้', ' 0฿'),
                  _buildInfoRow('รวมราคา', ' 8516.00฿'),
                ],
              ),
            ),

          // 🔹 กล่อง: การชำระเงิน (ซ่อนถ้าสถานะเป็น รอส่งไปโกดังจีน หรือ ถึงโกดังจีน)
          if (widget.status != 'รอส่งไปโกดังจีน' && widget.status != 'ถึงโกดังจีน')
            _buildBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('assets/icons/menu-board-blue.png', 'การชำระเงิน'),
                  const SizedBox(height: 12),
                  _buildInfoRow('การชำระเงิน', 'QR พร้อมเพย์'),
                  _buildInfoRow('เลขที่เอกสาร  X2504290002', '.'),
                ],
              ),
            ),

          // 🔹 กล่อง: พัสดุทั้งหมด
          _buildBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildSectionTitle('assets/icons/box.png', 'พัสดุทั้งหมด'),
                    const Spacer(),
                    Text('${_getDeliveryOrderListsCount()} ชิ้น', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _getDeliveryOrderListsCount(),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final deliveryOrderLists = _getDeliveryOrderLists();
                    final item = deliveryOrderLists[index];
                    final parcelCode = item['barcode'] ?? 'N/A';

                    return Container(
                      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        title: Text(parcelCode),
                        trailing: const Icon(Icons.chevron_right),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ParcelSubDetailPage(deliveryOrderItem: item, orderCode: orderData?['code'] ?? 'N/A')),
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods สำหรับดึงข้อมูล delivery order lists
  List<dynamic> _getDeliveryOrderLists() {
    if (orderData == null) return [];

    List<dynamic> allLists = [];
    final deliveryOrderTracks = orderData!['delivery_order_tracks'] as List<dynamic>?;

    if (deliveryOrderTracks != null) {
      for (var track in deliveryOrderTracks) {
        final deliveryOrderLists = track['delivery_order_lists'] as List<dynamic>?;
        if (deliveryOrderLists != null) {
          allLists.addAll(deliveryOrderLists);
        }
      }
    }

    return allLists;
  }

  int _getDeliveryOrderListsCount() {
    return _getDeliveryOrderLists().length;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Expanded(child: Text(label)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }
}
