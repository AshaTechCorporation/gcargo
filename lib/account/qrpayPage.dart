import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/services/accountService.dart';
import 'package:gcargo/services/uploadService.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class QrpayPage extends StatefulWidget {
  QrpayPage({super.key, required this.totalPrice, required this.type});
  final double totalPrice;
  final String type;

  @override
  State<QrpayPage> createState() => _QrpayPageState();
}

class _QrpayPageState extends State<QrpayPage> {
  File? uploadedImage;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  String? imageQR;
  final OrderController orderController = Get.find<OrderController>();
  List<dynamic> bankAccounts = [];
  bool isLoadingBanks = true;

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
  }

  // โหลดข้อมูลบัญชีธนาคาร
  Future<void> _loadBankAccounts() async {
    try {
      final accounts = await AccountService.getBankVerify();
      setState(() {
        for (var i = 0; i < accounts.length; i++) {
          // if (widget.vat == true) {
          //   if (accounts[i]['vat'] == "Y") {
          //     bankAccounts.add(accounts[i]);
          //   }
          // } else {
          if (accounts[i]['vat'] == "N") {
            bankAccounts.add(accounts[i]);
          }
          // }
        }
        // bankAccounts = accounts;
        isLoadingBanks = false;
      });
    } catch (e) {
      setState(() {
        isLoadingBanks = false;
      });
      print('Error loading bank accounts: $e');
    }
  }

  // ฟอแมทตัวเลขให้มีคอมม่า
  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
  }

  // เลือกรูปจากแกลเลอรี่
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        uploadedImage = File(image.path);
      });
    }
  }

  // ถ่ายรูป
  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        uploadedImage = File(image.path);
      });
    }
  }

  // แสดง dialog เลือกรูป
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เลือกรูปภาพ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('เลือกจากแกลเลอรี่'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('ถ่ายรูป'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ลบรูป
  void _removeImage() {
    setState(() {
      uploadedImage = null;
    });
  }

  // ดูรูป
  void _viewImage() {
    if (uploadedImage != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.black,
            child: Stack(
              children: [
                Center(child: Image.file(uploadedImage!, fit: BoxFit.contain)),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white, size: 30)),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // จัดการการชำระเงิน
  Future<void> _handlePayment() async {
    if (uploadedImage == null) {
      _showErrorDialog('กรุณาอัปโหลดหลักฐานการโอนเงิน');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // อัปโหลดรูปภาพ
      final imageQR = await UoloadService.addImage(file: uploadedImage!, path: 'uploads/alipay/');

      if (imageQR != null) {
        // เรียก API เติมเงิน
        await AccountService.walletTrans(amount: widget.totalPrice.toString(), image: imageQR, type: widget.type);

        // หากสำเร็จ
        if (mounted) {
          // อัปเดทข้อมูล wallet
          await orderController.getWalletTrans();

          // แสดงข้อความสำเร็จ
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('เติมเงินสำเร็จ! รอเจ้าหน้าที่ตรวจสอบ'), backgroundColor: Colors.green));

            // กลับไปหน้า WalletPage
            Navigator.of(context)
              ..pop(true)
              ..pop(true);
          }
        }
      } else {
        throw Exception('ไม่สามารถอัปโหลดรูปภาพได้');
      }
    } catch (e) {
      // หากเกิดข้อผิดพลาด
      if (mounted) {
        _showErrorDialog('เกิดข้อผิดพลาดในการชำระเงิน: ${e.toString()}');
      }
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // แสดง dialog ข้อผิดพลาด
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เกิดข้อผิดพลาด'),
          content: Text(message),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ตกลง'))],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF8),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('QR พร้อมเพย์', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(child: Column(children: [_buildBankCard(), const SizedBox(height: 16), _buildUploadBox()])),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () {
            // ชำระ
            _handlePayment();
          },
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoading ? Colors.grey : const Color.fromARGB(255, 28, 37, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child:
                  isLoading
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          ),
                          SizedBox(width: 8),
                          Text('กำลังดำเนินการ...', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      )
                      : const Text('ชำระเงิน', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  // สร้าง URL เต็มสำหรับรูปภาพ
  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    } else {
      return 'https://g-cargo.dev-asha9.com/public/$imageUrl';
    }
  }

  // คัดลอกเลขบัญชี
  void _copyAccountNumber(String accountNumber) {
    Clipboard.setData(ClipboardData(text: accountNumber));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('คัดลอกเลขบัญชี $accountNumber แล้ว')));
  }

  // สร้างส่วนแสดง PromptPay
  Widget _buildPromptPaySection() {
    // หาธนาคารที่เป็น PromptPay
    final promptPayBank = bankAccounts.firstWhere((bank) {
      final bankName = (bank['bank_name'] ?? '').toString().toLowerCase();
      return bankName.contains('พร้อมเพย์') || bankName.contains('promptpay') || bankName.contains('prompt pay');
    }, orElse: () => null);

    if (promptPayBank != null) {
      return Column(
        children: [
          // แสดงรูป icon ของ PromptPay
          Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            child:
                promptPayBank['icon'] != null && promptPayBank['icon'].isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _getFullImageUrl(promptPayBank['icon']),
                        width: 400,
                        height: 400,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code, size: 200, color: Colors.grey),
                      ),
                    )
                    : ClipOval(child: Image.asset('assets/images/No_Image.jpg', width: 400, height: 400, fit: BoxFit.fill)),
          ),
          const SizedBox(height: 12),
          // แสดงข้อมูลบัญชี
          Text(promptPayBank['account_name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(promptPayBank['account_number'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildBankCard() {
    if (isLoadingBanks) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE5E5E5)), borderRadius: BorderRadius.circular(12)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (bankAccounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE5E5E5)), borderRadius: BorderRadius.circular(12)),
        child: const Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('ไม่พบข้อมูลธนาคาร', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text('โปรดติดต่อเจ้าหน้าที่', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE5E5E5)), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // รายการธนาคาร
          ...bankAccounts.asMap().entries.map((entry) {
            final index = entry.key;
            final bank = entry.value;
            return Column(
              children: [
                Row(
                  children: [
                    // ไอคอนธนาคาร
                    bank['icon'] != null && bank['icon'].isNotEmpty
                        ? ClipOval(
                          child: Image.network(
                            _getFullImageUrl(bank['icon']),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Image.asset('assets/images/No_Image.jpg', width: 40, height: 40, fit: BoxFit.cover),
                          ),
                        )
                        : ClipOval(child: Image.asset('assets/images/No_Image.jpg', width: 40, height: 40, fit: BoxFit.cover)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bank['bank_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(bank['account_name'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                          Text(bank['account_number'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _copyAccountNumber(bank['account_number'] ?? ''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF001B47),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('คัดลอก', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                if (index < bankAccounts.length - 1) ...[const SizedBox(height: 12), const Divider(), const SizedBox(height: 12)],
              ],
            );
          }),

          const SizedBox(height: 16),
          const SizedBox(height: 12),
          const Divider(),
          _buildPromptPaySection(),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: Text('ยอดชำระทั้งหมด: ${_formatAmount(widget.totalPrice)} บาท', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF9381FF)),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF7F5FF),
      ),
      child:
          uploadedImage == null
              ? Column(
                children: [
                  Image.asset('assets/icons/cl11.png', width: 40, height: 40),
                  const SizedBox(height: 8),
                  const Text('อัปโหลดรูปภาพหลักฐานการโอน', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('รองรับไฟล์รูปนามสกุล JPG, PNG เท่านั้น', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _showImagePickerDialog,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      side: const BorderSide(color: Color(0xFF9381FF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      foregroundColor: const Color(0xFF9381FF),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text('เลือกไฟล์', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              )
              : Column(
                children: [
                  // แสดงรูปที่อัปโหลด
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(uploadedImage!, width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      // ปุ่มดูและลบ
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ปุ่มดู
                            GestureDetector(
                              onTap: _viewImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                child: const Icon(Icons.visibility, color: Colors.white, size: 18),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // ปุ่มลบ
                            GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('หลักฐานการโอน', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _showImagePickerDialog,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      side: const BorderSide(color: Color(0xFF9381FF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      foregroundColor: const Color(0xFF9381FF),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text('เปลี่ยนรูป', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
    );
  }
}
