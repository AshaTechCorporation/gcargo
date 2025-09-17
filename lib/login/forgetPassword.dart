import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/login/otpPage.dart';
import 'package:gcargo/services/loginService.dart';
import 'package:gcargo/widgets/CustomTextFormField.dart';
import 'package:http/http.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('ลืนรหัสผ่าน', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black)),
        bottom: PreferredSize(preferredSize: Size.fromHeight(1.0), child: Container(color: Colors.grey, height: 1.0)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.001),

              // 🔹 พื้นหลังพร้อมความโปร่ง
              // Container(
              //   width: size.width,
              //   height: size.height,
              //   decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/backgg.png"), fit: BoxFit.cover)),
              //   foregroundDecoration: BoxDecoration(color: Colors.white.withOpacity(0.85)),
              // ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/Logo.png', width: 300, fit: BoxFit.fill), // 🔺 เปลี่ยนตรงนี้
                    //const SizedBox(height: 16),
                    // const Text(
                    //   'บริการขนส่งระหว่างประเทศ\nรวดเร็ว ปลอดภัย ติดตามได้ทุกขั้นตอน',
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(fontSize: 20, color: kButtonColor, fontWeight: FontWeight.w500),
                    // ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.1),
              // 🔹 Email
              SizedBox(height: 8),
              CustomTextFormField(label: 'อีเมล', hintText: 'กรุณากรอกอีเมล', controller: _emailController, keyboardType: TextInputType.emailAddress),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: GestureDetector(
            onTap:
                isLoading
                    ? null
                    : () async {
                      if (_emailController.text.isNotEmpty) {
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final forgot = await LoginService.forgotPassword(email: _emailController.text);
                          if (forgot != null && mounted) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => OtpPage(email: _emailController.text)));
                          }
                        } on ClientException catch (e) {
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
                        } on SocketException catch (e) {
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
                        } on HttpException catch (e) {
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
                        } on FormatException catch (e) {
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
                          //LoadingDialog.close(context);
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
                        } finally {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      }
                    },
            child: Container(
              height: size.height * 0.07,
              width: size.width * 0.9,
              decoration: BoxDecoration(color: isLoading ? Colors.grey : kButtonColor, borderRadius: BorderRadius.circular(15)),
              child: Center(
                child:
                    isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('ลืมรหัสผ่าน', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
