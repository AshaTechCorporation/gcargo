import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
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
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController lineIdController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController referCodeController = TextEditingController();
  final TextEditingController agentCodeController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  String import_code = '';
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'profile': 'โปรไฟล์',
        'profile_picture': 'รูปโปรไฟล์',
        'change_picture': 'เปลี่ยนรูป',
        'email': 'อีเมล',
        'password': 'รหัสผ่าน',
        'confirm_password': 'ยืนยันรหัสผ่าน',
        'first_name': 'ชื่อ',
        'last_name': 'นามสกุล',
        'line_id': 'ไลน์ไอดี',
        'phone': 'เบอร์โทรศัพท์',
        'refer_code': 'รหัสแนะนำ',
        'agent_code': 'รหัสเอเจนต์',
        'birth_date': 'วันเกิด',
        'gender': 'เพศ',
        'male': 'ชาย',
        'female': 'หญิง',
        'address': 'ที่อยู่',
        'province': 'จังหวัด',
        'district': 'อำเภอ',
        'subdistrict': 'ตำบล',
        'postal_code': 'รหัสไปรษณีย์',
        'tax_id': 'เลขประจำตัวผู้เสียภาษี',
        'save': 'บันทึก',
        'saving': 'กำลังบันทึก...',
        'select_province': 'เลือกจังหวัด',
        'select_district': 'เลือกอำเภอ',
        'select_subdistrict': 'เลือกตำบล',
        'select_date': 'เลือกวันที่',
        'success': 'สำเร็จ',
        'error': 'เกิดข้อผิดพลาด',
        'profile_updated': 'อัปเดตโปรไฟล์สำเร็จ',
        'please_fill_required': 'กรุณากรอกข้อมูลที่จำเป็น',
        'password_not_match': 'รหัสผ่านไม่ตรงกัน',
        'invalid_email': 'รูปแบบอีเมลไม่ถูกต้อง',
        'invalid_phone': 'รูปแบบเบอร์โทรศัพท์ไม่ถูกต้อง',
        'select_image_source': 'เลือกแหล่งที่มาของรูปภาพ',
        'camera': 'กล้อง',
        'gallery': 'แกลเลอรี่',
        'cancel': 'ยกเลิก',
      },
      'en': {
        'profile': 'Profile',
        'profile_picture': 'Profile Picture',
        'change_picture': 'Change Picture',
        'email': 'Email',
        'password': 'Password',
        'confirm_password': 'Confirm Password',
        'first_name': 'First Name',
        'last_name': 'Last Name',
        'line_id': 'Line ID',
        'phone': 'Phone Number',
        'refer_code': 'Refer Code',
        'agent_code': 'Agent Code',
        'birth_date': 'Birth Date',
        'gender': 'Gender',
        'male': 'Male',
        'female': 'Female',
        'address': 'Address',
        'province': 'Province',
        'district': 'District',
        'subdistrict': 'Subdistrict',
        'postal_code': 'Postal Code',
        'tax_id': 'Tax ID',
        'save': 'Save',
        'saving': 'Saving...',
        'select_province': 'Select Province',
        'select_district': 'Select District',
        'select_subdistrict': 'Select Subdistrict',
        'select_date': 'Select Date',
        'success': 'Success',
        'error': 'Error',
        'profile_updated': 'Profile updated successfully',
        'please_fill_required': 'Please fill required fields',
        'password_not_match': 'Passwords do not match',
        'invalid_email': 'Invalid email format',
        'invalid_phone': 'Invalid phone number format',
        'select_image_source': 'Select Image Source',
        'camera': 'Camera',
        'gallery': 'Gallery',
        'cancel': 'Cancel',
      },
      'zh': {
        'profile': '个人资料',
        'profile_picture': '头像',
        'change_picture': '更换头像',
        'email': '邮箱',
        'password': '密码',
        'confirm_password': '确认密码',
        'first_name': '名字',
        'last_name': '姓氏',
        'line_id': 'Line ID',
        'phone': '电话号码',
        'refer_code': '推荐码',
        'agent_code': '代理码',
        'birth_date': '出生日期',
        'gender': '性别',
        'male': '男',
        'female': '女',
        'address': '地址',
        'province': '省份',
        'district': '区',
        'subdistrict': '街道',
        'postal_code': '邮政编码',
        'tax_id': '税号',
        'save': '保存',
        'saving': '保存中...',
        'select_province': '选择省份',
        'select_district': '选择区',
        'select_subdistrict': '选择街道',
        'select_date': '选择日期',
        'success': '成功',
        'error': '发生错误',
        'profile_updated': '个人资料更新成功',
        'please_fill_required': '请填写必填字段',
        'password_not_match': '密码不匹配',
        'invalid_email': '邮箱格式无效',
        'invalid_phone': '电话号码格式无效',
        'select_image_source': '选择图片来源',
        'camera': '相机',
        'gallery': '相册',
        'cancel': '取消',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

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
    languageController = Get.find<LanguageController>();
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
      lastnameController.text = user.lname ?? '';
      lineIdController.text = user.line_id ?? '';
      phoneController.text = user.phone ?? '';
      referCodeController.text = user.referrer ?? '';
      _addressController.text = user.address ?? '';
      agentCodeController.text = user.detail?.frequent_importer ?? '123654';
      passwordController.text = user.password ?? '';
      setState(() {
        import_code = user.importer_code ?? '';
      });

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

  // Show image source selection dialog
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(getTranslation('camera')),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(getTranslation('gallery')),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImageFromSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: Text(getTranslation('cancel')),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Pick image from selected source
  Future<void> _getImageFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);

      if (image != null) {
        setState(() {
          selectedFile = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getTranslation('error')), backgroundColor: Colors.red));
      }
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
    lastnameController.dispose();
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

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(getTranslation('profile'), style: TextStyle(color: Colors.black)),
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
                                              Image.asset('assets/images/user.png', width: 100, height: 100, fit: BoxFit.cover),
                                    )
                                    : Image.asset('assets/images/user.png', width: 100, height: 100, fit: BoxFit.cover),
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
                    TextButton(onPressed: _pickImage, child: Text(getTranslation('change_picture'), style: TextStyle(color: Colors.blue))),
                  ],
                ),
                const SizedBox(height: 16),

                // 🔹 ช่องกรอกข้อมูล
                CustomTextFormField(label: getTranslation('email'), hintText: 'Gcargo@gmail.com', controller: emailController),
                const SizedBox(height: 14),
                // CustomTextFormField(label: getTranslation('password'), hintText: 'กรอกรหัสผ่าน', controller: passwordController, isPassword: true),
                // const SizedBox(height: 14),
                // CustomTextFormField(label: getTranslation('confirm_password'), hintText: 'ยืนยันรหัสผ่าน', controller: confirmPasswordController, isPassword: true),
                const SizedBox(height: 14),
                CustomTextFormField(label: getTranslation('first_name'), hintText: getTranslation('first_name'), controller: nameController),
                const SizedBox(height: 14),
                CustomTextFormField(label: getTranslation('last_name'), hintText: getTranslation('last_name'), controller: lastnameController),
                const SizedBox(height: 14),
                CustomTextFormField(label: getTranslation('line_id'), hintText: '-', controller: lineIdController),
                const SizedBox(height: 14),

                // 🔹 เพศ
                Row(
                  children: [
                    Text(getTranslation('gender'), style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        Radio<String>(value: 'female', groupValue: gender, onChanged: (value) => setState(() => gender = value!)),
                        Text(getTranslation('female')),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(value: 'male', groupValue: gender, onChanged: (value) => setState(() => gender = value!)),
                        Text(getTranslation('male')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 🔹 วันเกิด
                DatePickerTextFormField(
                  label: getTranslation('birth_date'),
                  controller: birthDateController,
                  hintText: getTranslation('select_date'),
                ),
                const SizedBox(height: 14),

                CustomTextFormField(label: getTranslation('phone'), hintText: '090-***-****', controller: phoneController),
                const SizedBox(height: 14),
                CustomTextFormField(label: getTranslation('refer_code'), hintText: '-', controller: referCodeController),
                const SizedBox(height: 14),
                CustomTextFormField(label: getTranslation('agent_code'), hintText: '-', controller: agentCodeController),
                const SizedBox(height: 20),
                CustomTextFormField(label: getTranslation('address'), hintText: '-', controller: _addressController, maxLines: 3),
                const SizedBox(height: 20),

                CustomTextFormField(label: getTranslation('tax_id'), hintText: '-', controller: _taxIdController),
                const SizedBox(height: 20),
                // 🔹 จังหวัด + อำเภอ
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdownFormField<Provice>(
                        label: getTranslation('province'),
                        hintText: getTranslation('select_province'),
                        value: selectedProvince,
                        items: provinces.map((province) => DropdownMenuItem<Provice>(value: province, child: Text(province.nameTH ?? ''))).toList(),
                        onChanged: _onProvinceChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                const SizedBox(height: 20),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextFormField(
                        label: getTranslation('postal_code'),
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
                          fname: nameController.text,
                          phone: phoneController.text,
                          gender: gender,
                          birth_date: _formatBirthDate(birthDateController.text),
                          importer_code: import_code,
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
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(getTranslation('profile_updated')), backgroundColor: Colors.green));

                        // เรียก getUserById ใหม่ใน HomeController
                        final homeController = Get.find<HomeController>();
                        print('🔄 กำลังอัปเดตข้อมูลผู้ใช้ใน HomeController...');
                        await homeController.getUserDataAndShippingAddresses();
                        print('✅ อัปเดตข้อมูลผู้ใช้สำเร็จ: ${homeController.currentUser.value?.fname}');

                        // กลับไปหน้าก่อนหน้า
                        if (mounted) {
                          Navigator.pop(context, true);
                        }
                      } catch (e) {
                        if (!mounted) return;
                        print(e);
                        setState(() {
                          isLoading = false;
                        });

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('${getTranslation('error')}: ${e.toString()}'), backgroundColor: Colors.red));
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
                            : Text(getTranslation('save'), style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
