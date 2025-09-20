import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/home/trackingHistoryPage.dart';
import 'package:gcargo/home/unclaimedParcelDetailPage.dart';
import 'package:get/get.dart';

class TrackingOwnerPage extends StatelessWidget {
  const TrackingOwnerPage({super.key});

  String getTranslation(String key) {
    final languageController = Get.find<LanguageController>();
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'find_owner': 'ตามหาเจ้าของ',
        'tracking_owner': 'ตามหาเจ้าของ',
        'history': 'ประวัติ',
        'tracking_history': 'ประวัติการตามหา',
        'no_unclaimed_parcels': 'ไม่มีพัสดุที่ยังไม่มีเจ้าของ',
        'unclaimed_parcels': 'พัสดุที่ยังไม่มีเจ้าของ',
        'tracking_number': 'หมายเลขติดตาม',
        'date_received': 'วันที่รับ',
        'view_details': 'ดูรายละเอียด',
        'claim_parcel': 'รับพัสดุ',
        'contact_owner': 'ติดต่อเจ้าของ',
        'parcel_info': 'ข้อมูลพัสดุ',
        'loading': 'กำลังโหลด...',
        'error_occurred': 'เกิดข้อผิดพลาด',
        'try_again': 'ลองใหม่อีกครั้ง',
        'refresh': 'รีเฟรช',
        'search_tracking': 'ค้นหาหมายเลขติดตาม',
        'enter_tracking_number': 'กรอกหมายเลขติดตาม',
        'search': 'ค้นหา',
        'recent_searches': 'การค้นหาล่าสุด',
        'clear_history': 'ล้างประวัติ',
        'storage_warning':
            'บริษัทจะจัดเก็บสินค้าที่ไม่มีผู้แสดงความเป็นเจ้าของไว้ไม่เกิน 30 วัน หากพ้นกำหนดโดยไม่มีการยืนยัน บริษัทขอสงวนสิทธิ์ในการดำเนินการตามดุลยพินิจ\nและไม่รับผิดชอบต่อความเสียหายที่อาจเกิดขึ้น',
      },
      'en': {
        'find_owner': 'Find Owner',
        'tracking_owner': 'Find Owner',
        'history': 'History',
        'tracking_history': 'Tracking History',
        'no_unclaimed_parcels': 'No Unclaimed Parcels',
        'unclaimed_parcels': 'Unclaimed Parcels',
        'tracking_number': 'Tracking Number',
        'date_received': 'Date Received',
        'view_details': 'View Details',
        'claim_parcel': 'Claim Parcel',
        'contact_owner': 'Contact Owner',
        'parcel_info': 'Parcel Info',
        'loading': 'Loading...',
        'error_occurred': 'An Error Occurred',
        'try_again': 'Try Again',
        'refresh': 'Refresh',
        'search_tracking': 'Search Tracking Number',
        'enter_tracking_number': 'Enter Tracking Number',
        'search': 'Search',
        'recent_searches': 'Recent Searches',
        'clear_history': 'Clear History',
        'storage_warning':
            'The company will store unclaimed items for no more than 30 days. If the deadline passes without confirmation, the company reserves the right to take action at its discretion\nand is not responsible for any damages that may occur.',
      },
      'zh': {
        'find_owner': '寻找失主',
        'tracking_owner': '寻找失主',
        'history': '历史',
        'tracking_history': '追踪历史',
        'no_unclaimed_parcels': '无无人认领包裹',
        'unclaimed_parcels': '无人认领包裹',
        'tracking_number': '追踪号码',
        'date_received': '接收日期',
        'view_details': '查看详情',
        'claim_parcel': '认领包裹',
        'contact_owner': '联系失主',
        'parcel_info': '包裹信息',
        'loading': '加载中...',
        'error_occurred': '发生错误',
        'try_again': '重试',
        'refresh': '刷新',
        'search_tracking': '搜索追踪号码',
        'enter_tracking_number': '输入追踪号码',
        'search': '搜索',
        'recent_searches': '最近搜索',
        'clear_history': '清除历史',
        'storage_warning': '公司将保存无人认领的物品不超过30天。如果超过期限而没有确认，公司保留根据自己的判断采取行动的权利\n并且不对可能发生的任何损害负责。',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  final List<Map<String, dynamic>> trackingData = const [
    // {
    //   'date': '02/07/2025',
    //   'items': [
    //     {
    //       'trackingNo': 'YT7518613489991',
    //       'images': ['assets/images/image11.png', 'assets/images/image14.png'],
    //     },
    //   ],
    // },
    // {
    //   'date': '01/07/2025',
    //   'items': [
    //     {
    //       'trackingNo': 'YT7518613489992',
    //       'images': ['assets/images/image11.png', 'assets/images/image14.png'],
    //     },
    //   ],
    // },
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black), onPressed: () => Navigator.pop(context)),
              Text(getTranslation('find_owner'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingHistoryPage())),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(getTranslation('history'), style: TextStyle(color: kButtonColor, fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ],
          ),
        ),

        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 4),

            // 🔍 ช่องค้นหา
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: getTranslation('search_tracking'),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔴 แจ้งเตือน
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Text(getTranslation('storage_warning'), style: TextStyle(color: kTextRedWanningColor, fontSize: 14)),
            ),

            // 📦 รายการตามวัน
            if (trackingData.isEmpty) ...[
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(getTranslation('no_unclaimed_parcels'), style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              ),
            ] else ...[
              ...trackingData.map((section) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section['date'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextgreyColor)),
                    const SizedBox(height: 8),
                    ...List.generate(section['items'].length, (index) {
                      final item = section['items'][index];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UnclaimedParcelDetailPage())),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[200], // หรือใช้สีอื่นที่ต้องการ
                                    ),
                                    child: Center(child: Image.asset('assets/icons/box-search.png', width: 24, height: 24)),
                                  ),

                                  const SizedBox(width: 8),
                                  Text(getTranslation('tracking_number'), style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 4),
                                  Text(item['trackingNo'], style: const TextStyle(fontSize: 16, color: kButtonColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Padding(padding: EdgeInsets.only(left: 32), child: Text(getTranslation('parcel_info'), style: TextStyle(fontSize: 16))),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 32),
                                child: Row(
                                  children:
                                      (item['images'] as List<String>).map((imgPath) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.asset(imgPath, width: 60, height: 60, fit: BoxFit.cover),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
