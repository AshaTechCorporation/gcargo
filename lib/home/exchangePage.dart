import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  int selectedMethod = 0;

  final List<String> paymentMethods = ['บัญชีธนาคาร', 'Alipay', 'WeChat Pay'];
  final List<String> icons = ['assets/icons/bank_icon.png', 'assets/icons/alipay_icon.png', 'assets/icons/wechat_icon.png'];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('แลกเปลี่ยนเงินบาทเป็นหยวน', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ยอดเงินหยวนที่ต้องการโอน'),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: size.width * 0.6,
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'กรอกยอดเงินหยวน', border: InputBorder.none),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: size.width * 0.26,
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: kBackgroundTextColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('¥', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('เลือกช่องทางการชำระเงิน'),
            SizedBox(height: 12),
            ...List.generate(paymentMethods.length, (index) {
              return GestureDetector(
                onTap: () => setState(() => selectedMethod = index),
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selectedMethod == index ? Colors.blue : Colors.grey.shade300, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Image.asset(icons[index], width: 28, height: 28),
                      SizedBox(width: 12),
                      Expanded(child: Text(paymentMethods[index], style: TextStyle(fontSize: 16))),
                      Radio(value: index, groupValue: selectedMethod, onChanged: (_) => setState(() => selectedMethod = index)),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: 16),
            _buildInputField('เบอร์โทรศัพท์'),
            SizedBox(height: 12),
            _buildInputField('เลขบัญชี'),
            SizedBox(height: 12),
            _buildInputField('ชื่อบัญชี'),

            if (selectedMethod == 1 || selectedMethod == 2) ...[
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Image.asset('assets/icons/cl11.png', width: 36, height: 36),
                          SizedBox(height: 8),
                          Text('อัปโหลดรูปภาพ QR Code', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('รองรับไฟล์รูปภาพ JPG, PNG, PDF เท่านั้น', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: BorderSide(color: Colors.grey.shade400),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onPressed: () {},
                            child: Text('เลือกไฟล์'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ✅ แจ้งเตือนนี้ต้องอยู่นอกเงื่อนไข เพื่อแสดงตลอด
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFFFF5E0),
                border: Border.all(color: Color(0xFFFFC107)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Image.asset('assets/icons/danger.png', width: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ช่วงเวลาที่สามารถทำธุรกรรม กรุณาดำเนินการวันจันทร์ - เสาร์ ในระหว่าง 8.00 - 17.00 น.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
            Row(
              children: [
                Text('อัตราแลกเปลี่ยน ', style: TextStyle(color: Colors.black54)),
                Text('5 บาทต่อหยวน', style: TextStyle(color: Colors.blue.shade700)),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E3C72), padding: EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {},
                child: Text('ชำระเงิน', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, {TextEditingController? controller, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: const InputDecoration(border: InputBorder.none, hintText: ''),
          ),
        ),
      ],
    );
  }
}
