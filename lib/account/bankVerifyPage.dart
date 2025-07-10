import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class BankVerifyPage extends StatefulWidget {
  const BankVerifyPage({super.key});

  @override
  State<BankVerifyPage> createState() => _BankVerifyPageState();
}

class _BankVerifyPageState extends State<BankVerifyPage> {
  bool submitted = false;
  File? selectedFile;
  String? fileName;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf']);

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        fileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
            const Text('ยืนยันบัญชีธนาคาร', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: submitted ? _buildSubmittedContent() : _buildUploadContent()),
          ),
          const Divider(height: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kButtonColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (submitted) {
                  Navigator.pop(context); // ✅ ออกจากหน้านี้
                } else {
                  setState(() {
                    submitted = true;
                  });
                }
              },
              child: Text(submitted ? 'ย้อนกลับ' : 'ยืนยัน', style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔴 Alert
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2F2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade300),
          ),
          child: const Text('ชื่อบัญชีธนาคารจะต้องตรงกับ ชื่อ - นามสกุล ที่อยู่ในระบบ', style: TextStyle(color: Colors.red)),
        ),

        // 📎 Preview หรือ Upload Area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
          child:
              selectedFile == null
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/icons/cl11.png', width: 64),
                      const SizedBox(height: 16),
                      const Text('อัปโหลดรูปภาพหลักฐานบัญชีธนาคาร'),
                      const Text('รองรับไฟล์รูปนามสกุล JPG, PNG, PDF เท่านั้น'),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: pickFile,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('เลือกไฟล์'),
                      ),
                    ],
                  )
                  : Column(
                    children: [
                      if (fileName != null)
                        fileName!.toLowerCase().endsWith('.pdf')
                            ? const Icon(Icons.picture_as_pdf, size: 60, color: Colors.red)
                            : Image.file(selectedFile!, width: 100, height: 100, fit: BoxFit.cover),
                      const SizedBox(height: 12),
                      Text(fileName ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: pickFile,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('เปลี่ยนไฟล์'),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _buildSubmittedContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icons/wanningLogout.png', width: 48),
          const SizedBox(height: 16),
          const Text('อยู่ในระหว่างการตรวจสอบ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'คำร้องของท่านอยู่ระหว่างดำเนินการระบบจะแจ้งผลให้ทราบ\nทันทีหลังจากขั้นตอนดังกล่าวเสร็จสิ้น',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 180,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('ประวัติการอัปโหลด'),
            ),
          ),
        ],
      ),
    );
  }
}
