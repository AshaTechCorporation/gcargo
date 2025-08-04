import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/parcel/addEditAddress.dart';

class ShippingAddressPage extends StatefulWidget {
  const ShippingAddressPage({super.key});

  @override
  State<ShippingAddressPage> createState() => _ShippingAddressPageState();
}

class _ShippingAddressPageState extends State<ShippingAddressPage> {
  final List<Map<String, String>> addresses = const [
    {
      'name': 'Girati Sukapat',
      'phone': '097 123 4567',
      'address': '167304 XXX',
      'detail': '167304 XXX XXXXXXX XXXXXX',
      'province': 'กรุงเทพมหานคร',
      'district': 'ลาดกระบัง',
      'subDistrict': 'ลาดกระบัง',
      'postalCode': '10500',
    },
    {
      'name': 'Girati Sukapat two',
      'phone': '097 223 4568',
      'address': '167304 XXX',
      'detail': '167304 XXX YYYYYYYY XXXXXX',
      'province': 'กรุงเทพมหานคร',
      'district': 'ลาดกระบัง',
      'subDistrict': 'ลาดกระบัง',
      'postalCode': '10500',
    },
  ];

  int selectedIndex = 0;

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
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
            const Text('ที่อยู่จัดส่ง', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              // 👉 เพิ่ม 1 แถว สำหรับปุ่ม "เพิ่มที่อยู่" ให้เป็นส่วนหนึ่งของลิสต์ (ตำแหน่งเหมือนภาพ)
              itemCount: addresses.length + 1,
              itemBuilder: (context, index) {
                if (index < addresses.length) {
                  final item = addresses[index];
                  return _buildAddressCard(item, index);
                } else {
                  return _buildAddAddressButton(); // แถวปุ่ม "เพิ่มที่อยู่"
                }
              },
            ),
          ),
          // ปุ่มยืนยัน เต็มความกว้าง ด้านล่างสุด
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001B47),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('ยืนยัน', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, String> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E5E5)), borderRadius: BorderRadius.circular(12), color: Colors.white),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Radio<int>(
            value: index,
            groupValue: selectedIndex,
            activeColor: const Color(0xFF001B47),
            onChanged: (value) {
              setState(() => selectedIndex = value!);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(item['phone']!, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditAddressPage(isEdit: true, address: item)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001B47),
                  minimumSize: const Size(50, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3), // 🔧 ปรับจาก 8 → 3
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('แก้ไข', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE9E9E9),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(50, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3), // 🔧 ปรับให้เหมือนกัน
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('ลบ', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ปุ่ม "เพิ่มที่อยู่" แบบการ์ดขอบอ่อน กึ่งกลาง เหมือนในภาพ
  Widget _buildAddAddressButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE5E5E5)), borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditAddressPage(isEdit: false)));
          },
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: const Text('เพิ่มที่อยู่', style: TextStyle(color: Color(0xFF9381FF), fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      ),
    );
  }
}
