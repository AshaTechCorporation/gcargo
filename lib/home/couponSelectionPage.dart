import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class CouponSelectionPage extends StatefulWidget {
  const CouponSelectionPage({super.key});

  @override
  State<CouponSelectionPage> createState() => _CouponSelectionPageState();
}

class _CouponSelectionPageState extends State<CouponSelectionPage> {
  int? selectedCouponIndex;

  final List<Map<String, String>> coupons = [
    {'title': 'ส่วนลด 50฿', 'condition': 'เมื่อซื้อขั้นต่ำ 990฿', 'code': 'C20240605100001'},
    {'title': 'ส่วนลด 50฿', 'condition': 'เมื่อซื้อขั้นต่ำ 0฿', 'code': 'C20240605100001'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('คูปองส่วนลด', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: Colors.grey.shade300)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: coupons.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade300),
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                return ListTile(
                  title: Text(coupon['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(coupon['condition']!),
                      Text(coupon['code']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  trailing: Radio<int>(
                    value: index,
                    groupValue: selectedCouponIndex,
                    onChanged: (value) {
                      setState(() {
                        selectedCouponIndex = value;
                      });
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                );
              },
            ),
          ),
          // ✅ ปุ่มยืนยัน
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300)), color: Colors.white),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: ใช้คูปอง
                  Navigator.pop(context, selectedCouponIndex);
                },
                style: ElevatedButton.styleFrom(backgroundColor: kButtonColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('ยืนยัน', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
