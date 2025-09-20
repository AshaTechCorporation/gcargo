import 'package:flutter/material.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/home/exchangeRatePage.dart';
import 'package:gcargo/home/shippingRatePage.dart';
import 'package:gcargo/home/trackingOwnerPage.dart';
import 'package:gcargo/home/transportCalculatePage.dart';
import 'package:get/get.dart';

class ServiceItemWidget extends StatelessWidget {
  final String iconPath;
  final String label;
  final String serviceKey; // เพิ่ม serviceKey เพื่อระบุประเภทของ service

  const ServiceItemWidget({super.key, required this.iconPath, required this.label, required this.serviceKey});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return GestureDetector(
      onTap: () {
        // ใช้ serviceKey แทนการเปรียบเทียบ label
        if (serviceKey == 'shipping_rate') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ShippingRatePage()));
        } else if (serviceKey == 'exchange_rate') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ExchangeRatePage(exchangeRate: homeController.exchangeRate)));
        } else if (serviceKey == 'calculate_service') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TransportCalculatePage()));
        } else if (serviceKey == 'track_package') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingOwnerPage()));
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Image.asset(iconPath, width: 36, height: 36),
          ),
          const SizedBox(height: 6),
          SizedBox(child: Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
