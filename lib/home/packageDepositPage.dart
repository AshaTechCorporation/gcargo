import 'package:flutter/material.dart';

class PackageDepositPage extends StatefulWidget {
  const PackageDepositPage({super.key});

  @override
  State<PackageDepositPage> createState() => _PackageDepositPageState();
}

class _PackageDepositPageState extends State<PackageDepositPage> {
  List<Map<String, dynamic>> packageList = [];
  String transportMethod = 'ขนส่งทางรถ';

  void _addPackage() {
    setState(() {
      packageList.add({
        'tracking': '',
        'service': 'ตีลังไม้',
        'qty': '',
        'type': 'เสื้อผ้า', // default
        'note': '',
      });
    });
  }

  void _editPackage(int index) async {
    final result = await showDialog(context: context, builder: (context) => _PackageDialog(initialData: packageList[index]));

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
      builder: (context) => _PackageDialog(initialData: {'tracking': '', 'service': 'ตีลังไม้', 'qty': '', 'type': 'เสื้อผ้า', 'note': ''}),
    );

    if (result != null) {
      setState(() {
        packageList.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('บริการฝากส่ง', style: TextStyle(color: Colors.black)),
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
                child: const Text('เพิ่มรายการ', style: TextStyle(color: Colors.black)),
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
                const Text('รูปแบบการขนส่ง', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Radio<String>(value: 'ขนส่งทางรถ', groupValue: transportMethod, onChanged: (val) => setState(() => transportMethod = val!)),
                    const Text('ขนส่งทางรถ'),
                  ],
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Radio<String>(value: 'ขนส่งทางเรือ', groupValue: transportMethod, onChanged: (val) => setState(() => transportMethod = val!)),
                    const Text('ขนส่งทางเรือ'),
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
                child: const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
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

  const _PackageDialog({required this.initialData});

  @override
  State<_PackageDialog> createState() => _PackageDialogState();
}

class _PackageDialogState extends State<_PackageDialog> {
  final TextEditingController trackingCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();
  String service = 'ตีลังไม้';
  String? selectedType;
  final List<String> productTypes = ['เสื้อผ้า', 'อาหาร', 'ของใช้', 'ของฝาก'];

  @override
  void initState() {
    super.initState();
    trackingCtrl.text = widget.initialData['tracking'] ?? '';
    qtyCtrl.text = widget.initialData['qty'] ?? '';
    noteCtrl.text = widget.initialData['note'] ?? '';
    service = widget.initialData['service'] ?? 'ตีลังไม้';

    final incomingType = widget.initialData['type'];
    selectedType = productTypes.contains(incomingType) ? incomingType : productTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context))],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('เลขขนส่งวัน'),
              const SizedBox(height: 6),
              TextField(controller: trackingCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'กรุณากรอกเลขขนส่งวัน')),
              const SizedBox(height: 16),

              const Text('เลือกบริการ'),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text('ตีลังไม้'),
                      value: 'ตีลังไม้',
                      groupValue: service,
                      onChanged: (val) => setState(() => service = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text('ไม่ตีลังไม้'),
                      value: 'ไม่ตีลังไม้',
                      groupValue: service,
                      onChanged: (val) => setState(() => service = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('จำนวนกล่องพัสดุ'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'กรุณากรอกจำนวน'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ประเภทสินค้า'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: productTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                          onChanged: (val) => setState(() => selectedType = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text('หมายเหตุ'),
              const SizedBox(height: 6),
              TextField(
                controller: noteCtrl,
                maxLength: 200,
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'กรุณากรอกหมายเหตุ'),
              ),

              const Spacer(),
              SizedBox(
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
                  child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
