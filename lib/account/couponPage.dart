import 'package:flutter/material.dart';

class CouponPage extends StatelessWidget {
  const CouponPage({super.key});

  @override
  Widget build(BuildContext context) {
    final coupons = [
      {'title': 'ส่วนลด 50฿', 'condition': 'เมื่อซื้อเกิน 599฿', 'code': 'C20240605100001'},
      {'title': 'ส่วนลด 50฿', 'condition': 'เมื่อซื้อเกิน 0฿', 'code': 'C20240605100001'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('คูปองส่วนลด', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: coupons.length,
        separatorBuilder: (_, __) => const Divider(height: 24, color: Colors.grey),
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(coupon['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(coupon['condition']!, style: const TextStyle(fontSize: 14, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(coupon['code']!, style: const TextStyle(fontSize: 13, color: Colors.black45)),
            ],
          );
        },
      ),
    );
  }
}
