import 'dart:developer';
import 'package:get/get.dart';
import 'package:gcargo/models/orders/ordersPageNew.dart';
import 'package:gcargo/services/parcelService.dart';

class ClaimDetailController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var orderDetail = Rxn<OrdersPageNew>();
  var errorMessage = ''.obs;
  var hasError = false.obs;
  var deliveryOrderId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    log('🚀 ClaimDetailController onInit called');
  }

  Future<void> getDeliveryOrderById(int id) async {
    if (id <= 0) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      deliveryOrderId.value = id;

      final data = await ParcelService.getIDeliveryOrderById(id: id);

      if (data != null) {
        orderDetail.value = data;
      } else {
        _setError('ไม่พบข้อมูลออเดอร์');
      }
    } catch (e) {
      log('❌ Error in getDeliveryOrderById: $e');
      _setError('ไม่สามารถโหลดข้อมูลออเดอร์ได้ กรุณาลองใหม่อีกครั้ง');
    } finally {
      isLoading.value = false;
    }
  }

  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    orderDetail.value = null;
  }

  // Method สำหรับ refresh ข้อมูล
  Future<void> refreshData() async {
    if (deliveryOrderId.value > 0) {
      await getDeliveryOrderById(deliveryOrderId.value);
    }
  }

  // Helper methods สำหรับดึงข้อมูลจาก orderDetail
  String get orderCode => orderDetail.value?.code ?? 'ไม่มีรหัสออเดอร์';
  String get poNumber => orderDetail.value?.po_no ?? 'ไม่มี PO';
  String get orderDate => orderDetail.value?.date ?? 'ไม่มีวันที่';
  String get driverName => orderDetail.value?.driver_name ?? 'ไม่มีข้อมูลคนขับ';
  String get driverPhone => orderDetail.value?.driver_phone ?? 'ไม่มีเบอร์โทร';
  String get memberName =>
      orderDetail.value?.member != null
          ? '${orderDetail.value!.member!.fname ?? ''} ${orderDetail.value!.member!.lname ?? ''}'.trim()
          : 'ไม่มีข้อมูลสมาชิก';
  String get memberPhone => orderDetail.value?.member?.phone ?? 'ไม่มีเบอร์โทร';
  String get status => orderDetail.value?.status ?? 'ไม่ทราบสถานะ';
  String get note => orderDetail.value?.note ?? '-';

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

  // Helper methods สำหรับข้อมูลออเดอร์
  double get totalPrice => orderDetail.value?.order?.total_price != null ? double.tryParse(orderDetail.value!.order!.total_price!) ?? 0.0 : 0.0;

  double get depositFee => orderDetail.value?.order?.deposit_fee != null ? double.tryParse(orderDetail.value!.order!.deposit_fee!) ?? 0.0 : 0.0;

  double get chinaShippingFee =>
      orderDetail.value?.order?.china_shipping_fee != null ? double.tryParse(orderDetail.value!.order!.china_shipping_fee!) ?? 0.0 : 0.0;

  double get exchangeRate => orderDetail.value?.order?.exchange_rate != null ? double.tryParse(orderDetail.value!.order!.exchange_rate!) ?? 0.0 : 0.0;

  String get orderNote => orderDetail.value?.order?.note ?? '-';
  String get paymentTerm => orderDetail.value?.order?.payment_term ?? 'ไม่ระบุ';
  String get shippingType => orderDetail.value?.order?.shipping_type ?? 'ไม่ระบุ';

  // Helper method สำหรับรายการสินค้า
  List<dynamic> get orderLists => orderDetail.value?.order?.order_lists ?? [];
}
