import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/parcel/claimDetailPage.dart';
import 'package:gcargo/parcel/claimRefundDetailPage.dart';
import 'package:gcargo/parcel/widgets/date_range_picker_widget.dart';
import 'package:get/get.dart';

class ProblemPackagePage extends StatefulWidget {
  const ProblemPackagePage({super.key});

  @override
  State<ProblemPackagePage> createState() => _ProblemPackagePageState();
}

class _ProblemPackagePageState extends State<ProblemPackagePage> {
  late LanguageController languageController;
  String selectedStatus = 'all';
  final TextEditingController _dateController = TextEditingController(text: '1/01/2024 - 01/07/2025');

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'problem_package': 'แจ้งเคลมพัสดุ',
        'all': 'ทั้งหมด',
        'pending_review': 'รอตรวจสอบ',
        'processing': 'กำลังดำเนินการ',
        'completed': 'สำเร็จ',
        'cancelled': 'ยกเลิก',
        'select_date_range': 'เลือกช่วงวันที่',
        'no_claims_found': 'ไม่พบรายการเคลม',
        'no_claims_status': 'ไม่มีรายการในสถานะ',
        'claims_will_show_here': 'เมื่อคุณแจ้งเคลม รายการจะแสดงที่นี่',
        'delivery_number': 'เลขที่จัดส่ง',
        'order_number': 'เลขที่ออเดอร์',
        'front_bill': 'บิลหน้า',
        'document_number': 'เลขที่เอกสาร',
        'status': 'สถานะ',
        'view_details': 'ดูรายละเอียด',
        'refund_details': 'รายละเอียดการคืนเงิน',
        'try_again': 'ลองใหม่',
        'loading': 'กำลังโหลด...',
        'error': 'เกิดข้อผิดพลาด',
        'china_tracking_number': 'เลขขนส่งจีน',
        'refund_to_wallet': 'คืนเงินค่าสินค้าเป็น wallet',
        'store_no_warranty': 'ร้านค้าไม่รับประกันสินค้า',
      },
      'en': {
        'problem_package': 'Package Claim',
        'all': 'All',
        'pending_review': 'Pending Review',
        'processing': 'Processing',
        'completed': 'Completed',
        'cancelled': 'Cancelled',
        'select_date_range': 'Select Date Range',
        'no_claims_found': 'No Claims Found',
        'no_claims_status': 'No claims in status',
        'claims_will_show_here': 'When you file a claim, it will appear here',
        'delivery_number': 'Delivery Number',
        'order_number': 'Order Number',
        'front_bill': 'Front Bill',
        'document_number': 'Document Number',
        'status': 'Status',
        'view_details': 'View Details',
        'refund_details': 'Refund Details',
        'try_again': 'Try Again',
        'loading': 'Loading...',
        'error': 'Error Occurred',
        'china_tracking_number': 'China Tracking Number',
        'refund_to_wallet': 'Refund to wallet',
        'store_no_warranty': 'Store does not provide warranty',
      },
      'zh': {
        'problem_package': '包裹理赔',
        'all': '全部',
        'pending_review': '等待审核',
        'processing': '处理中',
        'completed': '已完成',
        'cancelled': '已取消',
        'select_date_range': '选择日期范围',
        'no_claims_found': '未找到理赔记录',
        'no_claims_status': '该状态下无理赔记录',
        'claims_will_show_here': '理赔记录将显示在这里',
        'delivery_number': '配送单号',
        'order_number': '订单号',
        'front_bill': '前台账单',
        'document_number': '文件编号',
        'status': '状态',
        'view_details': '查看详情',
        'refund_details': '退款详情',
        'try_again': '重试',
        'loading': '加载中...',
        'error': '发生错误',
        'china_tracking_number': '中国跟踪号',
        'refund_to_wallet': '退款到钱包',
        'store_no_warranty': '商店不提供保修',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  List<String> get statusList => [
    getTranslation('all'),
    getTranslation('pending_review'),
    getTranslation('processing'),
    getTranslation('completed'),
    getTranslation('cancelled'),
  ];

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
  }

  final List<Map<String, dynamic>> items = [
    // {
    //   'date': '02/07/2025',
    //   'deliveryNo': '00044',
    //   'orderNo': '167304',
    //   'frontBill': '000000',
    //   'documentNo': 'X2504290002',
    //   'status': 'กำลังดำเนินการ',
    // },
    // {'date': '02/07/2025', 'deliveryNo': '00043', 'orderNo': '167303', 'frontBill': '000000', 'documentNo': 'X2504290002', 'status': 'รอตรวจสอบ'},
    // {'date': '01/07/2025', 'deliveryNo': '00045', 'orderNo': '167305', 'frontBill': '000001', 'documentNo': 'X2504290003', 'status': 'สำเร็จ'},
    // {'date': '01/07/2025', 'deliveryNo': '00046', 'orderNo': '167305', 'frontBill': '000005', 'documentNo': 'X2504290005', 'status': 'ยกเลิก'},
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (var item in items) {
        if (selectedStatus != 'all' && item['status'] != getTranslation(selectedStatus)) continue;
        grouped.putIfAbsent(item['date'], () => []).add(item);
      }

      final Map<String, int> statusCounts = {
        getTranslation('all'): items.length,
        getTranslation('pending_review'): items.where((e) => e['status'] == getTranslation('pending_review')).length,
        getTranslation('processing'): items.where((e) => e['status'] == getTranslation('processing')).length,
        getTranslation('completed'): items.where((e) => e['status'] == getTranslation('completed')).length,
        getTranslation('cancelled'): items.where((e) => e['status'] == getTranslation('cancelled')).length,
      };

      return Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: Row(
            children: [
              Text(getTranslation('problem_package'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
              const Spacer(),
            ],
          ),
        ),
        body: Column(
          children: [
            // SizedBox(
            //   width: 200,
            //   child: DateRangePickerWidget(
            //     controller: _dateController,
            //     hintText: 'เลือกช่วงวันที่',
            //     onDateRangeSelected: (DateTimeRange? picked) {
            //       if (picked != null) {
            //         setState(() {
            //           // อัปเดตการแสดงผลตามวันที่ที่เลือก
            //         });
            //       }
            //     },
            //   ),
            // ),
            // 🔹 แถบสถานะ (ดีไซน์เหมือน OrderStatusPage)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                //width: 180,
                child: DateRangePickerWidget(
                  controller: _dateController,
                  hintText: getTranslation('select_date_range'),
                  onDateRangeSelected: (DateTimeRange? picked) {
                    if (picked != null) {
                      setState(() {
                        // อัปเดตการแสดงผลตามวันที่ที่เลือก
                      });
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: statusList.length,
                  itemBuilder: (_, index) {
                    final status = statusList[index];
                    final statusKey = ['all', 'pending_review', 'processing', 'completed', 'cancelled'][index];
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
            ),

            // 🔹 รายการพัสดุ
            Expanded(
              child:
                  grouped.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(getTranslation('no_claims_found'), style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      )
                      : ListView(
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
    }); // ปิด Obx
  }

  Widget _buildDeliveryCard(Map<String, dynamic> item) {
    final bool isSuccess = item['status'] == getTranslation('completed');
    final bool isCancelled = item['status'] == getTranslation('cancelled');

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
                      Text(
                        '${getTranslation('china_tracking_number')} ${item['deliveryNo']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
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
                        Text(getTranslation('refund_to_wallet'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
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
                        Text(getTranslation('store_no_warranty'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
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
