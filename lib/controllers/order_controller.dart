import 'dart:developer';
import 'package:flutter/scheduler.dart';
import 'package:gcargo/models/legalimport.dart';
import 'package:gcargo/models/wallettrans.dart';
import 'package:get/get.dart';
import 'package:gcargo/models/orders/ordersPage.dart';
import 'package:gcargo/services/orderService.dart';

class OrderController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var orders = <OrdersPage>[].obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  var deilveryOrders = <LegalImport>[].obs;
  var order = Rxn<OrdersPage>();
  var walletTrans = <WalletTrans>[].obs;

  @override
  void onInit() {
    super.onInit();
    log('🚀 OrderController onInit called');
    // เรียก API build เสร็จแล้วเพื่อหลีกเลี่ยง setState during build error
    SchedulerBinding.instance.addPostFrameCallback((_) {
      getOrders();
    });
  }

  Future<void> getOrders() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await OrderService.geTrackOrders();

      if (data.isNotEmpty) {
        orders.value = data;
      } else {
        orders.clear();
      }
    } catch (e) {
      log('❌ Error in getOrders: $e');
      _setError('ไม่สามารถโหลดข้อมูลออเดอร์ได้ ลองใหม่ครั้ง');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getDeliveryOrders() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await OrderService.getDeliveryOrders();

      if (data.isNotEmpty) {
        deilveryOrders.value = data;
      } else {
        deilveryOrders.clear();
      }
    } catch (e) {
      log('❌ Error in getOrders: $e');
      _setError('ไม่สามารถโหลดข้อมูลออเดอร์ได้ ลองใหม่ครั้ง');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getOrderById(int id) async {
    if (id <= 0) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await OrderService.getOrderById(order_id: id);

      if (data != null) {
        order.value = data;
      } else {
        _setError('ไม่พบข้อมูลออเดอร์');
      }
    } catch (e) {
      log('❌ Error in getOrderById: $e');
      _setError('ไม่สามารถโหลดข้อมูลออเดอร์ได้ ลองใหม่ครั้ง');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getWalletTrans() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await OrderService.getWalletTrans();

      if (data.isNotEmpty) {
        walletTrans.value = data;
      } else {
        walletTrans.clear();
      }
    } catch (e) {
      log('❌ Error in getWalletTrans: $e');
      _setError('ไม่สามารถโหลดข้อมูล Wallet ได้ ลองใหม่ครั้ง');
    } finally {
      isLoading.value = false;
    }
  }

  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    orders.clear();
  }

  // Method refresh ข้อมูล
  Future<void> refreshData() async {
    await getOrders();
  }
}
