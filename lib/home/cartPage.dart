import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isDeleteMode = false;
  List<bool> selectedItems = [false, false];

  List<Map<String, dynamic>> cartItems = [
    {'image': 'assets/images/unsplash0.png', 'title': 'เสื้อแขนสั้น', 'price': 10, 'size': 'M', 'color': 'สีดำ', 'quantity': 1},
    {'image': 'assets/images/unsplash1.png', 'title': 'รองเท้าบาส', 'price': 100, 'size': 'M', 'color': 'สีฟ้า', 'quantity': 1},
  ];

  void toggleDeleteMode() {
    setState(() {
      isDeleteMode = !isDeleteMode;
      selectedItems = List.filled(cartItems.length, false);
    });
  }

  void removeSelectedItems() {
    setState(() {
      cartItems = [
        for (int i = 0; i < cartItems.length; i++)
          if (!selectedItems[i]) cartItems[i],
      ];
      selectedItems = List.filled(cartItems.length, false);
      isDeleteMode = false;
    });
  }

  Widget buildCartItem(int index) {
    final item = cartItems[index];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDeleteMode)
            Radio<bool>(
              value: true,
              groupValue: selectedItems[index],
              onChanged: (value) {
                setState(() => selectedItems[index] = !selectedItems[index]);
              },
              fillColor: MaterialStateProperty.all(kButtonColor),
            ),
          if (!isDeleteMode) const Icon(Icons.circle_outlined, size: 22),
          const SizedBox(width: 8),
          Image.asset(item['image'], width: 60, height: 60, fit: BoxFit.cover),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¥${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(item['title'], style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    buildLabel(item['size']),
                    const SizedBox(width: 6),
                    buildLabel(item['color']),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => setState(() => item['quantity']++)),
                    Text(item['quantity'].toString()),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed:
                          () => setState(() {
                            if (item['quantity'] > 1) item['quantity']--;
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.grey.shade200),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDeleteMode ? Colors.white : kButtonColor,
            foregroundColor: isDeleteMode ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: isDeleteMode ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
            ),
          ),
          onPressed: () {
            if (isDeleteMode) {
              removeSelectedItems();
            }
          },
          child: Text(isDeleteMode ? 'ลบสินค้า' : '¥0 (฿ 0.00)'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตะกร้าสินค้า', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          isDeleteMode
              ? TextButton(onPressed: toggleDeleteMode, child: const Text('ยกเลิก', style: TextStyle(color: Colors.black)))
              : IconButton(onPressed: toggleDeleteMode, icon: const Icon(Icons.delete_outline, color: Colors.black)),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: cartItems.length, itemBuilder: (_, index) => buildCartItem(index)),
          ),
          buildBottomBar(),
        ],
      ),
    );
  }
}
