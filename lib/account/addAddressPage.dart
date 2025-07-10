import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/widgets/CustomTextFormField.dart';
import 'package:gcargo/widgets/CustomDropdownField.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final nameController = TextEditingController();
  final receiverController = TextEditingController();
  final phoneController = TextEditingController();
  final detailController = TextEditingController();
  final postalCodeController = TextEditingController();

  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSubDistrict;

  final provinces = ['กรุงเทพมหานคร', 'เชียงใหม่', 'ขอนแก่น'];
  final districts = ['เขตจตุจักร', 'เขตดินแดง', 'อำเภอเมือง'];
  final subDistricts = ['แขวงลาดยาว', 'ตำบลสันกำแพง', 'ตำบลในเมือง'];

  @override
  void dispose() {
    nameController.dispose();
    receiverController.dispose();
    phoneController.dispose();
    detailController.dispose();
    postalCodeController.dispose();
    super.dispose();
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
            IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
            Text('เพิ่มที่อยู่', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextFormField(label: 'ชื่อที่อยู่จัดส่ง', hintText: 'กรุณากรอกชื่อที่อยู่จัดส่ง', controller: nameController),
                    SizedBox(height: 16),
                    CustomTextFormField(label: 'ชื่อผู้รับ', hintText: 'กรุณากรอกชื่อผู้รับ', controller: receiverController),
                    SizedBox(height: 16),
                    CustomTextFormField(label: 'เบอร์ติดต่อ', hintText: 'กรุณากรอกเบอร์ติดต่อ', controller: phoneController),
                    SizedBox(height: 16),
                    CustomTextFormField(
                      label: 'รายละเอียดที่อยู่จัดส่ง',
                      hintText: 'กรุณากรอกรายละเอียดที่อยู่จัดส่ง',
                      controller: detailController,
                      maxLines: 4,
                    ),
                    SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: CustomDropdownField(
                            label: 'จังหวัด',
                            hintText: 'กรุณาเลือกจังหวัด',
                            items: provinces,
                            selectedValue: selectedProvince,
                            onChanged: (value) => setState(() => selectedProvince = value),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: CustomDropdownField(
                            label: 'อำเภอ',
                            hintText: 'กรุณาเลือกอำเภอ',
                            items: districts,
                            selectedValue: selectedDistrict,
                            onChanged: (value) => setState(() => selectedDistrict = value),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDropdownField(
                            label: 'ตำบล',
                            hintText: 'กรุณาเลือกตำบล',
                            items: subDistricts,
                            selectedValue: selectedSubDistrict,
                            onChanged: (value) => setState(() => selectedSubDistrict = value),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: CustomTextFormField(label: 'รหัสไปรษณีย์', hintText: 'กรุณากรอกรหัสไปรษณีย์', controller: postalCodeController),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // TODO: บันทึกข้อมูล
                  Navigator.pop(context);
                },
                child: Text('ยืนยัน', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
