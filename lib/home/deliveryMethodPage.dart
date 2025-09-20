import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:get/get.dart';

class DeliveryMethodPage extends StatefulWidget {
  const DeliveryMethodPage({super.key});

  @override
  State<DeliveryMethodPage> createState() => _DeliveryMethodPageState();
}

class _DeliveryMethodPageState extends State<DeliveryMethodPage> {
  int? selectedIndex;
  Map<String, dynamic> selectedOption = {};
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'delivery_method': 'รูปแบบการขนส่ง',
        'shipping_method': 'วิธีการจัดส่ง',
        'land_transport': 'ขนส่งทางรถ',
        'sea_transport': 'ขนส่งทางเรือ',
        'air_transport': 'ขนส่งทางอากาศ',
        'confirm': 'ยืนยัน',
        'select_method': 'เลือกวิธีการจัดส่ง',
        'fast_delivery': 'จัดส่งเร็ว',
        'standard_delivery': 'จัดส่งมาตรฐาน',
        'economy_delivery': 'จัดส่งประหยัด',
      },
      'en': {
        'delivery_method': 'Delivery Method',
        'shipping_method': 'Shipping Method',
        'land_transport': 'Land Transport',
        'sea_transport': 'Sea Transport',
        'air_transport': 'Air Transport',
        'confirm': 'Confirm',
        'select_method': 'Select Shipping Method',
        'fast_delivery': 'Fast Delivery',
        'standard_delivery': 'Standard Delivery',
        'economy_delivery': 'Economy Delivery',
      },
      'zh': {
        'delivery_method': '配送方式',
        'shipping_method': '运输方式',
        'land_transport': '陆运',
        'sea_transport': '海运',
        'air_transport': '空运',
        'confirm': '确认',
        'select_method': '选择配送方式',
        'fast_delivery': '快速配送',
        'standard_delivery': '标准配送',
        'economy_delivery': '经济配送',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  // Original data for functionality (never changes)
  final List<Map<String, dynamic>> originalDeliveryOptions = [
    {'id': 1, 'name': 'ขนส่งทางรถ', 'nameEng': 'car'},
    {'id': 2, 'name': 'ขนส่งทางเรือ', 'nameEng': 'Ship'},
  ];

  // Display data with translations
  List<Map<String, dynamic>> get displayDeliveryOptions => [
    {'id': 1, 'name': getTranslation('land_transport'), 'nameEng': 'car', 'originalName': 'ขนส่งทางรถ'},
    {'id': 2, 'name': getTranslation('sea_transport'), 'nameEng': 'Ship', 'originalName': 'ขนส่งทางเรือ'},
  ];

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    selectedIndex = 0;
    selectedOption = originalDeliveryOptions[0]; // Use original data for functionality
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(getTranslation('delivery_method'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: Colors.grey.shade300)),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: displayDeliveryOptions.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade300),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(displayDeliveryOptions[index]['name'], style: const TextStyle(fontSize: 16)),
                    trailing: Radio<int>(
                      value: index,
                      groupValue: selectedIndex,
                      onChanged: (value) {
                        setState(() {
                          selectedIndex = value;
                          // Always use original data for functionality
                          selectedOption = originalDeliveryOptions[value!];
                        });
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  );
                },
              ),
            ),
            // ✅ ปุ่มยืนยัน
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, selectedOption);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kButtonColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(getTranslation('confirm'), style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
