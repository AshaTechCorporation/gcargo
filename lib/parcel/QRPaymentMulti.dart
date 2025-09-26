import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/services/orderService.dart';
import 'package:gcargo/services/uploadService.dart';
import 'package:gcargo/services/accountService.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';

class QRPaymentMulti extends StatefulWidget {
  QRPaymentMulti({super.key, required this.totalPrice, required this.orderType, required this.items, required this.vat});
  final double totalPrice;
  final String orderType;
  final List<Map<String, dynamic>> items;
  bool vat;

  @override
  State<QRPaymentMulti> createState() => _QRPaymentMultiState();
}

class _QRPaymentMultiState extends State<QRPaymentMulti> {
  File? uploadedImage;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  String? imageQR;
  List<dynamic> bankAccounts = [];
  bool isLoadingBanks = true;
  final LanguageController languageController = Get.find<LanguageController>();

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'qr_promptpay': 'QR พร้อมเพย์',
        'copy_account': 'คัดลอก',
        'copy_account_success': 'คัดลอกเลขบัญชี',
        'total_amount_pay': 'ยอดชำระทั้งหมด',
        'baht': 'บาท',
        'no_bank_data': 'ไม่พบข้อมูลธนาคาร',
        'contact_staff': 'โปรดติดต่อเจ้าหน้าที่',
        'upload_slip': 'อัปโหลดสลิป',
        'select_image': 'เลือกรูปภาพ',
        'upload_payment_slip': 'อัปโหลดสลิปการชำระเงิน',
        'confirm_payment': 'ยืนยันการชำระเงิน',
        'uploading': 'กำลังอัปโหลด...',
        'payment_success': 'ชำระเงินสำเร็จ',
        'payment_failed': 'การชำระเงินล้มเหลว',
        'change_image': 'เปลี่ยนรูป',
      },
      'en': {
        'qr_promptpay': 'QR PromptPay',
        'copy_account': 'Copy',
        'copy_account_success': 'Copied account number',
        'total_amount_pay': 'Total Amount',
        'baht': 'Baht',
        'no_bank_data': 'No bank data found',
        'contact_staff': 'Please contact staff',
        'upload_slip': 'Upload Slip',
        'select_image': 'Select Image',
        'upload_payment_slip': 'Upload Payment Slip',
        'confirm_payment': 'Confirm Payment',
        'uploading': 'Uploading...',
        'payment_success': 'Payment Successful',
        'payment_failed': 'Payment Failed',
        'change_image': 'Change Image',
      },
      'zh': {
        'qr_promptpay': 'QR 即时支付',
        'copy_account': '复制',
        'copy_account_success': '已复制账号',
        'total_amount_pay': '总金额',
        'baht': '泰铢',
        'no_bank_data': '未找到银行数据',
        'contact_staff': '请联系工作人员',
        'upload_slip': '上传凭证',
        'select_image': '选择图片',
        'upload_payment_slip': '上传付款凭证',
        'confirm_payment': '确认付款',
        'uploading': '上传中...',
        'payment_success': '付款成功',
        'payment_failed': '付款失败',
        'change_image': '更换图片',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

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
        bankAccounts = accounts;
        isLoadingBanks = false;
      });
    } catch (e) {
      setState(() {
        isLoadingBanks = false;
      });
      print('Error loading bank accounts: $e');
    }
  }

  // คัดลอกเลขบัญชี
  void _copyAccountNumber(String accountNumber) {
    Clipboard.setData(ClipboardData(text: accountNumber));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${getTranslation('copy_account_success')} $accountNumber แล้ว')));
  }

  // สร้าง URL เต็มสำหรับรูปภาพ
  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    } else {
      return 'https://g-cargo.dev-asha9.com/public/$imageUrl';
    }
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
      // ถ้าไม่มี PromptPay ให้แสดง QR Code เดิม (แต่ตอนนี้ comment ไว้)
      return SizedBox.shrink();
    }
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
        // อัปเดต widget.items ให้มี imageQR ในฟิลด์ image
        List<Map<String, dynamic>> updatedItems =
            widget.items.map((item) {
              Map<String, dynamic> updatedItem = Map.from(item);
              updatedItem['image'] = imageQR;
              return updatedItem;
            }).toList();

        // เรียก API ชำระเงิน
        String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await OrderService.paymentOrderMultiple(
          vat: widget.vat,
          payment_type: 'upload',
          total_price: widget.totalPrice,
          order_type: widget.orderType,
          item: updatedItems,
        );

        // หากสำเร็จ
        if (mounted) {
          // Show success message
          Get.snackbar('สำเร็จ', 'ชำระเงินสำเร็จ', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);

          // Go back to OrderStatusPage and refresh data
          // Use Get to go back to OrderStatusPage and trigger refresh
          Get.until((route) => Get.currentRoute == '/orderStatus' || route.isFirst);

          // Refresh OrderController data
          final OrderController orderController = Get.find<OrderController>();
          orderController.refreshData();
        }
      } else {
        throw Exception('ไม่สามารถอัปโหลดรูปภาพได้');
      }
    } catch (e) {
      // หากเกิดข้อผิดพลาด
      if (mounted) {
        _showErrorDialog('เกิดข้อผิดพลาดในการชำระเงิน: ${e.toString()}');
      }
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
        title: Text(getTranslation('qr_promptpay'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(child: Column(children: [_buildBankCard(), const SizedBox(height: 16), _buildUploadBox()])),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: isLoading ? Colors.grey : const Color(0xFF001B47),
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
    );
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
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(getTranslation('no_bank_data'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text(getTranslation('contact_staff'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
                        backgroundColor: Color(0xFF001B47),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(getTranslation('copy_account'), style: const TextStyle(fontSize: 12)),
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
            child: Text(
              '${getTranslation('total_amount_pay')}: ${widget.totalPrice.toStringAsFixed(2)} ${getTranslation('baht')}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
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
