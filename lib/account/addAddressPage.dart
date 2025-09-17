import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/account_controller.dart';
import 'package:gcargo/models/provice.dart';
import 'package:gcargo/widgets/CustomTextFormField.dart';
import 'package:gcargo/widgets/CustomDropdownFormField.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

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
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  // Location และ AccountController
  late final AccountController accountController;
  bool isLoading = false;

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
    accountController = Get.put(AccountController());
    _loadProvinceData();
  }

  Future<void> getLatLongFromAddress({required String address}) async {
    // String address = 'จังหัวด อำเภอ ตำบล 12345'; // ใส่ชื่อ/อำเภอ/ตำบล/รหัสไปรษณีย์
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        latitudeController.text = locations.first.latitude.toString();
        longitudeController.text = locations.first.longitude.toString();
        print('Latitude: ${locations.first.latitude}');
        print('Longitude: ${locations.first.longitude}');
        setState(() {});
      } else {
        print('ไม่พบตำแหน่ง');
      }
    } catch (e) {
      print('Error: $e');
    }
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
        getLatLongFromAddress(
          address:
              '${selectedProvince?.nameTH ?? ''} ${selectedDistrict?.nameTH ?? ''}  ${selectedSubdistrict?.nameTH ?? ''} ${selectedSubdistrict?.postalCode.toString() ?? ''}',
        );
      } else {
        postalCodeController.clear();
      }
    });
  }

  // ฟังก์ชั่นสำหรับบันทึกข้อมูล
  Future<void> _saveAddress() async {
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

        await accountController.addAddress(addressData);

        if (mounted) {
          // แสดงข้อความสำเร็จ
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เพิ่มที่อยู่สำเร็จ'), backgroundColor: Colors.green));

          // กลับไปหน้า AddressListPage และส่งสัญญาณให้โหลดข้อมูลใหม่
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
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
    if (receiverController.text.isEmpty ||
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
                          child: CustomDropdownFormField<Provice>(
                            label: 'จังหวัด',
                            hintText: 'กรุณาเลือกจังหวัด',
                            value: selectedProvince,
                            items:
                                provinces.map((province) => DropdownMenuItem<Provice>(value: province, child: Text(province.nameTH ?? ''))).toList(),
                            onChanged: _onProvinceChanged,
                          ),
                        ),
                        SizedBox(width: 12),
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
                    SizedBox(height: 16),
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
                        SizedBox(width: 12),
                        Expanded(
                          child: CustomTextFormField(label: 'รหัสไปรษณีย์', hintText: 'กรุณากรอกรหัสไปรษณีย์', controller: postalCodeController),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: CustomTextFormField(label: 'Latitude', hintText: 'ละติจูด', controller: latitudeController)),
                        SizedBox(width: 12),
                        Expanded(child: CustomTextFormField(label: 'Longitude', hintText: 'ลองติจูด', controller: longitudeController)),
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
                onPressed: isLoading ? null : _saveAddress,
                child: Text('ยืนยัน', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
