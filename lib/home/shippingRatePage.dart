import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/utils/number_formatter.dart';
import 'package:get/get.dart';

class ShippingRatePage extends StatefulWidget {
  const ShippingRatePage({super.key});

  @override
  State<ShippingRatePage> createState() => _ShippingRatePageState();
}

class _ShippingRatePageState extends State<ShippingRatePage> {
  final HomeController homeController = Get.put(HomeController());
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'shipping_rate': 'อัตราค่าขนส่ง',
        'land_transport': 'ขนส่งทางรถ',
        'sea_transport': 'ขนส่งทางเรือ',
        'weight_kg': 'น้ำหนัก (กก.)',
        'price_cbm': 'ราคา/ลบ.ม',
        'baht': 'บาท',
        'loading': 'กำลังโหลด...',
        'no_data': 'ไม่มีข้อมูล',
      },
      'en': {
        'shipping_rate': 'Shipping Rate',
        'land_transport': 'Land Transport',
        'sea_transport': 'Sea Transport',
        'weight_kg': 'Weight (kg)',
        'price_cbm': 'Price/CBM',
        'baht': 'Baht',
        'loading': 'Loading...',
        'no_data': 'No Data',
      },
      'zh': {
        'shipping_rate': '运费',
        'land_transport': '陆运',
        'sea_transport': '海运',
        'weight_kg': '重量 (公斤)',
        'price_cbm': '价格/立方米',
        'baht': '泰铢',
        'loading': '加载中...',
        'no_data': '无数据',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    // Call getRateShipFromAPI when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.getRateShipFromAPI();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(getTranslation('shipping_rate'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 24)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        ),
        body: Obx(() {
          // Separate data by vehicle type
          List<RateItem> truckRateItems =
              homeController.rateShip.where((rateShip) => rateShip.vehicle?.toLowerCase() == 'car' || rateShip.vehicle?.toLowerCase() == 'รถ').map((
                rateShip,
              ) {
                return RateItem(
                  image: _getImageByType(rateShip.type ?? ''),
                  label: rateShip.name ?? '',
                  kg: NumberFormatter.formatNumber(rateShip.kg, decimalPlaces: 0),
                  price: NumberFormatter.formatNumber(rateShip.cbm, decimalPlaces: 0),
                );
              }).toList();

          List<RateItem> shipRateItems =
              homeController.rateShip.where((rateShip) => rateShip.vehicle?.toLowerCase() == 'ship' || rateShip.vehicle?.toLowerCase() == 'เรือ').map(
                (rateShip) {
                  return RateItem(
                    image: _getImageByType(rateShip.type ?? ''),
                    label: rateShip.name ?? '',
                    kg: NumberFormatter.formatNumber(rateShip.kg, decimalPlaces: 0),
                    price: NumberFormatter.formatNumber(rateShip.cbm, decimalPlaces: 0),
                  );
                },
              ).toList();

          // Use API data if available, otherwise use mock data
          List<RateItem> firstSectionItems = truckRateItems.isNotEmpty ? truckRateItems : [];

          List<RateItem> secondSectionItems = shipRateItems.isNotEmpty ? shipRateItems : [];

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔷 รูปภาพหัวข้อ section แรก (รถ)
                Image.asset('assets/images/Frame10.png', fit: BoxFit.fitWidth),
                SizedBox(height: 12),
                _buildGrid(firstSectionItems),
                SizedBox(height: 24),
                // 🔷 รูปภาพหัวข้อ section สอง (เรือ)
                Image.asset('assets/images/Frame11.png', fit: BoxFit.fitWidth),
                SizedBox(height: 12),
                _buildGrid(secondSectionItems),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Helper method to map API type to image
  String _getImageByType(String type) {
    switch (type.toLowerCase()) {
      case 'general':
      case 'ทั่วไป':
        return 'assets/images/Frame12.png';
      case 'mog':
      case 'มอก':
        return 'assets/images/Frame13.png';
      case 'fda':
      case 'อย':
        return 'assets/images/Frame14.png';
      case 'special':
      case 'พิเศษ':
      case 'แบรนด์':
        return 'assets/images/Frame15.png';
      default:
        return 'assets/images/Frame12.png';
    }
  }

  Widget _buildGrid(List<RateItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.97),
      itemBuilder: (context, index) {
        return _buildCardItem(items[index]);
      },
    );
  }

  Widget _buildCardItem(RateItem item) {
    return Container(
      height: 140, // 🔸 เพิ่มความสูงเพื่อป้องกัน overflow
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 ส่วนบน: รูปภาพ + label (แบ่งซ้าย/ขวาเท่ากัน)
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 5, child: Center(child: Image.asset(item.image, width: 50, height: 50, fit: BoxFit.fill))),
                  Expanded(
                    flex: 5,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.label,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTitleTextGridColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔻 ส่วนล่าง: กิโลกรัม / ราคา (แบ่งเป็น 2 แถว)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // แถว label
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          getTranslation('weight_kg'),
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          getTranslation('price_cbm'),
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  // แถว value
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.kg,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: kSubTitleTextGridColor),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.price,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: kSubTitleTextGridColor),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RateItem {
  final String image;
  final String label;
  final String kg;
  final String price;

  RateItem({required this.image, required this.label, required this.kg, required this.price});
}
