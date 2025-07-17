import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class ShippingRatePage extends StatelessWidget {
  const ShippingRatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('อัตราค่าขนส่ง', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 เฉพาะรูปภาพหัวข้อ
            Image.asset('assets/images/Frame10.png', fit: BoxFit.fitWidth),
            SizedBox(height: 12),
            _buildGrid([
              RateItem(image: 'assets/images/Frame12.png', label: 'ทั่วไป', kg: '38', price: '5,200'),
              RateItem(image: 'assets/images/Frame13.png', label: 'มอก', kg: '50', price: '5,800'),
              RateItem(image: 'assets/images/Frame14.png', label: 'อย', kg: '45', price: '8,800'),
              RateItem(image: 'assets/images/Frame15.png', label: 'พิเศษ/แบรน', kg: '25', price: '-'),
            ]),
            SizedBox(height: 24),
            Image.asset('assets/images/Frame11.png', fit: BoxFit.fitWidth),
            SizedBox(height: 12),
            _buildGrid([
              RateItem(image: 'assets/images/Frame12.png', label: 'ทั่วไป', kg: '38', price: '5,200'),
              RateItem(image: 'assets/images/Frame13.png', label: 'มอก', kg: '50', price: '5,800'),
              RateItem(image: 'assets/images/Frame14.png', label: 'อย', kg: '45', price: '8,800'),
              RateItem(image: 'assets/images/Frame15.png', label: 'พิเศษ/แบรน', kg: '25', price: '-'),
            ]),
          ],
        ),
      ),
    );
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
      height: 140, // 🔸 ควบคุมความสูงให้เท่ากันทุกใบ
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          // 🔹 ส่วนบน: รูปภาพ + label (แบ่งซ้าย/ขวาเท่ากัน)
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 5, child: Center(child: Image.asset(item.image, width: 56, height: 56, fit: BoxFit.fill))),
                Expanded(
                  flex: 5,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(item.label, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTitleTextGridColor)),
                  ),
                ),
              ],
            ),
          ),

          // 🔻 ส่วนล่าง: กิโลกรัม / ประมาณ (แบ่งซ้าย/ขวาเท่ากัน)
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('กิโลกรัม', style: TextStyle(fontSize: 18, color: Colors.black54)),
                        SizedBox(height: 4),
                        Text(item.kg, style: TextStyle(fontSize: 24, color: kSubTitleTextGridColor)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ประมาณ', style: TextStyle(fontSize: 18, color: Colors.black54)),
                        SizedBox(height: 4),
                        Text(item.price, style: TextStyle(fontSize: 24, color: kSubTitleTextGridColor)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
