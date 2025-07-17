import 'package:flutter/material.dart';
import 'package:gcargo/parcel/exchangeDetailPage.dart';

class ExchangeStatusPage extends StatefulWidget {
  const ExchangeStatusPage({super.key});

  @override
  State<ExchangeStatusPage> createState() => _ExchangeStatusPageState();
}

class _ExchangeStatusPageState extends State<ExchangeStatusPage> {
  String selectedStatus = 'ทั้งหมด';

  final List<String> statusList = ['ทั้งหมด', 'รอชำระเงิน', 'กำลังดำเนินการ', 'สำเร็จ', 'ยกเลิก'];
  final TextEditingController _dateController = TextEditingController(text: '1/01/2024 - 01/07/2025');

  final List<Map<String, dynamic>> exchanges = [
    {
      'date': '02/07/2025',
      'method': 'บัญชีธนาคาร',
      'icon': 'assets/icons/bank_icon.png',
      'ref': '0000000000',
      'status': 'กำลังดำเนินการ',
      'cny': '100',
      'thb': '500',
    },
    {
      'date': '02/07/2025',
      'method': 'Alipay',
      'icon': 'assets/icons/alipay_icon.png',
      'ref': '0000000000',
      'status': 'รอชำระเงิน',
      'cny': '150',
      'thb': '750',
    },
    {
      'date': '02/07/2025',
      'method': 'WeChat Pay',
      'icon': 'assets/icons/wechat_icon.png',
      'ref': '0000000000',
      'status': 'สำเร็จ',
      'cny': '200',
      'thb': '1000',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var item in exchanges) {
      if (selectedStatus != 'ทั้งหมด' && item['status'] != selectedStatus) continue;
      grouped.putIfAbsent(item['date'], () => []).add(item);
    }

    final Map<String, int> statusCounts = {
      for (var status in statusList) status: exchanges.where((e) => status == 'ทั้งหมด' || e['status'] == status).length,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('แลกเปลี่ยนเงินบาทเป็นหยวน', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          // 🔹 ช่องวันที่แบบ TextField
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextFormField(
              controller: _dateController,
              readOnly: false,
              decoration: InputDecoration(
                prefixIcon: Padding(padding: const EdgeInsets.all(12.0), child: Image.asset('assets/icons/calendar_icon.png', width: 20)),
                hintText: 'เลือกช่วงวันที่',
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
              onTap: () {
                // TODO: picker date
              },
            ),
          ),

          // 🔹 แถบสถานะ
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: statusList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final status = statusList[i];
                final isSelected = status == selectedStatus;
                final count = statusCounts[status] ?? 0;

                return GestureDetector(
                  onTap: () => setState(() => selectedStatus = status),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF246BFD) : Colors.white,
                      border: Border.all(color: const Color(0xFF246BFD)),
                      borderRadius: BorderRadius.circular(5), // มุมลดลง
                    ),
                    child: Row(
                      children: [
                        Text(status, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF246BFD), fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('$count', style: TextStyle(fontSize: 12, color: isSelected ? const Color(0xFF246BFD) : Colors.black)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔹 รายการ
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children:
                  grouped.entries.map((e) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...e.value.map((item) => _buildCard(item)),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        if (item['method'] == 'บัญชีธนาคาร') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ExchangeDetailPage(
                    method: 'บัญชีธนาคาร', // หรือ 'บัญชีธนาคาร', 'WeChat Pay'
                    iconPath: 'assets/icons/bank_icon.png', // เปลี่ยนตามประเภท
                    reference: '0000000000',
                    cny: '100',
                    thb: '500.00',
                  ),
            ),
          );
        } else if (item['method'] == 'Alipay') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ExchangeDetailPage(
                    method: 'Alipay', // หรือ 'บัญชีธนาคาร', 'WeChat Pay'
                    iconPath: 'assets/icons/alipay_icon.png', // เปลี่ยนตามประเภท
                    reference: '0000000000',
                    cny: '100',
                    thb: '500.00',
                  ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ExchangeDetailPage(
                    method: 'WeChat Pay', //
                    iconPath: 'assets/icons/wechat_icon.png', // เปลี่ยนตามประเภท
                    reference: '0000000000',
                    cny: '100',
                    thb: '500.00',
                  ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Row บนสุด ไอคอน + ชื่อ + สถานะ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF1F1F1)),
                      child: Center(child: Image.asset(item['icon'], width: 20, height: 20)),
                    ),
                    const SizedBox(width: 8),
                    Text(item['method'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Text(item['status'], style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),

            // 🔹 Ref
            Text(item['method'] == 'บัญชีธนาคาร' ? 'เลขที่บัญชี' : 'เบอร์โทรศัพท์', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(item['ref'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),

            const SizedBox(height: 12),

            // 🔹 แถวข้อมูลยอดเงิน
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ยอดเงินหยวนที่ต้องการโอน', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('${item['cny']} ¥', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('ยอดเงินที่ต้องชำระ:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('${item['thb']} ฿', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
