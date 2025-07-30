import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/models/provice.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:gcargo/services/registerService.dart';
import 'package:gcargo/services/uploadService.dart';
import 'package:gcargo/widgets/CustomDropdownFormField.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/models/user.dart';
import 'package:gcargo/widgets/CustomTextFormField.dart';
import 'package:gcargo/widgets/DatePickerTextFormField.dart';

class ProfilePage extends StatefulWidget {
  final User? user;

  const ProfilePage({super.key, this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lineIdController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController referCodeController = TextEditingController();
  final TextEditingController agentCodeController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  String gender = 'male';
  bool isLoading = false;
  File? selectedFile;
  String? currentImageUrl;

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
    _initializeData();
  }

  Future<void> _initializeData() async {
    // โหลดข้อมูลจังหวัดก่อน
    await _loadProvinceData();
    // จากนั้นค่อย populate ข้อมูลผู้ใช้
    _populateUserData();
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

  void _populateUserData() {
    if (widget.user != null) {
      final user = widget.user!;

      // Populate form fields with user data
      emailController.text = user.email ?? '';
      nameController.text = user.fname ?? '';
      lineIdController.text = user.line_id ?? '';
      phoneController.text = user.phone ?? '';
      referCodeController.text = user.referrer ?? '';
      _addressController.text = user.address ?? '';
      agentCodeController.text = user.detail?.frequent_importer ?? '';

      // Format birth date if available
      if (user.birth_date != null && user.birth_date!.isNotEmpty) {
        try {
          final date = DateTime.parse(user.birth_date!);
          birthDateController.text = DateFormat('dd/MM/yyyy').format(date);
        } catch (e) {
          birthDateController.text = user.birth_date ?? '';
        }
      }

      // Set gender
      gender = user.gender ?? 'male';

      // Set current image URL
      currentImageUrl = user.image;

      // Populate address fields
      _populateAddressData(user);
    }
  }

  // Pick image from gallery or camera
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);

      if (image != null) {
        setState(() {
          selectedFile = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เกิดข้อผิดพลาดในการเลือกรูปภาพ'), backgroundColor: Colors.red));
    }
  }

  void _populateAddressData(User user) {
    // เช็คข้อมูลที่อยู่จาก ship_address ก่อน
    if (user.ship_address != null && user.ship_address!.isNotEmpty) {
      // ใช้ที่อยู่แรกจาก ship_address
      final firstAddress = user.ship_address!.last;

      // Set address และ postal code จาก ship_address
      _addressController.text = firstAddress.address ?? '';
      _postalCodeController.text = firstAddress.postal_code ?? '';

      // Find and set province จาก ship_address
      if (firstAddress.province != null && firstAddress.province!.isNotEmpty) {
        try {
          selectedProvince = provinces.firstWhere((province) => province.nameTH == firstAddress.province);
        } catch (e) {
          selectedProvince = provinces.isNotEmpty ? provinces.first : null;
        }

        // Filter districts for selected province
        if (selectedProvince != null) {
          filteredDistricts = districts.where((district) => district.provinceCode == selectedProvince!.provinceCode).toList();

          // Find and set district จาก ship_address
          if (firstAddress.district != null && firstAddress.district!.isNotEmpty) {
            try {
              selectedDistrict = filteredDistricts.firstWhere((district) => district.nameTH == firstAddress.district);
            } catch (e) {
              selectedDistrict = filteredDistricts.isNotEmpty ? filteredDistricts.first : null;
            }

            // Filter subdistricts for selected district
            if (selectedDistrict != null) {
              filteredSubdistricts = subdistricts.where((subdistrict) => subdistrict.districtCode == selectedDistrict!.districtCode).toList();

              // Find and set subdistrict จาก ship_address
              if (firstAddress.sub_district != null && firstAddress.sub_district!.isNotEmpty) {
                try {
                  selectedSubdistrict = filteredSubdistricts.firstWhere((subdistrict) => subdistrict.nameTH == firstAddress.sub_district);
                } catch (e) {
                  selectedSubdistrict = filteredSubdistricts.isNotEmpty ? filteredSubdistricts.first : null;
                }
              }
            }
          }
        }
      }
    } else {
      // ถ้าไม่มี ship_address ให้ใช้ข้อมูลจาก user profile
      _addressController.text = user.address ?? '';
      _postalCodeController.text = user.postal_code ?? '';

      // Find and set province จาก user profile
      if (user.province != null && user.province!.isNotEmpty) {
        try {
          selectedProvince = provinces.firstWhere((province) => province.nameTH == user.province);
        } catch (e) {
          selectedProvince = provinces.isNotEmpty ? provinces.first : null;
        }

        // Filter districts for selected province
        if (selectedProvince != null) {
          filteredDistricts = districts.where((district) => district.provinceCode == selectedProvince!.provinceCode).toList();

          // Find and set district จาก user profile
          if (user.district != null && user.district!.isNotEmpty) {
            try {
              selectedDistrict = filteredDistricts.firstWhere((district) => district.nameTH == user.district);
            } catch (e) {
              selectedDistrict = filteredDistricts.isNotEmpty ? filteredDistricts.first : null;
            }

            // Filter subdistricts for selected district
            if (selectedDistrict != null) {
              filteredSubdistricts = subdistricts.where((subdistrict) => subdistrict.districtCode == selectedDistrict!.districtCode).toList();

              // Find and set subdistrict จาก user profile
              if (user.sub_district != null && user.sub_district!.isNotEmpty) {
                try {
                  selectedSubdistrict = filteredSubdistricts.firstWhere((subdistrict) => subdistrict.nameTH == user.sub_district);
                } catch (e) {
                  selectedSubdistrict = filteredSubdistricts.isNotEmpty ? filteredSubdistricts.first : null;
                }
              }
            }
          }
        }
      }
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

  // Format birth date for API
  String _formatBirthDate(String input) {
    if (input.isEmpty) return '';
    try {
      final parsed = DateFormat('dd/MM/yyyy').parseStrict(input);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    lineIdController.dispose();
    phoneController.dispose();
    referCodeController.dispose();
    agentCodeController.dispose();
    birthDateController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF002D65);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('โปรไฟล์', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 รูปโปรไฟล์
              Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        ClipOval(
                          child:
                              selectedFile != null
                                  ? Image.file(selectedFile!, width: 100, height: 100, fit: BoxFit.cover)
                                  : currentImageUrl != null && currentImageUrl!.isNotEmpty
                                  ? Image.network(
                                    currentImageUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset('assets/images/Avatar.png', width: 100, height: 100, fit: BoxFit.cover),
                                  )
                                  : Image.asset('assets/images/Avatar.png', width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _pickImage, child: const Text('แก้ไขรูปภาพ', style: TextStyle(color: Colors.blue))),
                ],
              ),
              const SizedBox(height: 16),

              // 🔹 ช่องกรอกข้อมูล
              CustomTextFormField(label: 'อีเมล', hintText: 'Gcargo@gmail.com', controller: emailController),
              const SizedBox(height: 14),
              CustomTextFormField(label: 'รหัสผ่าน', hintText: 'กรอกรหัสผ่าน', controller: passwordController, isPassword: true),
              const SizedBox(height: 14),
              CustomTextFormField(label: 'ยืนยันรหัสผ่าน', hintText: 'ยืนยันรหัสผ่าน', controller: confirmPasswordController, isPassword: true),
              const SizedBox(height: 14),
              CustomTextFormField(label: 'ชื่อ-นามสกุล', hintText: 'ชื่อผู้ใช้ ชื่อผู้ใช้', controller: nameController),
              const SizedBox(height: 14),
              CustomTextFormField(label: 'ไอดีไลน์', hintText: '090-999-9599', controller: lineIdController),
              const SizedBox(height: 14),

              // 🔹 เพศ
              Row(
                children: [
                  const Text('เพศ', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      Radio<String>(value: 'female', groupValue: gender, onChanged: (value) => setState(() => gender = value!)),
                      const Text('หญิง'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(value: 'male', groupValue: gender, onChanged: (value) => setState(() => gender = value!)),
                      const Text('ชาย'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 🔹 วันเกิด
              DatePickerTextFormField(label: 'วันเดือนปีเกิด', controller: birthDateController, hintText: ''),
              const SizedBox(height: 14),

              CustomTextFormField(label: 'เบอร์โทรศัพท์มือถือ', hintText: '090-999-9599', controller: phoneController),
              const SizedBox(height: 14),
              CustomTextFormField(label: 'รหัสแนะนำ', hintText: '-', controller: referCodeController),
              const SizedBox(height: 14),
              CustomTextFormField(label: 'รหัสเซลล์', hintText: '-', controller: agentCodeController),
              const SizedBox(height: 20),
              CustomTextFormField(label: 'รายละเอียดที่อยู่ในเสร็จรับเงิน', hintText: '-', controller: _addressController, maxLines: 3),
              const SizedBox(height: 20),

              CustomTextFormField(label: 'เลขที่ภาษี', hintText: '-', controller: _taxIdController),
              const SizedBox(height: 20),
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

              // 🔹 ปุ่มยืนยัน
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (!mounted) return;

                    setState(() {
                      isLoading = true;
                    });

                    try {
                      String? imageUrl;

                      // ถ้ามีรูปใหม่ ให้อัปโหลดก่อน
                      if (selectedFile != null) {
                        imageUrl = await UoloadService.addImage(file: selectedFile, path: 'uploads/asset/');
                      }

                      // เรียก API แก้ไขโปรไฟล์
                      final registerEditResult = await RegisterService.registerEdit(
                        member_type: 'บุคคลทั่วไป',
                        email: emailController.text,
                        password: passwordController.text.isNotEmpty ? passwordController.text : '',
                        fname: nameController.text,
                        phone: phoneController.text,
                        gender: gender,
                        birth_date: _formatBirthDate(birthDateController.text),
                        importer_code: '',
                        referrer: referCodeController.text.isNotEmpty ? referCodeController.text : '',
                        frequent_importer: agentCodeController.text.isNotEmpty ? agentCodeController.text : '',
                        address: _addressController.text.isNotEmpty ? _addressController.text : '',
                        province: selectedProvince?.nameTH,
                        district: selectedDistrict?.nameTH,
                        sub_district: selectedSubdistrict?.nameTH,
                        postal_code: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : '',
                        image: imageUrl ?? currentImageUrl,
                        comp_name: '',
                        comp_tax: '',
                        comp_phone: '',
                        cargo_name: '',
                        cargo_website: '',
                        cargo_image: '',
                        order_quantity_in_thai: '',
                        transport_thai_master_id: 1,
                        ever_imported_from_china: 'เคย',
                        order_quantity: '',
                        need_transport_type: '',
                        additional_requests: '',
                        line_id: lineIdController.text.isNotEmpty ? lineIdController.text : '',
                      );

                      if (!mounted) return;

                      // แสดงข้อความสำเร็จ
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('แก้ไขโปรไฟล์สำเร็จ!'), backgroundColor: Colors.green));

                      // เรียก getUserById ใหม่ใน HomeController
                      final homeController = Get.find<HomeController>();
                      await homeController.getUserDataAndShippingAddresses();

                      // กลับไปหน้าก่อนหน้า
                      Navigator.pop(context, true);
                    } catch (e) {
                      if (!mounted) return;
                      print(e);
                      setState(() {
                        isLoading = false;
                      });

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}'), backgroundColor: Colors.red));
                    } finally {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                  child:
                      isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('ยืนยัน', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
