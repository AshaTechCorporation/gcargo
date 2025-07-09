import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/widgets/CustomTextFormField.dart';
import 'package:gcargo/widgets/DatePickerTextFormField.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lineIdController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController referCodeController = TextEditingController();
  final TextEditingController agentCodeController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  String gender = 'male';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    lineIdController.dispose();
    phoneController.dispose();
    referCodeController.dispose();
    agentCodeController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF002D65);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('โปรไฟล์', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 รูปโปรไฟล์
              Column(
                children: [
                  ClipOval(child: Image.asset('assets/images/Avatar.png', width: 100, height: 100, fit: BoxFit.cover)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () {}, child: const Text('แก้ไขรูปภาพ', style: TextStyle(color: Colors.blue))),
                ],
              ),
              const SizedBox(height: 16),

              // 🔹 ช่องกรอกข้อมูล
              CustomTextFormField(label: 'อีเมล', hintText: 'Gcargo@gmail.com', controller: emailController),
              const SizedBox(height: 14),
              CustomTextFormField(label: 'รหัสผ่าน', hintText: 'กรอกรหัสผ่าน', controller: passwordController, isPassword: true),
              const SizedBox(height: 14),
              CustomTextFormField(label: 'ยืนยันรหัสผ่าน', hintText: 'ยืนยันรหัสผ่าน', controller: confirmPasswordController, isPassword: true),
              const SizedBox(height: 14),
              CustomTextFormField(label: 'ชื่อ-นามสกุล', hintText: 'ชื่อผู้ใช้ ชื่อผู้ใช้', controller: nameController),
              const SizedBox(height: 14),
              CustomTextFormField(label: 'ไอดีไลน์', hintText: '090-999-9599', controller: lineIdController),
              const SizedBox(height: 14),

              // 🔹 เพศ
              Row(
                children: [
                  const Text('เพศ', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      Radio<String>(value: 'female', groupValue: gender, onChanged: (value) => setState(() => gender = value!)),
                      const Text('หญิง'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(value: 'male', groupValue: gender, onChanged: (value) => setState(() => gender = value!)),
                      const Text('ชาย'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 🔹 วันเกิด
              DatePickerTextFormField(label: 'วันเดือนปีเกิด', controller: birthDateController, hintText: ''),
              const SizedBox(height: 14),

              CustomTextFormField(label: 'เบอร์โทรศัพท์มือถือ', hintText: '090-999-9599', controller: phoneController),
              const SizedBox(height: 14),
              CustomTextFormField(label: 'รหัสแนะนำ', hintText: '-', controller: referCodeController),
              const SizedBox(height: 14),
              CustomTextFormField(label: 'รหัสแอเจนต์', hintText: '-', controller: agentCodeController),
              const SizedBox(height: 24),

              // 🔹 ปุ่มยืนยัน
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  child: const Text('ยืนยัน', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
