import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/account_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/models/provice.dart';
import 'package:gcargo/models/shipping.dart';
import 'package:gcargo/widgets/CustomTextFormField.dart';
import 'package:gcargo/widgets/CustomDropdownFormField.dart';
import 'package:get/get.dart';

class EditAddressPage extends StatefulWidget {
  final Shipping address;

  const EditAddressPage({super.key, required this.address});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final nameController = TextEditingController();
  final receiverController = TextEditingController();
  final phoneController = TextEditingController();
  final detailController = TextEditingController();
  final postalCodeController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  // Location และ AccountController
  late final AccountController accountController;
  late LanguageController languageController;
  bool isLoading = false;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'edit_address': 'แก้ไขที่อยู่',
        'address_name': 'ชื่อที่อยู่',
        'receiver_name': 'ชื่อผู้รับ',
        'phone_number': 'เบอร์โทรศัพท์',
        'address_detail': 'รายละเอียดที่อยู่',
        'province': 'จังหวัด',
        'district': 'อำเภอ',
        'subdistrict': 'ตำบล',
        'postal_code': 'รหัสไปรษณีย์',
        'latitude': 'ละติจูด',
        'longitude': 'ลองจิจูด',
        'save': 'บันทึก',
        'saving': 'กำลังบันทึก...',
        'select_province': 'เลือกจังหวัด',
        'select_district': 'เลือกอำเภอ',
        'select_subdistrict': 'เลือกตำบล',
        'success': 'สำเร็จ',
        'error': 'เกิดข้อผิดพลาด',
        'address_updated': 'แก้ไขที่อยู่สำเร็จ',
        'please_fill_required': 'กรุณากรอกข้อมูลที่จำเป็น',
        'invalid_phone': 'รูปแบบเบอร์โทรศัพท์ไม่ถูกต้อง',
      },
      'en': {
        'edit_address': 'Edit Address',
        'address_name': 'Address Name',
        'receiver_name': 'Receiver Name',
        'phone_number': 'Phone Number',
        'address_detail': 'Address Detail',
        'province': 'Province',
        'district': 'District',
        'subdistrict': 'Subdistrict',
        'postal_code': 'Postal Code',
        'latitude': 'Latitude',
        'longitude': 'Longitude',
        'save': 'Save',
        'saving': 'Saving...',
        'select_province': 'Select Province',
        'select_district': 'Select District',
        'select_subdistrict': 'Select Subdistrict',
        'success': 'Success',
        'error': 'Error',
        'address_updated': 'Address updated successfully',
        'please_fill_required': 'Please fill required fields',
        'invalid_phone': 'Invalid phone number format',
      },
      'zh': {
        'edit_address': '编辑地址',
        'address_name': '地址名称',
        'receiver_name': '收件人姓名',
        'phone_number': '电话号码',
        'address_detail': '地址详情',
        'province': '省份',
        'district': '区',
        'subdistrict': '街道',
        'postal_code': '邮政编码',
        'latitude': '纬度',
        'longitude': '经度',
        'save': '保存',
        'saving': '保存中...',
        'select_province': '选择省份',
        'select_district': '选择区',
        'select_subdistrict': '选择街道',
        'success': '成功',
        'error': '错误',
        'address_updated': '地址更新成功',
        'please_fill_required': '请填写必填字段',
        'invalid_phone': '电话号码格式无效',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  // Province data
  List<Provice> provinces = [];
  List<Provice> districts = [];
  List<Provice> subdistricts = [];

  // Selected values
  Provice? selectedProvince;
  Provice? selectedDistrict;
  Provice? selectedSubdistrict;

  // Filtered lists
  List<Provice> filteredDistricts = [];
  List<Provice> filteredSubdistricts = [];

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    accountController = Get.put(AccountController());
    _loadProvinceData();
    _populateFields();
  }

  // Load province data from JSON files
  Future<void> _loadProvinceData() async {
    try {
      // Load provinces
      final provincesJson = await rootBundle.loadString('assets/provice/provinces.json');
      final provincesData = json.decode(provincesJson) as List;
      provinces = provincesData.map((json) => Provice.fromJson(json)).toList();

      // Load districts
      final districtsJson = await rootBundle.loadString('assets/provice/districts.json');
      final districtsData = json.decode(districtsJson) as List;
      districts = districtsData.map((json) => Provice.fromJson(json)).toList();

      // Load subdistricts
      final subdistrictsJson = await rootBundle.loadString('assets/provice/subdistricts.json');
      final subdistrictsData = json.decode(subdistrictsJson) as List;
      subdistricts = subdistrictsData.map((json) => Provice.fromJson(json)).toList();

      setState(() {});
      _setSelectedProvinces();
    } catch (e) {
      print('Error loading province data: $e');
    }
  }

  // Populate fields with existing address data
  void _populateFields() {
    nameController.text = widget.address.address ?? '';
    receiverController.text = widget.address.contact_name ?? '';
    phoneController.text = widget.address.contact_phone ?? '';
    postalCodeController.text = widget.address.postal_code ?? '';
    latitudeController.text = widget.address.latitude ?? '0.000';
    longitudeController.text = widget.address.longitude ?? '0.000';
  }

  // Set selected provinces based on existing data
  void _setSelectedProvinces() {
    if (provinces.isNotEmpty && districts.isNotEmpty && subdistricts.isNotEmpty) {
      // Find matching province
      selectedProvince = provinces.firstWhere((p) => p.nameTH == widget.address.province, orElse: () => provinces.first);

      if (selectedProvince != null) {
        filteredDistricts = districts.where((d) => d.provinceCode == selectedProvince!.provinceCode).toList();

        // Find matching district
        selectedDistrict = filteredDistricts.firstWhere(
          (d) => d.nameTH == widget.address.district,
          orElse: () => filteredDistricts.isNotEmpty ? filteredDistricts.first : districts.first,
        );

        if (selectedDistrict != null) {
          filteredSubdistricts = subdistricts.where((s) => s.districtCode == selectedDistrict!.districtCode).toList();

          // Find matching subdistrict
          selectedSubdistrict = filteredSubdistricts.firstWhere(
            (s) => s.nameTH == widget.address.sub_district,
            orElse: () => filteredSubdistricts.isNotEmpty ? filteredSubdistricts.first : subdistricts.first,
          );
        }
      }
      setState(() {});
    }
  }

  // Filter districts based on selected province
  void _onProvinceChanged(Provice? province) {
    setState(() {
      selectedProvince = province;
      selectedDistrict = null;
      selectedSubdistrict = null;

      if (province != null) {
        filteredDistricts = districts.where((district) => district.provinceCode == province.provinceCode).toList();
      } else {
        filteredDistricts = [];
      }
      filteredSubdistricts = [];
      postalCodeController.clear();
    });
  }

  // Filter subdistricts based on selected district
  void _onDistrictChanged(Provice? district) {
    setState(() {
      selectedDistrict = district;
      selectedSubdistrict = null;

      if (district != null) {
        filteredSubdistricts = subdistricts.where((subdistrict) => subdistrict.districtCode == district.districtCode).toList();
      } else {
        filteredSubdistricts = [];
      }
      postalCodeController.clear();
    });
  }

  // Update postal code when subdistrict is selected
  void _onSubdistrictChanged(Provice? subdistrict) {
    setState(() {
      selectedSubdistrict = subdistrict;
      if (subdistrict != null && subdistrict.postalCode != null) {
        postalCodeController.text = subdistrict.postalCode.toString();
      } else {
        postalCodeController.clear();
      }
    });
  }

  // ฟังก์ชั่นสำหรับแก้ไขข้อมูล
  Future<void> _updateAddress() async {
    if (_validateForm()) {
      setState(() {
        isLoading = true;
      });

      try {
        final addressData = {
          'address': nameController.text,
          'province': selectedProvince?.nameTH ?? '',
          'district': selectedDistrict?.nameTH ?? '',
          'sub_district': selectedSubdistrict?.nameTH ?? '',
          'postal_code': postalCodeController.text,
          'latitude': double.tryParse(latitudeController.text) ?? 0.0,
          'longitude': double.tryParse(longitudeController.text) ?? 0.0,
          'contact_name': receiverController.text,
          'contact_phone': phoneController.text,
        };

        await accountController.editAddress(widget.address.id!, addressData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getTranslation('address_updated')), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${getTranslation('error')}: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  // ฟังก์ชั่นสำหรับตรวจสอบข้อมูล
  bool _validateForm() {
    if (nameController.text.isEmpty ||
        receiverController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedProvince == null ||
        selectedDistrict == null ||
        selectedSubdistrict == null ||
        postalCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')));
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    nameController.dispose();
    receiverController.dispose();
    phoneController.dispose();
    detailController.dispose();
    postalCodeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back_ios_new, color: Colors.black)),
          title: Text(getTranslation('edit_address'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(label: getTranslation('address_name'), hintText: getTranslation('address_name'), controller: nameController),
                    SizedBox(height: 16),
                    CustomTextFormField(
                      label: getTranslation('receiver_name'),
                      hintText: getTranslation('receiver_name'),
                      controller: receiverController,
                    ),
                    SizedBox(height: 16),
                    CustomTextFormField(
                      label: getTranslation('phone_number'),
                      hintText: getTranslation('phone_number'),
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    CustomTextFormField(
                      label: getTranslation('address_detail'),
                      hintText: getTranslation('address_detail'),
                      controller: detailController,
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDropdownFormField<Provice>(
                            label: getTranslation('province'),
                            hintText: getTranslation('select_province'),
                            value: selectedProvince,
                            items:
                                provinces.map((province) => DropdownMenuItem<Provice>(value: province, child: Text(province.nameTH ?? ''))).toList(),
                            onChanged: _onProvinceChanged,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: CustomDropdownFormField<Provice>(
                            label: getTranslation('district'),
                            hintText: getTranslation('select_district'),
                            value: selectedDistrict,
                            items:
                                filteredDistricts
                                    .map((district) => DropdownMenuItem<Provice>(value: district, child: Text(district.nameTH ?? '')))
                                    .toList(),
                            onChanged: _onDistrictChanged,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDropdownFormField<Provice>(
                            label: getTranslation('subdistrict'),
                            hintText: getTranslation('select_subdistrict'),
                            value: selectedSubdistrict,
                            items:
                                filteredSubdistricts
                                    .map((subdistrict) => DropdownMenuItem<Provice>(value: subdistrict, child: Text(subdistrict.nameTH ?? '')))
                                    .toList(),
                            onChanged: _onSubdistrictChanged,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: CustomTextFormField(
                            label: getTranslation('postal_code'),
                            hintText: getTranslation('postal_code'),
                            controller: postalCodeController,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            label: getTranslation('latitude'),
                            hintText: getTranslation('latitude'),
                            controller: latitudeController,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: CustomTextFormField(
                            label: getTranslation('longitude'),
                            hintText: getTranslation('longitude'),
                            controller: longitudeController,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isLoading ? null : _updateAddress,
                  child:
                      isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(getTranslation('save'), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
