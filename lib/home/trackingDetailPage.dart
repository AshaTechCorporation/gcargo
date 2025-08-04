import 'package:flutter/material.dart';

class TrackingDetailPage extends StatefulWidget {
  const TrackingDetailPage({super.key});

  @override
  State<TrackingDetailPage> createState() => _TrackingDetailPageState();
}

class _TrackingDetailPageState extends State<TrackingDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color kButtonColor = const Color(0xFF427D9D);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Widget _buildImageRow() {
    return Row(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/image14.png', width: 80, height: 80, fit: BoxFit.cover)),
        const SizedBox(width: 8),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/image14.png', width: 80, height: 80, fit: BoxFit.cover)),
      ],
    );
  }

  Widget _buildProductInfoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Text('วันที่โค้ดยืนยัน', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        const Text('2024-08-13 15:59:17', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('รูปภาพอ้างอิง', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        _buildImageRow(),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildProblemInfoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Text('รายละเอียด', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        const Text('-', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('รูปภาพหลักฐาน', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        _buildImageRow(),
        const Divider(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('เลขขนส่งจีน YT7518613489991', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              labelColor: kButtonColor,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              indicatorColor: kButtonColor,
              indicatorWeight: 3,
              tabs: const [Tab(text: 'ข้อมูลสินค้า'), Tab(text: 'ข้อมูลการแจ้งพัสดุมีปัญหา')],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TabBarView(controller: _tabController, children: [_buildProductInfoTab(), _buildProblemInfoTab()]),
      ),
    );
  }
}
