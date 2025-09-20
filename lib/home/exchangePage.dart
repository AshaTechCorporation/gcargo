import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:gcargo/services/uploadService.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  int selectedMethod = 0;
  final TextEditingController _bahtController = TextEditingController();
  final HomeController homeController = Get.put(HomeController());
  late LanguageController languageController;

  // File picker variables
  File? selectedFile;
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers for API data
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // API data variables
  String? selectedType = 'alipay'; // transaction type
  String? imageQR; // QR code image
  String? image; // uploaded image
  String? extensionfileQR; // file extension

  List<String> paymentMethods = [];
  final List<String> icons = ['assets/icons/bank_icon.png', 'assets/icons/alipay_icon.png', 'assets/icons/wechat_icon.png'];

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'exchange': 'แลกเงิน',
        'exchange_rate': 'อัตราแลกเปลี่ยน',
        'service_fee': 'ค่าบริการ',
        'total_amount': 'จำนวนเงินรวม',
        'payment_method': 'วิธีการชำระเงิน',
        'bank_account': 'บัญชีธนาคาร',
        'alipay': 'Alipay',
        'wechat_pay': 'Wechat pay',
        'enter_amount': 'กรอกจำนวนเงิน',
        'baht': 'บาท',
        'yuan': 'หยวน',
        'phone_number': 'เบอร์โทรศัพท์',
        'account_number': 'เลขบัญชี',
        'account_name': 'ชื่อบัญชี',
        'upload_slip': 'อัปโหลดสลิป',
        'select_file': 'เลือกไฟล์',
        'camera': 'กล้อง',
        'gallery': 'แกลเลอรี่',
        'cancel': 'ยกเลิก',
        'confirm': 'ยืนยัน',
        'success': 'สำเร็จ',
        'error': 'ข้อผิดพลาด',
        'send_success': 'ส่งข้อมูลสำเร็จ',
        'send_error': 'ไม่สามารถส่งข้อมูลได้',
        'please_fill_all': 'กรุณากรอกข้อมูลให้ครบถ้วน',
        'please_upload_slip': 'กรุณาอัปโหลดสลิป',
        'uploading': 'กำลังอัปโหลด...',
        'select_image_source': 'เลือกแหล่งที่มาของรูปภาพ',
        'qr_code': 'QR Code',
        'scan_qr': 'สแกน QR Code',
        'select_payment_method': 'เลือกช่องทางการชำระเงิน',
        'yuan_amount_to_transfer': 'ยอดเงินหยวนที่ต้องการโอน',
        'click_image_to_view': 'กดที่รูปเพื่อดูไฟล์',
        'upload_qr_image': 'อัปโหลดรูปภาพ QR Code',
        'supported_file_formats': 'รองรับไฟล์รูปภาพ JPG, PNG, PDF เท่านั้น',
        'change_file': 'เปลี่ยนไฟล์',
        'transaction_hours': 'ช่วงเวลาที่สามารถทำธุรกรรม',
        'business_hours_message': 'กรุณาดำเนินการวันจันทร์ - เสาร์ ในระหว่าง 8.00 - 17.00 น.',
      },
      'en': {
        'exchange': 'Exchange',
        'exchange_rate': 'Exchange Rate',
        'service_fee': 'Service Fee',
        'total_amount': 'Total Amount',
        'payment_method': 'Payment Method',
        'bank_account': 'Bank Account',
        'alipay': 'Alipay',
        'wechat_pay': 'Wechat Pay',
        'enter_amount': 'Enter Amount',
        'baht': 'Baht',
        'yuan': 'Yuan',
        'phone_number': 'Phone Number',
        'account_number': 'Account Number',
        'account_name': 'Account Name',
        'upload_slip': 'Upload Slip',
        'select_file': 'Select File',
        'camera': 'Camera',
        'gallery': 'Gallery',
        'cancel': 'Cancel',
        'confirm': 'Confirm',
        'success': 'Success',
        'error': 'Error',
        'send_success': 'Data sent successfully',
        'send_error': 'Unable to send data',
        'please_fill_all': 'Please fill in all information',
        'please_upload_slip': 'Please upload slip',
        'uploading': 'Uploading...',
        'select_image_source': 'Select Image Source',
        'qr_code': 'QR Code',
        'scan_qr': 'Scan QR Code',
        'select_payment_method': 'Select Payment Method',
        'yuan_amount_to_transfer': 'Yuan Amount to Transfer',
        'click_image_to_view': 'Click Image to View File',
        'upload_qr_image': 'Upload QR Code Image',
        'supported_file_formats': 'Supports JPG, PNG, PDF files only',
        'change_file': 'Change File',
        'transaction_hours': 'Transaction Hours',
        'business_hours_message': 'Please proceed Monday - Saturday between 8:00 - 17:00.',
      },
      'zh': {
        'exchange': '兑换',
        'exchange_rate': '汇率',
        'service_fee': '服务费',
        'total_amount': '总金额',
        'payment_method': '支付方式',
        'bank_account': '银行账户',
        'alipay': '支付宝',
        'wechat_pay': '微信支付',
        'enter_amount': '输入金额',
        'baht': '泰铢',
        'yuan': '人民币',
        'phone_number': '电话号码',
        'account_number': '账号',
        'account_name': '账户名',
        'upload_slip': '上传凭证',
        'select_file': '选择文件',
        'camera': '相机',
        'gallery': '相册',
        'cancel': '取消',
        'confirm': '确认',
        'success': '成功',
        'error': '错误',
        'send_success': '数据发送成功',
        'send_error': '无法发送数据',
        'please_fill_all': '请填写完整信息',
        'please_upload_slip': '请上传凭证',
        'uploading': '上传中...',
        'select_image_source': '选择图片来源',
        'qr_code': '二维码',
        'scan_qr': '扫描二维码',
        'select_payment_method': '选择支付方式',
        'yuan_amount_to_transfer': '需要转账的人民币金额',
        'click_image_to_view': '点击图片查看文件',
        'upload_qr_image': '上传二维码图片',
        'supported_file_formats': '仅支持JPG、PNG、PDF文件',
        'change_file': '更换文件',
        'transaction_hours': '交易时间',
        'business_hours_message': '请在周一至周六 8:00 - 17:00 期间操作。',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();

    // Initialize payment methods with translations
    paymentMethods = [getTranslation('bank_account'), getTranslation('alipay'), getTranslation('wechat_pay')];

    // Call APIs when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.getExchangeRateFromAPI();
      homeController.getServiceFeeFromAPI(); // เพิ่มการเรียก getServiceFee
    });

    // Listen to text changes for real-time calculation
    _bahtController.addListener(_calculateYuan);
  }

  @override
  void dispose() {
    _bahtController.dispose();
    _phoneController.dispose();
    _accountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Calculate Yuan from Baht input
  void _calculateYuan() {
    setState(() {}); // Trigger rebuild to update Yuan display
  }

  // Get calculated Yuan amount using Alipay rate
  String get calculatedYuan {
    final bahtText = _bahtController.text.trim();

    // ถ้ายังไม่กรอกตัวเลขไปก็ไม่ต้องคำนวณ
    if (bahtText.isEmpty) return '0.00';

    final bahtAmount = double.tryParse(bahtText);
    if (bahtAmount == null || bahtAmount <= 0) return '0.00';

    // Get Alipay rate from exchangeRate
    final alipayRate = homeController.exchangeRate['alipay_topup_rate'];
    final rate = double.tryParse(alipayRate?.toString() ?? '0') ?? 0.0;
    if (rate == 0) return '0.00';

    // Convert Baht to Yuan (Baht / rate = Yuan)
    final yuanAmount = bahtAmount / rate;
    return yuanAmount.toStringAsFixed(2);
  }

  // Validation function
  bool _validateData() {
    // เช็คว่าเลือก Alipay หรือ WeChat
    if (selectedMethod != 1 && selectedMethod != 2) {
      Get.snackbar(getTranslation('error'), getTranslation('please_fill_all'), backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    // เช็คจำนวนเงิน
    final bahtAmount = double.tryParse(_bahtController.text);
    if (bahtAmount == null || bahtAmount <= 0) {
      Get.snackbar(getTranslation('error'), getTranslation('please_fill_all'), backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    // เช็คจำนวนเงินขั้นต่ำ (ถ้ามี)
    if (bahtAmount < 100) {
      Get.snackbar(getTranslation('error'), getTranslation('please_fill_all'), backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    // เช็คเบอร์โทรศัพท์
    if (_phoneController.text.trim().isEmpty) {
      Get.snackbar(getTranslation('error'), getTranslation('please_fill_all'), backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    // เช็ครูปแบบเบอร์โทรศัพท์
    final phonePattern = RegExp(r'^[0-9]{9,10}$');
    if (!phonePattern.hasMatch(_phoneController.text.trim())) {
      Get.snackbar('ข้อผิดพลาด', 'กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง (9-10 หลัก)', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    // เช็คไฟล์ที่อัปโหลด (รูปภาพหรือ PDF)
    if (selectedFile == null) {
      Get.snackbar(getTranslation('error'), getTranslation('please_upload_slip'), backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    // เช็คว่าไฟล์มีอยู่จริงและสามารถอ่านได้
    if (!selectedFile!.existsSync()) {
      Get.snackbar('ข้อผิดพลาด', 'ไฟล์ที่เลือกไม่พบหรือเสียหาย กรุณาเลือกไฟล์ใหม่', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    // เช็คประเภทไฟล์
    final filePath = selectedFile!.path.toLowerCase();
    if (filePath.endsWith('.pdf')) {
      extensionfileQR = 'pdf';
    } else if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg') || filePath.endsWith('.png')) {
      extensionfileQR = 'image';
    } else {
      Get.snackbar('ข้อผิดพลาด', 'รองรับเฉพาะไฟล์ JPG, JPEG, PNG, PDF เท่านั้น', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    // เช็คขนาดไฟล์ (ไม่เกิน 5MB)
    try {
      final fileSizeInBytes = selectedFile!.lengthSync();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      if (fileSizeInMB > 5) {
        Get.snackbar(
          'ข้อผิดพลาด',
          'ขนาดไฟล์ต้องไม่เกิน 5MB (ปัจจุบัน ${fileSizeInMB.toStringAsFixed(1)}MB)',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // เช็คขนาดไฟล์ขั้นต่ำ (ไม่น้อยกว่า 1KB)
      if (fileSizeInBytes < 1024) {
        Get.snackbar('ข้อผิดพลาด', 'ไฟล์มีขนาดเล็กเกินไป กรุณาเลือกไฟล์ที่มีเนื้อหา', backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถอ่านข้อมูลไฟล์ได้ กรุณาเลือกไฟล์ใหม่', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    // เช็คว่ามี transfer fee หรือไม่
    final transferFee = homeController.transferFee.value;
    if (transferFee == null) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถโหลดข้อมูลค่าธรรมเนียมได้', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    return true;
  }

  checkTimeAndShowDialog(BuildContext context) async {
    final now = TimeOfDay.now();

    // ช่วงเวลาที่อนุญาต
    final start = TimeOfDay(hour: 10, minute: 30);
    final end = TimeOfDay(hour: 16, minute: 29);

    bool isInTimeRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
      final currentMinutes = current.hour * 60 + current.minute;
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    }

    if (!isInTimeRange(now, start, end)) {
      // ถ้าอยู่นอกช่วงเวลา ให้โชว์ Dialog
      final out = await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(getTranslation('error')),
              content: Text('เวลาทำการของเจ้าหน้า 10:30 - 16:29 รายการของท่านจะดำเนินการในเวลาทำการ'),
              actions: [TextButton(onPressed: () => Navigator.pop(context, true), child: Text(getTranslation('cancel')))],
            ),
      );
      return out;
    } else {
      return true;
    }
  }

  // Show file picker options for Alipay and WeChat
  void _showFilePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text(getTranslation('gallery')),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text(getTranslation('select_file')),
                onTap: () {
                  Navigator.pop(context);
                  _pickPDF();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text(getTranslation('camera')),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedFile = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถเลือกรูปภาพได้: $e');
    }
  }

  // Take photo with camera
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          selectedFile = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถถ่ายรูปได้: $e');
    }
  }

  // Pick PDF file
  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถเลือกไฟล์ PDF ได้: $e');
    }
  }

  // View selected file (image or PDF)
  void _viewSelectedFile() {
    if (selectedFile == null) return;

    if (selectedFile!.path.toLowerCase().endsWith('.pdf')) {
      // For PDF files, show info dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ไฟล์ PDF'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text(selectedFile!.path.split('/').last, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                SizedBox(height: 8),
                Text('ไฟล์ PDF ถูกเลือกแล้ว', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('ปิด'))],
          );
        },
      );
    } else {
      // For image files, show full screen image
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.black,
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: Image.file(
                      selectedFile!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, color: Colors.white, size: 64),
                            SizedBox(height: 16),
                            Text('ไม่สามารถแสดงรูปภาพได้', style: TextStyle(color: Colors.white)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(icon: Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
                ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                    child: Text(selectedFile!.path.split('/').last, style: TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text(getTranslation('exchange'), style: TextStyle(color: Colors.black)),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exchange rate display (Alipay)
              Obx(() {
                final alipayRate = homeController.exchangeRate['alipay_topup_rate'];
                final rate = alipayRate?.toString();
                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.currency_exchange, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        '${getTranslation('exchange_rate')} G-cargo-A: ${rate != null ? "1 ¥ = $rate ฿" : getTranslation('uploading')}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 16),
              Text(getTranslation('yuan_amount_to_transfer')),
              SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: size.width * 0.6,
                    height: 48,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _bahtController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: getTranslation('enter_amount'), border: InputBorder.none),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: size.width * 0.26,
                    height: 48,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: kBackgroundTextColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(calculatedYuan, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(width: 4),
                        Text('¥', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(getTranslation('select_payment_method')),
              SizedBox(height: 12),
              ...List.generate(paymentMethods.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedMethod = index);
                    // Show file picker for Alipay and WeChat
                    if (index == 1 || index == 2) {
                      // Alipay or WeChat
                      _showFilePickerOptions();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selectedMethod == index ? Colors.blue : Colors.grey.shade300, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        //Image.asset(icons[index], width: 28, height: 28),
                        SizedBox(width: 12),
                        Expanded(child: Text(_getAccountName(paymentMethods[index]), style: TextStyle(fontSize: 16))),
                        Radio(value: index, groupValue: selectedMethod, onChanged: (_) => setState(() => selectedMethod = index)),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 16),
              _buildInputField(getTranslation('phone_number'), controller: _phoneController, keyboardType: TextInputType.phone),
              SizedBox(height: 12),
              _buildInputField(getTranslation('account_number'), controller: _accountController, keyboardType: TextInputType.number),
              SizedBox(height: 12),
              _buildInputField(getTranslation('account_name'), controller: _nameController),

              if (selectedMethod == 1 || selectedMethod == 2) ...[
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            // แสดงไฟล์ที่เลือกหรือไอคอนเริ่มต้น
                            GestureDetector(
                              onTap: selectedFile != null ? _viewSelectedFile : null,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                  color: selectedFile != null ? Colors.white : Colors.grey.shade50,
                                ),
                                child:
                                    selectedFile != null
                                        ? Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child:
                                                  selectedFile!.path.toLowerCase().endsWith('.pdf')
                                                      ? Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                                                          SizedBox(height: 8),
                                                          Text('PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                          Text('กดเพื่อดู', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                                        ],
                                                      )
                                                      : Stack(
                                                        children: [
                                                          Image.file(
                                                            selectedFile!,
                                                            width: 120,
                                                            height: 120,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return Icon(Icons.broken_image, color: Colors.grey, size: 40);
                                                            },
                                                          ),
                                                          Positioned(
                                                            bottom: 4,
                                                            right: 4,
                                                            child: Container(
                                                              padding: EdgeInsets.all(4),
                                                              decoration: BoxDecoration(
                                                                color: Colors.black54,
                                                                borderRadius: BorderRadius.circular(4),
                                                              ),
                                                              child: Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                            ),
                                            // ปุ่มลบ
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedFile = null;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                                                  child: Icon(Icons.close, color: Colors.white, size: 16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                        : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset('assets/icons/cl11.png', width: 36, height: 36),
                                            SizedBox(height: 8),
                                            Text(getTranslation('upload_slip'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              selectedFile != null ? getTranslation('click_image_to_view') : getTranslation('upload_qr_image'),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(getTranslation('supported_file_formats'), style: TextStyle(fontSize: 12, color: Colors.black54)),
                            SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                side: BorderSide(color: Colors.grey.shade400),
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              onPressed: _showFilePickerOptions,
                              child: Text(selectedFile != null ? getTranslation('change_file') : getTranslation('select_file')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ✅ แจ้งเตือนนี้ต้องอยู่นอกเงื่อนไข เพื่อแสดงตลอด
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF5E0),
                  border: Border.all(color: Color(0xFFFFC107)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/icons/danger.png', width: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${getTranslation('transaction_hours')} ${getTranslation('business_hours_message')}',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),
              Obx(() {
                final alipayRate = homeController.exchangeRate['alipay_topup_rate'];
                final rate = double.tryParse(alipayRate?.toString() ?? '0') ?? 0.0;
                return Row(
                  children: [
                    Text('${getTranslation('exchange_rate')} ', style: TextStyle(color: Colors.black54)),
                    Text(
                      rate > 0 ? '${rate.toStringAsFixed(2)} ${getTranslation('baht')}/${getTranslation('yuan')}' : getTranslation('uploading'),
                      style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                    ),
                  ],
                );
              }),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E3C72), padding: EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () async {
                    try {
                      // เช็คข้อมูลก่อนดำเนินการ
                      if (!_validateData()) {
                        return;
                      }

                      // final out = await checkTimeAndShowDialog(context);
                      // if (out == true) {

                      // }
                      // แสดง loading
                      Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);

                      // เตรียมข้อมูลสำหรับ API
                      final bahtAmount = double.tryParse(_bahtController.text) ?? 0.0;
                      final transferFee = homeController.transferFee.value;
                      final feeAmount = double.tryParse(transferFee?.alipay_fee ?? '0') ?? 0.0;

                      // อัปโหลดไฟล์ก่อน
                      if (selectedFile != null) {
                        if (extensionfileQR == 'pdf') {
                          imageQR = await UoloadService.addFile(file: selectedFile, path: 'uploads/alipay/');
                        } else {
                          imageQR = await UoloadService.addImage(file: selectedFile, path: 'uploads/alipay/');
                        }
                      }

                      // เรียก API
                      final deposit = await HomeService.productPaymentAlipayService(
                        transaction: selectedMethod == 1 ? 'alipay' : 'wechat',
                        amount: bahtAmount,
                        fee: feeAmount,
                        phone: _phoneController.text,
                        image_qr_code: imageQR ?? '',
                        image: imageQR ?? '',
                        image_url: imageQR ?? '',
                        image_slip: imageQR ?? '',
                        image_slip_url: imageQR ?? '',
                      );

                      // ปิด loading
                      Get.back();

                      // แสดงผลลัพธ์
                      if (deposit != null) {
                        Get.snackbar(
                          getTranslation('success'),
                          getTranslation('send_success'),
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        // ย้อนกลับหน้าก่อนหน้า
                        Navigator.pop(context);
                      } else {
                        Get.snackbar(getTranslation('error'), getTranslation('send_error'), backgroundColor: Colors.red, colorText: Colors.white);
                      }
                    } catch (e) {
                      // ปิด loading ถ้ามี
                      if (Get.isDialogOpen == true) {
                        Get.back();
                      }
                      Get.snackbar('ข้อผิดพลาด', 'เกิดข้อผิดพลาด: $e', backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  },
                  child: Text(getTranslation('confirm'), style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชั่นสำหรับแปลงชื่อ payment method เป็นชื่อบัญชี
  String _getAccountName(String paymentMethod) {
    // Check against translated payment method names
    if (paymentMethod == getTranslation('alipay')) {
      return 'บัญชี G-cargo-A';
    } else if (paymentMethod == getTranslation('wechat_pay')) {
      return 'บัญชี G-cargo-W';
    } else {
      return paymentMethod;
    }
  }

  Widget _buildInputField(String label, {TextEditingController? controller, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: const InputDecoration(border: InputBorder.none, hintText: ''),
          ),
        ),
      ],
    );
  }
}
