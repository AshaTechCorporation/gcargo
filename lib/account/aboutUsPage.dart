import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('เกี่ยวกับเรา', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('คู่มือการใช้งาน'),
            const SizedBox(height: 20),
            _buildSection('คู่มือการใช้งาน'),
            const SizedBox(height: 20),
            _buildSection('โปรโมชั่น'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด\n'
          'รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด\n'
          'รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด\n'
          'รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด\n'
          'รายละเอียด รายละเอียด รายละเอียด รายละเอียด รายละเอียด',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
