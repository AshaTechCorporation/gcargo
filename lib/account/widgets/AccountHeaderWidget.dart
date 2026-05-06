import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/models/user.dart';
import 'package:gcargo/models/wallettrans.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountHeaderWidget extends StatefulWidget {
  final VoidCallback onCreditTap;
  final VoidCallback onPointTap;
  final VoidCallback onParcelTap;
  final VoidCallback onWalletTap;
  final VoidCallback onTransferTap;
  final User? user;
  final bool isLoading;
  final List<WalletTrans>? walletTrans;

  const AccountHeaderWidget({
    super.key,
    required this.onCreditTap,
    required this.onPointTap,
    required this.onParcelTap,
    required this.onWalletTap,
    required this.onTransferTap,
    this.user,
    this.isLoading = false,
    this.walletTrans,
  });

  @override
  State<AccountHeaderWidget> createState() => _AccountHeaderWidgetState();
}

class _AccountHeaderWidgetState extends State<AccountHeaderWidget> {
  String _walletBalance = '0';
  String _pointBalance = '0';

  @override
  void initState() {
    super.initState();
    _loadBalancesFromPrefs();
  }

  Future<void> _loadBalancesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _walletBalance = prefs.getString('wallet_balance') ?? '0';
      _pointBalance = prefs.getString('point_balance') ?? '0';
    });
  }

  String getTranslation(String key) {
    final languageController = Get.find<LanguageController>();
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'user_not_logged_in': 'ผู้ใช้ยังไม่เข้าสู่ระบบ',
        'my_parcel': 'พัสดุของฉัน',
        'status': 'สถานะ',
        'transfer_money': 'โอนเงิน',
        'my_wallet': 'Wallet ของฉัน',
      },
      'en': {
        'user_not_logged_in': 'User not logged in',
        'my_parcel': 'My Parcel',
        'status': 'Status',
        'transfer_money': 'Transfer Money',
        'my_wallet': 'My Wallet',
      },
      'zh': {'user_not_logged_in': '用户未登录', 'my_parcel': '我的包裹', 'status': '状态', 'transfer_money': '转账', 'my_wallet': '我的钱包'},
    };

    return translations[currentLang]?[key] ?? translations['th']?[key] ?? key;
  }

  // ฟังก์ชั่นสำหรับนับจำนวนพัสดุที่มีสถานะ "สำเร็จ"
  int _getCompletedParcelCount() {
    try {
      final orderController = Get.find<OrderController>();
      int count = 0;

      for (var legalImport in orderController.deilveryOrders) {
        if (legalImport.delivery_orders != null) {
          for (var order in legalImport.delivery_orders!) {
            final status = order.status?.toLowerCase();
            if (status == 'completed' || status == 'สำเร็จ') {
              count++;
            }
          }
        }
      }

      return count;
    } catch (e) {
      // ถ้าไม่พบ OrderController หรือเกิดข้อผิดพลาด ให้คืนค่า 0
      return 0;
    }
  }

  // ฟังก์ชั่นสำหรับฟอแมทตัวเลขให้มีคอมม่า
  String _formatNumber(String balance) {
    try {
      if (balance.isEmpty) return '0.00';
      final double value = double.parse(balance);
      final formatter = NumberFormat('#,##0.00');
      return formatter.format(value);
    } catch (e) {
      return '0.00';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GetBuilder<LanguageController>(
      builder:
          (controller) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Avatar + Name + Code
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child:
                              (widget.user?.image != null && widget.user!.image!.isNotEmpty)
                                  ? Image.network(
                                    widget.user!.image!,
                                    width: isPhone(context) ? 48 : 52,
                                    height: isPhone(context) ? 48 : 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // ถ้าโหลดรูปจาก network ไม่ได้ ให้แสดง Avatar default
                                      return Image.asset(
                                        'assets/images/user.png',
                                        width: isPhone(context) ? 48 : 52,
                                        height: isPhone(context) ? 48 : 52,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      // แสดง loading indicator ขณะโหลดรูป
                                      return Container(
                                        width: isPhone(context) ? 48 : 52,
                                        height: isPhone(context) ? 48 : 52,
                                        decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      );
                                    },
                                  )
                                  : Image.asset(
                                    'assets/images/user.png',
                                    width: isPhone(context) ? 48 : 52,
                                    height: isPhone(context) ? 48 : 52,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                        const SizedBox(width: 12),
                        widget.isLoading
                            ? Container(
                              width: size.width * 0.3, // 30% ของหน้าจอ 100,
                              height: isPhone(context) ? 16 : 18,
                              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                            )
                            : Text(
                              widget.user?.fname ?? getTranslation('user_not_logged_in'),
                              style: TextStyle(fontSize: isPhone(context) ? 16 : 18, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                      ],
                    ),
                    widget.isLoading
                        ? Container(
                          width: isPhone(context) ? 50 : 70,
                          height: isPhone(context) ? 14 : 18,
                          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                        )
                        : Text(
                          widget.user?.importer_code?.toUpperCase() ?? widget.user?.code ?? '',
                          style: TextStyle(fontSize: isPhone(context) ? 14 : 16, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                  ],
                ),

                const SizedBox(height: 20),
                // 🔹 Credit Card รูปเต็มใบ
                GestureDetector(
                  onTap: widget.onCreditTap,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/credit111.png',
                          height: isPhone(context) ? 80 : 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 25,
                        child: Text(
                          _formatNumber(_walletBalance),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isPhone(context) ? 30 : 30,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black.withOpacity(0.5))],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Point Card รูปเต็มใบ
                GestureDetector(
                  onTap: widget.onPointTap,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/point111.png',
                          height: isPhone(context) ? 80 : 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 25,
                        child: Text(
                          _formatNumber(_pointBalance),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isPhone(context) ? 30 : 30,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black.withOpacity(0.5))],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Quick Menu (3 items)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _quickItem(
                      '${_getCompletedParcelCount()}',
                      getTranslation('my_parcel'),
                      'assets/icons/box-blusee.png',
                      widget.onParcelTap,
                      getTranslation('status'),
                      context,
                      size,
                    ),
                    _quickItem(
                      '฿${_formatNumber(_walletBalance)}',
                      getTranslation('my_wallet'),
                      'assets/icons/empty-wallet.png',
                      widget.onWalletTap,
                      getTranslation('transfer_money'),
                      context,
                      size,
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _quickItem(String value, String label, String iconPath, VoidCallback onTap, String transferLabel, BuildContext context, Size size) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isPhone(context) ? 180 : size.width * 0.45,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)), // ✅ ขอบสีเทา
        ),
        child: Row(
          children: [
            // 🔹 ฝั่งตัวเลข + label (ซ้าย)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (value.isNotEmpty) Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isPhone(context) ? 16 : 22)),
                  const SizedBox(height: 4),
                  Text(label, style: TextStyle(fontSize: isPhone(context) ? 12 : 18, color: Colors.grey)),
                ],
              ),
            ),
            // 🔹 ฝั่งไอคอน + label (ขวา)
            Column(
              children: [
                Container(
                  width: isPhone(context) ? 36 : 42,
                  height: isPhone(context) ? 36 : 42,
                  decoration: BoxDecoration(color: const Color(0xFFF5F6F8), borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Image.asset(iconPath, width: isPhone(context) ? 20 : 30)),
                ),
                const SizedBox(height: 4),
                Text('$transferLabel', style: TextStyle(fontSize: isPhone(context) ? 12 : 18)), // หรือข้อความอื่นตามรูป
              ],
            ),
          ],
        ),
      ),
    );
  }
}
