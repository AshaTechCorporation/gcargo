import 'package:flutter/material.dart';

class TransportCalculatePage extends StatefulWidget {
  const TransportCalculatePage({super.key});

  @override
  State<TransportCalculatePage> createState() => _TransportCalculatePageState();
}

class _TransportCalculatePageState extends State<TransportCalculatePage> with TickerProviderStateMixin {
  late final TabController _tabController;

  final List<String> productTypes = ['ทั่วไป', 'มอก', 'อย', 'แบรน', 'พิเศษ'];
  String? selectedProductType;
  String selectedMethod = 'การรถ';
  final TextEditingController widthCtrl = TextEditingController();
  final TextEditingController lengthCtrl = TextEditingController();
  final TextEditingController heightCtrl = TextEditingController();
  final TextEditingController weightCtrl = TextEditingController();

  final TextEditingController woodWidthCtrl = TextEditingController();
  final TextEditingController woodLengthCtrl = TextEditingController();
  final TextEditingController woodHeightCtrl = TextEditingController();

  bool showError = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
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
    return selectedProductType == 'ทั่วไป' || selectedProductType == 'มอก';
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = selectedProductType != null && !isAllowedProductType();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('คำนวณ', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black), onPressed: () => Navigator.pop(context)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [Tab(text: 'วิธีคำนวณค่าขนส่ง'), Tab(text: 'วิธีคำนวณตู้ลังไม้')],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [_buildNormalTab(context, isBlocked), _buildWoodBoxTab()]),
    );
  }

  Widget _buildNormalTab(BuildContext context, bool isBlocked) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const SizedBox(height: 12),
          const Text('ประเภทสินค้า', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedProductType,
            decoration: InputDecoration(
              hintText: 'เลือกประเภทสินค้า',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items:
                productTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedProductType = value;
                showError = !isAllowedProductType();
              });
            },
          ),
          const SizedBox(height: 16),

          const Text('เลือกรูปแบบขนส่ง', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  title: const Text('การรถ'),
                  value: 'การรถ',
                  groupValue: selectedMethod,
                  onChanged: (val) => setState(() => selectedMethod = val!),
                  dense: true,
                ),
              ),
              Expanded(
                child: RadioListTile(
                  title: const Text('ทางเรือ'),
                  value: 'ทางเรือ',
                  groupValue: selectedMethod,
                  onChanged: (val) => setState(() => selectedMethod = val!),
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _buildInputField(widthCtrl, 'ความกว้าง', 'cm')),
              const SizedBox(width: 12),
              Expanded(child: _buildInputField(lengthCtrl, 'ความยาว', 'cm')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInputField(heightCtrl, 'ความสูง', 'cm')),
              const SizedBox(width: 12),
              Expanded(child: _buildInputField(weightCtrl, 'น้ำหนัก', 'kg')),
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

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      widthCtrl.clear();
                      lengthCtrl.clear();
                      heightCtrl.clear();
                      weightCtrl.clear();
                      showError = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.grey)),
                  child: const Text('ล้างข้อมูล'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isBlocked ? null : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBlocked ? Colors.grey.shade300 : const Color(0xFF002A5B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('คำนวณ', style: TextStyle(color: Colors.white)),
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
      child: ListView(
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
            child: const Text('0.00 บาท', style: TextStyle(fontSize: 16)),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    woodWidthCtrl.clear();
                    woodLengthCtrl.clear();
                    woodHeightCtrl.clear();
                  },
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.grey)),
                  child: const Text('ล้างข้อมูล'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002A5B), padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('คำนวณ', style: TextStyle(color: Colors.white)),
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
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
}
