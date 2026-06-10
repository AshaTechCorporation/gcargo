import 'package:flutter/material.dart';
import 'package:gcargo/bill/transportCostDetailPage.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ShippingBillPage extends StatefulWidget {
  const ShippingBillPage({super.key});

  @override
  State<ShippingBillPage> createState() => _ShippingBillPageState();
}

class _ShippingBillPageState extends State<ShippingBillPage> {
  late LanguageController languageController;
  late final OrderController orderController;
  String selectedStatus = 'all';
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'title': 'บิลค่าขนส่ง',
        'all': 'ทั้งหมด',
        'processing': 'รอดำเนินการ',
        'completed': 'สำเร็จ',
        'select_date_range': 'เลือกช่วงวันที่',
        'search_document': 'ค้นหาเลขที่เอกสาร',
        'no_documents_found': 'ไม่พบบิลค่าขนส่ง',
        'document_number': 'เลขที่เอกสาร',
        'recipient': 'ผู้รับ',
        'address': 'ที่อยู่',
        'phone': 'เบอร์โทร',
        'items': 'รายการ',
        'tracking_number': 'เลขขนส่งจีน',
        'product_name': 'สินค้า',
        'baht': 'บาท',
        'try_again': 'ลองใหม่',
        'loading': 'กำลังโหลด...',
        'china_thailand_transport': 'รวมค่าขนส่งจีนไทย',
      },
      'en': {
        'title': 'Shipping Bill',
        'all': 'All',
        'processing': 'Processing',
        'completed': 'Completed',
        'select_date_range': 'Select Date Range',
        'search_document': 'Search Document Number',
        'no_documents_found': 'No Shipping Bills Found',
        'document_number': 'Document Number',
        'recipient': 'Recipient',
        'address': 'Address',
        'phone': 'Phone',
        'items': 'Items',
        'tracking_number': 'China Tracking Number',
        'product_name': 'Product',
        'baht': 'Baht',
        'try_again': 'Try Again',
        'loading': 'Loading...',
        'china_thailand_transport': 'China-Thailand Transport Cost',
      },
      'zh': {
        'title': '运费账单',
        'all': '全部',
        'processing': '处理中',
        'completed': '已完成',
        'select_date_range': '选择日期范围',
        'search_document': '搜索文件编号',
        'no_documents_found': '未找到运费账单',
        'document_number': '文件编号',
        'recipient': '收件人',
        'address': '地址',
        'phone': '电话',
        'items': '项目',
        'tracking_number': '中国运单号',
        'product_name': '商品',
        'baht': '泰铢',
        'try_again': '重试',
        'loading': '加载中...',
        'china_thailand_transport': '中泰运输费用',
      },
    };

    return translations[currentLang]?[key] ?? translations['th']?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    orderController =
        Get.isRegistered<OrderController>()
            ? Get.find<OrderController>()
            : Get.put(OrderController());
    _dateController.text = getTranslation('select_date_range');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getBills();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getStatusText(String? apiStatus) {
    switch (apiStatus) {
      case 'pending':
      case 'processing':
      case 'awaiting_payment':
      case 'in_transit':
      case 'arrived_china_warehouse':
      case 'arrived_thailand_warehouse':
        return getTranslation('processing');
      case 'completed':
      case 'delivered':
      case 'paid':
        return getTranslation('completed');
      default:
        return getTranslation('processing');
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  List<Map<String, dynamic>> _buildDisplayBills() {
    return orderController.billing.map((bill) {
      final memberAddress = _asMap(bill['member_address']);
      final billLists = _asList(bill['bill_lists_grouped']);
      final firstBillList =
          billLists.isNotEmpty ? _asMap(billLists.first) : <String, dynamic>{};
      return {
        'id': _toInt(bill['id']),
        'date': _formatDate(
          (bill['in_thai_date'] ?? bill['created_at'])?.toString(),
        ),
        'docNo': bill['code']?.toString() ?? '',
        'status': _getStatusText(bill['status']?.toString()),
        'amount': _toDouble(bill['total_amount']),
        'recipient': memberAddress['contact_name']?.toString() ?? '',
        'phone': memberAddress['contact_phone']?.toString() ?? '',
        'address': _formatAddress(memberAddress),
        'itemCount': billLists.length,
        'trackingNo':
            (firstBillList['barcode'] ?? firstBillList['code'])?.toString() ??
            '',
        'productName': firstBillList['product_name']?.toString() ?? '',
      };
    }).toList();
  }

  String _formatAddress(Map<String, dynamic> address) {
    if (address.isEmpty) return '';
    return [
          address['address'],
          address['sub_district'],
          address['district'],
          address['province'],
          address['postal_code'],
        ]
        .where((value) => value != null && value.toString().trim().isNotEmpty)
        .join(' ');
  }

  List<Map<String, dynamic>> _filterBills(List<Map<String, dynamic>> bills) {
    final keyword = _searchController.text.trim().toLowerCase();
    var filteredData =
        selectedStatus == 'all'
            ? bills
            : bills
                .where((e) => e['status'] == getTranslation(selectedStatus))
                .toList();

    if (keyword.isNotEmpty) {
      filteredData =
          filteredData.where((item) {
            final searchableText =
                [
                  item['docNo'],
                  item['recipient'],
                  item['address'],
                  item['phone'],
                  item['trackingNo'],
                  item['productName'],
                ].join(' ').toLowerCase();
            return searchableText.contains(keyword);
          }).toList();
    }

    if (startDate != null && endDate != null) {
      filteredData =
          filteredData.where((item) {
            final itemDateStr = item['date'] as String;
            if (itemDateStr.isEmpty) return false;

            try {
              final itemDate = DateFormat('dd/MM/yyyy').parse(itemDateStr);
              final startOfDay = DateTime(
                startDate!.year,
                startDate!.month,
                startDate!.day,
              );
              final endOfDay = DateTime(
                endDate!.year,
                endDate!.month,
                endDate!.day,
                23,
                59,
                59,
              );

              return itemDate.isAfter(
                    startOfDay.subtract(const Duration(days: 1)),
                  ) &&
                  itemDate.isBefore(endOfDay.add(const Duration(days: 1)));
            } catch (e) {
              return false;
            }
          }).toList();
    }

    return filteredData;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (orderController.isLoading.value) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(includeDatePicker: false),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(getTranslation('loading')),
              ],
            ),
          ),
        );
      }

      if (orderController.hasError.value) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(includeDatePicker: false),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  orderController.errorMessage.value,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: orderController.getBills,
                  child: Text(getTranslation('try_again')),
                ),
              ],
            ),
          ),
        );
      }

      final displayBills = _buildDisplayBills();
      final filteredBills = _filterBills(displayBills);
      final totalCount = displayBills.length;
      final pendingCount =
          displayBills
              .where((e) => e['status'] == getTranslation('processing'))
              .length;
      final successCount =
          displayBills
              .where((e) => e['status'] == getTranslation('completed'))
              .length;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: getTranslation('search_document'),
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildChip(
                              getTranslation('all'),
                              'all',
                              count: totalCount,
                            ),
                            _buildChip(
                              getTranslation('processing'),
                              'processing',
                              count: pendingCount,
                            ),
                            _buildChip(
                              getTranslation('completed'),
                              'completed',
                              count: successCount,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (filteredBills.isEmpty)
                        Center(
                          child: Text(
                            getTranslation('no_documents_found'),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      else
                        ..._buildGroupedList(filteredBills),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar({bool includeDatePicker = true}) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslation('title'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (includeDatePicker) ...[
            const SizedBox(width: 20),
            Expanded(
              child: TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDateRange,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/icons/calendar_icon.png',
                      width: 18,
                    ),
                  ),
                  hintText: getTranslation('select_date_range'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: startDate ?? DateTime(2024, 1, 1),
        end: endDate ?? DateTime(2025, 7, 1),
      ),
    );

    if (picked == null) return;

    setState(() {
      startDate = picked.start;
      endDate = picked.end;
      _dateController.text =
          '${DateFormat('dd/MM/yyyy').format(picked.start)} - ${DateFormat('dd/MM/yyyy').format(picked.end)}';
    });
  }

  Widget _buildChip(String label, String statusKey, {int? count}) {
    final selected = selectedStatus == statusKey;

    return GestureDetector(
      onTap: () => setState(() => selectedStatus = statusKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color:
              selected
                  ? kBackgroundTextColor.withValues(alpha: 0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? kBackgroundTextColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? kBackgroundTextColor : Colors.black,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: selected ? kCicleColor : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedList(List<Map<String, dynamic>> bills) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final bill in bills) {
      grouped.putIfAbsent(bill['date'].toString(), () => []).add(bill);
    }

    return grouped.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...entry.value.map(_buildDocumentCard),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Widget _buildDocumentCard(Map<String, dynamic> item) {
    final status = item['status'] as String;
    final statusColor =
        status == getTranslation('completed')
            ? Colors.green
            : status == getTranslation('processing')
            ? Colors.orange
            : Colors.black;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => TransportCostDetailPage(
                  paper_number: item['docNo'].toString(),
                  billId: item['id'] as int,
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/icons/menu-board-blue.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${getTranslation('document_number')} ${item['docNo']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              getTranslation('china_thailand_transport'),
              '${(item['amount'] as double).toStringAsFixed(2)} ${getTranslation('baht')}',
              valueStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (item['recipient'].toString().isNotEmpty)
              _buildInfoRow(
                getTranslation('recipient'),
                item['recipient'].toString(),
              ),
            if (item['phone'].toString().isNotEmpty)
              _buildInfoRow(getTranslation('phone'), item['phone'].toString()),
            if (item['address'].toString().isNotEmpty)
              _buildInfoRow(
                getTranslation('address'),
                item['address'].toString(),
              ),
            _buildInfoRow(
              getTranslation('items'),
              item['itemCount'].toString(),
            ),
            if (item['trackingNo'].toString().isNotEmpty)
              _buildInfoRow(
                getTranslation('tracking_number'),
                item['trackingNo'].toString(),
              ),
            if (item['productName'].toString().isNotEmpty)
              _buildInfoRow(
                getTranslation('product_name'),
                item['productName'].toString(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  valueStyle ??
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  List<dynamic> _asList(dynamic value) {
    return value is List ? value : const [];
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
