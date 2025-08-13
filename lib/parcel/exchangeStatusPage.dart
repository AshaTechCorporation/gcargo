import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/parcel/exchangeDetailPage.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/utils/number_formatter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExchangeStatusPage extends StatefulWidget {
  const ExchangeStatusPage({super.key});

  @override
  State<ExchangeStatusPage> createState() => _ExchangeStatusPageState();
}

class _ExchangeStatusPageState extends State<ExchangeStatusPage> {
  String selectedStatus = 'ทั้งหมด';
  final HomeController homeController = Get.put(HomeController());

  final List<String> statusList = ['ทั้งหมด', 'รอชำระเงิน', 'สำเร็จ'];
  final TextEditingController _dateController = TextEditingController();

  // Date filter variables
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _dateController.text = 'เลือกช่วงวันที่'; // ไม่ตั้งค่าเริ่มต้น

    // ไม่ตั้งค่าวันที่เริ่มต้น - ให้ผู้ใช้เลือกเอง
    startDate = null;
    endDate = null;

    // เรียก API เมื่อเข้าหน้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.getAlipayPaymentFromAPI();
      homeController.getExchangeRateFromAPI();
      homeController.getServiceFeeFromAPI();
    });
  }

  // Parse date string to DateTime for filtering
  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Try different date formats
      try {
        // Try dd/MM/yyyy format
        return DateFormat('dd/MM/yyyy').parse(dateString);
      } catch (e2) {
        try {
          // Try yyyy-MM-dd format
          return DateFormat('yyyy-MM-dd').parse(dateString);
        } catch (e3) {
          print('Cannot parse date: $dateString');
          return null;
        }
      }
    }
  }

  // ฟังก์ชั่นสำหรับเลือกช่วงวันที่
  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: startDate != null && endDate != null ? DateTimeRange(start: startDate!, end: endDate!) : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: kButtonColor, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        _dateController.text = '${DateFormat('dd/MM/yyyy').format(picked.start)} - ${DateFormat('dd/MM/yyyy').format(picked.end)}';

        // Debug: แสดงวันที่ที่เลือก
        print('🗓️ เลือกช่วงวันที่: $startDate ถึง $endDate');
      });
    }
  }

  // แปลงสถานะจาก API เป็นสถานะที่แสดงใน UI
  String _getDisplayStatus(String apiStatus) {
    switch (apiStatus) {
      case 'awaiting_payment':
        return 'รอชำระเงิน';
      case 'completed':
        return 'สำเร็จ';
      default:
        return 'รอชำระเงิน';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final payments = homeController.alipayPayment;

      // กรองข้อมูลตามสถานะและวันที่ที่เลือก
      List<dynamic> filteredPayments = List.from(payments);

      // ฟิลเตอร์ตามช่วงวันที่ (เฉพาะเมื่อผู้ใช้เลือกแล้ว)
      if (startDate != null && endDate != null) {
        print('🔍 กำลังฟิลเตอร์ตามวันที่: $startDate ถึง $endDate');
        print('📊 จำนวนรายการก่อนฟิลเตอร์: ${filteredPayments.length}');

        filteredPayments =
            filteredPayments.where((payment) {
              final paymentDateStr = payment.created_at?.toString();

              print('📅 ตรวจสอบรายการ: created_at="$paymentDateStr"');

              if (paymentDateStr == null || paymentDateStr.isEmpty) {
                print('❌ ไม่มีวันที่');
                return false;
              }

              final paymentDate = _parseDate(paymentDateStr);
              if (paymentDate == null) {
                print('❌ ไม่สามารถแปลงวันที่: $paymentDateStr');
                return false;
              }

              // ตรวจสอบว่าวันที่รายการอยู่ในช่วงที่เลือก
              final startOfDay = DateTime(startDate!.year, startDate!.month, startDate!.day);
              final endOfDay = DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59);

              final isInRange =
                  paymentDate.isAfter(startOfDay.subtract(const Duration(days: 1))) && paymentDate.isBefore(endOfDay.add(const Duration(days: 1)));

              print('✅ วันที่รายการ: $paymentDate, อยู่ในช่วง: $isInRange');

              return isInRange;
            }).toList();

        print('📊 จำนวนรายการหลังฟิลเตอร์: ${filteredPayments.length}');
      } else {
        print('📅 ไม่ได้เลือกช่วงวันที่ - แสดงรายการทั้งหมด');
      }

      // ฟิลเตอร์ตามสถานะ
      if (selectedStatus != 'ทั้งหมด') {
        filteredPayments =
            filteredPayments.where((payment) {
              final displayStatus = _getDisplayStatus(payment.status ?? '');
              return displayStatus == selectedStatus;
            }).toList();
      }

      // จัดกลุ่มตามวันที่
      final grouped = <String, List<dynamic>>{};
      for (var payment in filteredPayments) {
        final date = payment.created_at?.toString().split(' ')[0] ?? 'ไม่ระบุวันที่';
        grouped.putIfAbsent(date, () => []).add(payment);
      }

      // นับจำนวนตามสถานะ (ใช้ข้อมูลทั้งหมดไม่ใช่ข้อมูลที่ถูกฟิลเตอร์)
      final Map<String, int> statusCounts = {
        'ทั้งหมด': payments.length,
        'รอชำระเงิน': payments.where((p) => _getDisplayStatus(p.status ?? '') == 'รอชำระเงิน').length,
        'สำเร็จ': payments.where((p) => _getDisplayStatus(p.status ?? '') == 'สำเร็จ').length,
      };

      return Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: const Text('แลกเปลี่ยนเงินบาทเป็นหยวน', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        ),
        body: Column(
          children: [
            // 🔹 ช่องวันที่แบบ TextField
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: Padding(padding: const EdgeInsets.all(12.0), child: Image.asset('assets/icons/calendar_icon.png', width: 20)),
                  hintText: 'เลือกช่วงวันที่',
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                onTap: _selectDateRange,
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF427D9D) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF427D9D)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            status,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? Colors.white : const Color(0xFF427D9D)),
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 6),
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: isSelected ? Colors.white : const Color(0xFF427D9D),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? const Color(0xFF427D9D) : Colors.white,
                                ),
                              ),
                            ),
                          ],
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
                children: () {
                  // เรียงวันที่ล่าสุดขึ้นก่อน (descending order)
                  final sortedEntries = grouped.entries.toList();
                  sortedEntries.sort((a, b) {
                    try {
                      final dateA = DateTime.parse(a.key);
                      final dateB = DateTime.parse(b.key);
                      return dateB.compareTo(dateA); // วันที่ล่าสุดก่อน
                    } catch (e) {
                      // ถ้า parse วันที่ไม่ได้ ให้เรียงตาม string
                      return b.key.compareTo(a.key);
                    }
                  });

                  return sortedEntries.map((e) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        ...e.value.map((payment) => _buildPaymentCard(payment)),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList();
                }(),
              ),
            ),
          ],
        ),
      );
    }); // ปิด Obx
  }

  Widget _buildPaymentCard(dynamic payment) {
    final displayStatus = _getDisplayStatus(payment.status ?? '');
    final method = payment.transaction ?? 'alipay';
    final iconPath = method == 'alipay' ? 'assets/icons/alipay_icon.png' : 'assets/icons/wechat_icon.png';
    final methodName = method == 'alipay' ? 'Alipay' : 'WeChat Pay';

    // คำนวณจำนวนเงินตามอัตราแลกเปลี่ยน
    // payment.amount เป็นเงินบาท ต้องแปลงเป็นหยวน
    final thbAmount = double.tryParse(payment.amount?.toString() ?? '0') ?? 0.0;
    final alipayRate = homeController.exchangeRate['alipay_topup_rate'];
    final exchangeRate = double.tryParse(alipayRate?.toString() ?? '5.0') ?? 5.0; // default rate
    final cnyAmount = thbAmount / exchangeRate; // บาท ÷ อัตราแลกเปลี่ยน = หยวน

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ExchangeDetailPage(
                  method: methodName,
                  iconPath: iconPath,
                  reference: payment.id?.toString() ?? '0',
                  cny: NumberFormatter.formatNumber(cnyAmount),
                  thb: payment.amount?.toString() ?? '0',
                ),
          ),
        );
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
                      child: Center(child: Image.asset(iconPath, width: 20, height: 20)),
                    ),
                    const SizedBox(width: 8),
                    Text(methodName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Text(displayStatus, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),

            // 🔹 Ref
            Text('เบอร์โทรศัพท์', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(payment.phone ?? 'ไม่ระบุ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

            const SizedBox(height: 12),

            // 🔹 แถวข้อมูลยอดเงิน
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ยอดเงินหยวนที่ต้องการโอน', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(NumberFormatter.formatCNY(cnyAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('ยอดเงินที่ต้องชำระ:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormatter.formatTHB(thbAmount),
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
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
