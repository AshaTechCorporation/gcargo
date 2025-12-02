import 'package:flutter/material.dart';
import 'package:gcargo/services/accountService.dart';
import 'package:intl/intl.dart';

class MyRate extends StatefulWidget {
  const MyRate({super.key, required this.transport_rate_id});
  final int transport_rate_id;

  @override
  State<MyRate> createState() => _MyRateState();
}

class _MyRateState extends State<MyRate> {
  Map<String, dynamic>? rateData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRateData();
  }

  Future<void> _loadRateData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await AccountService.getMyRate(transport_rate_id: widget.transport_rate_id);

      setState(() {
        rateData = data['data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('อัตราค่าขนส่งของฉัน'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('เกิดข้อผิดพลาด: $errorMessage'),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadRateData, child: const Text('ลองใหม่')),
                  ],
                ),
              )
              : _buildRateContent(),
    );
  }

  Widget _buildRateContent() {
    if (rateData == null) return const Center(child: Text('ไม่มีข้อมูล'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 2,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(child: Text(rateData!['name'] ?? 'ไม่มีชื่อ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('รหัส: ${rateData!['code'] ?? 'ไม่มีรหัส'}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  if (rateData!['remark'] != null && rateData!['remark'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('หมายเหตุ: ${rateData!['remark']}', style: const TextStyle(fontSize: 14)),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'อัตราขั้นต่ำ: ${NumberFormat('#,##0.00').format(double.tryParse(rateData!['min_rate'].toString()) ?? 0)} บาท',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Rate Lists grouped by transport type
          if (rateData!['rate_lists'] != null && rateData!['rate_lists'].isNotEmpty)
            ..._buildGroupedRateLists()
          else
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Center(child: Text('ไม่มีข้อมูลอัตราค่าขนส่ง')))),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedRateLists() {
    final rateLists = rateData!['rate_lists'] as List<dynamic>;

    // Group by transport type
    final Map<String, List<dynamic>> groupedRates = {};
    for (var rate in rateLists) {
      final transportType = rate['transport_type']?['name_th'] ?? 'ไม่ระบุ';
      if (!groupedRates.containsKey(transportType)) {
        groupedRates[transportType] = [];
      }
      groupedRates[transportType]!.add(rate);
    }

    List<Widget> widgets = [];

    groupedRates.forEach((transportType, rates) {
      // Transport type header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            children: [
              Icon(transportType.contains('เรือ') ? Icons.directions_boat : Icons.local_shipping, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(transportType, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );

      // Rate cards for this transport type in grid layout
      widgets.add(_buildRateGrid(rates, transportType));
    });

    return widgets;
  }

  Widget _buildRateGrid(List<dynamic> rates, String transportType) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: rates.length,
      itemBuilder: (context, index) {
        return _buildRateCard(rates[index], transportType);
      },
    );
  }

  Widget _buildRateCard(Map<String, dynamic> rateItem, String transportType) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transport type code
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
              child: Text(rateItem['transport_type']?['code'] ?? 'ไม่มีรหัส', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),

            // Product type name - fixed height
            SizedBox(
              height: 40,
              child: Text(
                rateItem['product_type']?['name'] ?? 'ไม่มีชื่อประเภทสินค้า',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4),

            // Product code
            Text('รหัส: ${rateItem['product_type']?['code'] ?? 'ไม่มี'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),

            const Spacer(),

            // Price - always at bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                '${NumberFormat('#,##0.00').format(double.tryParse(rateItem['rate_price'].toString()) ?? 0)} บาท/${rateItem['rate_type']}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
