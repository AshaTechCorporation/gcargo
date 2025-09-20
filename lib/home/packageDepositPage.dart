import 'package:flutter/material.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:get/get.dart';

class PackageDepositPage extends StatefulWidget {
  const PackageDepositPage({super.key});

  @override
  State<PackageDepositPage> createState() => _PackageDepositPageState();
}

class _PackageDepositPageState extends State<PackageDepositPage> {
  List<Map<String, dynamic>> packageList = [];
  String transportMethod = '';
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'package_deposit': 'ฝากพัสดุ',
        'transport_method': 'วิธีการขนส่ง',
        'land_transport': 'ขนส่งทางรถ',
        'air_transport': 'ขนส่งทางเครื่องบิน',
        'sea_transport': 'ขนส่งทางเรือ',
        'add_package': 'เพิ่มพัสดุ',
        'package_list': 'รายการพัสดุ',
        'no_packages': 'ยังไม่มีพัสดุ',
        'tracking_number': 'หมายเลขติดตาม',
        'service': 'บริการ',
        'quantity': 'จำนวน',
        'type': 'ประเภท',
        'note': 'หมายเหตุ',
        'edit': 'แก้ไข',
        'delete': 'ลบ',
        'confirm': 'ยืนยัน',
        'cancel': 'ยกเลิก',
        'save': 'บันทึก',
        'wooden_crate': 'ตีลังไม้',
        'plastic_wrap': 'พันพลาสติก',
        'bubble_wrap': 'พันฟองอากาศ',
        'clothing': 'เสื้อผ้า',
        'electronics': 'อิเล็กทรอนิกส์',
        'cosmetics': 'เครื่องสำอาง',
        'food': 'อาหาร',
        'books': 'หนังสือ',
        'toys': 'ของเล่น',
        'others': 'อื่นๆ',
        'package_details': 'รายละเอียดพัสดุ',
        'enter_tracking': 'กรอกหมายเลขติดตาม',
        'enter_quantity': 'กรอกจำนวน',
        'enter_note': 'กรอกหมายเหตุ (ถ้ามี)',
        'select_service': 'เลือกบริการ',
        'select_type': 'เลือกประเภท',
      },
      'en': {
        'package_deposit': 'Package Deposit',
        'transport_method': 'Transport',
        'land_transport': 'Land Transport',
        'air_transport': 'Air Transport',
        'sea_transport': 'Sea Transport',
        'add_package': 'Add Package',
        'package_list': 'Package List',
        'no_packages': 'No Packages Yet',
        'tracking_number': 'Tracking Number',
        'service': 'Service',
        'quantity': 'Quantity',
        'type': 'Type',
        'note': 'Note',
        'edit': 'Edit',
        'delete': 'Delete',
        'confirm': 'Confirm',
        'cancel': 'Cancel',
        'save': 'Save',
        'wooden_crate': 'Wooden Crate',
        'plastic_wrap': 'Plastic Wrap',
        'bubble_wrap': 'Bubble Wrap',
        'clothing': 'Clothing',
        'electronics': 'Electronics',
        'cosmetics': 'Cosmetics',
        'food': 'Food',
        'books': 'Books',
        'toys': 'Toys',
        'others': 'Others',
        'package_details': 'Package Details',
        'enter_tracking': 'Enter Tracking Number',
        'enter_quantity': 'Enter Quantity',
        'enter_note': 'Enter Note (Optional)',
        'select_service': 'Select Service',
        'select_type': 'Select Type',
      },
      'zh': {
        'package_deposit': '包裹寄存',
        'transport_method': '运输方式',
        'land_transport': '陆运',
        'air_transport': '空运',
        'sea_transport': '海运',
        'add_package': '添加包裹',
        'package_list': '包裹列表',
        'no_packages': '暂无包裹',
        'tracking_number': '追踪号码',
        'service': '服务',
        'quantity': '数量',
        'type': '类型',
        'note': '备注',
        'edit': '编辑',
        'delete': '删除',
        'confirm': '确认',
        'cancel': '取消',
        'save': '保存',
        'wooden_crate': '木箱包装',
        'plastic_wrap': '塑料包装',
        'bubble_wrap': '气泡包装',
        'clothing': '服装',
        'electronics': '电子产品',
        'cosmetics': '化妆品',
        'food': '食品',
        'books': '书籍',
        'toys': '玩具',
        'others': '其他',
        'package_details': '包裹详情',
        'enter_tracking': '输入追踪号码',
        'enter_quantity': '输入数量',
        'enter_note': '输入备注（可选）',
        'select_service': '选择服务',
        'select_type': '选择类型',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    transportMethod = getTranslation('land_transport'); // Set default transport method
  }

  void _addPackage() {
    setState(() {
      packageList.add({
        'tracking': '',
        'service': getTranslation('wooden_crate'),
        'qty': '',
        'type': getTranslation('clothing'), // default
        'note': '',
      });
    });
  }

  void _editPackage(int index) async {
    final result = await showDialog(
      context: context,
      builder: (context) => _PackageDialog(initialData: packageList[index], getTranslation: getTranslation),
    );

    if (result != null) {
      setState(() {
        packageList[index] = result;
      });
    }
  }

  void _removePackage(int index) {
    setState(() {
      packageList.removeAt(index);
    });
  }

  void _confirmPackages() async {
    final result = await showDialog(
      context: context,
      builder:
          (context) => _PackageDialog(
            initialData: {'tracking': '', 'service': getTranslation('wooden_crate'), 'qty': '', 'type': getTranslation('clothing'), 'note': ''},
            getTranslation: getTranslation,
          ),
    );

    if (result != null) {
      setState(() {
        packageList.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(getTranslation('package_deposit'), style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black), onPressed: () => Navigator.pop(context)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                child: TextButton(
                  onPressed: _addPackage,
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  child: Text(getTranslation('add_package'), style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: packageList.length,
                  itemBuilder:
                      (context, index) => GestureDetector(onTap: () => _editPackage(index), child: _buildPackageCard(packageList[index], index)),
                ),
              ),

              // วิธีขนส่ง
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(getTranslation('transport_method'), style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Radio<String>(
                        value: getTranslation('land_transport'),
                        groupValue: transportMethod,
                        onChanged: (val) => setState(() => transportMethod = val!),
                      ),
                      Text(getTranslation('land_transport')),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Radio<String>(
                        value: getTranslation('sea_transport'),
                        groupValue: transportMethod,
                        onChanged: (val) => setState(() => transportMethod = val!),
                      ),
                      Text(getTranslation('sea_transport')),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002A5B), padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text(getTranslation('confirm'), style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔵 ไอคอนรถในวงกลม
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEDF6FF)),
            child: Center(child: Image.asset('assets/icons/car.png', width: 20, height: 20)),
          ),

          const SizedBox(width: 12),

          // 📝 ข้อความกลางการ์ด
          Expanded(child: Text(item['tracking'] ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),

          // ❌ ปุ่มลบด้านขวากลาง
          GestureDetector(onTap: () => _removePackage(index), child: Image.asset('assets/icons/Vectorremove.png', width: 20, height: 20)),
        ],
      ),
    );
  }
}

