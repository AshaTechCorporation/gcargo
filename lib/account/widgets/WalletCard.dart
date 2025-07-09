import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart'; // คุณต้องนิยาม kCardLine1Color, kCardLine2Color, kCardLine3Color

class WalletCard extends StatelessWidget {
  const WalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kCardLine1Color, kCardLine2Color, kCardLine3Color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 รูปกับชื่อ
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/images/Avatar.png', width: 32, height: 32, fit: BoxFit.cover),
              ),
              const SizedBox(width: 8),
              const Text('ชื่อผู้ใช้ ชื่อผู้ใช้', style: TextStyle(color: Colors.cyanAccent, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),

          // 🔹 0.00฿ และ card ด้านขวาอยู่ในแถวเดียวกัน
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔸 0.00฿ และ เครดิต
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('0.00฿', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('เครดิตของฉัน', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              const Spacer(),

              // 🔸 Card Wallet
              Container(
                width: 140,
                height: 60,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    // ฝั่งซ้าย: ไอคอนในกรอบ
                    Container(
                      width: 60,
                      decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.account_balance_wallet_outlined, size: 20, color: Colors.black),
                            SizedBox(height: 2),
                            Text('โอนเงิน', style: TextStyle(fontSize: 10, color: Colors.black)),
                          ],
                        ),
                      ),
                    ),

                    // ฝั่งขวา: ตัวเลขและข้อความ
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('0.00', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            SizedBox(height: 2),
                            Text('wallet ของฉัน', style: TextStyle(fontSize: 10, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
