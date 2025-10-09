import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class TermsDialog extends StatefulWidget {
  const TermsDialog({super.key});

  @override
  State<TermsDialog> createState() => _TermsDialogState();
}

class _TermsDialogState extends State<TermsDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _hasReachedBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_hasReachedBottom) {
      setState(() {
        _hasReachedBottom = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('เงื่อนไขบริการ', style: TextStyle(fontSize: isPhone(context) ? 22 : 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: Colors.black, size: isPhone(context) ? 24 : 30)),
                ],
              ),
              const SizedBox(height: 4),
              Text('กรุณาอ่านเงื่อนไขในบริการให้ครบถ้วน', style: TextStyle(fontSize: isPhone(context) ? 14 : 18, color: kHintTextColor)),
              const SizedBox(height: 16),

              // 🔹 เงื่อนไขแบบ scroll
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _termsSection('1. การรับสินค้า', [
                        'ลูกค้าต้องแจ้งรายละเอียดสินค้าให้ครบถ้วน (น้ำหนัก, ขนาด, จำนวน, ประเภท)',
                        'ห้ามส่งสินค้าผิดกฎหมาย เช่น วัตถุอันตราย, สารเสพติด, อาวุธ',
                      ]),
                      _termsSection('2. การชำระเงิน', [
                        'ต้องชำระเงินก่อนดำเนินการขนส่ง',
                        'รองรับการโอนผ่านบัญชีธนาคาร หรือ QR พร้อมเพย์',
                        'หากต้องการใบกำกับภาษี กรุณาแจ้งก่อนชำระเงิน',
                      ]),
                      _termsSection('3. การจัดส่ง', [
                        'ระยะเวลาประมาณจากจีนถึงไทย 5–10 วันทำการ',
                        'ไม่รับประกันวันถึง เนื่องจากอาจมีเหตุสุดวิสัย (ด่านศุลกากร, ภัยธรรมชาติ ฯลฯ)',
                      ]),
                      _termsSection('4. ความเสียหายหรือสูญหาย', [
                        'แจ้งเคลมภายใน 3 วันหลังรับของ หากเกิดจากความผิดของบริษัท',
                        'ต้องมีหลักฐานการรับของและภาพสินค้าเพื่อประกอบการเคลม',
                      ]),
                      _termsSection('5. การคืนเงิน', [
                        'คืนเงินเฉพาะกรณีที่เกิดจากความผิดของบริษัท เช่น คิดเงินผิด, ไม่ได้จัดส่ง',
                        'คืนภายใน 7 วันทำการหลังตรวจสอบเสร็จ',
                      ]),
                      _termsSection('6. การเปลี่ยนแปลงข้อมูล', [
                        'สามารถเปลี่ยนแปลงข้อมูลจัดส่งได้ก่อนสินค้าถึงโกดัง',
                        'บริษัทขอสงวนสิทธิ์ไม่รับเปลี่ยนแปลงหลังขึ้นระบบจัดส่ง',
                      ]),
                      _termsSection('7. ความรับผิดชอบของลูกค้า', [
                        'ตรวจสอบข้อมูลพัสดุก่อนยืนยัน',
                        'ให้ข้อมูลชื่อ, ที่อยู่, เบอร์โทรอย่างถูกต้อง',
                        'เข้ารับพัสดุตามเวลาที่กำหนด มิฉะนั้นอาจมีค่าฝากพัสดุ',
                      ]),
                      _termsSection('8. การยอมรับข้อตกลง', ['การใช้บริการถือว่าลูกค้าได้อ่านและยอมรับข้อตกลงนี้แล้ว']),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // 🔹 ปุ่มยอมรับ / ปิด
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _hasReachedBottom ? () => Navigator.pop(context, true) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasReachedBottom ? kButtonColor : kButtondiableColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('ยอมรับเงื่อนไขการบริการ', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kButtonColor,
                        side: const BorderSide(color: kButtonColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('ปิดหน้าต่าง', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Section Helper Widget
class _termsSection extends StatelessWidget {
  final String title;
  final List<String> bullets;

  const _termsSection(this.title, this.bullets);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: isPhone(context) ? 16 : 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(fontSize: isPhone(context) ? 14 : 18)),
                  Expanded(child: Text(b, style: TextStyle(fontSize: isPhone(context) ? 14 : 18))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
