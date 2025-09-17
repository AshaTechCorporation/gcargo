import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/account_controller.dart';
import 'package:get/get.dart';

class CouponSelectionPage extends StatefulWidget {
  final Map<String, dynamic>? selectedCoupon;

  const CouponSelectionPage({super.key, this.selectedCoupon});

  @override
  State<CouponSelectionPage> createState() => _CouponSelectionPageState();
}

class _CouponSelectionPageState extends State<CouponSelectionPage> {
  int? selectedCouponIndex;
  late final AccountController accountController;

  @override
  void initState() {
    super.initState();
    accountController = Get.put(AccountController());

    // เรียกฟังก์ชั่น getCoupons เมื่อเข้าหน้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      accountController.getCoupons().then((_) {
        // ตั้งค่าคูปองที่เลือกไว้หลังจากโหลดข้อมูลเสร็จ
        if (widget.selectedCoupon != null) {
          final coupons = accountController.coupons;
          final index = coupons.indexWhere((coupon) => coupon['code'] == widget.selectedCoupon!['code']);
          if (index != -1) {
            setState(() {
              selectedCouponIndex = index;
            });
          }
        }
      });
    });
  }

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
            child: Obx(() {
              final coupons = accountController.coupons;
              return ListView.separated(
                itemCount: coupons.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade300),
                itemBuilder: (context, index) {
                  final coupon = coupons[index];
                  return ListTile(
                    title: Text(coupon['name']?.toString() ?? 'ไม่มีชื่อ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(coupon['description']?.toString() ?? 'ไม่มีเงื่อนไข'),
                        Text(coupon['code']?.toString() ?? 'ไม่มีรหัส', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
              );
            }),
          ),
          // ✅ ปุ่มยืนยัน
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300)), color: Colors.white),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    selectedCouponIndex != null
                        ? () {
                          // ส่งข้อมูลคูปองที่เลือกกลับไป
                          final selectedCoupon = accountController.coupons[selectedCouponIndex!];
                          Navigator.pop(context, selectedCoupon);
                        }
                        : null, // ถ้ายังไม่เลือกคูปองจะกดไม่ได้
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedCouponIndex != null ? kButtonColor : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('ยืนยัน', style: TextStyle(fontSize: 16, color: selectedCouponIndex != null ? Colors.white : Colors.white70)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
