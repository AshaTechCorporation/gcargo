import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class RewardRedeemPage extends StatefulWidget {
  const RewardRedeemPage({super.key});

  @override
  State<RewardRedeemPage> createState() => _RewardRedeemPageState();
}

class _RewardRedeemPageState extends State<RewardRedeemPage> {
  int selectedReward = 0;

  final List<Map<String, dynamic>> rewards = [
    {'title': 'ทองคำแท่ง aurora หนัก 0.2 บาท\nหนัก 0.2 บาท หนัก 0.2  หนัก 0.2', 'points': '100', 'enabled': true},
    {'title': 'ทองคำแท่ง aurora หนัก 1 บาท', 'points': '20,000', 'enabled': false},
    {'title': 'ทองคำแท่ง aurora หนัก 0.2 บาท', 'points': '100', 'enabled': true},
  ];

  Widget _buildRewardCard(int index) {
    final reward = rewards[index];
    final isSelected = selectedReward == index;
    final isEnabled = reward['enabled'] == true;

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
            Image.asset('assets/images/g14.png', width: 64, height: 64),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reward['title'], style: TextStyle(fontWeight: FontWeight.bold, color: isEnabled ? const Color(0xFF001C40) : Colors.black54)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      reward['points'],
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
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
            const Text('แลกของรางวัล', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(right: 16),
              height: 36,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                child: const Text('ประวัติ', style: TextStyle(color: Colors.black54)),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              itemCount: rewards.length,
              itemBuilder: (context, index) => _buildRewardCard(index),
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text('100', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                    SizedBox(height: 4),
                    Text('แต้มทั้งหมดของฉัน', style: TextStyle(color: Colors.black54)),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    child: const Text('แลกของรางวัล', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
