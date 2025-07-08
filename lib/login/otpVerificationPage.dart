import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/login/otpSuccessPage.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final int pinLength = 6;
  List<String> otp = List.filled(6, '');
  List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  bool get isOtpComplete => otp.every((digit) => digit.isNotEmpty);

  void _onOtpChanged(String value, int index) {
    if (value.length == 1) {
      otp[index] = value;
      if (index < pinLength - 1) {
        focusNodes[index + 1].requestFocus();
      }
    } else if (value.isEmpty) {
      otp[index] = '';
      if (index > 0) {
        focusNodes[index - 1].requestFocus();
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.arrow_back),
              const SizedBox(height: 16),
              const Text('ลงทะเบียน', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kButtonColor)),
              const SizedBox(height: 4),
              const Text('สมัครใช้งานง่าย ส่งของจากจีนถึงไทยสบายใจทุกขั้นตอน', style: TextStyle(fontSize: 13, color: kHintTextColor)),
              const SizedBox(height: 24),
              const Text('กรุณากรอกรหัส OTP ที่เบอร์', style: TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 4),
              const Text('+66 99 999 9999', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              const SizedBox(height: 24),

              // 🔢 OTP input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(pinLength, (index) {
                  return SizedBox(
                    width: 44,
                    height: 52,
                    child: TextField(
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(counterText: '', border: OutlineInputBorder(borderRadius: BorderRadius.circular(6))),
                      onChanged: (value) => _onOtpChanged(value, index),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // ✅ ปุ่ม "ยืนยัน"
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      isOtpComplete
                          ? () {
                            // TODO: ดำเนินการต่อ
                            Navigator.push(context, MaterialPageRoute(builder: (context) => OtpSuccessPage()));
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOtpComplete ? kButtonColor : kButtondiableColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('ยืนยัน', style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 12),

              // 🔁 ปุ่มส่งใหม่
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: ส่งรหัสใหม่
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kButtonColor,
                    side: const BorderSide(color: kButtonColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('ส่งรหัสใหม่', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
