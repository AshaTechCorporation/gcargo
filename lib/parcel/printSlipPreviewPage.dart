import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gcargo/models/orders/ordersPage.dart';
import 'package:gcargo/models/orders/productsTrack.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PrintSlipPreviewPage extends StatelessWidget {
  final OrdersPage order;
  final String statusText;

  const PrintSlipPreviewPage({super.key, required this.order, required this.statusText});

  static const _downloadsChannel = MethodChannel('gcargo/downloads');
  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _line = Color(0xFFD1D5DB);
  static const _softLine = Color(0xFFE5E7EB);
  static const _success = Color(0xFF047857);

  @override
  Widget build(BuildContext context) {
    final products = order.order_lists ?? [];
    final productTotal = _calculateProductTotal(products);
    final transferFee = 0.0;
    final discount = 0.0;
    final netTotal = _parseAmount(order.total_price) > 0 ? _parseAmount(order.total_price) : productTotal + transferFee - discount;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('ปริ๊นสลิป', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [IconButton(tooltip: 'ปริ๊นสลิป', onPressed: () => _savePdfToDownloads(context), icon: const Icon(Icons.print_outlined))],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 760),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _line)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(orderCode: order.code ?? '-'),
                  _MetaRow(receiptNo: _receiptNo, issuedAt: _formatDateTime(DateTime.now()), paymentAt: _formatNullableDate(order.created_at)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 18, 30, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ข้อมูลบิล', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _ink)),
                        const SizedBox(height: 12),
                        _InfoGrid(
                          fields: [
                            _SlipField('เลขที่ออเดอร์', order.code ?? '-'),
                            _SlipField('สถานะ', statusText, valueColor: _success),
                            _SlipField('ลูกค้า', _customerName),
                            _SlipField('จำนวนรายการ', '${products.length} รายการ'),
                            const _SlipField('วิธีชำระเงิน', '-'),
                            _SlipField('วันที่สั่งซื้อ', _formatNullableString(order.date)),
                          ],
                        ),
                        const SizedBox(height: 26),
                        const Text('รายการสินค้าแยกตามร้าน', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _ink)),
                        const SizedBox(height: 12),
                        _ProductSection(products: products),
                        const SizedBox(height: 20),
                        const Text('สรุปท้ายบิล', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _ink)),
                        const SizedBox(height: 10),
                        _SummaryTable(
                          productTotal: productTotal,
                          transferFee: transferFee,
                          discount: discount,
                          orderTotal: netTotal,
                          netTotal: netTotal,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFFAFAFA), border: Border.all(color: _softLine)),
                          child: const Text(
                            'หมายเหตุ: เอกสารนี้เป็นหลักฐานรับแจ้ง/บันทึกการชำระเงินจากระบบ ไม่ใช่ใบกำกับภาษี และข้อมูลอาจมีการตรวจสอบเพิ่มเติมตามสถานะรายการ',
                            style: TextStyle(fontSize: 11, color: _ink, height: 1.4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: _softLine),
                        const SizedBox(height: 8),
                        const Center(child: Text('เอกสารนี้จัดทำโดยระบบ G-Cargo', style: TextStyle(fontSize: 11, color: _muted))),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _receiptNo => order.code == null || order.code!.isEmpty ? '-' : 'RC-${order.code}';

  String get _customerName {
    final member = order.member;
    final parts =
        [member?.code, member?.fname, member?.lname].where((part) => part != null && part.trim().isNotEmpty).map((part) => part!.trim()).toList();
    return parts.isEmpty ? '-' : parts.join(' ');
  }

  Future<void> _savePdfToDownloads(BuildContext context) async {
    try {
      final pdf = await _buildPdfDocument();
      final safeCode = (order.code?.isNotEmpty == true ? order.code! : 'order-${order.id ?? DateTime.now().millisecondsSinceEpoch}').replaceAll(
        RegExp(r'[^A-Za-z0-9_-]'),
        '-',
      );
      final fileName = 'GCargo-slip-$safeCode.pdf';
      final bytes = await pdf.save();
      final savedPath = await _saveBytesToDownloads(fileName, bytes);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('บันทึก PDF แล้ว: $savedPath'), backgroundColor: Colors.green));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('สร้าง PDF ไม่สำเร็จ: $e'), backgroundColor: Colors.red));
    }
  }

  Future<String> _saveBytesToDownloads(String fileName, List<int> bytes) async {
    if (Platform.isAndroid) {
      final savedPath = await _downloadsChannel.invokeMethod<String>('savePdfToDownloads', {'fileName': fileName, 'bytes': bytes});
      return savedPath ?? 'Downloads/$fileName';
    }

    final downloadsDir = await _getDownloadsDirectory();
    final file = File('${downloadsDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }

    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) return downloadsDir;
    } catch (_) {}

    if (Platform.isAndroid) {
      final androidDownloads = Directory('/storage/emulated/0/Download');
      if (await androidDownloads.exists()) return androidDownloads;
    }

    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home != null && home.isNotEmpty) {
      final fallback = Directory('$home/Downloads');
      if (await fallback.exists()) return fallback;
    }

    return getApplicationDocumentsDirectory();
  }

  Future<pw.Document> _buildPdfDocument() async {
    final thaiFont = pw.Font.ttf(await rootBundle.load('fonts/SukhumvitSet-Text.ttf'));
    final unicodeFont = pw.Font.ttf(await rootBundle.load('fonts/ArialUnicode.ttf'));
    final products = order.order_lists ?? [];
    final productTotal = _calculateProductTotal(products);
    final transferFee = 0.0;
    final discount = 0.0;
    final netTotal = _parseAmount(order.total_price) > 0 ? _parseAmount(order.total_price) : productTotal + transferFee - discount;
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(8 * PdfPageFormat.mm),
        theme: pw.ThemeData.withFont(base: thaiFont, bold: thaiFont, fontFallback: [unicodeFont]),
        build:
            (context) => [
              _pdfHeader(),
              _pdfMetaRow(_receiptNo, _formatDateTime(DateTime.now()), _formatNullableDate(order.created_at)),
              pw.SizedBox(height: 14),
              _pdfSectionTitle('ข้อมูลบิล'),
              pw.SizedBox(height: 8),
              _pdfInfoGrid(products.length),
              pw.SizedBox(height: 18),
              _pdfSectionTitle('รายการสินค้าแยกตามร้าน'),
              pw.SizedBox(height: 8),
              _pdfProductSection(products),
              pw.SizedBox(height: 14),
              _pdfSectionTitle('สรุปท้ายบิล'),
              pw.SizedBox(height: 8),
              _pdfSummaryTable(productTotal, transferFee, discount, netTotal, netTotal),
              pw.SizedBox(height: 12),
              _pdfNotice(),
              pw.SizedBox(height: 12),
              pw.Divider(color: PdfColor.fromHex('#E5E7EB')),
              pw.Center(child: pw.Text('เอกสารนี้จัดทำโดยระบบ G-Cargo', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600))),
            ],
      ),
    );

    return doc;
  }

  pw.Widget _pdfHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      color: PdfColor.fromHex('#111827'),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('G-Cargo', style: pw.TextStyle(color: PdfColors.white, fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('เอกสารรับแจ้งชำระเงินจากระบบ G-Cargo', style: pw.TextStyle(color: PdfColor.fromHex('#D1D5DB'), fontSize: 11)),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('ใบรับแจ้งชำระเงิน', style: pw.TextStyle(color: PdfColors.white, fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('PAYMENT ACKNOWLEDGEMENT', style: pw.TextStyle(color: PdfColor.fromHex('#D1D5DB'), fontSize: 9)),
              pw.SizedBox(height: 6),
              pw.Text(order.code ?? '-', style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfMetaRow(String receiptNo, String issuedAt, String paymentAt) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#E5E7EB')))),
      child: pw.Row(
        children: [
          pw.Expanded(child: _pdfLabelValue('เลขที่เอกสาร', receiptNo)),
          pw.Expanded(child: _pdfLabelValue('วันที่ออกเอกสาร', issuedAt)),
          pw.Expanded(child: _pdfLabelValue('วันที่ชำระเงิน', paymentAt)),
        ],
      ),
    );
  }

  pw.Widget _pdfInfoGrid(int productCount) {
    final fields = [
      ('เลขที่ออเดอร์', order.code ?? '-', PdfColor.fromHex('#111827')),
      ('สถานะ', statusText, PdfColor.fromHex('#047857')),
      ('ลูกค้า', _customerName, PdfColor.fromHex('#111827')),
      ('จำนวนรายการ', '$productCount รายการ', PdfColor.fromHex('#111827')),
      ('วิธีชำระเงิน', '-', PdfColor.fromHex('#111827')),
      ('วันที่สั่งซื้อ', _formatNullableString(order.date), PdfColor.fromHex('#111827')),
    ];

    return pw.Wrap(
      spacing: 18,
      runSpacing: 10,
      children: fields.map((field) => pw.SizedBox(width: 154, child: _pdfLabelValue(field.$1, field.$2, valueColor: field.$3))).toList(),
    );
  }

  pw.Widget _pdfProductSection(List<ProductsTrack> products) {
    if (products.isEmpty) {
      return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColor.fromHex('#E5E7EB'))),
        child: pw.Center(child: pw.Text('ไม่มีรายการสินค้า', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10))),
      );
    }

    final grouped = <String, List<ProductsTrack>>{};
    for (final product in products) {
      final shop = product.product_store_type?.trim().isNotEmpty == true ? product.product_store_type!.trim() : 'ร้านค้า';
      grouped.putIfAbsent(shop, () => []).add(product);
    }

    var index = 0;
    return pw.Column(
      children:
          grouped.entries.map((entry) {
            index++;
            return pw.Padding(padding: const pw.EdgeInsets.only(bottom: 8), child: _pdfShopBlock(index, entry.key, entry.value));
          }).toList(),
    );
  }

  pw.Widget _pdfShopBlock(int index, String shopName, List<ProductsTrack> products) {
    final total = _calculateProductTotal(products);

    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColor.fromHex('#D1D5DB'))),
      child: pw.Column(
        children: [
          pw.Container(
            color: PdfColor.fromHex('#F3F4F6'),
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: pw.Row(
              children: [
                pw.Expanded(child: pw.Text('#$index $shopName', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                pw.Text('${products.length} รายการ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          ...products.map(_pdfProductRow),
          pw.Container(
            color: PdfColor.fromHex('#FAFAFA'),
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: pw.Column(
              children: [
                _pdfTotalLine('รวมสินค้า', _money(total)),
                _pdfTotalLine('ค่าส่งจีน', _money(0)),
                _pdfTotalLine('ส่วนลด', '-${_money(0)}'),
                _pdfTotalLine('รวมร้านนี้', _money(total), bold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfProductRow(ProductsTrack product) {
    final price = _parseAmount(product.product_real_price ?? product.product_price);
    final qty = product.product_qty ?? 1;
    final amount = price * qty;
    final productName = product.product_name?.trim().isNotEmpty == true ? product.product_name!.trim() : '-';

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColor.fromHex('#E5E7EB')))),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(productName, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 2),
                pw.Text('1 x ${price.toStringAsFixed(4)} บาท', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ],
            ),
          ),
          pw.SizedBox(width: 34, child: pw.Text('$qty', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10))),
          pw.SizedBox(width: 76, child: pw.Text(amount.toStringAsFixed(4), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }

  pw.Widget _pdfSummaryTable(double productTotal, double transferFee, double discount, double orderTotal, double netTotal) {
    final rows = [
      ('รวมค่าสินค้า', productTotal),
      ('รวมค่าส่งจีน', transferFee),
      ('ค่าบริการ', 0.0),
      ('ส่วนลด', -discount),
      ('ยอดโอน', orderTotal),
      ('ยอดรวมสุทธิ', netTotal),
    ];

    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColor.fromHex('#D1D5DB'))),
      child: pw.Column(
        children: [
          pw.Container(
            color: PdfColor.fromHex('#111827'),
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: pw.Row(
              children: [
                pw.SizedBox(width: 30, child: pw.Text('#', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10))),
                pw.Expanded(child: pw.Text('รายการ', style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold))),
                pw.Text('จำนวนเงิน', style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          ...rows.asMap().entries.map((entry) {
            final isLast = entry.key == rows.length - 1;
            return pw.Container(
              color: isLast ? PdfColor.fromHex('#F3F4F6') : PdfColors.white,
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: pw.Row(
                children: [
                  pw.SizedBox(width: 30, child: pw.Text('${entry.key + 1}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))),
                  pw.Expanded(
                    child: pw.Text(entry.value.$1, style: pw.TextStyle(fontSize: 10, fontWeight: isLast ? pw.FontWeight.bold : pw.FontWeight.normal)),
                  ),
                  pw.Text(_money(entry.value.$2), style: pw.TextStyle(fontSize: 10, fontWeight: isLast ? pw.FontWeight.bold : pw.FontWeight.normal)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  pw.Widget _pdfNotice() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(color: PdfColor.fromHex('#FAFAFA'), border: pw.Border.all(color: PdfColor.fromHex('#E5E7EB'))),
      child: pw.Text(
        'หมายเหตุ: เอกสารนี้เป็นหลักฐานรับแจ้ง/บันทึกการชำระเงินจากระบบ ไม่ใช่ใบกำกับภาษี และข้อมูลอาจมีการตรวจสอบเพิ่มเติมตามสถานะรายการ',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
      ),
    );
  }

  pw.Widget _pdfSectionTitle(String text) {
    return pw.Text(text, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#111827')));
  }

  pw.Widget _pdfLabelValue(String label, String value, {PdfColor? valueColor}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8)),
        pw.SizedBox(height: 3),
        pw.Text(value, style: pw.TextStyle(color: valueColor ?? PdfColor.fromHex('#111827'), fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _pdfTotalLine(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.SizedBox(
            width: 92,
            child: pw.Text(
              label,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
            ),
          ),
          pw.SizedBox(width: 14),
          pw.SizedBox(
            width: 92,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontSize: 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  static double _parseAmount(String? value) {
    return double.tryParse((value ?? '').replaceAll(',', '')) ?? 0.0;
  }

  static double _calculateProductTotal(List<ProductsTrack> products) {
    return products.fold(0.0, (total, product) {
      final price = _parseAmount(product.product_real_price ?? product.product_price);
      final qty = product.product_qty ?? 1;
      return total + (price * qty);
    });
  }

  static String _money(double value) => '${value.toStringAsFixed(4)} บาท';

  static String _formatNullableString(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  static String _formatNullableDate(DateTime? value) {
    if (value == null) return '-';
    return _formatDateTime(value);
  }

  static String _formatDateTime(DateTime value) {
    return DateFormat('dd/MM/yyyy HH:mm').format(value);
  }
}

class _Header extends StatelessWidget {
  final String orderCode;

  const _Header({required this.orderCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PrintSlipPreviewPage._ink,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('G-Cargo', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('เอกสารรับแจ้งชำระเงินจากระบบ G-Cargo', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('ใบรับแจ้งชำระเงิน', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('PAYMENT ACKNOWLEDGEMENT', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 10)),
              const SizedBox(height: 6),
              Text(orderCode, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String receiptNo;
  final String issuedAt;
  final String paymentAt;

  const _MetaRow({required this.receiptNo, required this.issuedAt, required this.paymentAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: PrintSlipPreviewPage._softLine))),
      child: Row(
        children: [
          Expanded(child: _LabelValue(label: 'เลขที่เอกสาร', value: receiptNo)),
          Expanded(child: _LabelValue(label: 'วันที่ออกเอกสาร', value: issuedAt)),
          Expanded(child: _LabelValue(label: 'วันที่ชำระเงิน', value: paymentAt)),
        ],
      ),
    );
  }
}

class _SlipField {
  final String label;
  final String value;
  final Color? valueColor;

  const _SlipField(this.label, this.value, {this.valueColor});
}

class _InfoGrid extends StatelessWidget {
  final List<_SlipField> fields;

  const _InfoGrid({required this.fields});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 28.0;
        final itemWidth = (constraints.maxWidth - (spacing * 2)) / 3;

        return Wrap(
          spacing: spacing,
          runSpacing: 12,
          children:
              fields.map((field) {
                return SizedBox(width: itemWidth, child: _LabelValue(label: field.label, value: field.value, valueColor: field.valueColor));
              }).toList(),
        );
      },
    );
  }
}

class _ProductSection extends StatelessWidget {
  final List<ProductsTrack> products;

  const _ProductSection({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(border: Border.all(color: PrintSlipPreviewPage._softLine)),
        child: const Text('ไม่มีรายการสินค้า', textAlign: TextAlign.center, style: TextStyle(color: PrintSlipPreviewPage._muted)),
      );
    }

    final grouped = <String, List<ProductsTrack>>{};
    for (final product in products) {
      final shop = product.product_store_type?.trim().isNotEmpty == true ? product.product_store_type!.trim() : 'ร้านค้า';
      grouped.putIfAbsent(shop, () => []).add(product);
    }

    var shopIndex = 0;
    return Column(
      children:
          grouped.entries.map((entry) {
            shopIndex++;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ShopBlock(index: shopIndex, shopName: entry.key, products: entry.value),
            );
          }).toList(),
    );
  }
}

class _ShopBlock extends StatelessWidget {
  final int index;
  final String shopName;
  final List<ProductsTrack> products;

  const _ShopBlock({required this.index, required this.shopName, required this.products});

  @override
  Widget build(BuildContext context) {
    final total = PrintSlipPreviewPage._calculateProductTotal(products);

    return Container(
      decoration: BoxDecoration(border: Border.all(color: PrintSlipPreviewPage._line)),
      child: Column(
        children: [
          Container(
            color: const Color(0xFFF3F4F6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Expanded(child: Text('#$index $shopName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                Text('${products.length} รายการ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          ...products.map((product) => _ProductRow(product: product)),
          Container(
            color: const Color(0xFFFAFAFA),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                _TotalLine('รวมสินค้า', PrintSlipPreviewPage._money(total)),
                const _TotalLine('ค่าส่งจีน', '0.0000 บาท'),
                const _TotalLine('ส่วนลด', '-0.0000 บาท'),
                _TotalLine('รวมร้านนี้', PrintSlipPreviewPage._money(total), bold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final ProductsTrack product;

  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final price = PrintSlipPreviewPage._parseAmount(product.product_real_price ?? product.product_price);
    final qty = product.product_qty ?? 1;
    final amount = price * qty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: PrintSlipPreviewPage._softLine))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_productDisplayName, style: const TextStyle(fontSize: 12, color: PrintSlipPreviewPage._ink)),
                const SizedBox(height: 3),
                Text('1 x ${price.toStringAsFixed(4)} บาท', style: const TextStyle(fontSize: 10, color: PrintSlipPreviewPage._muted)),
              ],
            ),
          ),
          SizedBox(width: 50, child: Text('$qty', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
          SizedBox(width: 110, child: Text(amount.toStringAsFixed(4), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  String get _productDisplayName {
    final originalName = product.product_name?.trim() ?? '';
    if (originalName.isEmpty) return '-';
    return originalName;
  }
}

class _SummaryTable extends StatelessWidget {
  final double productTotal;
  final double transferFee;
  final double discount;
  final double orderTotal;
  final double netTotal;

  const _SummaryTable({
    required this.productTotal,
    required this.transferFee,
    required this.discount,
    required this.orderTotal,
    required this.netTotal,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('รวมค่าสินค้า', productTotal),
      ('รวมค่าส่งจีน', transferFee),
      ('ค่าบริการ', 0.0),
      ('ส่วนลด', -discount),
      ('ยอดโอน', orderTotal),
      ('ยอดรวมสุทธิ', netTotal),
    ];

    return Container(
      decoration: BoxDecoration(border: Border.all(color: PrintSlipPreviewPage._line)),
      child: Column(
        children: [
          Container(
            color: PrintSlipPreviewPage._ink,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: const Row(
              children: [
                SizedBox(width: 40, child: Text('#', style: TextStyle(color: Colors.white, fontSize: 12))),
                Expanded(child: Text('รายการ', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                Text('จำนวนเงิน', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          ...rows.asMap().entries.map((entry) {
            final isLast = entry.key == rows.length - 1;
            return Container(
              color: isLast ? const Color(0xFFF3F4F6) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(fontSize: 12, color: isLast ? PrintSlipPreviewPage._ink : PrintSlipPreviewPage._muted),
                    ),
                  ),
                  Expanded(child: Text(entry.value.$1, style: TextStyle(fontSize: 12, fontWeight: isLast ? FontWeight.w700 : FontWeight.w500))),
                  Text(
                    PrintSlipPreviewPage._money(entry.value.$2),
                    style: TextStyle(fontSize: 12, fontWeight: isLast ? FontWeight.w700 : FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _LabelValue({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: PrintSlipPreviewPage._muted, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor ?? PrintSlipPreviewPage._ink, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _TotalLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _TotalLine(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                color: bold ? PrintSlipPreviewPage._ink : const Color(0xFF4B5563),
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            width: 120,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, color: PrintSlipPreviewPage._ink, fontWeight: bold ? FontWeight.w700 : FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
