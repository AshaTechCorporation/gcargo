import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/home/widgets/SuccessConfirmPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ConfirmOwnershipPage extends StatefulWidget {
  const ConfirmOwnershipPage({super.key});

  @override
  State<ConfirmOwnershipPage> createState() => _ConfirmOwnershipPageState();
}

class _ConfirmOwnershipPageState extends State<ConfirmOwnershipPage> {
  final List<File> selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  // เลือกรูปภาพ
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);

      if (image != null) {
        setState(() {
          selectedFiles.add(File(image.path));
        });
      }
    } catch (e) {
      _showErrorSnackBar('เกิดข้อผิดพลาดในการเลือกรูปภาพ');
    }
  }

  // เลือกไฟล์ PDF
  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedFiles.add(File(result.files.single.path!));
        });
      }
    } catch (e) {
      _showErrorSnackBar('เกิดข้อผิดพลาดในการเลือกไฟล์ PDF');
    }
  }

  // แสดงตัวเลือกเลือกไฟล์
  void _showFilePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('เลือกรูปภาพ'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('เลือกไฟล์ PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPDF();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('ถ่าย<|im_start|>'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ถ่ายรูป
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);

      if (image != null) {
        setState(() {
          selectedFiles.add(File(image.path));
        });
      }
    } catch (e) {
      _showErrorSnackBar('เกิดข้อผิดพลาดในการถ่ายรูป');
    }
  }

  // ลบไฟล์
  void _removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  // แสดง error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  // ดูไฟล์
  void _viewFile(File file) {
    String fileName = file.path.split('/').last;
    String extension = fileName.split('.').last.toLowerCase();

    if (extension == 'pdf') {
      // แสดง PDF viewer หรือเปิดด้วย app อื่น
      _showErrorSnackBar('ไฟล์ PDF: $fileName');
    } else {
      // แสดงรูปภาพ
      showDialog(
        context: context,
        builder:
            (context) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(title: Text(fileName), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))),
                  Expanded(child: Image.file(file, fit: BoxFit.contain)),
                ],
              ),
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String trackingNumber = 'YT7518613489991';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('เลขขนส่งจีน  $trackingNumber', style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
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
                  const Text('รายละเอียด', style: TextStyle(fontSize: 16)),
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
                        const Text('อัปโหลดรูปภาพหลักฐาน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text('รองรับไฟล์รูปเท่านั้น JPG, PNG, PDF เท่านั้น', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 12),
                        OutlinedButton(onPressed: _showFilePickerOptions, child: const Text('เลือกไฟล์')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 แสดงไฟล์ที่เลือก
                  if (selectedFiles.isNotEmpty) ...[
                    const Text('ไฟล์ที่เลือก', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          selectedFiles.asMap().entries.map((entry) {
                            int index = entry.key;
                            File file = entry.value;
                            return _buildFilePreview(file, index);
                          }).toList(),
                    ),
                  ],
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
                  backgroundColor: kButtonColor, // kButtonColor
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

  Widget _buildFilePreview(File file, int index) {
    String fileName = file.path.split('/').last;
    String extension = fileName.split('.').last.toLowerCase();

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: Stack(
        children: [
          // แสดงไฟล์
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  extension == 'pdf'
                      ? Container(
                        color: Colors.red.shade50,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                            Text('PDF', style: TextStyle(fontSize: 10, color: Colors.red)),
                          ],
                        ),
                      )
                      : Image.file(file, fit: BoxFit.cover),
            ),
          ),

          // ปุ่มดู
          Positioned(
            top: 2,
            left: 2,
            child: GestureDetector(
              onTap: () => _viewFile(file),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                child: const Icon(Icons.visibility, color: Colors.white, size: 12),
              ),
            ),
          ),

          // ปุ่มลบ
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => _removeFile(index),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
