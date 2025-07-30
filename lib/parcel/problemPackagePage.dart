import 'package:flutter/material.dart';
import 'package:gcargo/parcel/claimDetailPage.dart';
import 'package:gcargo/parcel/claimRefundDetailPage.dart';

class ProblemPackagePage extends StatefulWidget {
  const ProblemPackagePage({super.key});

  @override
  State<ProblemPackagePage> createState() => _ProblemPackagePageState();
}

class _ProblemPackagePageState extends State<ProblemPackagePage> {
  String selectedStatus = 'ทั้งหมด';
  final TextEditingController _dateController = TextEditingController(text: '1/01/2024 - 01/07/2025');
  final List<String> statusList = ['ทั้งหมด', 'รอตรวจสอบ', 'กำลังดำเนินการ', 'สำเร็จ', 'ยกเลิก'];

  final List<Map<String, dynamic>> items = [
    {
      'date': '02/07/2025',
      'deliveryNo': '00044',
      'orderNo': '167304',
      'frontBill': '000000',
      'documentNo': 'X2504290002',
      'status': 'กำลังดำเนินการ',
    },
    {'date': '02/07/2025', 'deliveryNo': '00043', 'orderNo': '167303', 'frontBill': '000000', 'documentNo': 'X2504290002', 'status': 'รอตรวจสอบ'},
    {'date': '01/07/2025', 'deliveryNo': '00045', 'orderNo': '167305', 'frontBill': '000001', 'documentNo': 'X2504290003', 'status': 'สำเร็จ'},
    {'date': '01/07/2025', 'deliveryNo': '00046', 'orderNo': '167305', 'frontBill': '000005', 'documentNo': 'X2504290005', 'status': 'ยกเลิก'},
  ];

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var item in items) {
      if (selectedStatus != 'ทั้งหมด' && item['status'] != selectedStatus) continue;
      grouped.putIfAbsent(item['date'], () => []).add(item);
    }

    final Map<String, int> statusCounts = {
      for (var status in statusList) status: items.where((e) => status == 'ทั้งหมด' || e['status'] == status).length,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            const Text('แจ้งเคลมพัสดุ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
            const Spacer(),
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6), color: Colors.white),
              child: Row(
                children: [
                  Image.asset('assets/icons/calendar_icon.png', width: 18),
                  const SizedBox(width: 4),
                  Text(_dateController.text, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 🔹 แถบสถานะ
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: statusList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final status = statusList[i];
                final isSelected = status == selectedStatus;
                final count = statusCounts[status] ?? 0;

                return GestureDetector(
                  onTap: () => setState(() => selectedStatus = status),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF246BFD) : Colors.white,
                      border: Border.all(color: const Color(0xFF246BFD)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Text(status, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF246BFD), fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('$count', style: TextStyle(fontSize: 12, color: isSelected ? const Color(0xFF246BFD) : Colors.black)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔹 รายการพัสดุ
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children:
                  grouped.entries.map((e) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...e.value.map((item) => _buildDeliveryCard(item)),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> item) {
    final bool isSuccess = item['status'] == 'สำเร็จ';
    final bool isCancelled = item['status'] == 'ยกเลิก';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (isSuccess == true) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ClaimRefundDetailPage()));
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ClaimDetailPage(status: item['status'])));
            }
          },
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🟦 ส่วนบน
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEAF1FF)),
                        child: Center(child: Image.asset('assets/icons/box.png', width: 22, height: 22)),
                      ),
                      const SizedBox(width: 12),
                      Text('เลขขนส่งจีน ${item['deliveryNo']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),

                // ✅ สำเร็จ
                if (isSuccess)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xFFEAF7E9), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Image.asset('assets/icons/iconsuccess.png', width: 20, height: 20),
                        const SizedBox(width: 8),
                        const Text('คืนเงินค่าสินค้าเป็น wallet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                      ],
                    ),
                  ),

                // ❌ ยกเลิก
                if (isCancelled)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xFFFFF2F2), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Image.asset('assets/icons/info-circle.png', width: 20, height: 20),
                        const SizedBox(width: 8),
                        const Text('ร้านค้าไม่รับประกันสินค้า', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
