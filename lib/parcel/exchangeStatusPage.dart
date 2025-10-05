import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/parcel/exchangeDetailPage.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/utils/number_formatter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExchangeStatusPage extends StatefulWidget {
  const ExchangeStatusPage({super.key});

  @override
  State<ExchangeStatusPage> createState() => _ExchangeStatusPageState();
}

class _ExchangeStatusPageState extends State<ExchangeStatusPage> {
  late LanguageController languageController;
  String selectedStatus = 'all';
  final HomeController homeController = Get.put(HomeController());
  final TextEditingController _dateController = TextEditingController();

  // Date filter variables
  DateTime? startDate;
  DateTime? endDate;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'exchange_status': 'สถานะ',
        'all': 'ทั้งหมด',
        'pending_payment': 'รอตรวจสอบ',
        'completed': 'สำเร็จ',
        'select_date_range': 'เลือกช่วงวันที่',
        'search_order': 'ค้นหาเลขที่ออเดอร์',
        'no_exchanges_found': 'ไม่พบรายการ',
        'no_exchanges_status': 'ไม่มีรายการในสถานะ',
        'exchanges_will_show_here': 'เมื่อคุณแลกเงิน รายการจะแสดงที่นี่',
        'order_number': 'เลขที่ออเดอร์',
        'exchange_rate': 'อัตราแลกเปลี่ยน',
        'service_fee': 'ค่าบริการ',
        'total_amount': 'จำนวนเงินรวม',
        'yuan': 'หยวน',
        'baht': 'บาท',
        'view_details': 'ดูรายละเอียด',
        'try_again': 'ลองใหม่',
        'loading': 'กำลังโหลด...',
        'error': 'เกิดข้อผิดพลาด',
        'phone_number': 'เบอร์โทรศัพท์',
        'not_specified': 'ไม่ระบุ',
        'yuan_amount_to_transfer': 'ยอดเงินหยวนที่ต้องการโอน',
        'amount_to_pay': 'ยอดเงินที่ต้องชำระ:',
        'account_gcargo_a': 'บัญชี G-cargo-A',
        'account_gcargo_w': 'บัญชี G-cargo-W',
      },
      'en': {
        'exchange_status': 'Exchange Status',
        'all': 'All',
        'pending_payment': 'Pending Payment',
        'completed': 'Completed',
        'select_date_range': 'Select Date Range',
        'search_order': 'Search Order Number',
        'no_exchanges_found': 'No Exchanges Found',
        'no_exchanges_status': 'No exchanges in status',
        'exchanges_will_show_here': 'When you exchange money, it will appear here',
        'order_number': 'Order Number',
        'exchange_rate': 'Exchange Rate',
        'service_fee': 'Service Fee',
        'total_amount': 'Total Amount',
        'yuan': 'Yuan',
        'baht': 'Baht',
        'view_details': 'View Details',
        'try_again': 'Try Again',
        'loading': 'Loading...',
        'error': 'Error Occurred',
        'phone_number': 'Phone Number',
        'not_specified': 'Not Specified',
        'yuan_amount_to_transfer': 'Yuan Amount to Transfer',
        'amount_to_pay': 'Amount to Pay:',
        'account_gcargo_a': 'G-cargo-A Account',
        'account_gcargo_w': 'G-cargo-W Account',
      },
      'zh': {
        'exchange_status': '兑换状态',
        'all': '全部',
        'pending_payment': '等待付款',
        'completed': '已完成',
        'select_date_range': '选择日期范围',
        'search_order': '搜索订单号',
        'no_exchanges_found': '未找到兑换记录',
        'no_exchanges_status': '该状态下无兑换记录',
        'exchanges_will_show_here': '兑换记录将显示在这里',
        'order_number': '订单号',
        'exchange_rate': '汇率',
        'service_fee': '服务费',
        'total_amount': '总金额',
        'yuan': '元',
        'baht': '泰铢',
        'view_details': '查看详情',
        'try_again': '重试',
        'loading': '加载中...',
        'error': '发生错误',
        'phone_number': '电话号码',
        'not_specified': '未指定',
        'yuan_amount_to_transfer': '要转账的人民币金额',
        'amount_to_pay': '应付金额:',
        'account_gcargo_a': 'G-cargo-A账户',
        'account_gcargo_w': 'G-cargo-W账户',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  List<String> get statusList => [getTranslation('all'), getTranslation('pending_payment'), getTranslation('completed')];

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    _dateController.text = getTranslation('select_date_range');

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
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: kButtonColor, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
            canvasColor: Colors.white,
          ),
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
        return getTranslation('pending_payment');
      case 'completed':
        return getTranslation('completed');
      default:
        return getTranslation('pending_payment');
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
      if (selectedStatus != 'all') {
        final targetStatus = getTranslation(selectedStatus);
        filteredPayments =
            filteredPayments.where((payment) {
              final displayStatus = _getDisplayStatus(payment.status ?? '');
              return displayStatus == targetStatus;
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
        getTranslation('all'): payments.length,
        getTranslation('pending_payment'): payments.where((p) => _getDisplayStatus(p.status ?? '') == getTranslation('pending_payment')).length,
        getTranslation('completed'): payments.where((p) => _getDisplayStatus(p.status ?? '') == getTranslation('completed')).length,
      };

      return Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: Text(getTranslation('exchange_status'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        ),
        body: Column(
          children: [
            // 🔹 ช่องวันที่แบบ TextField
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: Padding(padding: EdgeInsets.all(12.0), child: Image.asset('assets/icons/calendar_icon.png', width: 20)),
                  hintText: getTranslation('select_date_range'),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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
                  final statusKey = ['all', 'pending_payment', 'completed'][i];
                  final isSelected = statusKey == selectedStatus;
                  final count = statusCounts[status] ?? 0;

                  return GestureDetector(
                    onTap: () => setState(() => selectedStatus = statusKey),
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
              child:
                  grouped.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(getTranslation('no_exchanges_found'), style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      )
                      : ListView(
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
                    // Container(
                    //   width: 36,
                    //   height: 36,
                    //   decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF1F1F1)),
                    //   child: Center(child: Image.asset(iconPath, width: 20, height: 20)),
                    // ),
                    const SizedBox(width: 8),
                    Text(_getAccountName(methodName), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Text(displayStatus, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),

            // 🔹 Ref
            Text(getTranslation('phone_number'), style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(payment.phone ?? getTranslation('not_specified'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

            const SizedBox(height: 12),

            // 🔹 แถวข้อมูลยอดเงิน
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getTranslation('yuan_amount_to_transfer'), style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                      Text(getTranslation('amount_to_pay'), style: TextStyle(fontSize: 14, color: Colors.grey)),
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

  // ฟังก์ชั่นสำหรับแปลงชื่อ payment method เป็นชื่อบัญชี
  String _getAccountName(String paymentMethod) {
    switch (paymentMethod) {
      case 'Alipay':
        return getTranslation('account_gcargo_a');
      case 'WeChat Pay':
        return getTranslation('account_gcargo_w');
      default:
        return paymentMethod;
    }
  }
}
