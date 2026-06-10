// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:gcargo/bill/chinaShippingDetailPage.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransportCostDetailPage extends StatefulWidget {
  final String paper_number;
  final int billId;

  const TransportCostDetailPage({
    super.key,
    required this.paper_number,
    required this.billId,
  });

  @override
  State<TransportCostDetailPage> createState() =>
      _TransportCostDetailPageState();
}

class _TransportCostDetailPageState extends State<TransportCostDetailPage> {
  final OrderController orderController = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getBillById(widget.billId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'เลขที่เอกสาร ${widget.paper_number}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F3F3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset('assets/icons/print-icon.png', width: 20),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (orderController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orderController.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  orderController.errorMessage.value,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => orderController.getBillById(widget.billId),
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        }

        final bill = _asMap(orderController.billingById.value);
        if (bill.isEmpty) {
          return const Center(child: Text('ไม่พบข้อมูล'));
        }

        final rows = _buildBillRows();

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(
                  child: Column(
                    children: [
                      _rowItem(
                        'รวมค่าขนส่งจีนไทย',
                        '${_formatAmount(bill['total_amount'])}฿',
                      ),
                      if (_amountValue(bill['total_vat']) > 0)
                        _rowItem('VAT', '${_formatAmount(bill['total_vat'])}฿'),
                      if (_amountValue(bill['manual_adjustment_amount']) != 0)
                        _rowItem(
                          'ปรับยอด',
                          '${_formatAmount(bill['manual_adjustment_amount'])}฿',
                        ),
                      if (_emptyDash(bill['manual_adjustment_note']) != '-')
                        _rowItem(
                          'หมายเหตุปรับยอด',
                          _emptyDash(bill['manual_adjustment_note']),
                        ),
                      const Divider(height: 24),
                      _rowItem(
                        'รวมราคาทั้งสิ้น',
                        '${_formatAmount(bill['total_amount'])}฿',
                        bold: true,
                      ),
                      _rowItem(
                        'สถานะ',
                        _getStatusText(bill['status']?.toString()),
                      ),
                      _rowItem(
                        'วันที่สินค้าเข้าไทย',
                        _formatDisplayDate(bill['in_thai_date']?.toString()),
                      ),
                      _rowItem(
                        'ช่องทางขนส่ง',
                        _emptyDash(bill['transportation_channel']),
                      ),
                      _rowItem('ประเภทลูกค้า', _emptyDash(bill['client_type'])),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('ข้อมูลผู้รับ'),
                _section(
                  child: Column(
                    children: [
                      _rowItem(
                        'ชื่อผู้รับ',
                        _emptyDash(
                          _asMap(bill['member_address'])['contact_name'],
                        ),
                      ),
                      _rowItem(
                        'เบอร์โทร',
                        _emptyDash(
                          _asMap(bill['member_address'])['contact_phone'],
                        ),
                      ),
                      _rowItem('ที่อยู่', _formatAddress()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('สรุปสินค้า'),
                _section(
                  child: Column(
                    children: [
                      _rowItem(
                        'จำนวนรายการ',
                        '${_toIntOrNull(bill['total_items']) ?? _totalItemCount(rows)}',
                      ),
                      _rowItem(
                        'น้ำหนักรวม',
                        '${_formatNumber(_toDoubleOrNull(bill['total_weight']))} กก.',
                      ),
                      _rowItem(
                        'CBM รวม',
                        _formatNumber(_toDoubleOrNull(bill['total_cbm'])),
                      ),
                      if (_rateLabel().isNotEmpty)
                        _rowItem('เรทที่ใช้', _rateLabel()),
                    ],
                  ),
                ),
                if (_asList(bill['payment']).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _sectionTitle('ข้อมูลการชำระเงิน'),
                  _section(child: Column(children: _buildPaymentRows())),
                ],
                const SizedBox(height: 16),
                _sectionTitle('รายการขนส่งจีน'),
                _section(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (rows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'ไม่มีข้อมูลรายการขนส่ง',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...rows.map((item) => _chinaRow(context, item)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _section({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }

  Widget _rowItem(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chinaRow(BuildContext context, Map<String, dynamic> item) {
    final code = _emptyDash(item['code']);
    final tracking = _emptyDash(item['barcode']);
    final navCode = tracking != '-' ? tracking : code;

    return Column(
      children: [
        InkWell(
          onTap:
              navCode == '-'
                  ? null
                  : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChinaShippingDetailPage(transportNo: navCode),
                    ),
                  ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tracking != '-' ? tracking : code,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${_formatAmount(item['amount'])}฿',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _miniRow('สินค้า', _emptyDash(item['product_name'])),
                _miniRow('เลขรายการ', code),
                _miniRow('จำนวนกล่อง', _emptyDash(item['qty_box'])),
                _miniRow('น้ำหนัก', '${_formatAmount(item['weight'])} กก.'),
                _miniRow(
                  'ขนาด',
                  '${_formatAmount(item['width'])} x ${_formatAmount(item['long'])} x ${_formatAmount(item['height'])}',
                ),
                if (_emptyDash(item['delivery_order_code']) != '-')
                  _miniRow(
                    'เลขใบรับสินค้า',
                    _emptyDash(item['delivery_order_code']),
                  ),
                if (_emptyDash(item['po_no']) != '-')
                  _miniRow('PO / Tracking', _emptyDash(item['po_no'])),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _miniRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPaymentRows() {
    final bill = _asMap(orderController.billingById.value);
    final payments = _asList(bill['payment']);
    final firstPayment =
        payments.isNotEmpty ? _asMap(payments.first) : <String, dynamic>{};
    return [
      _rowItem('วิธีชำระเงิน', _emptyDash(firstPayment['payment_type'])),
      _rowItem('เลขอ้างอิง', _emptyDash(firstPayment['ref_no'])),
      _rowItem('ยอดชำระ', '${_formatAmount(firstPayment['total_price'])}฿'),
      _rowItem('สถานะชำระเงิน', _emptyDash(firstPayment['status'])),
      _rowItem(
        'วันที่ชำระ',
        _formatDisplayDate(firstPayment['date']?.toString()),
      ),
    ];
  }

  List<Map<String, dynamic>> _buildBillRows() {
    final bill = _asMap(orderController.billingById.value);
    if (bill.isEmpty) return [];

    final poRows = _asList(bill['bill_po_lists']);
    if (poRows.isNotEmpty) {
      return poRows.map((poItem) {
        final po = _asMap(poItem);
        final line = _extractDeliveryOrderList(po);
        final deliveryOrder = _extractDeliveryOrder(po);
        return {
          'code': _value(line, 'code'),
          'barcode':
              _value(line, 'barcode') == '-'
                  ? _value(deliveryOrder, 'po_no')
                  : _value(line, 'barcode'),
          'product_name': _value(line, 'product_name'),
          'qty_box':
              _value(po, 'allocated_qty_box') == '-'
                  ? _value(line, 'qty_box')
                  : _value(po, 'allocated_qty_box'),
          'weight':
              _value(po, 'allocated_weight_total') == '-'
                  ? _value(line, 'weight')
                  : _value(po, 'allocated_weight_total'),
          'width': _value(line, 'width'),
          'height': _value(line, 'height'),
          'long': _value(line, 'long'),
          'amount': _value(po, 'total_amount'),
          'delivery_order_code': _value(deliveryOrder, 'code'),
          'po_no': _value(deliveryOrder, 'po_no'),
        };
      }).toList();
    }

    return _asList(bill['bill_lists_grouped']).map((rawItem) {
      final item = _asMap(rawItem);
      final deliveryOrder = _asMap(item['delivery_order']);
      return {
        'code': _emptyDash(item['code']),
        'barcode': _emptyDash(item['barcode']),
        'product_name': _emptyDash(item['product_name']),
        'qty_box': _emptyDash(item['qty_box']),
        'weight': _emptyDash(item['weight']),
        'width': _emptyDash(item['width']),
        'height': _emptyDash(item['height']),
        'long': _emptyDash(item['long']),
        'amount': '0',
        'delivery_order_code': _emptyDash(deliveryOrder['code']),
        'po_no': _emptyDash(deliveryOrder['po_no']),
      };
    }).toList();
  }

  Map<String, dynamic> _extractDeliveryOrderList(Map<String, dynamic> po) {
    final direct = _asMap(po['delivery_order_list']);
    if (direct.isNotEmpty) return direct;

    final thaiList = _asMap(po['delivery_order_thai_list']);
    final fromThaiList = _asMap(thaiList['delivery_order_list']);
    if (fromThaiList.isNotEmpty) return fromThaiList;

    final billLists = po['bill_lists'];
    if (billLists is List && billLists.isNotEmpty) {
      final firstBillList = _asMap(billLists.first);
      final nestedThaiList = _asMap(firstBillList['delivery_order_thai_list']);
      return _asMap(nestedThaiList['delivery_order_list']);
    }

    return {};
  }

  Map<String, dynamic> _extractDeliveryOrder(Map<String, dynamic> po) {
    final direct = _asMap(po['delivery_order']);
    if (direct.isNotEmpty) return direct;

    final thaiList = _asMap(po['delivery_order_thai_list']);
    final fromThaiList = _asMap(thaiList['delivery_order']);
    if (fromThaiList.isNotEmpty) return fromThaiList;

    final billLists = po['bill_lists'];
    if (billLists is List && billLists.isNotEmpty) {
      final firstBillList = _asMap(billLists.first);
      final nestedThaiList = _asMap(firstBillList['delivery_order_thai_list']);
      return _asMap(nestedThaiList['delivery_order']);
    }

    return {};
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    try {
      final json = value?.toJson();
      if (json is Map) return Map<String, dynamic>.from(json);
    } catch (_) {}
    return {};
  }

  String _value(Map<String, dynamic> map, String key) => _emptyDash(map[key]);

  String _formatAmount(dynamic amount) {
    final value = _amountValue(amount);
    return value.toStringAsFixed(2);
  }

  double _amountValue(dynamic amount) {
    if (amount == null) return 0;
    if (amount is num) return amount.toDouble();
    return double.tryParse(amount.toString()) ?? 0;
  }

  String _formatNumber(num? value) {
    if (value == null) return '0';
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  String _formatDisplayDate(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) return '-';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  String _formatAddress() {
    final bill = _asMap(orderController.billingById.value);
    final address = _asMap(bill['member_address']);
    if (address.isEmpty) return '-';
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

  String _rateLabel() {
    final bill = _asMap(orderController.billingById.value);
    final rate = bill['rate']?.toString();
    if (rate == null || rate.trim().isEmpty) return '';
    final typeMatch = RegExp(r'"type"\s*:\s*"([^"]+)"').firstMatch(rate);
    final priceMatch = RegExp(r'"rate_price"\s*:\s*([0-9.]+)').firstMatch(rate);
    final type = typeMatch?.group(1);
    final price = priceMatch?.group(1);
    if (type == null && price == null) return '';
    return [
      if (type != null) type.toUpperCase(),
      if (price != null) '${_formatAmount(price)}฿',
    ].join(' / ');
  }

  int _totalItemCount(List<Map<String, dynamic>> rows) {
    return rows.fold<int>(0, (sum, item) {
      final qtyBox = int.tryParse(item['qty_box'].toString());
      return sum + (qtyBox ?? 1);
    });
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'paid':
      case 'completed':
      case 'delivered':
        return 'สำเร็จ';
      case 'pending':
      case 'processing':
      case 'awaiting_payment':
        return 'รอดำเนินการ';
      case null:
      case '':
        return '-';
      default:
        return status;
    }
  }

  String _emptyDash(dynamic value) {
    if (value == null) return '-';
    final text = value.toString().trim();
    return text.isEmpty || text == 'null' ? '-' : text;
  }

  List<dynamic> _asList(dynamic value) {
    return value is List ? value : const [];
  }

  int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
