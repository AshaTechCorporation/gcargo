import 'package:flutter/material.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:get/get.dart';

class ExchangeDetailPage extends StatefulWidget {
  final String method; // เช่น "บัญชีธนาคาร", "Alipay", "WeChat Pay"
  final String iconPath;
  final String reference; // payment ID
  final String cny;
  final String thb;

  const ExchangeDetailPage({super.key, required this.method, required this.iconPath, required this.reference, required this.cny, required this.thb});

  @override
  State<ExchangeDetailPage> createState() => _ExchangeDetailPageState();
}

class _ExchangeDetailPageState extends State<ExchangeDetailPage> {
  final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    // เรียก API เมื่อเข้าหน้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentId = int.tryParse(widget.reference);
      if (paymentId != null) {
        homeController.getAlipayPaymentById(paymentId);
      }
    });
  }

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
      body: Obx(() {
        final payment = homeController.alipayPaymentById.value;

        // คำนวณจำนวนเงินตามอัตราแลกเปลี่ยน
        final thbAmount = double.tryParse(widget.thb) ?? 0.0;
        final alipayRate = homeController.exchangeRate['alipay_topup_rate'];
        final exchangeRate = double.tryParse(alipayRate?.toString() ?? '5.0') ?? 5.0;
        final cnyAmount = thbAmount / exchangeRate;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              widget.method == 'บัญชีธนาคาร'
                  ? _buildBankInfoCard(payment, cnyAmount, thbAmount)
                  : _buildQRCodeInfoCard(payment, cnyAmount, thbAmount),
              const SizedBox(height: 16),
              _buildCostCard(payment, cnyAmount, thbAmount),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBankInfoCard(dynamic payment, double cnyAmount, double thbAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTitle(widget.iconPath, widget.method),
          const SizedBox(height: 12),
          _buildRow('เลขที่บัญชี', payment?.id?.toString() ?? widget.reference),
          _buildRow('ชื่อบัญชี', 'xxxxxx xxxxxxx'),
          _buildRow('ชื่อธนาคาร', 'xxxxxxxxxxxxxxxxxxxx'),
          _buildRow('ยอดเงินหยวนที่ต้องการโอน', '${cnyAmount.toStringAsFixed(2)} ¥', bold: true),
        ],
      ),
    );
  }

  Widget _buildQRCodeInfoCard(dynamic payment, double cnyAmount, double thbAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTitle(widget.iconPath, widget.method),
          const SizedBox(height: 12),
          _buildRow('เบอร์โทรศัพท์', payment?.phone ?? widget.reference),
          const Text('รูปภาพช่องจ่าย', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  payment?.image_qr_code != null && payment!.image_qr_code!.isNotEmpty
                      ? Image.network(
                        payment.image_qr_code!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/qrcode.png', fit: BoxFit.cover),
                      )
                      : Image.asset('assets/images/qrcode.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
          _buildRow('ยอดเงินหยวนที่ต้องการโอน', '${cnyAmount.toStringAsFixed(2)} ¥', bold: true),
        ],
      ),
    );
  }

  Widget _buildCostCard(dynamic payment, double cnyAmount, double thbAmount) {
    final serviceFee = payment?.fee ?? '08'; // ใช้ fee จาก Payment model
    final serviceFeeAmount = double.tryParse(serviceFee) ?? 8.0;
    final totalAmount = thbAmount + serviceFeeAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTitle('assets/icons/dollar-circle.png', 'ค่าใช้จ่าย'),
          const SizedBox(height: 12),
          _buildRow('ยอดเงินหยวนที่ต้องการโอน', '(${cnyAmount.toStringAsFixed(2)} ¥) ${thbAmount.toStringAsFixed(2)} ฿'),
          _buildRow('ค่าบริการ', '${serviceFeeAmount.toStringAsFixed(2)} ฿'),
          _buildRow('รวมราคา', '${totalAmount.toStringAsFixed(2)} ฿', bold: true),
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
