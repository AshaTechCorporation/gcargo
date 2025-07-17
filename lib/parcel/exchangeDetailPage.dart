import 'package:flutter/material.dart';

class ExchangeDetailPage extends StatelessWidget {
  final String method; // เช่น "บัญชีธนาคาร", "Alipay", "WeChat Pay"
  final String iconPath;
  final String reference;
  final String cny;
  final String thb;

  const ExchangeDetailPage({super.key, required this.method, required this.iconPath, required this.reference, required this.cny, required this.thb});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('แลกเปลี่ยนเงินบาทเป็นหยวน', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [method == 'บัญชีธนาคาร' ? _buildBankInfoCard() : _buildQRCodeInfoCard(), const SizedBox(height: 16), _buildCostCard()],
        ),
      ),
    );
  }

  Widget _buildBankInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTitle(iconPath, method),
          const SizedBox(height: 12),
          _buildRow('เลขที่บัญชี', reference),
          _buildRow('ชื่อบัญชี', 'xxxxxx xxxxxxx'),
          _buildRow('ชื่อธนาคาร', 'xxxxxxxxxxxxxxxxxxxx'),
          _buildRow('ยอดเงินหยวนที่ต้องการโอน', '$cny ¥', bold: true),
        ],
      ),
    );
  }

  Widget _buildQRCodeInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTitle(iconPath, method),
          const SizedBox(height: 12),
          _buildRow('เบอร์โทรศัพท์', reference),
          const Text('รูปภาพช่องจ่าย', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/qrcode.png', fit: BoxFit.cover)),
          ),
          const SizedBox(height: 12),
          _buildRow('ยอดเงินหยวนที่ต้องการโอน', '$cny ¥', bold: true),
        ],
      ),
    );
  }

  Widget _buildCostCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTitle('assets/icons/dollar-circle.png', 'ค่าใช้จ่าย'),
          const SizedBox(height: 12),
          _buildRow('ยอดเงินหยวนที่ต้องการโอน', '($cny ¥) $thb ฿'),
          _buildRow('ค่าบริการ', '08'),
          _buildRow('รวมราคา', '$thb ฿', bold: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? Colors.black : Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildIconTitle(String iconPath, String title) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF1F1F1)),
          child: Center(child: Image.asset(iconPath, width: 18)),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
    );
  }
}
