import 'package:flutter/material.dart';
import 'package:gcargo/home/widgets/SuccessConfirmPage.dart';

class ConfirmOwnershipPage extends StatelessWidget {
  const ConfirmOwnershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String trackingNumber = 'YT7518613489991';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('เลขขนส่งจีน  $trackingNumber', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 รายละเอียด
                  const Text('รายละเอียด', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: const TextField(maxLines: 4, maxLength: 200, decoration: InputDecoration.collapsed(hintText: 'กรุณากรอกรายละเอียด')),
                  ),
                  const SizedBox(height: 16),

                  // 🔹 กล่องอัปโหลด
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid, width: 1),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/icons/cl11.png', width: 40),
                        const SizedBox(height: 8),
                        const Text('อัปโหลดรูปภาพหลักฐาน', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('รองรับไฟล์รูปเท่านั้น JPG, PNG, PDF เท่านั้น', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            // TODO: handle file picker
                          },
                          child: const Text('เลือกไฟล์'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 ตัวอย่างรูปภาพ
                  Row(children: [_previewImage('assets/images/image11.png'), const SizedBox(width: 12), _previewImage('assets/images/image14.png')]),
                ],
              ),
            ),
          ),

          // 🔹 ปุ่มยืนยัน
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3C72), // kButtonColor
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // TODO: handle confirm
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SuccessConfirmPage()));
                },
                child: const Text('ยืนยันความเป็นเจ้าของ', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewImage(String path) {
    return ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(path, width: 64, height: 64, fit: BoxFit.cover));
  }
}
