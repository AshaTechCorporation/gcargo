import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
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
  String pointBalance = '0';

  @override
  void initState() {
    super.initState();
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
  void _checkPointsAndRedeem() {
    final rewards = homeController.reward;
    if (rewards.isEmpty || selectedReward >= rewards.length) {
      _showAlert('กรุณาเลือกรางวัลที่ต้องการแลก');
      return;
    }

    final selectedRewardData = rewards[selectedReward];
    final requiredPoints = double.tryParse(selectedRewardData['point']?.toString() ?? '0') ?? 0;
    final currentPoints = double.tryParse(pointBalance) ?? 0;

    if (currentPoints >= requiredPoints) {
      // แต้มพอ ไปหน้าสำเร็จ
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RewardSuccessPage()));
    } else {
      // แต้มไม่พอ แจ้งเตือน
      _showAlert('มีแต้มไม่พอ\nต้องการ ${requiredPoints.toStringAsFixed(2)} แต้ม\nคุณมี ${currentPoints.toStringAsFixed(2)} แต้ม');
    }
  }

  // ฟังก์ชั่นสำหรับแสดง Alert Dialog
  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('แจ้งเตือน'),
          content: Text(message),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('ตกลง'))],
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
            Text('แลกของรางวัล', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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
                child: Text('ประวัติ', style: TextStyle(color: Colors.black54)),
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
                      ? const Center(child: CircularProgressIndicator())
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
                      Text(_formatPointBalance(pointBalance), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 4),
                      const Text('แต้มทั้งหมดของฉัน', style: TextStyle(color: Colors.black54)),
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
                      child: Text('แลกของรางวัล', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
