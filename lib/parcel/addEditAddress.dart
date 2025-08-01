import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcargo/models/provice.dart';
import 'package:gcargo/widgets/CustomDropdownFormField.dart';
import 'package:gcargo/widgets/CustomTextFormField.dart';

class AddEditAddressPage extends StatefulWidget {
  final bool isEdit;
  final Map<String, String>? address;

  const AddEditAddressPage({super.key, required this.isEdit, this.address});

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final nameAddressController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final detailController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // ตัวแปรสำหรับจังหวัด อำเภอ ตำบล
  Provice? selectedProvince;
  Provice? selectedDistrict;
  Provice? selectedSubdistrict;

  // รายการข้อมูล
  List<Provice> provinces = [];
  List<Provice> districts = [];
  List<Provice> subdistricts = [];
  List<Provice> filteredDistricts = [];
  List<Provice> filteredSubdistricts = [];

  @override
  void initState() {
    super.initState();
    _loadProvinceData().then((_) {
      if (widget.isEdit && widget.address != null) {
        _populateEditData();
      }
    });
  }

  // แพชข้อมูลเมื่อแก้ไข
  void _populateEditData() {
    final address = widget.address!;

    // แพชข้อมูลพื้นฐาน
    nameAddressController.text = address['address'] ?? '';
    nameController.text = address['name'] ?? '';
    phoneController.text = address['phone'] ?? '';
    detailController.text = address['detail'] ?? '';
    _postalCodeController.text = address['postalCode'] ?? '';

    // หาและตั้งค่าจังหวัด
    if (address['province'] != null) {
      selectedProvince = provinces.firstWhere((province) => province.nameTH == address['province'], orElse: () => provinces.first);
      if (selectedProvince != null) {
        filteredDistricts = districts.where((district) => district.provinceCode == selectedProvince!.provinceCode).toList();
      }
    }

    // หาและตั้งค่าอำเภอ
    if (address['district'] != null && selectedProvince != null) {
      selectedDistrict = filteredDistricts.firstWhere(
        (district) => district.nameTH == address['district'],
        orElse: () => filteredDistricts.isNotEmpty ? filteredDistricts.first : Provice(0, null, null, null, '', '', null),
      );
      if (selectedDistrict != null) {
        filteredSubdistricts = subdistricts.where((subdistrict) => subdistrict.districtCode == selectedDistrict!.districtCode).toList();
      }
    }

    // หาและตั้งค่าตำบล
    if (address['subDistrict'] != null && selectedDistrict != null) {
      selectedSubdistrict = filteredSubdistricts.firstWhere(
        (subdistrict) => subdistrict.nameTH == address['subDistrict'],
        orElse: () => filteredSubdistricts.isNotEmpty ? filteredSubdistricts.first : Provice(0, null, null, null, '', '', null),
      );
    }

    setState(() {});
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
    } catch (e) {
      print('Error loading province data: $e');
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
      _postalCodeController.clear();
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
      _postalCodeController.clear();
    });
  }

  // Update postal code when subdistrict is selected
  void _onSubdistrictChanged(Provice? subdistrict) {
    setState(() {
      selectedSubdistrict = subdistrict;
      if (subdistrict != null && subdistrict.postalCode != null) {
        _postalCodeController.text = subdistrict.postalCode.toString();
      } else {
        _postalCodeController.clear();
      }
    });
  }

  @override
  void dispose() {
    nameAddressController.dispose();
    nameController.dispose();
    phoneController.dispose();
    detailController.dispose();
    _postalCodeController.dispose();
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
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
            Text(widget.isEdit ? 'แก้ไข' : 'เพิ่มที่อยู่', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CustomTextFormField(label: 'ชื่อที่อยู่จัดส่ง', hintText: '', controller: nameAddressController),
              const SizedBox(height: 16),
              CustomTextFormField(label: 'ชื่อผู้รับ', hintText: '', controller: nameController),
              const SizedBox(height: 16),
              CustomTextFormField(label: 'เบอร์ติดต่อ', hintText: '', controller: phoneController),
              const SizedBox(height: 16),
              CustomTextFormField(label: 'รายละเอียดที่อยู่จัดส่ง', hintText: '', controller: detailController, maxLines: 3),
              const SizedBox(height: 16),
              // 🔹 จังหวัด + อำเภอ
              Row(
                children: [
                  Expanded(
                    child: CustomDropdownFormField<Provice>(
                      label: 'จังหวัด',
                      hintText: 'กรุณาเลือกจังหวัด',
                      value: selectedProvince,
                      items: provinces.map((province) => DropdownMenuItem<Provice>(value: province, child: Text(province.nameTH ?? ''))).toList(),
                      onChanged: _onProvinceChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomDropdownFormField<Provice>(
                      label: 'อำเภอ',
                      hintText: 'กรุณาเลือกอำเภอ',
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomDropdownFormField<Provice>(
                      label: 'ตำบล',
                      hintText: 'กรุณาเลือกตำบล',
                      value: selectedSubdistrict,
                      items:
                          filteredSubdistricts
                              .map((subdistrict) => DropdownMenuItem<Provice>(value: subdistrict, child: Text(subdistrict.nameTH ?? '')))
                              .toList(),
                      onChanged: _onSubdistrictChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextFormField(
                      label: 'รหัสไปรษณีย์',
                      hintText: '-',
                      controller: _postalCodeController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
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
}
