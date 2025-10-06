import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RewardHistoryPage extends StatefulWidget {
  const RewardHistoryPage({super.key});

  @override
  State<RewardHistoryPage> createState() => _RewardHistoryPageState();
}

class _RewardHistoryPageState extends State<RewardHistoryPage> {
  int selectedTabIndex = 0;
  late LanguageController languageController;
  late HomeController homeController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'reward_history': 'ประวัติการแลก',
        'all': 'ทั้งหมด',
        'pending': 'รอตรวจสอบ',
        'approved': 'อนุมัติแล้ว',
        'processing': 'กำลังดำเนินการ',
        'shipped': 'จัดส่งแล้ว',
        'completed': 'สำเร็จ',
        'rejected': 'ปฏิเสธ',
        'canceled': 'ยกเลิก',
        'expired': 'หมดอายุ',
        'no_history': 'ไม่มีประวัติการแลก',
        'start_redeeming': 'เริ่มแลกของรางวัล',
        'points': 'แต้ม',
        'status': 'สถานะ',
        'date': 'วันที่',
        'reward_item': 'รายการรางวัล',
        'loading': 'กำลังโหลด...',
        'error_occurred': 'เกิดข้อผิดพลาด',
        'try_again': 'ลองใหม่อีกครั้ง',
        'filter_by_status': 'กรองตามสถานะ',
        'total_points_used': 'แต้มที่ใช้ทั้งหมด',
        'quantity': 'จำนวน',
      },
      'en': {
        'reward_history': 'Reward History',
        'all': 'All',
        'pending': 'Pending',
        'approved': 'Approved',
        'processing': 'Processing',
        'shipped': 'Shipped',
        'completed': 'Completed',
        'rejected': 'Rejected',
        'canceled': 'Canceled',
        'expired': 'Expired',
        'no_history': 'No Reward History',
        'start_redeeming': 'Start Redeeming Rewards',
        'points': 'Points',
        'status': 'Status',
        'date': 'Date',
        'reward_item': 'Reward Item',
        'loading': 'Loading...',
        'error_occurred': 'An Error Occurred',
        'try_again': 'Try Again',
        'filter_by_status': 'Filter by Status',
        'total_points_used': 'Total Points Used',
        'quantity': 'Quantity',
      },
      'zh': {
        'reward_history': '兑换历史',
        'all': '全部',
        'pending': '待审核',
        'approved': '已批准',
        'processing': '处理中',
        'shipped': '已发货',
        'completed': '已完成',
        'rejected': '已拒绝',
        'canceled': '已取消',
        'expired': '已过期',
        'no_history': '无兑换历史',
        'start_redeeming': '开始兑换奖励',
        'points': '积分',
        'status': '状态',
        'date': '日期',
        'reward_item': '奖励项目',
        'loading': '加载中...',
        'error_occurred': '发生错误',
        'try_again': '重试',
        'filter_by_status': '按状态筛选',
        'total_points_used': '使用的总积分',
        'quantity': '数量',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  List<Map<String, dynamic>> get filters => [
    {'label': getTranslation('all'), 'status': 'all'},
    {'label': getTranslation('pending'), 'status': 'pending'},
    {'label': getTranslation('approved'), 'status': 'approved'},
    {'label': getTranslation('processing'), 'status': 'processing'},
    {'label': getTranslation('shipped'), 'status': 'shipped'},
    {'label': getTranslation('completed'), 'status': 'completed'},
    {'label': getTranslation('rejected'), 'status': 'rejected'},
    {'label': getTranslation('canceled'), 'status': 'canceled'},
    {'label': getTranslation('expired'), 'status': 'expired'},
  ];

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    homeController = Get.find<HomeController>();
    // โหลดข้อมูลประวัติการแลก
    homeController.getRewardExchangeFromAPI();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'rejected':
      case 'canceled':
      case 'expired':
        return Colors.red;
      case 'shipped':
        return Colors.blue;
      case 'approved':
        return Colors.orange;
      case 'processing':
        return Colors.purple;
      case 'pending':
      default:
        return kButtonColor;
    }
  }

  Widget _buildFilterTabs() {
    return Obx(() {
      final rewardData = homeController.rewardExchangeHistory;

      // คำนวณจำนวนของแต่ละสถานะ
      Map<String, int> statusCounts = {};

      for (var filter in filters) {
        final status = filter['status'];
        if (status == 'all') {
          statusCounts[filter['label']] = rewardData.length;
        } else {
          statusCounts[filter['label']] = rewardData.where((item) => item['status'] == status).length;
        }
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: List.generate(filters.length, (index) {
            final selected = selectedTabIndex == index;
            final label = filters[index]['label'];
            final count = statusCounts[label] ?? 0;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTabIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? kButtonColor : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kButtonColor),
                ),
                child: Row(
                  children: [
                    Text(label, style: TextStyle(color: selected ? Colors.white : kButtonColor, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: selected ? Colors.white : kButtonColor, shape: BoxShape.circle),
                      child: Text(
                        count.toString(),
                        style: TextStyle(color: selected ? kButtonColor : Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _buildHistoryList() {
    return Obx(() {
      if (homeController.isLoadingRewardHistory.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final rewardData = homeController.rewardExchangeHistory;
      final selectedFilter = filters[selectedTabIndex];
      final filterStatus = selectedFilter['status'];

      // กรองข้อมูลตามสเตตัส
      List<Map<String, dynamic>> filteredData = [];
      if (filterStatus == 'all') {
        filteredData = List.from(rewardData);
      } else {
        filteredData = rewardData.where((item) => item['status'] == filterStatus).toList();
      }

      if (filteredData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(getTranslation('no_history'), style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 8),
              Text(getTranslation('start_redeeming'), style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        );
      }

      // จัดกลุ่มตามวันที่
      Map<String, List<Map<String, dynamic>>> groupedByDate = {};
      for (var item in filteredData) {
        final createdAt = item['created_at'] ?? '';
        final date = _formatDate(createdAt);

        if (!groupedByDate.containsKey(date)) {
          groupedByDate[date] = [];
        }
        groupedByDate[date]!.add(item);
      }

      // เรียงลำดับวันที่จากใหม่ไปเก่า
      final sortedDates = groupedByDate.keys.toList()..sort((a, b) => b.compareTo(a));

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children:
            sortedDates.map((date) {
              final items = groupedByDate[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...items.map((item) => _buildRewardItem(item)),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
      );
    });
  }

  Widget _buildRewardItem(Map<String, dynamic> item) {
    final reward = item['reward'] ?? {};
    final rewardName = reward['name'] ?? 'Unknown Reward';
    final rewardImage = reward['image'] ?? '';
    final points = reward['point'] ?? '0';
    final qty = item['qty'] ?? 1;
    final status = item['status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          // รูปรางวัล
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade100),
            child:
                rewardImage.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://g-cargo.dev-asha9.com/public/$rewardImage',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.card_giftcard, size: 32, color: Colors.grey),
                      ),
                    )
                    : Icon(Icons.card_giftcard, size: 32, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rewardName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF001C40))),
                const SizedBox(height: 4),
                Text('${getTranslation('quantity')}: $qty', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Text('$points ${getTranslation('points')}', style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(getTranslation(status), style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
              Text(getTranslation('reward_history'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
        body: Column(children: [const SizedBox(height: 8), _buildFilterTabs(), const Divider(height: 20), Expanded(child: _buildHistoryList())]),
      ),
    );
  }
}
