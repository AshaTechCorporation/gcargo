import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
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

  String? selectedProductType;
  String selectedMethod = 'ทางรถ';
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

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('คำนวณ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
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
          tabs: [Tab(text: 'วิธีคำนวณค่าขนส่ง'), Tab(text: 'วิธีคำนวณตู้ลังไม้')],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [_buildNormalTab(context, isBlocked), _buildWoodBoxTab()]),
    );
  }

  Widget _buildNormalTab(BuildContext context, bool isBlocked) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(children: [const Text('ประเภทสินค้า', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
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
                hintText: 'เลือกประเภทสินค้า',
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
          Row(children: [const Text('เลือกรูปแบบขนส่ง', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  title: const Text('ทางรถ', style: TextStyle(fontSize: 16)),
                  value: 'ทางรถ',
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
                  title: const Text('ทางเรือ', style: TextStyle(fontSize: 16)),
                  value: 'ทางเรือ',
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
              Expanded(child: _buildInputField(widthCtrl, 'กรอกความกว้าง', 'cm')),
              const SizedBox(width: 12),
              Expanded(child: _buildInputField(lengthCtrl, 'กรอกความยาว', 'cm')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInputField(heightCtrl, 'กรอกความสูง', 'cm')),
              const SizedBox(width: 12),
              Expanded(child: _buildInputField(weightCtrl, 'กรอกน้ำหนัก', 'kg')),
            ],
          ),
          const SizedBox(height: 16),
          if (isBlocked)
            Container(
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
                  const Text('ผลการคำนวณ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('ค่าขนส่ง: ${NumberFormatter.formatTHB(calculatedCost)}', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),

          Spacer(),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      widthCtrl.clear();
                      lengthCtrl.clear();
                      heightCtrl.clear();
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
                  child: Text('ล้างข้อมูล', style: TextStyle(fontSize: 20, color: kHintTextColor)),
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
                  child: const Text('คำนวณ', style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWoodBoxTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: Text('(กว้าง × ยาว × สูง) × 1,500', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              Image.asset('assets/icons/boxGroup.png', width: 60, height: 60),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 24),

          _buildLabeledInput('ความกว้าง', woodWidthCtrl, 'cm'),
          const SizedBox(height: 16),
          _buildLabeledInput('ความยาว', woodLengthCtrl, 'cm'),
          const SizedBox(height: 16),
          _buildLabeledInput('ความสูง', woodHeightCtrl, 'cm'),

          const SizedBox(height: 24),
          const Text('ค่าตีลังไม้', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: Text(NumberFormatter.formatTHB(woodBoxCost), style: const TextStyle(fontSize: 16)),
          ),

          const SizedBox(height: 24),
          Spacer(),
          Row(
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
                  child: const Text('ล้างข้อมูล', style: TextStyle(fontSize: 20, color: kHintTextColor)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 7,
                child: ElevatedButton(
                  onPressed: calculateWoodBoxCost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF002A5B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('คำนวณ', style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
            ],
          ),
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
    if (method == 'ทางรถ') {
      vehicleType = 'car';
    } else if (method == 'ทางเรือ') {
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
    return apiProductTypes.isNotEmpty ? apiProductTypes : [];
  }
}
