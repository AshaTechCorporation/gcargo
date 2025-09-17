import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/services/loginService.dart';
import 'package:gcargo/widgets/CustomTextFormField.dart';
import 'package:http/http.dart';

class ResetPassword extends StatefulWidget {
  ResetPassword({super.key, required this.email});
  String email;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<FormState> _resetFormKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController newpassword = TextEditingController();
  final TextEditingController confirmnewpassword = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      email.text = widget.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('ยืนยัน Otp', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black)),
        bottom: PreferredSize(preferredSize: Size.fromHeight(1.0), child: Container(color: Colors.grey, height: 1.0)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.001),
              Center(
                child: Container(
                  height: size.height * 0.12,
                  width: size.width * 0.23,
                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/icons/Frame 61.png'), fit: BoxFit.fill)),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Center(
                child: Container(
                  height: size.height * 0.055,
                  width: size.width * 0.45,
                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/icons/Frame 76.png'), fit: BoxFit.fill)),
                ),
              ),
              SizedBox(height: size.height * 0.1),
              // 🔹 Email
              CustomTextFormField(label: 'อีเมล', hintText: 'กรุณากรอกอีเมล', controller: email, keyboardType: TextInputType.emailAddress),
              SizedBox(height: size.height * 0.02),
              CustomTextFormField(label: 'รหัสผ่าน', hintText: 'กรุณากรอกอีเมล', controller: newpassword, isPassword: true),
              SizedBox(height: size.height * 0.02),
              CustomTextFormField(label: 'ยืนยันรหัสผ่าน', hintText: 'กรุณากรอกอีเมล', controller: confirmnewpassword, isPassword: true),
              SizedBox(height: size.height * 0.02),
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
                      if (email.text.isNotEmpty && newpassword.text.isNotEmpty && confirmnewpassword.text.isNotEmpty) {
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          final reset = await LoginService.resetPassword(
                            email: email.text,
                            new_password: newpassword.text,
                            confirm_new_password: confirmnewpassword.text,
                          );
                          if (reset == true && mounted) {
                            Navigator.pop(context); // 1st pop
                            Navigator.pop(context); // 2nd pop
                            Navigator.pop(context); // 3rd pop
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
                        : Text('รีเซ็ตรหัสผ่าน', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
