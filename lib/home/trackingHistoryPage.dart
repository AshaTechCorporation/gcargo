import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/home/trackingDetailPage.dart';
import 'package:get/get.dart';

class TrackingHistoryPage extends StatefulWidget {
  const TrackingHistoryPage({super.key});

  @override
  State<TrackingHistoryPage> createState() => _TrackingHistoryPageState();
}

class _TrackingHistoryPageState extends State<TrackingHistoryPage> {
  int selectedTab = 0;
  String selectedStatus = 'ทั้งหมด'; // Keep original for functionality
  late LanguageController languageController;

  // Original statuses for functionality (never changes)
  final List<String> originalStatuses = ['ทั้งหมด', 'รอส่งไปโกดังจีน', 'ถึงโกดังจีน', 'ปิดถุง', 'ถึงโกดังไทย', 'กำลังตรวจสอบ', 'รอตัดส่ง', 'สำเร็จ'];

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'tracking_history': 'ประวัติการติดตาม',
        'all': 'ทั้งหมด',
        'waiting_to_china': 'รอส่งไปโกดังจีน',
        'arrived_china': 'ถึงโกดังจีน',
        'bag_closed': 'ปิดถุง',
        'arrived_thailand': 'ถึงโกดังไทย',
        'inspecting': 'กำลังตรวจสอบ',
        'ready_to_ship': 'รอตัดส่ง',
        'completed': 'สำเร็จ',
        'tracking_number': 'หมายเลขติดตาม',
        'status': 'สถานะ',
        'date': 'วันที่',
        'items': 'รายการ',
        'no_tracking_history': 'ไม่มีประวัติการติดตาม',
        'start_tracking': 'เริ่มติดตามพัสดุ',
        'loading': 'กำลังโหลด...',
        'error_occurred': 'เกิดข้อผิดพลาด',
        'try_again': 'ลองใหม่อีกครั้ง',
        'refresh': 'รีเฟรช',
        'view_details': 'ดูรายละเอียด',
        'search_tracking': 'ค้นหาหมายเลขติดตาม',
        'filter_by_status': 'กรองตามสถานะ',
        'clear_filter': 'ล้างตัวกรอง',
      },
      'en': {
        'tracking_history': 'Tracking History',
        'all': 'All',
        'waiting_to_china': 'Waiting to China Warehouse',
        'arrived_china': 'Arrived China Warehouse',
        'bag_closed': 'Bag Closed',
        'arrived_thailand': 'Arrived Thailand Warehouse',
        'inspecting': 'Inspecting',
        'ready_to_ship': 'Ready to Ship',
        'completed': 'Completed',
        'tracking_number': 'Tracking Number',
        'status': 'Status',
        'date': 'Date',
        'items': 'Items',
        'no_tracking_history': 'No Tracking History',
        'start_tracking': 'Start Tracking Parcels',
        'loading': 'Loading...',
        'error_occurred': 'An Error Occurred',
        'try_again': 'Try Again',
        'refresh': 'Refresh',
        'view_details': 'View Details',
        'search_tracking': 'Search Tracking Number',
        'filter_by_status': 'Filter by Status',
        'clear_filter': 'Clear Filter',
      },
      'zh': {
        'tracking_history': '追踪历史',
        'all': '全部',
        'waiting_to_china': '等待发往中国仓库',
        'arrived_china': '到达中国仓库',
        'bag_closed': '封袋',
        'arrived_thailand': '到达泰国仓库',
        'inspecting': '检查中',
        'ready_to_ship': '准备发货',
        'completed': '已完成',
        'tracking_number': '追踪号码',
        'status': '状态',
        'date': '日期',
        'items': '项目',
        'no_tracking_history': '无追踪历史',
        'start_tracking': '开始追踪包裹',
        'loading': '加载中...',
        'error_occurred': '发生错误',
        'try_again': '重试',
        'refresh': '刷新',
        'view_details': '查看详情',
        'search_tracking': '搜索追踪号码',
        'filter_by_status': '按状态筛选',
        'clear_filter': '清除筛选',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  // Display statuses with translations
  List<String> get displayStatuses => [
    getTranslation('all'),
    getTranslation('waiting_to_china'),
    getTranslation('arrived_china'),
    getTranslation('bag_closed'),
    getTranslation('arrived_thailand'),
    getTranslation('inspecting'),
    getTranslation('ready_to_ship'),
    getTranslation('completed'),
  ];

  // Get translated status for display
  String getStatusTranslation(String originalStatus) {
    final statusMap = {
      'ทั้งหมด': getTranslation('all'),
      'รอส่งไปโกดังจีน': getTranslation('waiting_to_china'),
      'ถึงโกดังจีน': getTranslation('arrived_china'),
      'ปิดถุง': getTranslation('bag_closed'),
      'ถึงโกดังไทย': getTranslation('arrived_thailand'),
      'กำลังตรวจสอบ': getTranslation('inspecting'),
      'รอตัดส่ง': getTranslation('ready_to_ship'),
      'สำเร็จ': getTranslation('completed'),
    };
    return statusMap[originalStatus] ?? originalStatus;
  }

  final Color kButtonColor = const Color(0xFF427D9D);

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
  }

  // Mock data สำหรับแต่ละสถานะ
  final Map<String, List<Map<String, dynamic>>> mockData = {
    // 'ทั้งหมด': [
    //   {'trackingNo': 'TH001', 'status': 'สำเร็จ', 'date': '2025-01-31', 'items': 3},
    //   {'trackingNo': 'TH002', 'status': 'รอตัดส่ง', 'date': '2025-01-30', 'items': 2},
    //   {'trackingNo': 'TH003', 'status': 'กำลังตรวจสอบ', 'date': '2025-01-29', 'items': 1},
    //   {'trackingNo': 'TH004', 'status': 'ถึงโกดังไทย', 'date': '2025-01-28', 'items': 4},
    //   {'trackingNo': 'TH005', 'status': 'ปิดถุง', 'date': '2025-01-27', 'items': 2},
    //   {'trackingNo': 'TH006', 'status': 'ถึงโกดังจีน', 'date': '2025-01-26', 'items': 3},
    //   {'trackingNo': 'TH007', 'status': 'รอส่งไปโกดังจีน', 'date': '2025-01-25', 'items': 1},
    // ],
    // 'รอส่งไปโกดังจีน': [
    //   {'trackingNo': 'TH007', 'status': 'รอส่งไปโกดังจีน', 'date': '2025-01-25', 'items': 1},
    //   {'trackingNo': 'TH008', 'status': 'รอส่งไปโกดังจีน', 'date': '2025-01-24', 'items': 2},
    // ],
    // 'ถึงโกดังจีน': [
    //   {'trackingNo': 'TH006', 'status': 'ถึงโกดังจีน', 'date': '2025-01-26', 'items': 3},
    //   {'trackingNo': 'TH009', 'status': 'ถึงโกดังจีน', 'date': '2025-01-23', 'items': 1},
    // ],
    // 'ปิดถุง': [
    //   {'trackingNo': 'TH005', 'status': 'ปิดถุง', 'date': '2025-01-27', 'items': 2},
    //   {'trackingNo': 'TH010', 'status': 'ปิดถุง', 'date': '2025-01-22', 'items': 3},
    // ],
    // 'ถึงโกดังไทย': [
    //   {'trackingNo': 'TH004', 'status': 'ถึงโกดังไทย', 'date': '2025-01-28', 'items': 4},
    //   {'trackingNo': 'TH011', 'status': 'ถึงโกดังไทย', 'date': '2025-01-21', 'items': 2},
    // ],
    // 'กำลังตรวจสอบ': [
    //   {'trackingNo': 'TH003', 'status': 'กำลังตรวจสอบ', 'date': '2025-01-29', 'items': 1},
    //   {'trackingNo': 'TH012', 'status': 'กำลังตรวจสอบ', 'date': '2025-01-20', 'items': 3},
    // ],
    // 'รอตัดส่ง': [
    //   {'trackingNo': 'TH002', 'status': 'รอตัดส่ง', 'date': '2025-01-30', 'items': 2},
    //   {'trackingNo': 'TH013', 'status': 'รอตัดส่ง', 'date': '2025-01-19', 'items': 1},
    // ],
    // 'สำเร็จ': [
    //   {'trackingNo': 'TH001', 'status': 'สำเร็จ', 'date': '2025-01-31', 'items': 3},
    //   {'trackingNo': 'TH014', 'status': 'สำเร็จ', 'date': '2025-01-18', 'items': 2},
    // ],
  };

  // คำนวณจำนวนแต่ละสถานะ
  Map<String, int> get statusCounts {
    return {
      'ทั้งหมด': mockData['ทั้งหมด']?.length ?? 0,
      'รอส่งไปโกดังจีน': mockData['รอส่งไปโกดังจีน']?.length ?? 0,
      'ถึงโกดังจีน': mockData['ถึงโกดังจีน']?.length ?? 0,
      'ปิดถุง': mockData['ปิดถุง']?.length ?? 0,
      'ถึงโกดังไทย': mockData['ถึงโกดังไทย']?.length ?? 0,
      'กำลังตรวจสอบ': mockData['กำลังตรวจสอบ']?.length ?? 0,
      'รอตัดส่ง': mockData['รอตัดส่ง']?.length ?? 0,
      'สำเร็จ': mockData['สำเร็จ']?.length ?? 0,
    };
  }

  Widget _buildTab(String label, int count, int index) {
    final bool isActive = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
          selectedStatus = originalStatuses[index]; // Use original for functionality
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isActive ? kButtonColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kButtonColor),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: isActive ? Colors.white : kButtonColor, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 10,
              backgroundColor: isActive ? Colors.white : kButtonColor,
              child: Text('$count', style: TextStyle(color: isActive ? kButtonColor : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingDetailPage())),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 🔵 Icon in circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: Color(0xFFE9F4FF), shape: BoxShape.circle),
                  child: Center(child: Image.asset('assets/icons/box-search.png', width: 18, height: 18)),
                ),
                const SizedBox(width: 8),
                const Expanded(child: Text('เลขขนส่งจีน YT7518613489991', style: TextStyle(fontWeight: FontWeight.bold))),
                Text('รอตรวจสอบ', style: TextStyle(fontSize: 12, color: Color(0xFF427D9D), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('รูปภาพอ้างอิง', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/image14.png', width: 80, height: 80, fit: BoxFit.cover),
                ),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/image14.png', width: 80, height: 80, fit: BoxFit.cover),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilteredList() {
    List<Map<String, dynamic>> currentData = mockData[selectedStatus] ?? [];

    if (currentData.isEmpty) {
      return [
        const SizedBox(height: 50),
        Center(
          child: Column(
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(getTranslation('no_tracking_history'), style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      ];
    }

    // จัดกลุ่มตามวันที่
    Map<String, List<Map<String, dynamic>>> groupedByDate = {};
    for (var item in currentData) {
      String date = item['date'];
      groupedByDate.putIfAbsent(date, () => []).add(item);
    }

    List<Widget> widgets = [];
    groupedByDate.forEach((date, items) {
      widgets.add(
        Padding(padding: const EdgeInsets.only(top: 16, bottom: 8), child: Text(date, style: const TextStyle(fontWeight: FontWeight.bold))),
      );

      for (int i = 0; i < items.length; i++) {
        widgets.add(_buildCardItem());
      }
    });

    return widgets;
  }

  Widget _buildTrackingCard(Map<String, dynamic> item) {
    Color statusColor = _getStatusColor(item['status']);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingDetailPage())),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(item['trackingNo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(getStatusTranslation(item['status']), style: TextStyle(color: statusColor, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${getTranslation('items')}: ${item['items']} ชิ้น', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${getTranslation('date')}: ${item['date']}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      const Text('ผู้ส่ง: นาย ก', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/image14.png', width: 80, height: 80, fit: BoxFit.cover),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'สำเร็จ':
        return Colors.green;
      case 'รอตัดส่ง':
        return Colors.orange;
      case 'กำลังตรวจสอบ':
        return Colors.blue;
      case 'ถึงโกดังไทย':
        return Colors.purple;
      case 'ปิดถุง':
        return Colors.indigo;
      case 'ถึงโกดังจีน':
        return Colors.teal;
      case 'รอส่งไปโกดังจีน':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: Text(getTranslation('tracking_history'), style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // 🔹 Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      displayStatuses.asMap().entries.map((entry) {
                        int index = entry.key;
                        String displayStatus = entry.value;
                        String originalStatus = originalStatuses[index];
                        int count = statusCounts[originalStatus] ?? 0;
                        return _buildTab(displayStatus, count, index);
                      }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 รายการข้อมูล
              ...(_buildFilteredList()),
            ],
          ),
        ),
      ),
    );
  }
}
