import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class ShippingMethodPage extends StatefulWidget {
  const ShippingMethodPage({super.key});

  @override
  State<ShippingMethodPage> createState() => _ShippingMethodPageState();
}

class _ShippingMethodPageState extends State<ShippingMethodPage> {
  String selectedMethod = 'รถเหมาบริษัท';

  final List<String> pickupOptions = ['รถเหมาบริษัท', 'ลูกค้ามารับเอง'];
  final List<String> codFrontOptions = ['KEX EXPRESS', 'FLASH EXPRESS', 'NIM EXPRESS'];
  final List<String> codBackOptions = ['PL EXPRESS', 'KSD', 'ธนาบัย', 'ก้าวเจริญ', 'นิ่มเชียงใหม่สายเหนือ'];

  Widget _buildRadioList(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...options.map((option) {
          return RadioListTile<String>(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(option, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kSubTitleTextGridColor)),
            value: option,
            groupValue: selectedMethod,
            activeColor: const Color(0xFF002A5D),
            onChanged: (value) => setState(() => selectedMethod = value!),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('ขนส่ง', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ที่อยู่จัดส่ง', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Expanded(child: Text('Girati Sukapat  097 123 4567')),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                    _buildRadioList('ขนส่งบริษัท', pickupOptions),
                    _buildRadioList('ขนส่งเก็บเงินต้นทาง', codFrontOptions),
                    _buildRadioList('ขนส่งเก็บเงินปลายทาง', codBackOptions),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFD25F)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/icons/danger.png', width: 20, height: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'บริษัทมีการเรียกเก็บค่าบริการเพิ่มเติม 50 บาทต่อบิล '
                              'ยกเว้นลูกค้ามารับเอง\nค่าบริการนี้ไม่รวมค่าขนส่งจากบริษัทขนส่ง',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  child: const Text('ยืนยัน', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
