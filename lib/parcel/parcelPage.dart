import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class ParcelPage extends StatefulWidget {
  const ParcelPage({super.key});

  @override
  State<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends State<ParcelPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('พัสดุของฉัน', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black))],
        bottom: TabBar(
          controller: _tabController,
          labelColor: kButtonColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: kButtonColor,
          tabs: const [Tab(text: 'ทั้งหมด'), Tab(text: 'กำลังส่ง'), Tab(text: 'เสร็จสิ้น')],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [_buildParcelList('all'), _buildParcelList('shipping'), _buildParcelList('completed')]),
      floatingActionButton: FloatingActionButton(onPressed: () {}, backgroundColor: kButtonColor, child: const Icon(Icons.add, color: Colors.white)),
    );
  }

  Widget _buildParcelList(String type) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildParcelCard(index, type);
      },
    );
  }

  Widget _buildParcelCard(int index, String type) {
    final List<Map<String, dynamic>> parcels = [
      {
        'id': 'GC001234567',
        'from': 'กรุงเทพฯ',
        'to': 'เชียงใหม่',
        'status': 'กำลังขนส่ง',
        'statusColor': Colors.orange,
        'date': '15 ธ.ค. 2567',
        'price': '120 บาท',
      },
      {
        'id': 'GC001234568',
        'from': 'เชียงใหม่',
        'to': 'ภูเก็ต',
        'status': 'เสร็จสิ้น',
        'statusColor': Colors.green,
        'date': '14 ธ.ค. 2567',
        'price': '180 บาท',
      },
      {
        'id': 'GC001234569',
        'from': 'กรุงเทพฯ',
        'to': 'ขอนแก่น',
        'status': 'รอรับพัสดุ',
        'statusColor': Colors.blue,
        'date': '13 ธ.ค. 2567',
        'price': '95 บาท',
      },
      {
        'id': 'GC001234570',
        'from': 'ภูเก็ต',
        'to': 'กรุงเทพฯ',
        'status': 'กำลังขนส่ง',
        'statusColor': Colors.orange,
        'date': '12 ธ.ค. 2567',
        'price': '160 บาท',
      },
      {
        'id': 'GC001234571',
        'from': 'ขอนแก่น',
        'to': 'อุดรธานี',
        'status': 'เสร็จสิ้น',
        'statusColor': Colors.green,
        'date': '11 ธ.ค. 2567',
        'price': '75 บาท',
      },
    ];

    final parcel = parcels[index % parcels.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(parcel['id'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: parcel['statusColor'].withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(parcel['status'], style: TextStyle(fontSize: 12, color: parcel['statusColor'], fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey.shade600, size: 16),
              const SizedBox(width: 8),
              Text('${parcel['from']} → ${parcel['to']}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 16),
                  const SizedBox(width: 8),
                  Text(parcel['date'], style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
              Text(parcel['price'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kButtonColor)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kButtonColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('ติดตาม', style: TextStyle(color: kButtonColor)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kButtonColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('รายละเอียด', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
