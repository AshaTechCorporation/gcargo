import 'package:flutter/material.dart';
import 'package:gcargo/account/addAddressPage.dart';
import 'package:gcargo/constants.dart';

class AddressListPage extends StatelessWidget {
  const AddressListPage({super.key});

  final List<Map<String, String>> addresses = const [
    {
      'name': 'Girati Sukapat',
      'phone': '097 123 4567',
      'address': '167304 รายละเอียดที่อยู่จัดส่ง รายละเอียดที่อยู่จัดส่ง รายละเอียดที่อยู่จัดส่ง รายละเอียดที่อยู่จัดส่ง',
    },
    {
      'name': 'Girati Sukapat',
      'phone': '097 123 4567',
      'address': '167304 รายละเอียดที่อยู่จัดส่ง รายละเอียดที่อยู่จัดส่ง รายละเอียดที่อยู่จัดส่ง รายละเอียดที่อยู่จัดส่ง',
    },
  ];

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
            Text('ที่อยู่จัดส่ง', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final item = addresses[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Header row
                      Row(
                        children: [
                          Image.asset('assets/icons/VectorPerson.png', width: 32),
                          SizedBox(width: 8),
                          Expanded(child: Text(item['name']!, style: TextStyle(fontWeight: FontWeight.bold))),
                          Text(item['phone']!),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(item['address']!),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kButtonColor,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('แก้ไข', style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('ลบ'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddAddressPage()));
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('เพิ่มที่อยู่', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
