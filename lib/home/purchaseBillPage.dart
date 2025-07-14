import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class PurchaseBillPage extends StatefulWidget {
  const PurchaseBillPage({super.key});

  @override
  State<PurchaseBillPage> createState() => _PurchaseBillPageState();
}

class _PurchaseBillPageState extends State<PurchaseBillPage> {
  int qty1 = 1;
  int qty2 = 1;
  bool taxChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        title: const Text('บิลสั่งซื้อสินค้า', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 16),
                const Text('รูปแบบการขนส่ง', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('ขนส่งทางเรือ', style: TextStyle(color: Colors.grey)),
                const Divider(height: 32),
                const Text('สินค้าทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildProductSection(),
                const SizedBox(height: 24),
                const Divider(height: 24, color: Colors.orange),
                const Text('หมายเหตุ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('หมายเหตุ หมายเหตุ หมายเหตุ หมายเหตุ หมายเหตุ หมายเหตุ หมายเหตุ'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('คูปองส่วนลด', style: TextStyle(fontWeight: FontWeight.bold)),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: taxChecked,
                      onChanged: (value) {
                        setState(() => taxChecked = value ?? false);
                      },
                    ),
                    const Expanded(child: Text('ออกใบกำกับภาษี 7 %')),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'หากต้องการออกใบกำกับภาษี 7 % กรุณายืนยันสินค้าก่อนทำการชำระเงิน',
                    style: TextStyle(fontSize: 12, color: kTextRedWanningColor),
                  ),
                ),
              ],
            ),
          ),
          // ✅ ด้านล่างสุด สรุปยอดสินค้า ตามภาพจริง
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 แถบอัตราแลกเปลี่ยน
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                alignment: Alignment.centerLeft,
                color: Colors.white,
                child: const Text('อัตราแลกเปลี่ยน  5 หยวนต่อบาท', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
              ),

              // 🔻 ด้านล่างสุด ตามภาพเป๊ะ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: kButtonColor, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      // 🔵 วงกลมมีเลข
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E73B9), // ฟ้าอ่อน
                          shape: BoxShape.circle,
                        ),
                        child: const Text('2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      const SizedBox(width: 12),
                      const Text('สินค้าทั้งหมด', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const Spacer(),
                      const Text('¥110 (฿ 550.00)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),

              // 🔹 แถบสีขาวบาง ๆ ด้านล่างสุด (ไม่กินพื้นที่)
              Container(height: 8, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1688', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildProductItem(
            image: 'assets/images/unsplash1.png',
            name: 'เสื้อแฟนชั่น',
            price: '¥10',
            qty: qty1,
            onAdd: () => setState(() => qty1++),
            onRemove: () => setState(() => qty1 = qty1 > 1 ? qty1 - 1 : 1),
          ),
          const SizedBox(height: 16),
          _buildProductItem(
            image: 'assets/images/unsplash2.png',
            name: 'รองเท้าผ้าใบ',
            price: '¥100',
            qty: qty2,
            onAdd: () => setState(() => qty2++),
            onRemove: () => setState(() => qty2 = qty2 > 1 ? qty2 - 1 : 1),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem({
    required String image,
    required String name,
    required String price,
    required int qty,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(image, width: 64, height: 64, fit: BoxFit.cover)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(name),
              const SizedBox(height: 8),
              Row(children: [_buildTag('M'), const SizedBox(width: 4), _buildTag('สีดำ', filled: true)]),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.remove), onPressed: onRemove),
            Text(qty.toString()),
            IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String text, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? kButtondiableColor : Colors.transparent,
        border: Border.all(color: kButtonColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: kButtonColor)),
    );
  }
}
