import 'package:flutter/material.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:get/get.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  String getTranslation(String key) {
    final languageController = Get.find<LanguageController>();
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'notifications': 'แจ้งเตือน',
        'news_promotions': 'ข่าวสาร & โปรโมชั่น',
        'discount_coupons': 'คูปองส่วนลด',
        'about_orders': 'เกี่ยวกับการสั่งซื้อ',
        'order_success': 'สั่งซื้อสินค้าสำเร็จ',
        'order_number': 'เลขออเดอร์',
        'no_notifications': 'ไม่มีการแจ้งเตือน',
        'mark_all_read': 'อ่านทั้งหมดแล้ว',
        'clear_all': 'ล้างทั้งหมด',
        'today': 'วันนี้',
        'yesterday': 'เมื่อวาน',
        'this_week': 'สัปดาห์นี้',
        'order_shipped': 'สินค้าถูกจัดส่งแล้ว',
        'order_delivered': 'สินค้าถูกส่งมอบแล้ว',
        'payment_confirmed': 'ยืนยันการชำระเงินแล้ว',
      },
      'en': {
        'notifications': 'Notifications',
        'news_promotions': 'News & Promotions',
        'discount_coupons': 'Discount Coupons',
        'about_orders': 'About Orders',
        'order_success': 'Order Placed Successfully',
        'order_number': 'Order Number',
        'no_notifications': 'No Notifications',
        'mark_all_read': 'Mark All as Read',
        'clear_all': 'Clear All',
        'today': 'Today',
        'yesterday': 'Yesterday',
        'this_week': 'This Week',
        'order_shipped': 'Order Shipped',
        'order_delivered': 'Order Delivered',
        'payment_confirmed': 'Payment Confirmed',
      },
      'zh': {
        'notifications': '通知',
        'news_promotions': '新闻与促销',
        'discount_coupons': '优惠券',
        'about_orders': '关于订单',
        'order_success': '订单下单成功',
        'order_number': '订单号',
        'no_notifications': '无通知',
        'mark_all_read': '全部标记为已读',
        'clear_all': '清除全部',
        'today': '今天',
        'yesterday': '昨天',
        'this_week': '本周',
        'order_shipped': '订单已发货',
        'order_delivered': '订单已送达',
        'payment_confirmed': '付款已确认',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 16, color: Colors.black);

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text(getTranslation('notifications'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        ),
        body: _buildNotificationList(textStyle),
      ),
    );
  }

  Widget _buildNotificationList(TextStyle textStyle) {
    // Sample notification data - in real app this would come from API
    final notifications = [
      {'type': 'section', 'title': getTranslation('news_promotions')},
      {'type': 'section', 'title': getTranslation('discount_coupons')},
      {'type': 'header', 'title': getTranslation('about_orders')},
      {'type': 'order', 'title': getTranslation('order_success'), 'orderNumber': '167304', 'time': '10:15', 'date': '14 พฤษภาคม 2568'},
      {'type': 'order', 'title': getTranslation('order_success'), 'orderNumber': '167305', 'time': '15:30', 'date': '13 พฤษภาคม 2568'},
    ];

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(getTranslation('no_notifications'), style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final type = notification['type'] as String;

        switch (type) {
          case 'section':
            return Column(children: [_buildSectionTitle(notification['title'] as String, onTap: () {}), Divider(height: 20)]);
          case 'header':
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(notification['title'] as String, style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                ),
                Divider(height: 20),
              ],
            );
          case 'order':
            return _buildOrderNotification(
              title: notification['title'] as String,
              orderNumber: notification['orderNumber'] as String,
              time: notification['time'] as String,
              date: notification['date'] as String,
            );
          default:
            return SizedBox.shrink();
        }
      },
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
              Text('${getTranslation('order_number')} $orderNumber', style: const TextStyle(fontSize: 16, color: Colors.grey)),
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
