import 'package:flutter/material.dart';

class DocumentDetailPage extends StatefulWidget {
  const DocumentDetailPage({super.key});

  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('เลขที่เอกสาร X2504290002', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1E3C72),
          tabs: const [Tab(text: 'ข้อมูลเอกสาร'), Tab(text: 'ข้อมูลการคืนเงิน')],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [_buildDocumentInfoTab(), _buildRefundInfoTab()]),
    );
  }

  Widget _buildDocumentInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🔴 แจ้งเตือน
          _warningBox(
            'ต้องชำระค่าขนส่งรวมก่อนสินค้าถึงที่โกดังสำหรับส่งต่อไทย',

            'assets/icons/info-circle.png',
            background: const Color(0xFFFFEEEE),
            iconColor: Colors.red,
          ),

          const SizedBox(height: 12),

          // 🟡 แจ้งเตือนเอกสาร
          _warningBox(
            'เอกสารนี้จะจัดส่งให้ทางไลน์ภายใน 24 ชั่วโมงหลังจากชำระเงินสำเร็จ',
            'assets/icons/danger.png',
            background: const Color(0xFFFFF6D9),
            iconColor: Colors.orange,
          ),

          const SizedBox(height: 16),

          // 💰 กล่องค่าใช้จ่าย
          _sectionCard(
            children: const [
              _DetailRow(label: 'รวมค่าขนส่งจีนไทย', value: '1,060.00฿'),
              _DetailRow(label: 'ค่าบริการ QC', value: '0฿'),
              _DetailRow(label: 'ค่าตัดไม้', value: '0฿'),
              _DetailRow(label: 'ค่าบริการ', value: '50฿'),
              _DetailRow(label: 'ค่าขนส่งในไทย', value: '0฿'),
              _DetailRow(label: 'ส่วนลด', value: '0฿'),
              Divider(height: 24),
              _DetailRow(label: 'รวมราคาทั้งสิ้น', value: '1,110.00฿', bold: true),
              _DetailRow(label: 'การชำระเงิน', value: 'QR พร้อมเพย์'),
              _DetailRow(label: 'หักภาษี ณ ที่จ่าย 1%', value: '', showCheck: true),
            ],
          ),

          const SizedBox(height: 16),

          // 🔢 รายการขนส่ง
          _sectionCard(
            title: 'เลขขนส่งจีน',
            children: [
              _shippingRow('00035', '660.00฿'),
              _shippingRow('00034', '100.00฿'),
              _shippingRow('00033', '100.00฿'),
              _shippingRow('00032', '100.00฿'),
              _shippingRow('00031', '100.00฿'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRefundInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _DetailRow(label: 'คืนเงินให้', value: 'บัญชีธนาคาร'),
          _DetailRow(label: 'วันที่คืนเงิน', value: '01/07/2025'),
          _DetailRow(label: 'จำนวนยอดที่คืน', value: '1,110.00฿'),
          SizedBox(height: 16),
          Text('ไฟล์', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Image(image: AssetImage('assets/images/image101.png'), width: 120),
        ],
      ),
    );
  }

  Widget _warningBox(String text, String iconPath, {required Color background, required Color iconColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Image.asset(iconPath, width: 18, color: iconColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _sectionCard({String? title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE0E0E0)), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 12)],
          ...children,
        ],
      ),
    );
  }

  Widget _shippingRow(String code, String price) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(code, style: const TextStyle(fontSize: 14)), Text(price, style: const TextStyle(fontSize: 14))],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool showCheck;

  const _DetailRow({required this.label, required this.value, this.bold = false, this.showCheck = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.grey))),
          if (showCheck)
            const Icon(Icons.check_circle, size: 18, color: Colors.green)
          else
            Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}
