import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ClaimPackagePage extends StatefulWidget {
  const ClaimPackagePage({super.key});

  @override
  State<ClaimPackagePage> createState() => _ClaimPackagePageState();
}

class _ClaimPackagePageState extends State<ClaimPackagePage> {
  // State สำหรับ checkbox
  bool selectAll = false;
  List<bool> selectedItems = [false, false, false]; // สมมติมี 3 รายการ

  // State สำหรับจำนวนสินค้า
  List<int> quantities = [1, 1, 1]; // จำนวนเริ่มต้นของแต่ละรายการ

  // State สำหรับรูปภาพ
  List<File> uploadedImages = [];
  final ImagePicker _picker = ImagePicker();

  // จัดการ checkbox ทั้งหมด
  void _toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      for (int i = 0; i < selectedItems.length; i++) {
        selectedItems[i] = selectAll;
      }
    });
  }

  // จัดการ checkbox แต่ละรายการ
  void _toggleItem(int index, bool? value) {
    setState(() {
      selectedItems[index] = value ?? false;
      selectAll = selectedItems.every((item) => item);
    });
  }

  // เพิ่มจำนวนสินค้า
  void _increaseQuantity(int index) {
    setState(() {
      quantities[index]++;
    });
  }

  // ลดจำนวนสินค้า
  void _decreaseQuantity(int index) {
    setState(() {
      if (quantities[index] > 1) {
        quantities[index]--;
      }
    });
  }

  // เลือกรูปจากแกลเลอรี่
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        uploadedImages.add(File(image.path));
      });
    }
  }

  // ถ่ายรูป
  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        uploadedImages.add(File(image.path));
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
  void _removeImage(int index) {
    setState(() {
      uploadedImages.removeAt(index);
    });
  }

  // ดูรูป
  void _viewImage(File image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Image.file(image), TextButton(onPressed: () => Navigator.pop(context), child: const Text('ปิด'))],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('แจ้งเคลมพัสดุ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProductCard(),
              const SizedBox(height: 12),
              _buildProductItem(1, 'เสื้อยืด', '300฿ x2', '600฿', 'L', 'สีแดง'),
              const SizedBox(height: 12),
              _buildProductItem(2, 'กางเกง', '800฿ x1', '800฿', 'XL', 'สีดำ'),
              const SizedBox(height: 20),
              _buildRemarkSection(),
              const SizedBox(height: 20),
              _buildUploadBox(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001B47),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ยืนยัน', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(int index, String name, String priceText, String totalPrice, String size, String color) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E5E5))),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Checkbox(value: selectedItems[index], activeColor: const Color(0xFF001B47), onChanged: (value) => _toggleItem(index, value)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/unsplash1.png', width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(priceText, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(totalPrice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [_buildTag(size), _buildTag(color)]),
                    _buildQuantity(index),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E5E5))),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(value: selectAll, activeColor: const Color(0xFF001B47), onChanged: _toggleSelectAll),
              const Text('เลือกทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Checkbox ด้านซ้าย
              Checkbox(
                value: selectedItems[0], // รายการแรก
                activeColor: const Color(0xFF001B47),
                onChanged: (value) => _toggleItem(0, value),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/images/unsplash1.png', width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('500฿ x5', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text('2,500฿', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const Text('รองเท้า', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [_buildTag('M'), _buildTag('สีฟ้า')]),
                        _buildQuantity(0), // รายการแรก index 0
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildQuantity(int index) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _decreaseQuantity(index),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: quantities[index] > 1 ? Colors.grey.shade200 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.remove, size: 18, color: quantities[index] > 1 ? Colors.grey.shade700 : Colors.grey.shade400),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
          child: Text('${quantities[index]}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _increaseQuantity(index),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
            child: Icon(Icons.add, size: 18, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  Widget _buildRemarkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('หมายเหตุ', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E5E5)), borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: const TextField(maxLines: 4, decoration: InputDecoration(border: InputBorder.none, hintText: 'หมายเหตุ')),
        ),
        const SizedBox(height: 4),
        const Align(alignment: Alignment.centerRight, child: Text('51/200', style: TextStyle(fontSize: 12, color: Colors.grey))),
      ],
    );
  }

  Widget _buildUploadBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF9381FF), style: BorderStyle.solid, width: 1),
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFF7F5FF),
          ),
          child:
              uploadedImages.isEmpty
                  ? Column(
                    children: [
                      Image.asset('assets/icons/cl11.png', width: 40, height: 40),
                      const SizedBox(height: 8),
                      const Text('อัปโหลดรูปภาพหลักฐาน', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('รองรับไฟล์นามสกุล JPG, PNG เท่านั้น', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 12),
                      OutlinedButton(onPressed: _showImagePickerDialog, child: const Text('เลือกไฟล์')),
                    ],
                  )
                  : Column(
                    children: [
                      // แสดงรูปแรกที่อัปโหลด
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(uploadedImages.first, width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 8),
                      const Text('รูปภาพหลักฐาน', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${uploadedImages.length} รูป', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 12),
                      OutlinedButton(onPressed: _showImagePickerDialog, child: const Text('เพิ่มรูป')),
                    ],
                  ),
        ),

        // แสดงรูปที่อัปโหลดแล้ว
        if (uploadedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('รูปภาพที่อัปโหลด:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                uploadedImages.asMap().entries.map((entry) {
                  int index = entry.key;
                  File image = entry.value;
                  return _buildImageCard(image, index);
                }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildImageCard(File image, int index) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: Stack(
        children: [
          // รูปภาพ
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(image, width: 120, height: 120, fit: BoxFit.cover)),

          // ปุ่มดูและลบ
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ปุ่มดู
                GestureDetector(
                  onTap: () => _viewImage(image),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    child: const Icon(Icons.visibility, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 4),
                // ปุ่มลบ
                GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
