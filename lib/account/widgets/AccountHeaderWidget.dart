import 'package:flutter/material.dart';
import 'package:gcargo/models/user.dart';

class AccountHeaderWidget extends StatelessWidget {
  final VoidCallback onCreditTap;
  final VoidCallback onPointTap;
  final VoidCallback onParcelTap;
  final VoidCallback onWalletTap;
  final VoidCallback onTransferTap;
  final User? user;
  final bool isLoading;

  const AccountHeaderWidget({
    super.key,
    required this.onCreditTap,
    required this.onPointTap,
    required this.onParcelTap,
    required this.onWalletTap,
    required this.onTransferTap,
    this.user,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                        (user?.image != null && user!.image!.isNotEmpty)
                            ? Image.network(
                              user!.image!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // ถ้าโหลดรูปจาก network ไม่ได้ ให้แสดง Avatar default
                                return Image.asset('assets/images/Avatar.png', width: 48, height: 48, fit: BoxFit.cover);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                // แสดง loading indicator ขณะโหลดรูป
                                return Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              },
                            )
                            : Image.asset('assets/images/Avatar.png', width: 48, height: 48, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  isLoading
                      ? Container(
                        width: 100,
                        height: 16,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                      )
                      : Text(
                        user?.fname ?? 'ผู้ใช้ยังไม่เข้าสู่ระบบ',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                ],
              ),
              isLoading
                  ? Container(width: 50, height: 14, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)))
                  : Text(user?.code ?? '', style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
            ],
          ),

          const SizedBox(height: 20),
          // 🔹 Credit Card รูปเต็มใบ
          GestureDetector(
            onTap: onCreditTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/credit.png', height: 80, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Point Card รูปเต็มใบ
          GestureDetector(
            onTap: onPointTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/point.png', height: 80, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),

          // 🔹 Quick Menu (3 items)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _quickItem('100', 'พัสดุของฉัน', 'assets/icons/box-blusee.png', onParcelTap, 'สถานะ'),
              _quickItem('฿100.00', 'Wallet ของฉัน', 'assets/icons/empty-wallet.png', onWalletTap, 'โอนเงิน'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickItem(String value, String label, String iconPath, VoidCallback onTap, String transferLabel) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
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
                  if (value.isNotEmpty) Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            // 🔹 ฝั่งไอคอน + label (ขวา)
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: const Color(0xFFF5F6F8), borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Image.asset(iconPath, width: 20)),
                ),
                const SizedBox(height: 4),
                Text('$transferLabel', style: TextStyle(fontSize: 12)), // หรือข้อความอื่นตามรูป
              ],
            ),
          ],
        ),
      ),
    );
  }
}
