import 'dart:developer';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gcargo/models/legalimport.dart';
import 'package:gcargo/services/parcelService.dart';

class ParcelController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var deliveryOrders = <LegalImport>[].obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;

  // สำหรับ Tab Controller
  var selectedTabIndex = 0.obs;

  // สำหรับแยกข้อมูลตาม status
  var arrivedChinaOrders = <LegalImport>[].obs;
  var inTransitOrders = <LegalImport>[].obs;
  var arrivedThailandOrders = <LegalImport>[].obs;
  var awaitingPaymentOrders = <LegalImport>[].obs;
  var deliveredOrders = <LegalImport>[].obs;

  @override
  void onInit() {
    super.onInit();
    log('🚀 ParcelController onInit called');
    // เรียก API หลังจาก build เสร็จแล้วเพื่อหลีกเลี่ยง setState during build error
    SchedulerBinding.instance.addPostFrameCallback((_) {
      getDeliveryOrders();
    });
  }

  Future<void> getDeliveryOrders() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await ParcelService.getDeliveryOrders();

      if (data.isNotEmpty) {
        deliveryOrders.value = data;
        _categorizeOrdersByStatus(data);
      } else {
        deliveryOrders.clear();
        _clearAllCategories();
      }
    } catch (e) {
      log('❌ Error in getDeliveryOrders: $e');
      _setError('ไม่สามารถโหลดข้อมูลพัสดุได้ กรุณาลองใหม่อีกครั้ง');
    } finally {
      isLoading.value = false;
    }
  }

  void _categorizeOrdersByStatus(List<LegalImport> orders) {
    // ล้างข้อมูลเก่า
    _clearAllCategories();

    // แยกข้อมูลตาม status
    for (var order in orders) {
      switch (order.status) {
        case 'arrived_china_warehouse':
          arrivedChinaOrders.add(order);
          break;
        case 'in_transit':
          inTransitOrders.add(order);
          break;
        case 'arrived_thailand_warehouse':
          arrivedThailandOrders.add(order);
          break;
        case 'awaiting_payment':
          awaitingPaymentOrders.add(order);
          break;
        case 'delivered':
          deliveredOrders.add(order);
          break;
        default:
          log('Unknown status: ${order.status}');
      }
    }
  }

  void _clearAllCategories() {
    arrivedChinaOrders.clear();
    inTransitOrders.clear();
    arrivedThailandOrders.clear();
    awaitingPaymentOrders.clear();
    deliveredOrders.clear();
  }

  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    deliveryOrders.clear();
    _clearAllCategories();
  }

  // Method สำหรับ refresh ข้อมูล
  Future<void> refreshData() async {
    await getDeliveryOrders();
  }

  // Method สำหรับเปลี่ยน tab
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  // Helper methods สำหรับดึงข้อมูลตาม tab ที่เลือก
  List<LegalImport> get currentTabOrders {
    switch (selectedTabIndex.value) {
      case 0:
        return deliveryOrders; // ทั้งหมด
      case 1:
        return arrivedChinaOrders + inTransitOrders; // กำลังส่ง (รวม arrived_china_warehouse + in_transit)
      case 2:
        return arrivedThailandOrders +
            awaitingPaymentOrders +
            deliveredOrders; // เสร็จสิ้น (รวม arrived_thailand_warehouse + awaiting_payment + delivered)
      default:
        return deliveryOrders;
    }
  }

  // Helper method สำหรับแปลง status เป็นภาษาไทย
  String getStatusText(String? status) {
    switch (status) {
      case 'arrived_china_warehouse':
        return 'ถึงคลังจีน';
      case 'in_transit':
        return 'กำลังขนส่ง';
      case 'arrived_thailand_warehouse':
        return 'ถึงคลังไทย';
      case 'awaiting_payment':
        return 'รอชำระเงิน';
      case 'delivered':
        return 'จัดส่งแล้ว';
      default:
        return status ?? 'ไม่ทราบสถานะ';
    }
  }

  // Helper method สำหรับสีของ status
  String getStatusColor(String? status) {
    switch (status) {
      case 'arrived_china_warehouse':
        return 'blue';
      case 'in_transit':
        return 'orange';
      case 'arrived_thailand_warehouse':
        return 'green';
      case 'awaiting_payment':
        return 'red';
      case 'delivered':
        return 'green';
      default:
        return 'grey';
    }
  }
}
