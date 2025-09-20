import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gcargo/account/bankVerifyHistory.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/models/memberbank.dart';
import 'package:gcargo/services/accountService.dart';
import 'package:gcargo/services/uploadService.dart';
import 'package:get/get.dart';

class BankVerifyPage extends StatefulWidget {
  const BankVerifyPage({super.key});

  @override
  State<BankVerifyPage> createState() => _BankVerifyPageState();
}

class _BankVerifyPageState extends State<BankVerifyPage> {
  bool submitted = false;
  File? selectedFile;
  String? fileName;
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'bank_verification': 'ยืนยันบัญชีธนาคาร',
        'upload_bank_book': 'อัปโหลดสมุดบัญชีธนาคาร',
        'select_file': 'เลือกไฟล์',
        'upload': 'อัปโหลด',
        'uploading': 'กำลังอัปโหลด...',
        'view_history': 'ดูประวัติ',
        'file_selected': 'เลือกไฟล์แล้ว',
        'no_file_selected': 'ยังไม่ได้เลือกไฟล์',
        'please_select_file': 'กรุณาเลือกไฟล์ก่อนอัปโหลด',
        'upload_success': 'อัปโหลดสำเร็จ',
        'upload_error': 'เกิดข้อผิดพลาดในการอัปโหลด',
        'error': 'เกิดข้อผิดพลาด',
        'bank_already_verified': 'บัญชีธนาคารได้รับการยืนยันแล้ว',
        'loading': 'กำลังโหลด...',
        'supported_formats': 'รองรับไฟล์ PDF, JPG, PNG',
        'max_file_size': 'ขนาดไฟล์สูงสุด 10MB',
        'back': 'ย้อนกลับ',
        'confirm': 'ยืนยัน',
        'change_file': 'เปลี่ยนไฟล์',
        'bank_name_must_match': 'ชื่อบัญชีธนาคารจะต้องตรงกับ ชื่อ - นามสกุล ที่อยู่ในระบบ',
        'upload_bank_document': 'อัปโหลดรูปภาพหลักฐานบัญชีธนาคาร',
        'supported_file_types': 'รองรับไฟล์รูปนามสกุล JPG, PNG, PDF เท่านั้น',
        'under_review': 'อยู่ในระหว่างการตรวจสอบ',
        'review_message': 'คำร้องของท่านอยู่ระหว่างดำเนินการระบบจะแจ้งผลให้ทราบ\nทันทีหลังจากขั้นตอนดังกล่าวเสร็จสิ้น',
        'upload_history': 'ประวัติการอัปโหลด',
        'congratulations': 'ยินดีด้วย! การยืนยันบัญชีสำเร็จ',
      },
      'en': {
        'bank_verification': 'Bank Account Verification',
        'upload_bank_book': 'Upload Bank Book',
        'select_file': 'Select File',
        'upload': 'Upload',
        'uploading': 'Uploading...',
        'view_history': 'View History',
        'file_selected': 'File Selected',
        'no_file_selected': 'No File Selected',
        'please_select_file': 'Please select a file before uploading',
        'upload_success': 'Upload Successful',
        'upload_error': 'Upload Error',
        'error': 'Error',
        'bank_already_verified': 'Bank Account Already Verified',
        'loading': 'Loading...',
        'supported_formats': 'Supports PDF, JPG, PNG files',
        'max_file_size': 'Maximum file size 10MB',
        'back': 'Back',
        'confirm': 'Confirm',
        'change_file': 'Change File',
        'bank_name_must_match': 'Bank account name must match the name in the system',
        'upload_bank_document': 'Upload Bank Account Document',
        'supported_file_types': 'Supports JPG, PNG, PDF files only',
        'under_review': 'Under Review',
        'review_message': 'Your request is being processed. The system will notify you\nimmediately after the process is completed.',
        'upload_history': 'Upload History',
        'congratulations': 'Congratulations! Bank Account Verification Successful',
      },
      'zh': {
        'bank_verification': '银行账户验证',
        'upload_bank_book': '上传银行存折',
        'select_file': '选择文件',
        'upload': '上传',
        'uploading': '上传中...',
        'view_history': '查看历史',
        'file_selected': '已选择文件',
        'no_file_selected': '未选择文件',
        'please_select_file': '请先选择文件再上传',
        'upload_success': '上传成功',
        'upload_error': '上传错误',
        'error': '错误',
        'bank_already_verified': '银行账户已验证',
        'loading': '加载中...',
        'supported_formats': '支持PDF、JPG、PNG文件',
        'max_file_size': '最大文件大小10MB',
        'back': '返回',
        'confirm': '确认',
        'change_file': '更换文件',
        'bank_name_must_match': '银行账户名必须与系统中的姓名一致',
        'upload_bank_document': '上传银行账户证明文件',
        'supported_file_types': '仅支持JPG、PNG、PDF文件',
        'under_review': '审核中',
        'review_message': '您的申请正在处理中，系统将在\n流程完成后立即通知您。',
        'upload_history': '上传历史',
        'congratulations': '恭喜！银行账户验证成功',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  bool isLoading = false;
  bool isLoadingStatus = true;
  bool hasApprovedBank = false;
  List<MemberBank> memberBanks = [];

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    _checkBankStatus();
  }

  Future<void> _checkBankStatus() async {
    try {
      setState(() {
        isLoadingStatus = true;
      });

      final user = await AccountService.getUserById();
      memberBanks = user.member_banks ?? [];

      // เช็คว่ามีสถานะ approved หรือไม่
      hasApprovedBank = memberBanks.any((bank) => bank.status?.toLowerCase() == 'approved');

      setState(() {
        isLoadingStatus = false;
      });
    } catch (e) {
      setState(() {
        isLoadingStatus = false;
      });
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf']);

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        fileName = result.files.single.name;
      });
    }
  }

  Widget _buildApprovedContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ไอคอนสำเร็จ
        Image.asset('assets/icons/iconsuccess.png', width: 80, height: 80),
        const SizedBox(height: 24),

        // ข้อความหลัก
        Text(
          getTranslation('congratulations'),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // ข้อความรอง
        Text(getTranslation('bank_already_verified'), style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
              Text(getTranslation('bank_verification'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    isLoadingStatus
                        ? const Center(child: CircularProgressIndicator())
                        : hasApprovedBank
                        ? _buildApprovedContent()
                        : memberBanks.isNotEmpty || submitted
                        ? _buildSubmittedContent()
                        : _buildUploadContent(),
              ),
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
                onPressed: () async {
                  if (submitted) {
                    Navigator.pop(context); // ✅ ออกจากหน้านี้
                  } else {
                    try {
                      if (!mounted) return;
                      String? imageUrl;
                      if (selectedFile != null) {
                        imageUrl = await UoloadService.addImage(file: selectedFile!, path: 'uploads/asset/');
                      }

                      //เรียกเอพีไอบันทึกบัญชีธนาคาร
                      if (imageUrl != null) {
                        final user = await AccountService.addBankVerify(image: imageUrl);
                        if (user != null) {
                          setState(() {
                            submitted = true;
                          });
                        }
                      }

                      setState(() {
                        isLoading = false;
                      });
                    } catch (e) {
                      print(e);

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('${getTranslation('error')}: ${e.toString()}'), backgroundColor: Colors.red));
                    } finally {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                    setState(() {
                      submitted = true;
                    });
                  }
                },
                child: Text(
                  submitted ? getTranslation('back') : getTranslation('confirm'),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
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
          child: Text(getTranslation('bank_name_must_match'), style: TextStyle(color: Colors.red)),
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
                      Text(getTranslation('upload_bank_document')),
                      Text(getTranslation('supported_file_types')),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: pickFile,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: Text(getTranslation('select_file')),
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
                        child: Text(getTranslation('change_file')),
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
          Text(getTranslation('under_review'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(getTranslation('review_message'), textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 180,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => BankVerifyHistoryPage()));
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(getTranslation('upload_history')),
            ),
          ),
        ],
      ),
    );
  }
}
