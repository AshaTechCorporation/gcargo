import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/login/otpVerificationPage.dart';
import 'package:gcargo/login/widgets/TermsDialog.dart';
import 'package:gcargo/models/provice.dart';
import 'package:gcargo/services/registerService.dart';
import 'package:gcargo/widgets/CustomDropdownFormField.dart';
import 'package:gcargo/widgets/CustomTextFormField.dart';
import 'package:gcargo/widgets/DatePickerTextFormField.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _lineController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _referralCodeController = TextEditingController();
  final _saleCodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _postalCodeController = TextEditingController();

  bool isMale = true;
  bool agree = false;

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
    _loadProvinceData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _lineController.dispose();
    _birthdateController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _referralCodeController.dispose();
    _saleCodeController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _postalCodeController.dispose();
    super.dispose();
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

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime(2000), firstDate: DateTime(1900), lastDate: DateTime.now());
    if (picked != null) {
      setState(() {
        _birthdateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  String _formatBirthDate(String input) {
    try {
      final parsed = DateFormat('dd/MM/yyyy').parseStrict(input);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (e) {
      return ''; // หรือ null ถ้า backend ยอมรับ
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 หัวข้อ
                const Text('ลงทะเบียน', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kButtonColor)),
                const SizedBox(height: 4),
                const Text('สมัครใช้งานง่าย ส่งของข้ามประเทศได้ปลอดภัยทุกขั้นตอน', style: TextStyle(fontSize: 13, color: kHintTextColor)),
                const SizedBox(height: 24),

                CustomTextFormField(
                  label: 'อีเมล',
                  hintText: 'กรุณากรอกอีเมล',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                CustomTextFormField(label: 'รหัสผ่าน', hintText: '••••••••', controller: _passwordController, isPassword: true),
                const SizedBox(height: 20),

                CustomTextFormField(label: 'ยืนยันรหัสผ่าน', hintText: '••••••••', controller: _confirmPasswordController, isPassword: true),
                const SizedBox(height: 20),

                CustomTextFormField(label: 'ชื่อ-นามสกุล', hintText: 'กรุณากรอกชื่อ-นามสกุล', controller: _nameController),
                const SizedBox(height: 20),

                CustomTextFormField(label: 'ไอดีไลน์', hintText: 'กรุณากรอกไอดีไลน์', controller: _lineController),
                const SizedBox(height: 20),

                const Text('เพศ', style: TextStyle(fontSize: 16, color: kButtonColor)),
                const SizedBox(height: 8),
                Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: kButtonColor,
                    radioTheme: RadioThemeData(fillColor: MaterialStateProperty.resolveWith<Color>((states) => kButtonColor)),
                  ),
                  child: Row(
                    children: [
                      Radio<bool>(value: false, groupValue: isMale, onChanged: (value) => setState(() => isMale = false)),
                      const Text('หญิง', style: TextStyle(color: kButtonColor)),
                      const SizedBox(width: 16),
                      Radio<bool>(value: true, groupValue: isMale, onChanged: (value) => setState(() => isMale = true)),
                      const Text('ชาย', style: TextStyle(color: kButtonColor)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 วันเดือนปีเกิด
                DatePickerTextFormField(label: 'วันเดือนปีเกิด', hintText: 'กรุณากรอกวันเดือนปีเกิด', controller: _birthdateController),

                const SizedBox(height: 12),

                CustomTextFormField(
                  label: 'เบอร์โทรศัพท์มือถือ',
                  hintText: 'กรุณากรอกเบอร์โทรศัพท์มือถือ',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                CustomTextFormField(label: 'รหัสนำเข้า', hintText: 'กรุณากรอกรหัสผ่านเข้า', controller: _pinController),
                const SizedBox(height: 20),

                CustomTextFormField(label: 'รหัสแนะนำ', hintText: 'กรุณากรอกรหัสแนะนำ', controller: _referralCodeController, isRequired: false),
                const SizedBox(height: 20),

                CustomTextFormField(label: 'รหัสเซลล์', hintText: 'กรุณากรอกรหัสเซลล์', controller: _saleCodeController, isRequired: false),
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

                // 🔹 Checkbox
                CheckboxTheme(
                  data: CheckboxThemeData(
                    shape: const CircleBorder(),
                    side: const BorderSide(color: kButtonColor),
                    fillColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return kButtonColor;
                      }
                      return Colors.transparent;
                    }),
                    checkColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: agree,
                        onChanged: (value) => setState(() => agree = value ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // ✅ ทำให้ขนาดแน่น
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4), // ✅ ลดช่องว่าง
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('ยินยอมในข้อตกลงเงื่อนไขในการบริการของทางเว็บไซต์', style: TextStyle(fontSize: 13, color: kHintTextColor)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 🔹 ปุ่มยืนยัน
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final accepted = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const TermsDialog(),
                        );

                        if (accepted == true) {
                          // TODO: ดำเนินการสมัครต่อ
                          try {
                            final currentContext = context;
                            final _register = await RegisterService.register(
                              member_type: 'บุคคลทั่วไป',
                              email: _emailController.text,
                              password: _passwordController.text,
                              fname: _nameController.text,
                              phone: _phoneController.text,
                              gender: isMale ? 'male' : 'female',
                              birth_date: _formatBirthDate(_birthdateController.text),
                              importer_code: _pinController.text,
                              referrer: _referralCodeController.text,
                              frequent_importer: _saleCodeController.text,
                              comp_name: '',
                              comp_tax: '',
                              comp_phone: '',
                              cargo_name: '',
                              cargo_website: '',
                              cargo_image: '',
                              order_quantity_in_thai: '',
                              transport_thai_master_id: 1,
                              ever_imported_from_china: 'เคย',
                              province: selectedProvince?.nameTH ?? '',
                              district: selectedDistrict?.nameTH ?? '',
                              sub_district: selectedSubdistrict?.nameTH ?? '',
                              postal_code: _postalCodeController.text,
                            );
                            if (_register != null) {
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => OtpVerificationPage()));
                              ScaffoldMessenger.of(
                                currentContext,
                              ).showSnackBar(const SnackBar(content: Text('สมัคสมาชิกสำเร็จ!'), backgroundColor: Colors.green));
                              Navigator.pop(context);
                            } else {
                              // TODO: Handle error
                            }
                          } on Exception catch (e) {
                            if (!mounted) return;
                            print(e);
                            //LoadingDialog.close(context);
                            // showDialog(
                            //   context: context,
                            //   builder:
                            //       (context) => AlertDialogYes(
                            //         title: 'Setting.warning'.tr(),
                            //         description: '$e',
                            //         pressYes: () {
                            //           Navigator.pop(context);
                            //         },
                            //       ),
                            // );
                          } catch (e) {
                            if (!mounted) return;
                            //LoadingDialog.close(context);
                            // showDialog(
                            //   context: context,
                            //   builder:
                            //       (context) => AlertDialogYes(
                            //         title: 'Setting.warning'.tr(),
                            //         description: '$e',
                            //         pressYes: () {
                            //           Navigator.pop(context);
                            //         },
                            //       ),
                            // );
                          }

                          //Navigator.push(context, MaterialPageRoute(builder: (context) => OtpVerificationPage()));
                        } else {
                          print('ผู้ใช้ปฏิเสธ');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('ยืนยัน', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 ปุ่มย้อนกลับ
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kButtonColor,
                      side: const BorderSide(color: kButtonColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('ย้อนกลับ', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
