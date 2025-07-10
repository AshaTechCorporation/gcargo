import 'package:flutter/material.dart';
import 'package:gcargo/account/aboutUsPage.dart';
import 'package:gcargo/account/addressListPage.dart';
import 'package:gcargo/account/bankVerifyPage.dart';
import 'package:gcargo/account/changeLanguagePage.dart';
import 'package:gcargo/account/couponPage.dart';
import 'package:gcargo/account/faqPage.dart';
import 'package:gcargo/account/favoritePage.dart';
import 'package:gcargo/account/newsPromotionPage.dart';
import 'package:gcargo/account/profilePage.dart';
import 'package:gcargo/account/userManualPage.dart';
import 'package:gcargo/account/widgets/WalletCard.dart';
import 'package:gcargo/constants.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header Profile (ชื่อผู้ใช้ + ยอด)
            WalletCard(),

            const SizedBox(height: 24),

            // Menu Sections
            Expanded(
              child: ListView(
                children: [
                  _buildSectionTitle('โปรโมชั่น'),
                  _buildMenuItem(
                    'ข่าวสาร & โปรโมชั่น',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NewsPromotionPage()));
                    },
                  ),
                  _buildMenuItem(
                    'คูปองส่วนลด',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CouponPage()));
                    },
                  ),
                  _buildMenuItem(
                    'รายการโปรด',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritePage()));
                    },
                  ),

                  _buildSectionTitle('ทั่วไป'),
                  _buildMenuItem(
                    'โปรไฟล์',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                    },
                  ),
                  _buildMenuItem(
                    'ที่อยู่ของฉัน',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddressListPage()));
                    },
                  ),
                  _buildMenuItem(
                    'ยืนยันบัญชีธนาคาร',
                    showVerified: true,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BankVerifyPage()));
                    },
                  ),
                  _buildMenuItem('ความปลอดภัย', onTap: () {}),
                  _buildMenuItem(
                    'เปลี่ยนภาษา',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeLanguagePage()));
                    },
                  ),

                  _buildSectionTitle('ความช่วยเหลือ'),
                  _buildMenuItem('ติดต่อเจ้าหน้าที่', onTap: () {}),
                  _buildMenuItem(
                    'คู่มือการใช้งาน',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UserManualPage()));
                    },
                  ),
                  _buildMenuItem(
                    'คำถามที่พบบ่อย',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FaqPage()));
                    },
                  ),
                  _buildMenuItem(
                    'เกี่ยวกับเรา',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsPage()));
                    },
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white,
                      ),
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: const Color(0xFF4A4A4A),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('ออกจากระบบ'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildMenuItem(String title, {bool showVerified = false, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15)),
                      if (showVerified) ...[const SizedBox(width: 8), const Icon(Icons.verified, color: Colors.grey, size: 18)],
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFE0E0E0)),
      ],
    );
  }
}
