import 'package:flutter/material.dart';
import 'package:gcargo/models/memberbank.dart';
import 'package:gcargo/models/user.dart';
import 'package:gcargo/services/accountService.dart';
import 'package:intl/intl.dart';

class BankVerifyHistoryPage extends StatefulWidget {
  const BankVerifyHistoryPage({super.key});

  @override
  State<BankVerifyHistoryPage> createState() => _BankVerifyHistoryPageState();
}

class _BankVerifyHistoryPageState extends State<BankVerifyHistoryPage> {
  List<MemberBank> memberBanks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('ประวัติการอัปโหลด', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : memberBanks.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('ไม่มีประวัติการอัปโหลด', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: memberBanks.length,
                  itemBuilder: (context, index) {
                    final bank = memberBanks[index];
                    return _BankVerifyItem(bank: bank, onImageTap: () => _showImageDialog(bank));
                  },
                ),
      ),
    );
  }

  void _showImageDialog(MemberBank bank) {
    if (bank.image == null || bank.image!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่มีรูปภาพ')));
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
  const _BankVerifyItem({required this.bank, required this.onImageTap});

  final MemberBank bank;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context) {
    // แปลงสถานะ
    String statusText;
    Color statusColor;

    switch (bank.status?.toLowerCase()) {
      case 'approved':
        statusText = 'ได้รับการอนุมัติ';
        statusColor = const Color(0xFF2EB872);
        break;
      case 'rejected':
        statusText = 'ไม่ได้รับการอนุมัติ';
        statusColor = const Color(0xFFE24C4B);
        break;
      case 'pending':
        statusText = 'รอการอนุมัติ';
        statusColor = const Color(0xFFF39C12);
        break;
      case 'request':
        statusText = 'รอการอนุมัติ';
        statusColor = const Color(0xFFF39C12);
        break;
      default:
        statusText = 'ไม่ทราบสถานะ';
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
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, color: Colors.grey, size: 32),
                              Text('ไม่มีรูป', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