class _PackageDialog extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final String Function(String) getTranslation;

  const _PackageDialog({required this.initialData, required this.getTranslation});

  @override
  State<_PackageDialog> createState() => _PackageDialogState();
}

class _PackageDialogState extends State<_PackageDialog> {
  final TextEditingController trackingCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();
  String service = '';
  String? selectedType;
  List<String> productTypes = [];
  List<String> serviceTypes = [];

  @override
  void initState() {
    super.initState();

    // Initialize translation-dependent data
    productTypes = [
      widget.getTranslation('clothing'),
      widget.getTranslation('electronics'),
      widget.getTranslation('cosmetics'),
      widget.getTranslation('food'),
      widget.getTranslation('books'),
      widget.getTranslation('toys'),
      widget.getTranslation('others'),
    ];

    serviceTypes = [widget.getTranslation('wooden_crate'), widget.getTranslation('plastic_wrap'), widget.getTranslation('bubble_wrap')];

    trackingCtrl.text = widget.initialData['tracking'] ?? '';
    qtyCtrl.text = widget.initialData['qty'] ?? '';
    noteCtrl.text = widget.initialData['note'] ?? '';
    service = widget.initialData['service'] ?? widget.getTranslation('wooden_crate');

    final incomingType = widget.initialData['type'];
    selectedType = productTypes.contains(incomingType) ? incomingType : productTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        resizeToAvoidBottomInset: false, // ป้องกัน overflow เมื่อ keyboard ขึ้น
        appBar: AppBar(
          title: Text(widget.getTranslation('package_details')),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context))],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.getTranslation('tracking_number')),
              const SizedBox(height: 6),
              TextField(
                controller: trackingCtrl,
                decoration: InputDecoration(border: OutlineInputBorder(), hintText: widget.getTranslation('enter_tracking')),
              ),
              const SizedBox(height: 16),

              Text(widget.getTranslation('select_service')),
              Column(
                children:
                    serviceTypes
                        .map(
                          (serviceType) => RadioListTile(
                            title: Text(serviceType),
                            value: serviceType,
                            groupValue: service,
                            onChanged: (val) => setState(() => service = val!),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.getTranslation('quantity')),
                        const SizedBox(height: 6),
                        TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(border: OutlineInputBorder(), hintText: widget.getTranslation('enter_quantity')),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.getTranslation('type')),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: InputDecoration(border: OutlineInputBorder(), hintText: widget.getTranslation('select_type')),
                          items: productTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                          onChanged: (val) => setState(() => selectedType = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(widget.getTranslation('note')),
              const SizedBox(height: 6),
              TextField(
                controller: noteCtrl,
                maxLength: 200,
                maxLines: 3,
                decoration: InputDecoration(border: OutlineInputBorder(), hintText: widget.getTranslation('enter_note')),
              ),

              const SizedBox(height: 32), // เปลี่ยนจาก Spacer เป็น SizedBox
              SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'tracking': trackingCtrl.text,
                        'service': service,
                        'qty': qtyCtrl.text,
                        'type': selectedType,
                        'note': noteCtrl.text,
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002A5B), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(widget.getTranslation('save'), style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
