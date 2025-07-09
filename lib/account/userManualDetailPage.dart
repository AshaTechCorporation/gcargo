import 'package:flutter/material.dart';

class UserManualDetailPage extends StatelessWidget {
  const UserManualDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('คู่มือการใช้งาน', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 รูปภาพขนาดใหญ่
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/images/imagenew14.png')),
            const SizedBox(height: 20),

            // 🔹 หัวข้อและรายละเอียด
            const Text('คู่มือการใช้งาน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              'รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด '
              'รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด '
              'รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            const Text('คู่มือการใช้งาน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              'รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด '
              'รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            const Text('โปรโมชั่น', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              'รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด '
              'รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
