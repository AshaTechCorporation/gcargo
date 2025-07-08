import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/widgets/CustomTextFormField.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 โลโก้ด้านขวาบน
                Align(alignment: Alignment.topRight, child: Image.asset('assets/icons/Logo.png', width: 80)),
                const SizedBox(height: 16),

                // 🔹 หัวข้อ
                const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kButtonColor)),
                const SizedBox(height: 4),

                // 🔹 คำอธิบาย
                const Text('บริการขนส่งระหว่างประเทศรวดเร็ว ปลอดภัย ติดตามได้ทุกขั้นตอน', style: TextStyle(fontSize: 13, color: kHintTextColor)),
                const SizedBox(height: 24),

                // 🔹 Email
                const SizedBox(height: 8),
                CustomTextFormField(label: 'อีเมล', hintText: 'กรุณากรอกอีเมล', controller: _emailController),
                const SizedBox(height: 20),
                CustomTextFormField(label: 'รหัสผ่าน', hintText: '••••••••', controller: _passwordController, isPassword: true),
                const SizedBox(height: 6),
                const Text('รหัสผ่านต้องมีความยาว 8 - 20 ตัวอักษร', style: TextStyle(fontSize: 12, color: kHintTextColor)),

                // 🔹 ลืมรหัสผ่าน
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text('ลืมรหัสผ่าน', style: TextStyle(color: kHintTextColor)),
                  ),
                ),
                const SizedBox(height: 4),

                // 🔹 ปุ่มเข้าสู่ระบบ
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        // ดำเนินการเข้าสู่ระบบ
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 16),

                // 🔹 ข้อความ "หรือ"
                const Center(child: Text('หรือ', style: TextStyle(color: kHintTextColor))),
                const SizedBox(height: 16),

                // 🔹 ไอคอน + สร้างบัญชีใหม่ในแถวเดียวกัน
                Row(
                  children: [
                    Image.asset('assets/icons/g.png', width: 40),
                    const SizedBox(width: 20),
                    Image.asset('assets/icons/f.png', width: 40),
                    const SizedBox(width: 20),
                    Image.asset('assets/icons/line.png', width: 40),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: kButtonColor),
                      child: Row(
                        children: [
                          const Text('สร้างบัญชีใหม่', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: kButtonColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: kButtonColor, width: 1.6),
                            ),
                            child: const Icon(CupertinoIcons.right_chevron, size: 18, color: Colors.white),
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
