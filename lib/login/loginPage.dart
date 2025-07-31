import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/home/firstPage.dart';
import 'package:gcargo/login/pinEntryPage.dart';
import 'package:gcargo/login/registerPage.dart';
import 'package:gcargo/services/loginService.dart';
import 'package:gcargo/widgets/CustomTextFormField.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String device_no = '';
  String notify_token = '';
  bool isLoading = false; // สำหรับแสดง loading state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getdeviceId();
    });
  }

  void getdeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      // ดึงข้อมูล Android ID
      final androidInfo = await deviceInfo.androidInfo;
      device_no = androidInfo.id;
      print('android: ${device_no}');
    } else if (Platform.isIOS) {
      // ดึงข้อมูล Identifier for Vendor (iOS)
      final iosInfo = await deviceInfo.iosInfo;
      device_no = iosInfo.identifierForVendor!;
      print('iOS Identifier: ${iosInfo.identifierForVendor}');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 โลโก้ด้านขวาบน
                Align(alignment: Alignment.topRight, child: Image.asset('assets/icons/Logo.png', width: 80)),
                SizedBox(height: 16),

                // 🔹 หัวข้อ
                Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: kButtonColor)),
                SizedBox(height: 4),

                // 🔹 คำอธิบาย
                Text('บริการขนส่งระหว่างประเทศรวดเร็ว ปลอดภัย ติดตามได้ทุกขั้นตอน', style: TextStyle(fontSize: 14, color: kHintTextColor)),
                SizedBox(height: 24),

                // 🔹 Email
                SizedBox(height: 8),
                CustomTextFormField(label: 'อีเมล', hintText: 'กรุณากรอกอีเมล', controller: _emailController),
                SizedBox(height: 20),
                CustomTextFormField(label: 'รหัสผ่าน', hintText: '••••••••', controller: _passwordController, isPassword: true),
                SizedBox(height: 6),
                Text('รหัสผ่านต้องมีความยาว 8 - 20 ตัวอักษร', style: TextStyle(fontSize: 14, color: kHintTextColor)),

                // 🔹 ลืมรหัสผ่าน
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text('ลืมรหัสผ่าน', style: TextStyle(color: kHintTextColor, fontSize: 14)),
                  ),
                ),
                SizedBox(height: 4),

                // 🔹 ปุ่มเข้าสู่ระบบ
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                setState(() {
                                  isLoading = true; // เริ่ม loading
                                });

                                try {
                                  final token = await LoginService.login(_emailController.text, _passwordController.text, device_no, notify_token);
                                  if (token != null) {
                                    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
                                    final SharedPreferences prefs = await _prefs;
                                    await prefs.setString('token', token['token']);
                                    await prefs.setInt('userID', token['userID']);

                                    // โหลดข้อมูลผู้ใช้ใน HomeController
                                    final homeController = Get.find<HomeController>();
                                    await homeController.getUserDataAndShippingAddresses();

                                    if (mounted) {
                                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => FirstPage()), (route) => false);
                                    }
                                    //Navigator.push(context, MaterialPageRoute(builder: (context) => PinEntryPage()));
                                  }
                                } on ClientException catch (e) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text('Setting.warning'),
                                          content: Text(e.toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Payment.agree'),
                                            ),
                                          ],
                                        ),
                                  );
                                } on SocketException catch (e) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text('Setting.warning'),
                                          content: Text(e.toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Payment.agree'),
                                            ),
                                          ],
                                        ),
                                  );
                                } on HttpException catch (e) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text('Setting.warning'),
                                          content: Text(e.toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('$e'),
                                            ),
                                          ],
                                        ),
                                  );
                                } on FormatException catch (e) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text('$e'),
                                          content: Text(e.toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Payment.agree'),
                                            ),
                                          ],
                                        ),
                                  );
                                } on Exception catch (e) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text('แจ้งเตือน'),
                                          content: Text(e.toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('ตกลง'),
                                            ),
                                          ],
                                        ),
                                  );
                                } catch (e) {
                                  print(e);
                                } finally {
                                  setState(() {
                                    isLoading = false; // หยุด loading
                                  });
                                }
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child:
                        isLoading
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                ),
                                SizedBox(width: 12),
                                Text('กำลังเข้าสู่ระบบ...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            )
                            : const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 16),

                // 🔹 ข้อความ "หรือ"
                Center(child: Text('หรือ', style: TextStyle(color: kHintTextColor))),
                SizedBox(height: 16),

                // 🔹 ไอคอน + สร้างบัญชีใหม่ในแถวเดียวกัน
                Row(
                  children: [
                    Image.asset('assets/icons/g.png', width: 50, fit: BoxFit.fill),
                    SizedBox(width: 20),
                    Image.asset('assets/icons/f.png', width: 50, fit: BoxFit.fill),
                    SizedBox(width: 20),
                    Image.asset('assets/icons/line.png', width: 50, fit: BoxFit.fill),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: kButtonColor),
                      child: Row(
                        children: [
                          Text('สร้างบัญชีใหม่', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: kButtonColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: kButtonColor, width: 1.6),
                            ),
                            child: Icon(CupertinoIcons.right_chevron, size: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
