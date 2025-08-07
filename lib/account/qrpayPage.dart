import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/services/accountService.dart';
import 'package:gcargo/services/uploadService.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:promptpay_qrcode_generate/promptpay_qrcode_generate.dart';

class QrpayPage extends StatefulWidget {
  QrpayPage({super.key, required this.totalPrice});
  final double totalPrice;

  @override
  State<QrpayPage> createState() => _QrpayPageState();
}

class _QrpayPageState extends State<QrpayPage> {
  File? uploadedImage;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  String? imageQR;
  final OrderController orderController = Get.find<OrderController>();

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
        await AccountService.walletTrans(amount: widget.totalPrice.toString());

        // หากสำเร็จ
        if (mounted) {
          // อัปเดทข้อมูล wallet
          await orderController.getWalletTrans();

          // แสดงข้อความสำเร็จ
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เติมเงินสำเร็จ!'), backgroundColor: Colors.green));

            // กลับไปหน้า WalletPage
            Navigator.of(context)
              ..pop()
              ..pop();
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

  Widget _buildBankCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE5E5E5)), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              ClipOval(child: Image.asset('assets/icons/image98.png', width: 40, height: 40, fit: BoxFit.cover)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ธนาคารกสิกรไทย', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('บริษัท ริการ์โต้ จำกัด', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    Text('ออมทรัพย์ 664-2-14124-2', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
              //TextButton(onPressed: () {}, child: const Text('ดาวน์โหลด', style: TextStyle(color: Color(0xFF9381FF), fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 12),
          QRCodeGenerate(promptPayId: "0923709961", amount: widget.totalPrice, width: 400, height: 400),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: Text('ยอดชำระทั้งหมด: ${widget.totalPrice} บาท', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
