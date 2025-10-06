import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/home/rewardHistoryPage.dart';
import 'package:gcargo/home/rewardSuccessPage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewardRedeemPage extends StatefulWidget {
  const RewardRedeemPage({super.key});

  @override
  State<RewardRedeemPage> createState() => _RewardRedeemPageState();
}

class _RewardRedeemPageState extends State<RewardRedeemPage> {
  int selectedReward = 0;
  late final HomeController homeController;
  late LanguageController languageController;
  String pointBalance = '0';

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'reward_redeem': 'แลกของรางวัล',
        'my_points': 'แต้มของฉัน',
        'points': 'แต้ม',
        'redeem_history': 'ประวัติการแลก',
        'available_rewards': 'ของรางวัลที่มี',
        'redeem_now': 'แลกเลย',
        'redeem': 'แลก',
        'insufficient_points': 'แต้มไม่เพียงพอ',
        'confirm_redeem': 'ยืนยันการแลก',
        'redeem_confirmation': 'คุณต้องการแลกของรางวัลนี้หรือไม่?',
        'cancel': 'ยกเลิก',
        'confirm': 'ยืนยัน',
        'redeem_success': 'แลกของรางวัลสำเร็จ',
        'redeem_failed': 'ไม่พบรายการ',
        'loading': 'กำลังโหลด...',
        'no_rewards': 'ไม่มีของรางวัล',
        'error_occurred': 'เกิดข้อผิดพลาด',
        'try_again': 'ลองใหม่อีกครั้ง',
        'points_required': 'แต้มที่ต้องใช้',
        'reward_details': 'รายละเอียดของรางวัล',
        'terms_conditions': 'เงื่อนไขการใช้งาน',
        'expiry_date': 'วันหมดอายุ',
        'quantity_limited': 'จำนวนจำกัด',
      },
      'en': {
        'reward_redeem': 'Redeem Rewards',
        'my_points': 'My Points',
        'points': 'Points',
        'redeem_history': 'Redeem History',
        'available_rewards': 'Available Rewards',
        'redeem_now': 'Redeem Now',
        'redeem': 'Redeem',
        'insufficient_points': 'Insufficient Points',
        'confirm_redeem': 'Confirm Redeem',
        'redeem_confirmation': 'Do you want to redeem this reward?',
        'cancel': 'Cancel',
        'confirm': 'Confirm',
        'redeem_success': 'Reward Redeemed Successfully',
        'redeem_failed': 'Redeem Failed',
        'loading': 'Loading...',
        'no_rewards': 'No Rewards Available',
        'error_occurred': 'An Error Occurred',
        'try_again': 'Try Again',
        'points_required': 'Points Required',
        'reward_details': 'Reward Details',
        'terms_conditions': 'Terms & Conditions',
        'expiry_date': 'Expiry Date',
        'quantity_limited': 'Limited Quantity',
      },
      'zh': {
        'reward_redeem': '兑换奖励',
        'my_points': '我的积分',
        'points': '积分',
        'redeem_history': '兑换历史',
        'available_rewards': '可用奖励',
        'redeem_now': '立即兑换',
        'redeem': '兑换',
        'insufficient_points': '积分不足',
        'confirm_redeem': '确认兑换',
        'redeem_confirmation': '您要兑换此奖励吗？',
        'cancel': '取消',
        'confirm': '确认',
        'redeem_success': '兑换成功',
        'redeem_failed': '兑换失败',
        'loading': '加载中...',
        'no_rewards': '无可用奖励',
        'error_occurred': '发生错误',
        'try_again': '重试',
        'points_required': '所需积分',
        'reward_details': '奖励详情',
        'terms_conditions': '条款与条件',
        'expiry_date': '到期日期',
        'quantity_limited': '数量有限',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    homeController = Get.put(HomeController());
    // เรียก API เมื่อเข้าหน้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.getRewardFromAPI();
      _loadPointBalance();
    });
  }

  // ฟังก์ชั่นสำหรับดึง point balance จาก SharedPreferences
  Future<void> _loadPointBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final balance = prefs.getString('point_balance');
    setState(() {
      pointBalance = balance ?? '0';
    });
  }

  // ฟังก์ชั่นสำหรับอัพเดท point balance จาก API
  Future<void> _updatePointBalance() async {
    try {
      final user = await homeController.getUserByIdFromAPI();
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('point_balance', user.point_balance ?? '0');
        setState(() {
          pointBalance = user.point_balance ?? '0';
        });
      }
    } catch (e) {
      print('Error updating point balance: $e');
    }
  }

  // ฟังก์ชั่นสำหรับแสดงแต้มเป็นทศนิยม 2 ตำแหน่ง
  String _formatPointBalance(String balance) {
    try {
      final double value = double.parse(balance);
      return value.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  // ฟังก์ชั่นสำหรับเช็คแต้มและแลกรางวัล
  Future<void> _checkPointsAndRedeem() async {
    final rewards = homeController.reward;
    if (rewards.isEmpty || selectedReward >= rewards.length) {
      _showAlert(getTranslation('no_rewards'));
      return;
    }

    final selectedRewardData = rewards[selectedReward];
    final requiredPoints = double.tryParse(selectedRewardData['point']?.toString() ?? '0') ?? 0;
    final currentPoints = double.tryParse(pointBalance) ?? 0;

    if (currentPoints >= requiredPoints) {
      // แต้มพอ ยิง API updateStatusReward
      final rewardId = selectedRewardData['id'];
      if (rewardId != null) {
        // แสดง loading
        showDialog(context: context, barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator()));

        // เรียก API
        final success = await homeController.updateRewardStatus(reward_id: rewardId);

        // ปิด loading
        if (mounted) {
          Navigator.of(context).pop();

          if (success) {
            // API สำเร็จ ไปหน้า RewardSuccessPage
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const RewardSuccessPage()));

            // ถ้ากลับมาจากหน้า RewardSuccessPage ให้อัพเดท point balance
            if (result == true) {
              await _updatePointBalance();
            }
          } else {
            // API ไม่สำเร็จ แจ้งเตือน
            _showAlert(getTranslation('redeem_failed'));
          }
        }
      } else {
        _showAlert(getTranslation('error_occurred'));
      }
    } else {
      // แต้มไม่พอ แจ้งเตือน
      _showAlert(
        '${getTranslation('insufficient_points')}\n${getTranslation('points_required')}: ${requiredPoints.toStringAsFixed(2)} ${getTranslation('points')}\n${getTranslation('my_points')}: ${currentPoints.toStringAsFixed(2)} ${getTranslation('points')}',
      );
    }
  }

  // ฟังก์ชั่นสำหรับแสดง Alert Dialog
  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslation('confirm_redeem')),
          content: Text(message),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(getTranslation('confirm')))],
        );
      },
    );
  }

  // ฟังก์ชั่นสำหรับแสดงรูปภาพ reward
  Widget _buildRewardImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // ถ้าโหลดรูปจาก URL ไม่ได้ให้แสดงรูปเดิม
          return Image.asset('assets/images/No_Image.jpg', width: 64, height: 64);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 64,
            height: 64,
            child: Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
              ),
            ),
          );
        },
      );
    } else {
      // ถ้าไม่มี URL ให้แสดงรูปเดิม
      return Image.asset('assets/images/No_Image.jpg', width: 64, height: 64);
    }
  }

  Widget _buildRewardCard(int index, List<Map<String, dynamic>> rewards) {
    final reward = rewards[index];
    final isSelected = selectedReward == index;
    final isEnabled = reward['status'] != 'disabled'; // แก้ไขเงื่อนไข enabled

    return GestureDetector(
      onTap:
          isEnabled
              ? () {
                setState(() {
                  selectedReward = index;
                });
              }
              : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey.shade100,
          border: Border.all(color: isSelected ? kButtonColor : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildRewardImage(reward['image']),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward['name']?.toString() ?? 'ไม่มีชื่อ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: isEnabled ? const Color(0xFF001C40) : Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '${reward['point']?.toString() ?? '0'} แต้ม',
                      style: TextStyle(color: isEnabled ? Colors.blue.shade900 : Colors.black45, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? kButtonColor : Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
              Text(getTranslation('reward_redeem'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              Spacer(),
              Container(
                margin: EdgeInsets.only(right: 16),
                height: 36,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RewardHistoryPage()));
                  },
                  child: Text(getTranslation('redeem_history'), style: TextStyle(color: Colors.black54)),
                ),
              ),
            ],
          ),
        ),
        body: Obx(() {
          final rewards = homeController.reward;

          return Column(
            children: [
              Expanded(
                child:
                    rewards.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [CircularProgressIndicator(), SizedBox(height: 16), Text(getTranslation('loading'))],
                          ),
                        )
                        : ListView.builder(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                          itemCount: rewards.length,
                          itemBuilder: (context, index) => _buildRewardCard(index, rewards),
                        ),
              ),
              Divider(height: 1),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _formatPointBalance(pointBalance),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        const SizedBox(height: 4),
                        Text(getTranslation('my_points'), style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kButtonColor,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          _checkPointsAndRedeem();
                        },
                        child: Text(getTranslation('redeem_now'), style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
