import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/login/loginPage.dart';
import 'package:gcargo/login/registerPage.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 พื้นหลังพร้อมความโปร่ง
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/backgg.png"), fit: BoxFit.cover)),
            foregroundDecoration: BoxDecoration(color: Colors.white.withOpacity(0.85)),
          ),

          Positioned(
            top: size.height * 0.18,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset('assets/icons/Logo.png', width: isPhone(context) ? 300 : 400, fit: BoxFit.fill), // 🔺 เปลี่ยนตรงนี้
                const SizedBox(height: 16),
                Text(
                  'บริการขนส่งระหว่างประเทศ\nรวดเร็ว ปลอดภัย ติดตามได้ทุกขั้นตอน',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isPhone(context) ? 20 : 30, color: kButtonColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // 🔹 ปุ่มด้านล่าง
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // ปุ่มเริ่มต้นใช้งาน
                SizedBox(
                  width: double.infinity,
                  height: isPhone(context) ? 50 : 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // ไปหน้าใช้งาน
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('เริ่มต้นใช้งาน', style: TextStyle(fontSize: isPhone(context) ? 20 : 26, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                // ปุ่มสร้างบัญชีใหม่ (ลูกศรอยู่ชิดขวา)
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      // ไปหน้าสมัคร
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                    },
                    style: TextButton.styleFrom(foregroundColor: kdefaultTextColor, padding: EdgeInsets.zero),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('สร้างบัญชีใหม่', style: TextStyle(fontSize: isPhone(context) ? 18 : 22, fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        CircleAvatar(
                          radius: 16, // ขนาดวงกลม
                          backgroundColor: kButtonColor, // เปลี่ยนสีพื้นหลังตามต้องการ
                          child: Icon(CupertinoIcons.right_chevron, color: Colors.white, size: isPhone(context) ? 18 : 22),
                        ),
                      ],
                    ),
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
