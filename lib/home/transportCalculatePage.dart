import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/home/widgets/QrCodeDialog.dart';
import 'package:gcargo/utils/number_formatter.dart';
import 'package:get/get.dart';

class TransportCalculatePage extends StatefulWidget {
  const TransportCalculatePage({super.key});

  @override
  State<TransportCalculatePage> createState() => _TransportCalculatePageState();
}

class _TransportCalculatePageState extends State<TransportCalculatePage> with TickerProviderStateMixin {
  late final TabController _tabController;
  final HomeController homeController = Get.put(HomeController());
  late LanguageController languageController;

  String? selectedProductType;
  String selectedMethod = '';
  final TextEditingController widthCtrl = TextEditingController();
  final TextEditingController lengthCtrl = TextEditingController();
  final TextEditingController heightCtrl = TextEditingController();
  final TextEditingController weightCtrl = TextEditingController();

  final TextEditingController woodWidthCtrl = TextEditingController();
  final TextEditingController woodLengthCtrl = TextEditingController();
  final TextEditingController woodHeightCtrl = TextEditingController();

  bool showError = false;
  double calculatedCost = 0.0;
  double woodBoxCost = 0.0;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'calculate_service': 'คำนวณค่าบริการ',
        'shipping_cost': 'ค่าขนส่ง',
        'wooden_box': 'ลังไม้',
        'land_transport': 'ทางรถ',
        'sea_transport': 'ทางเรือ',
        'product_type': 'ประเภทสินค้า',
        'select_product_type': 'เลือกประเภทสินค้า',
        'width': 'กว้าง',
        'length': 'ยาว',
        'height': 'สูง',
        'weight': 'น้ำหนัก',
        'cm': 'ซม.',
        'kg': 'กก.',
        'calculate': 'คำนวณ',
        'total_cost': 'ค่าใช้จ่ายรวม',
        'baht': 'บาท',
        'please_fill_all': 'กรุณากรอกข้อมูลให้ครบถ้วน',
        'electronics': 'อิเล็กทรอนิกส์',
        'clothing': 'เสื้อผ้า',
        'cosmetics': 'เครื่องสำอาง',
        'food': 'อาหาร',
        'books': 'หนังสือ',
        'toys': 'ของเล่น',
        'others': 'อื่นๆ',
        'clear_data': 'ล้างข้อมูล',
        'select_transport_method': 'เลือกรูปแบบขนส่ง',
        'calculation_result': 'ผลการคำนวณ',
        'shipping_cost_result': 'ค่าขนส่ง',
        'wooden_box_cost': 'ค่าตีลังไม้',
        'formula_text': '(กว้าง × ยาว × สูง) × 1,500',
      },
      'en': {
        'calculate_service': 'Calculate Service',
        'shipping_cost': 'Shipping Cost',
        'wooden_box': 'Wooden Box',
        'land_transport': 'Land Transport',
        'sea_transport': 'Sea Transport',
        'product_type': 'Product Type',
        'select_product_type': 'Select Product Type',
        'width': 'Width',
        'length': 'Length',
        'height': 'Height',
        'weight': 'Weight',
        'cm': 'cm',
        'kg': 'kg',
        'calculate': 'Calculate',
        'total_cost': 'Total Cost',
        'baht': 'Baht',
        'please_fill_all': 'Please fill in all information',
        'electronics': 'Electronics',
        'clothing': 'Clothing',
        'cosmetics': 'Cosmetics',
        'food': 'Food',
        'books': 'Books',
        'toys': 'Toys',
        'others': 'Others',
        'clear_data': 'Clear Data',
        'select_transport_method': 'Select Transport Method',
        'calculation_result': 'Calculation Result',
        'shipping_cost_result': 'Shipping Cost',
        'wooden_box_cost': 'Wooden Box Cost',
        'formula_text': '(Width × Length × Height) × 1,500',
      },
      'zh': {
        'calculate_service': '计算服务费',
        'shipping_cost': '运费',
        'wooden_box': '木箱',
        'land_transport': '陆运',
        'sea_transport': '海运',
        'product_type': '产品类型',
        'select_product_type': '选择产品类型',
        'width': '宽度',
        'length': '长度',
        'height': '高度',
        'weight': '重量',
        'cm': '厘米',
        'kg': '公斤',
        'calculate': '计算',
        'total_cost': '总费用',
        'baht': '泰铢',
        'please_fill_all': '请填写完整信息',
        'electronics': '电子产品',
        'clothing': '服装',
        'cosmetics': '化妆品',
        'food': '食品',
        'books': '书籍',
        'toys': '玩具',
        'others': '其他',
        'clear_data': '清除数据',
        'select_transport_method': '选择运输方式',
        'calculation_result': '计算结果',
        'shipping_cost_result': '运费',
        'wooden_box_cost': '木箱费用',
        'formula_text': '(宽 × 长 × 高) × 1,500',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    languageController = Get.find<LanguageController>();
    selectedMethod = getTranslation('land_transport'); // Set default transport method

    // เพิ่ม listener สำหรับ real-time calculation
    woodWidthCtrl.addListener(_calculateWoodBoxRealTime);
    woodLengthCtrl.addListener(_calculateWoodBoxRealTime);
    woodHeightCtrl.addListener(_calculateWoodBoxRealTime);

    // Call getRateShipFromAPI when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.getRateShipFromAPI();
    });
  }

  void _calculateWoodBoxRealTime() {
    if (woodWidthCtrl.text.isNotEmpty && woodLengthCtrl.text.isNotEmpty && woodHeightCtrl.text.isNotEmpty) {
      calculateWoodBoxCost();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    widthCtrl.dispose();
    lengthCtrl.dispose();
    heightCtrl.dispose();
    weightCtrl.dispose();
    woodWidthCtrl.dispose();
    woodLengthCtrl.dispose();
    woodHeightCtrl.dispose();
    super.dispose();
  }

  bool isAllowedProductType() {
    return selectedProductType == 'สินค้าทั่วไป' || selectedProductType == 'มอก.';
  }

  // คำนวณค่าขนส่งตามสูตรปริมาตร
  void calculateShippingCost() {
    print('🧮 Calculate called - selectedMethod: $selectedMethod, selectedProductType: $selectedProductType');

    if (!isAllowedProductType()) {
      print('❌ Product type not allowed');
      setState(() {
        showError = true;
        calculatedCost = 0.0;
      });
      return;
    }

    // ตรวจสอบว่ากรอกข้อมูลครบหรือไม่
    if (widthCtrl.text.isEmpty || lengthCtrl.text.isEmpty || heightCtrl.text.isEmpty || weightCtrl.text.isEmpty) {
      print('❌ Missing input data');
      setState(() {
        showError = true;
        calculatedCost = 0.0;
      });
      return;
    }

    try {
      // แปลงค่าจาก cm เป็น m และคำนวณปริมาตร
      double width = double.parse(widthCtrl.text) / 100; // cm to m
      double length = double.parse(lengthCtrl.text) / 100; // cm to m
      double height = double.parse(heightCtrl.text) / 100; // cm to m
      double weight = double.parse(weightCtrl.text); // kg

      // คำนวณปริมาตร (CBM)
      double volume = width * length * height;

      // หาอัตราค่าขนส่งจาก API ตาม selectedProductType และ selectedMethod
      String vehicleType = selectedMethod == 'ทางรถ' ? 'car' : 'ship';

      // ค้นหา rate ที่ตรงกับประเภทสินค้าและวิธีขนส่ง
      var matchingRate = homeController.rateShip.firstWhere(
        (rate) =>
            (rate.vehicle?.toLowerCase() == vehicleType || rate.vehicle?.toLowerCase() == (vehicleType == 'car' ? 'รถ' : 'เรือ')) &&
            rate.name == selectedProductType,
        orElse: () => homeController.rateShip.first,
      );

      // ดึงอัตราค่าขนส่งต่อ CBM
      double ratePerCBM = NumberFormatter.toDouble(matchingRate.cbm);

      // คำนวณค่าขนส่ง = ปริมาตร × อัตราค่าขนส่งต่อ CBM
      double shippingCost = volume * ratePerCBM;

      setState(() {
        calculatedCost = shippingCost;
        showError = false;
      });
    } catch (e) {
      setState(() {
        showError = true;
        calculatedCost = 0.0;
      });
    }
  }

  // คำนวณค่าตีลังไม้
  void calculateWoodBoxCost() {
    print('🪵 Wood box calculate called');

    if (woodWidthCtrl.text.isEmpty || woodLengthCtrl.text.isEmpty || woodHeightCtrl.text.isEmpty) {
      print('❌ Wood box missing input data');
      setState(() {
        woodBoxCost = 0.0;
      });
      return;
    }

    try {
      // ใช้ค่าเป็น cm โดยตรง
      double width = double.parse(woodWidthCtrl.text); // cm
      double length = double.parse(woodLengthCtrl.text); // cm
      double height = double.parse(woodHeightCtrl.text); // cm

      // คำนวณ CBM = (กว้าง × ยาว × สูง) ÷ 1,000,000
      double cbm = (width * length * height) / 1000000;

      // คำนวณค่าตีลังไม้ = CBM × 1,500
      double cost = cbm * 1500;

      print('✅ Wood box calculated: $width×$length×$height cm³ = $cbm CBM, cost=$cost THB');

      setState(() {
        woodBoxCost = cost;
      });
    } catch (e) {
      setState(() {
        woodBoxCost = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = selectedProductType != null && !isAllowedProductType();

    // Debug log
    print('🔧 Build - selectedMethod: $selectedMethod, selectedProductType: $selectedProductType, isBlocked: $isBlocked');

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false, // ป้องกัน overflow เมื่อ keyboard ขึ้น
        appBar: AppBar(
          title: Text(getTranslation('calculate_service'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black), onPressed: () => Navigator.pop(context)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.black,
            indicatorWeight: 3,
            labelColor: kButtonColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
            tabs: [
              Tab(child: Text(getTranslation('shipping_cost'), style: TextStyle(fontFamily: 'SukhumvitSet'))),
              Tab(child: Text(getTranslation('wooden_box'), style: TextStyle(fontFamily: 'SukhumvitSet'))),
            ],
          ),
        ),
        body: TabBarView(controller: _tabController, children: [_buildNormalTab(context, isBlocked), _buildWoodBoxTab()]),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -2))],
          ),
          child: SafeArea(child: _buildCalculateButton()),
        ),
      ),
    );
  }

  // สร้างปุ่มคำนวนตามแท็บที่เลือก
  Widget _buildCalculateButton() {
    final currentIndex = _tabController.index;
    final isBlocked = false; // ใช้ false ชั่วคราว หรือเช็คจาก SharedPreferences

    if (currentIndex == 0) {
      // แท็บแรก - คำนวณค่าขนส่ง
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  selectedMethod = '';
                  weightCtrl.clear();
                  showError = false;
                  calculatedCost = 0.0;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFD0D0D0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(getTranslation('clear_data'), style: TextStyle(fontSize: 20, color: kHintTextColor)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 7,
            child: ElevatedButton(
              onPressed:
                  isBlocked
                      ? null
                      : () {
                        print('🔘 Button pressed!');
                        calculateShippingCost();
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlocked ? Colors.grey.shade300 : const Color(0xFF002A5B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(getTranslation('calculate'), style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
        ],
      );
    } else {
      // แท็บที่สอง - คำนวณตู้ลังไม้
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  woodWidthCtrl.clear();
                  woodLengthCtrl.clear();
                  woodHeightCtrl.clear();
                  woodBoxCost = 0.0;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFD0D0D0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(getTranslation('clear_data'), style: TextStyle(fontSize: 20, color: kHintTextColor, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 7,
            child: ElevatedButton(
              onPressed: calculateWoodBoxCost,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002A5B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(getTranslation('calculate'), style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildNormalTab(BuildContext context, bool isBlocked) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(children: [Text(getTranslation('product_type'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
          const SizedBox(height: 6),
          Obx(() {
            List<String> availableProductTypes = _getProductTypesByMethod(selectedMethod);
            if (selectedProductType != null && !availableProductTypes.contains(selectedProductType)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  selectedProductType = null;
                });
              });
            }

            return DropdownButtonFormField<String>(
              value: selectedProductType,
              decoration: InputDecoration(
                hintText: getTranslation('select_product_type'),
                hintStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black),
              items: availableProductTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProductType = value;
                  calculatedCost = 0.0; // เคลียร์ผลการคำนวณเมื่อเปลี่ยนประเภทสินค้า
                  showError = !isAllowedProductType();
                });
              },
            );
          }),
          const SizedBox(height: 14),
          Row(children: [Text(getTranslation('select_transport_method'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  title: Text(getTranslation('land_transport'), style: TextStyle(fontSize: 16)),
                  value: getTranslation('land_transport'),
                  groupValue: selectedMethod,
                  onChanged: (val) {
                    setState(() {
                      selectedMethod = val!;
                      selectedProductType = null;
                      calculatedCost = 0.0; // เคลียร์ผลการคำนวณเมื่อเปลี่ยนรูปแบบขนส่ง
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile(
                  title: Text(getTranslation('sea_transport'), style: TextStyle(fontSize: 16)),
                  value: getTranslation('sea_transport'),
                  groupValue: selectedMethod,
                  onChanged: (val) {
                    setState(() {
                      selectedMethod = val!;
                      selectedProductType = null;
                      calculatedCost = 0.0; // เคลียร์ผลการคำนวณเมื่อเปลี่ยนรูปแบบขนส่ง
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInputField(widthCtrl, '${getTranslation('width')} (${getTranslation('cm')})', 'cm')),
              const SizedBox(width: 12),
              Expanded(child: _buildInputField(lengthCtrl, '${getTranslation('length')} (${getTranslation('cm')})', 'cm')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInputField(heightCtrl, '${getTranslation('height')} (${getTranslation('cm')})', 'cm')),
              const SizedBox(width: 12),
              Expanded(child: _buildInputField(weightCtrl, '${getTranslation('weight')} (${getTranslation('kg')})', 'kg')),
            ],
          ),
          const SizedBox(height: 16),
          if (isBlocked)
            GestureDetector(
              onTap: () {
                // TODO: ต้องการให้ไปที่หน้าไหน
                showDialog(context: context, builder: (_) => const QrCodeDialog());
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: const Color(0xFFFFE5E5), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: const [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'หากต้องการคำนวณค่าขนส่งของสินค้าประเภท อย / แบรน / พิเศษ กรุณาดูที่ตู้ลังไม้',
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // แสดงผลการคำนวณ
          if (calculatedCost > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(getTranslation('calculation_result'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '${getTranslation('shipping_cost_result')}: ${NumberFormatter.formatTHB(calculatedCost)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

          // Spacer(),
          // Row(
          //   children: [
          //     Expanded(
          //       flex: 3,
          //       child: OutlinedButton(
          //         onPressed: () {
          //           setState(() {
          //             widthCtrl.clear();
          //             lengthCtrl.clear();
          //             heightCtrl.clear();
          //             weightCtrl.clear();
          //             showError = false;
          //             calculatedCost = 0.0;
          //           });
          //         },
          //         style: OutlinedButton.styleFrom(
          //           padding: const EdgeInsets.symmetric(vertical: 16),
          //           side: const BorderSide(color: Color(0xFFD0D0D0)),
          //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          //         ),
          //         child: Text('ล้างข้อมูล', style: TextStyle(fontSize: 20, color: kHintTextColor)),
          //       ),
          //     ),
          //     // ปุ่มคำนวนย้ายไป bottomNavigationBar แล้ว
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildWoodBoxTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(getTranslation('formula_text'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              Image.asset('assets/icons/boxGroup.png', width: 60, height: 60),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 24),

          _buildLabeledInput(getTranslation('width'), woodWidthCtrl, getTranslation('cm')),
          const SizedBox(height: 16),
          _buildLabeledInput(getTranslation('length'), woodLengthCtrl, getTranslation('cm')),
          const SizedBox(height: 16),
          _buildLabeledInput(getTranslation('height'), woodHeightCtrl, getTranslation('cm')),

          const SizedBox(height: 24),
          Text(getTranslation('wooden_box_cost'), style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: Text(NumberFormatter.formatTHB(woodBoxCost), style: const TextStyle(fontSize: 16)),
          ),

          // const SizedBox(height: 24),
          // Spacer(),
          // Row(
          //   children: [
          //     Expanded(
          //       flex: 3,
          //       child: OutlinedButton(
          //         onPressed: () {
          //           setState(() {
          //             woodWidthCtrl.clear();
          //             woodLengthCtrl.clear();
          //             woodHeightCtrl.clear();
          //             woodBoxCost = 0.0;
          //           });
          //         },
          //         style: OutlinedButton.styleFrom(
          //           padding: const EdgeInsets.symmetric(vertical: 16),
          //           side: const BorderSide(color: Color(0xFFD0D0D0)),
          //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          //         ),
          //         child: const Text('ล้างข้อมูล', style: TextStyle(fontSize: 20, color: kHintTextColor)),
          //       ),
          //     ),
          //     // ปุ่มคำนวนย้ายไป bottomNavigationBar แล้ว
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, String suffix) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _buildLabeledInput(String label, TextEditingController controller, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  // Get product types based on selected transport method and API data
  List<String> _getProductTypesByMethod(String method) {
    // Determine vehicle type based on method
    String vehicleType = '';
    if (method == getTranslation('land_transport')) {
      vehicleType = 'car';
    } else if (method == getTranslation('sea_transport')) {
      vehicleType = 'ship';
    }

    // Get product types from API data for the selected vehicle
    List<String> apiProductTypes =
        homeController.rateShip
            .where(
              (rateShip) =>
                  rateShip.vehicle?.toLowerCase() == vehicleType || rateShip.vehicle?.toLowerCase() == (vehicleType == 'car' ? 'รถ' : 'เรือ'),
            )
            .map((rateShip) => rateShip.name ?? '')
            .where((name) => name.isNotEmpty)
            .toSet() // Remove duplicates
            .toList();

    // Debug log
    print('🚗 Method: $method, VehicleType: $vehicleType');
    print('📦 API Product Types: $apiProductTypes');
    print('🔢 Total rateShip items: ${homeController.rateShip.length}');

    // Use API data if available, otherwise use default product types
    if (apiProductTypes.isNotEmpty) {
      return apiProductTypes;
    } else {
      // Return translated default product types
      return [
        getTranslation('electronics'),
        getTranslation('clothing'),
        getTranslation('cosmetics'),
        getTranslation('food'),
        getTranslation('books'),
        getTranslation('toys'),
        getTranslation('others'),
      ];
    }
  }
}
