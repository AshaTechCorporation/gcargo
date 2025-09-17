import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/login/resetPassword.dart';
import 'package:gcargo/services/loginService.dart';
import 'package:http/http.dart';
import 'package:pinput/pinput.dart';

class OtpPage extends StatefulWidget {
  OtpPage({super.key, required this.email});
  String email;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();
  bool isLoading = false;
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
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
                SizedBox(height: size.height * 0.01),
                Text('กรอกรหัสยืนยัน', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                Text(
                  'เราได้ส่ง OTP พร้อมรหัสยืนยันตัวตนของคุณ\nไปยังที่ ${widget.email} แล้ว',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 10),
                // FromRegister(
                //   width: size.width * 0.9,
                //   controller: _otpController,
                //   hintText: 'email',
                // ),
                // PinCodeTextField(
                //   appContext: context,
                //   controller: _otpController,
                //   length: 6,
                //   keyboardType: TextInputType.number,
                //   animationType: AnimationType.fade,
                //   autoFocus: true,
                //   pinTheme: PinTheme(
                //     shape: PinCodeFieldShape.box,
                //     borderRadius: BorderRadius.circular(8),
                //     fieldHeight: 50,
                //     fieldWidth: 45,
                //     activeColor: Colors.blue,
                //     selectedColor: Colors.orange,
                //     inactiveColor: Colors.grey,
                //   ),
                //   onChanged: (value) {
                //     print("Current value: $value");
                //   },
                //   onCompleted: (otp) {
                //     print("OTP Completed: $otp");
                //     setState(() {
                //       _otpController.text = otp;
                //     });
                //   },
                // ),
                Pinput(
                  // obscureText: true,
                  // obscuringCharacter: '•',
                  focusedPinTheme: PinTheme(
                    height: size.height * 0.075,
                    width: size.width * 0.15,
                    textStyle: TextStyle(color: kButtonColor, fontSize: 25),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kButtonColor),
                    ),
                  ),
                  defaultPinTheme: PinTheme(
                    height: size.height * 0.075,
                    width: size.width * 0.15,
                    textStyle: TextStyle(color: kButtonColor, fontSize: 25),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                  followingPinTheme: PinTheme(
                    height: size.height * 0.075,
                    width: size.width * 0.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                  controller: _otpController,
                  length: 6,
                  showCursor: false,
                  // readOnly: true,
                  // onChanged: (value) {
                  //   setState(() {
                  //     _pin = value;
                  //   });
                  // },
                  onCompleted: (pin) {},
                ),
              ],
            ),
            GestureDetector(
              onTap:
                  isLoading
                      ? null
                      : () async {
                        if (_otpController.text.isNotEmpty) {
                          setState(() {
                            isLoading = true;
                          });

                          try {
                            final otp = await LoginService.verifyOtpPassword(email: widget.email, otp: _otpController.text);
                            if (otp == true && mounted) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPassword(email: widget.email)));
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
                          : Text('ยืนยัน OTP', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
