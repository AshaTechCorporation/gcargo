import 'package:flutter/material.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/models/memberbank.dart';
import 'package:gcargo/models/user.dart';
import 'package:gcargo/services/accountService.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BankVerifyHistoryPage extends StatefulWidget {
  const BankVerifyHistoryPage({super.key});

  @override
  State<BankVerifyHistoryPage> createState() => _BankVerifyHistoryPageState();
}

class _BankVerifyHistoryPageState extends State<BankVerifyHistoryPage> {
  List<MemberBank> memberBanks = [];
  bool isLoading = true;
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'bank_verify_history': 'ประวัติการยืนยันบัญชีธนาคาร',
        'no_bank_history': 'ไม่มีประวัติการยืนยันบัญชีธนาคาร',
        'bank_name': 'ธนาคาร',
        'account_number': 'เลขบัญชี',
        'account_name': 'ชื่อบัญชี',
        'status': 'สถานะ',
        'date': 'วันที่',
        'pending': 'รอดำเนินการ',
        'approved': 'อนุมัติแล้ว',
        'rejected': 'ปฏิเสธ',
        'error': 'เกิดข้อผิดพลาด',
        'loading': 'กำลังโหลด...',
        'no_image': 'ไม่มีรูปภาพ',
        'no_photo': 'ไม่มีรูป',
      },
      'en': {
        'bank_verify_history': 'Bank Verification History',
        'no_bank_history': 'No Bank Verification History',
        'bank_name': 'Bank',
        'account_number': 'Account Number',
        'account_name': 'Account Name',
        'status': 'Status',
        'date': 'Date',
        'pending': 'Pending',
        'approved': 'Approved',
        'rejected': 'Rejected',
        'error': 'Error',
        'loading': 'Loading...',
        'no_image': 'No Image',
        'no_photo': 'No Photo',
      },
      'zh': {
        'bank_verify_history': '银行验证历史',
        'no_bank_history': '暂无银行验证历史',
        'bank_name': '银行',
        'account_number': '账号',
        'account_name': '账户名',
        'status': '状态',
        'date': '日期',
        'pending': '待处理',
        'approved': '已批准',
        'rejected': '已拒绝',
        'error': '错误',
        'loading': '加载中...',
        'no_image': '无图片',
        'no_photo': '无照片',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    _loadBankVerifyHistory();
  }

  Future<void> _loadBankVerifyHistory() async {
    try {
      setState(() {
        isLoading = true;
      });

      final user = await AccountService.getUserById();

      setState(() {
        memberBanks = user.member_banks ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${getTranslation('error')}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: false,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: Text(getTranslation('bank_verify_history'), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        body: SafeArea(
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : memberBanks.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(getTranslation('no_bank_history'), style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: memberBanks.length,
                    itemBuilder: (context, index) {
                      final bank = memberBanks[index];
                      return _BankVerifyItem(bank: bank, onImageTap: () => _showImageDialog(bank), getTranslation: getTranslation);
                    },
                  ),
        ),
      ),
    );
  }

  void _showImageDialog(MemberBank bank) {
    if (bank.image == null || bank.image!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getTranslation('no_image'))));
      return;
    }

    String imageUrl = bank.image!;
    if (!imageUrl.startsWith('http')) {
      imageUrl = 'https://g-cargo.dev-asha9.com/$imageUrl';
    }
    final isPdf = imageUrl.toLowerCase().endsWith('.pdf');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child:
                    isPdf
                        ? Container(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 80),
                              const SizedBox(height: 16),
                              const Text('ไฟล์ PDF', style: TextStyle(color: Colors.white, fontSize: 18)),
                              const SizedBox(height: 8),
                              Text(imageUrl.split('/').last, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        )
                        : InteractiveViewer(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, color: Colors.white, size: 64),
                                  SizedBox(height: 16),
                                  Text('ไม่สามารถแสดงรูปภาพได้', style: TextStyle(color: Colors.white)),
                                ],
                              );
                            },
                          ),
                        ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BankVerifyItem extends StatelessWidget {
  const _BankVerifyItem({required this.bank, required this.onImageTap, required this.getTranslation});

  final MemberBank bank;
  final VoidCallback onImageTap;
  final String Function(String) getTranslation;

  @override
  Widget build(BuildContext context) {
    // แปลงสถานะ
    String statusText;
    Color statusColor;

    switch (bank.status?.toLowerCase()) {
      case 'approved':
        statusText = getTranslation('approved');
        statusColor = const Color(0xFF2EB872);
        break;
      case 'rejected':
        statusText = getTranslation('rejected');
        statusColor = const Color(0xFFE24C4B);
        break;
      case 'pending':
        statusText = getTranslation('pending');
        statusColor = const Color(0xFFF39C12);
        break;
      case 'request':
        statusText = getTranslation('pending');
        statusColor = const Color(0xFFF39C12);
        break;
      default:
        statusText = getTranslation('pending');
        statusColor = const Color(0xFF6C6C6C);
    }

    // ตรวจสอบประเภทไฟล์และเพิ่ม base URL
    String imageUrl = bank.image ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://g-cargo.dev-asha9.com/$imageUrl';
    }
    final isPdf = imageUrl.toLowerCase().endsWith('.pdf');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // วันที่
          if (bank.created_at != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                DateFormat('dd/MM/yyyy').format(bank.created_at!),
                style: const TextStyle(color: Color(0xFF6C6C6C), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),

          // รูปภาพ/ไฟล์
          GestureDetector(
            onTap: onImageTap,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child:
                    imageUrl.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, color: Colors.grey, size: 32),
                              Text(getTranslation('no_photo'), style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        )
                        : isPdf
                        ? Container(
                          color: Colors.red.shade50,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                              Text('PDF', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                        : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, color: Colors.grey, size: 32),
                                  Text('ไม่สามารถโหลดรูป', style: TextStyle(fontSize: 8, color: Colors.grey)),
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // สถานะ
          Text(statusText, style: TextStyle(color: statusColor, fontSize: 14, fontWeight: FontWeight.w600)),

          // ชื่อ/รายละเอียด (ถ้ามี)
          if (bank.name != null && bank.name!.isNotEmpty)
            Padding(padding: const EdgeInsets.only(top: 4), child: Text(bank.name!, style: const TextStyle(fontSize: 12, color: Colors.grey))),
        ],
      ),
    );
  }
}
