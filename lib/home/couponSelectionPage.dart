import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/account_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
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
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'coupon_selection': 'คูปองส่วนลด',
        'select_coupon': 'เลือกคูปอง',
        'available_coupons': 'คูปองที่ใช้ได้',
        'no_coupons': 'ไม่มีคูปอง',
        'no_coupons_available': 'ไม่มีคูปองที่ใช้ได้',
        'expired': 'หมดอายุ',
        'used': 'ใช้แล้ว',
        'available': 'ใช้ได้',
        'discount': 'ส่วนลด',
        'minimum_order': 'ยอดขั้นต่ำ',
        'valid_until': 'ใช้ได้ถึง',
        'confirm': 'ยืนยัน',
        'cancel': 'ยกเลิก',
        'loading': 'กำลังโหลด...',
        'error_loading': 'เกิดข้อผิดพลาดในการโหลด',
        'baht': 'บาท',
        'percent': 'เปอร์เซ็นต์',
        'free_shipping': 'ฟรีค่าจัดส่ง',
        'coupon_code': 'รหัสคูปอง',
        'terms_conditions': 'เงื่อนไขการใช้งาน',
      },
      'en': {
        'coupon_selection': 'Coupon Selection',
        'select_coupon': 'Select Coupon',
        'available_coupons': 'Available Coupons',
        'no_coupons': 'No Coupons',
        'no_coupons_available': 'No Coupons Available',
        'expired': 'Expired',
        'used': 'Used',
        'available': 'Available',
        'discount': 'Discount',
        'minimum_order': 'Minimum Order',
        'valid_until': 'Valid Until',
        'confirm': 'Confirm',
        'cancel': 'Cancel',
        'loading': 'Loading...',
        'error_loading': 'Error Loading',
        'baht': 'Baht',
        'percent': 'Percent',
        'free_shipping': 'Free Shipping',
        'coupon_code': 'Coupon Code',
        'terms_conditions': 'Terms & Conditions',
      },
      'zh': {
        'coupon_selection': '优惠券选择',
        'select_coupon': '选择优惠券',
        'available_coupons': '可用优惠券',
        'no_coupons': '无优惠券',
        'no_coupons_available': '无可用优惠券',
        'expired': '已过期',
        'used': '已使用',
        'available': '可用',
        'discount': '折扣',
        'minimum_order': '最低订单',
        'valid_until': '有效期至',
        'confirm': '确认',
        'cancel': '取消',
        'loading': '加载中...',
        'error_loading': '加载错误',
        'baht': '泰铢',
        'percent': '百分比',
        'free_shipping': '免运费',
        'coupon_code': '优惠券代码',
        'terms_conditions': '条款与条件',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
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
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(getTranslation('coupon_selection'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: Colors.grey.shade300)),
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                final coupons = accountController.coupons;

                if (coupons.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(getTranslation('no_coupons_available'), style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: coupons.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade300),
                  itemBuilder: (context, index) {
                    final coupon = coupons[index];
                    return ListTile(
                      title: Text(coupon['name']?.toString() ?? getTranslation('no_coupons'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(coupon['description']?.toString() ?? getTranslation('terms_conditions')),
                          Text(coupon['code']?.toString() ?? getTranslation('coupon_code'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                  child: Text(
                    getTranslation('confirm'),
                    style: TextStyle(fontSize: 16, color: selectedCouponIndex != null ? Colors.white : Colors.white70),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
