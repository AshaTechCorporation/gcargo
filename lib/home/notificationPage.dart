import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 16, color: Colors.black);
    final subTextStyle = TextStyle(fontSize: 14, color: Colors.grey.shade600);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('แจ้งเตือน', style: TextStyle(color: Colors.black)),
      ),
      body: ListView(
        children: [
          _buildSectionTitle('ข่าวสาร & โปรโมชั่น', onTap: () {}),
          _buildSectionTitle('คูปองส่วนลด', onTap: () {}),
          const Divider(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('เกี่ยวกับการสั่งซื้อ', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          _buildOrderNotification(title: 'สั่งซื้อสินค้าสำเร็จ', orderNumber: '167304', time: '10:15', date: '14 พฤษภาคม 2568'),
          _buildOrderNotification(title: 'สั่งซื้อสินค้าสำเร็จ', orderNumber: '167304', time: '10:15', date: '14 พฤษภาคม 2568'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onTap}) {
    return ListTile(title: Text(title, style: const TextStyle(fontSize: 16)), trailing: const Icon(Icons.chevron_right), onTap: onTap);
  }

  Widget _buildOrderNotification({required String title, required String orderNumber, required String time, required String date}) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('เลขออเดอร์ $orderNumber', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 2),
              Text('$time     $date', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          onTap: () {
            // ไปยังหน้ารายละเอียดคำสั่งซื้อ
          },
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(height: 1)),
      ],
    );
  }
}
