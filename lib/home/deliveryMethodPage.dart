import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class DeliveryMethodPage extends StatefulWidget {
  const DeliveryMethodPage({super.key});

  @override
  State<DeliveryMethodPage> createState() => _DeliveryMethodPageState();
}

class _DeliveryMethodPageState extends State<DeliveryMethodPage> {
  int? selectedIndex;

  final List<String> deliveryOptions = ['ขนส่งทางรถ', 'ขนส่งทางเรือ'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('รูปแบบการขนส่ง', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: Colors.grey.shade300)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: deliveryOptions.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade300),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(deliveryOptions[index], style: const TextStyle(fontSize: 16)),
                  trailing: Radio<int>(
                    value: index,
                    groupValue: selectedIndex,
                    onChanged: (value) {
                      setState(() => selectedIndex = value);
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                );
              },
            ),
          ),
          // ✅ ปุ่มยืนยัน
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade300))),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Navigator.pop(context, selectedIndex);
                },
                style: ElevatedButton.styleFrom(backgroundColor: kButtonColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('ยืนยัน', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
